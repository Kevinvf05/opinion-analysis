"""
Professor routes
Handles professor-specific operations like viewing dashboard, subjects, and profile management
"""
from flask import Blueprint, request, jsonify
from ..models import db, User, Professor, Survey, Comment, Subject, GroupClass
from ..routes import token_required
from datetime import datetime, timedelta
from sqlalchemy import func
from werkzeug.security import generate_password_hash

professor_bp = Blueprint('professor', __name__, url_prefix='/api/professor')


@professor_bp.route('/dashboard', methods=['GET'])
@token_required
def get_dashboard_stats(current_user):
    """
    Get dashboard statistics for the authenticated professor
    Returns: total subjects, groups, students, satisfaction rate, sentiment breakdown, recent comments
    """
    try:
        # Ensure the user is a professor
        if current_user.role != 'professor':
            return jsonify({'error': 'Access denied - Professors only'}), 403
        
        # Get total subjects taught by this professor
        total_subjects = Subject.query.filter_by(professor_id=current_user.professor.id, is_active=True).count()
        
        # Get total groups
        total_groups = GroupClass.query.filter_by(professor_id=current_user.professor.id, is_active=True).count()
        
        # Get total students (sum of current_students in all groups)
        total_students = db.session.query(func.sum(GroupClass.current_students)).filter_by(
            professor_id=current_user.professor.id,
            is_active=True
        ).scalar() or 0
        
        # Get all surveys for this professor
        surveys = Survey.query.filter_by(professor_id=current_user.id, status='completed').all()
        
        # Get sentiment breakdown from comments
        positive_count = 0
        neutral_count = 0
        negative_count = 0
        
        for survey in surveys:
            comments = Comment.query.filter_by(survey_id=survey.id).all()
            for comment in comments:
                if comment.sentiment == 'positive':
                    positive_count += 1
                elif comment.sentiment == 'neutral':
                    neutral_count += 1
                elif comment.sentiment == 'negative':
                    negative_count += 1
        
        total_comments = positive_count + neutral_count + negative_count
        
        # Calculate satisfaction rate (positive / total)
        satisfaction_rate = round((positive_count / total_comments * 100), 1) if total_comments > 0 else 0.0
        
        # Get recent comments (last 10)
        recent_comments_data = []
        recent_surveys = Survey.query.filter_by(
            professor_id=current_user.id,
            status='completed'
        ).order_by(Survey.completed_at.desc()).limit(10).all()
        
        for survey in recent_surveys:
            comments = Comment.query.filter_by(survey_id=survey.id).all()
            subject = Subject.query.get(survey.subject_id)
            
            for comment in comments:
                # Calculate days ago
                days_ago = (datetime.utcnow() - comment.created_at).days if comment.created_at else 0
                time_text = f"Hace {days_ago} días" if days_ago > 0 else "Hoy"
                
                recent_comments_data.append({
                    'text': comment.text,
                    'sentiment': comment.sentiment,
                    'subject': subject.name if subject else 'Unknown',
                    'time_ago': time_text
                })
        
        # Limit to 10 most recent
        recent_comments_data = recent_comments_data[:10]
        
        return jsonify({
            'stats': {
                'total_subjects': total_subjects,
                'total_groups': total_groups,
                'total_students': int(total_students),
                'satisfaction_rate': satisfaction_rate
            },
            'sentiment': {
                'positive': positive_count,
                'neutral': neutral_count,
                'negative': negative_count,
                'total': total_comments
            },
            'recent_comments': recent_comments_data
        }), 200
        
    except Exception as e:
        print(f"Error fetching professor dashboard: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500


@professor_bp.route('/subjects', methods=['GET'])
@token_required
def get_subjects(current_user):
    """
    Get all subjects taught by the authenticated professor with groups and stats
    """
    try:
        # Ensure the user is a professor
        if current_user.role != 'professor':
            return jsonify({'error': 'Access denied - Professors only'}), 403
        
        # Get all subjects taught by this professor
        subjects = Subject.query.filter_by(professor_id=current_user.professor.id, is_active=True).all()
        
        subjects_data = []
        for subject in subjects:
            # Get groups for this subject
            groups = GroupClass.query.filter_by(
                subject_id=subject.id,
                professor_id=current_user.professor.id,
                is_active=True
            ).all()
            
            # Get sentiment stats for this subject
            subject_surveys = Survey.query.filter_by(
                professor_id=current_user.id,
                subject_id=subject.id,
                status='completed'
            ).all()
            
            subject_positive = 0
            subject_neutral = 0
            subject_negative = 0
            
            for survey in subject_surveys:
                comments = Comment.query.filter_by(survey_id=survey.id).all()
                for comment in comments:
                    if comment.sentiment == 'positive':
                        subject_positive += 1
                    elif comment.sentiment == 'neutral':
                        subject_neutral += 1
                    elif comment.sentiment == 'negative':
                        subject_negative += 1
            
            subject_total = subject_positive + subject_neutral + subject_negative
            subject_satisfaction = round((subject_positive / subject_total * 100), 1) if subject_total > 0 else 0.0
            
            # Build groups data
            groups_data = []
            for group in groups:
                groups_data.append({
                    'id': group.id,
                    'name': group.group_name,
                    'students': group.current_students or 0,
                    'schedule': group.schedule,
                    'classroom': 'TBD',  # You can add classroom field to GroupClass model if needed
                    'semester_period': group.semester_period
                })
            
            subjects_data.append({
                'id': subject.id,
                'name': subject.name,
                'code': subject.code,
                'semester': subject.semester,
                'satisfaction': subject_satisfaction,
                'groups': groups_data,
                'sentiment': {
                    'positive': subject_positive,
                    'neutral': subject_neutral,
                    'negative': subject_negative,
                    'total': subject_total
                }
            })
        
        return jsonify({
            'subjects': subjects_data,
            'total': len(subjects_data)
        }), 200
        
    except Exception as e:
        print(f"Error fetching professor subjects: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500


@professor_bp.route('/profile', methods=['GET'])
@token_required
def get_profile(current_user):
    """
    Get profile information for the authenticated professor
    """
    try:
        # Ensure the user is a professor
        if current_user.role != 'professor':
            return jsonify({'error': 'Access denied - Professors only'}), 403
        
        professor = current_user.professor
        
        # Get stats
        total_subjects = Subject.query.filter_by(professor_id=professor.id, is_active=True).count()
        total_groups = GroupClass.query.filter_by(professor_id=professor.id, is_active=True).count()
        total_students = db.session.query(func.sum(GroupClass.current_students)).filter_by(
            professor_id=professor.id,
            is_active=True
        ).scalar() or 0
        
        # Get satisfaction rate
        surveys = Survey.query.filter_by(professor_id=current_user.id, status='completed').all()
        positive_count = 0
        total_count = 0
        
        for survey in surveys:
            comments = Comment.query.filter_by(survey_id=survey.id).all()
            for comment in comments:
                total_count += 1
                if comment.sentiment == 'positive':
                    positive_count += 1
        
        satisfaction_rate = round((positive_count / total_count * 100), 1) if total_count > 0 else 0.0
        
        return jsonify({
            'profile': {
                'first_name': current_user.first_name,
                'last_name': current_user.last_name,
                'email': current_user.email,
                'phone': professor.phone or '',
                'department': professor.department or '',
                'office': professor.office or '',
                'specialization': professor.specialization or '',
                'initials': f"{current_user.first_name[0]}{current_user.last_name[0]}".upper()
            },
            'stats': {
                'total_subjects': total_subjects,
                'total_groups': total_groups,
                'total_students': int(total_students),
                'satisfaction_rate': satisfaction_rate
            }
        }), 200
        
    except Exception as e:
        print(f"Error fetching professor profile: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500


@professor_bp.route('/profile', methods=['PUT'])
@token_required
def update_profile(current_user):
    """
    Update profile information for the authenticated professor
    Email cannot be changed, only phone, department, office, and specialization
    """
    try:
        # Ensure the user is a professor
        if current_user.role != 'professor':
            return jsonify({'error': 'Access denied - Professors only'}), 403
        
        data = request.get_json()
        
        if not data:
            return jsonify({'error': 'No data provided'}), 400
        
        professor = current_user.professor
        
        # Update allowed fields
        if 'first_name' in data:
            current_user.first_name = data['first_name']
        
        if 'last_name' in data:
            current_user.last_name = data['last_name']
        
        if 'phone' in data:
            professor.phone = data['phone']
        
        if 'department' in data:
            professor.department = data['department']
        
        if 'office' in data:
            professor.office = data['office']
        
        if 'specialization' in data:
            professor.specialization = data['specialization']
        
        db.session.commit()
        
        print(f"✅ Professor profile updated: {current_user.email}")
        
        return jsonify({
            'message': 'Profile updated successfully',
            'profile': {
                'first_name': current_user.first_name,
                'last_name': current_user.last_name,
                'email': current_user.email,
                'phone': professor.phone,
                'department': professor.department,
                'office': professor.office,
                'specialization': professor.specialization
            }
        }), 200
        
    except Exception as e:
        db.session.rollback()
        print(f"Error updating professor profile: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500


@professor_bp.route('/password', methods=['PUT'])
@token_required
def change_password(current_user):
    """
    Change password for the authenticated professor
    """
    try:
        # Ensure the user is a professor
        if current_user.role != 'professor':
            return jsonify({'error': 'Access denied - Professors only'}), 403
        
        data = request.get_json()
        
        if not data:
            return jsonify({'error': 'No data provided'}), 400
        
        current_password = data.get('current_password')
        new_password = data.get('new_password')
        
        if not current_password or not new_password:
            return jsonify({'error': 'Current password and new password are required'}), 400
        
        # Verify current password
        if not current_user.check_password(current_password):
            return jsonify({'error': 'Current password is incorrect'}), 401
        
        # Validate new password
        if len(new_password) < 8:
            return jsonify({'error': 'New password must be at least 8 characters'}), 400
        
        # Update password
        current_user.password_hash = generate_password_hash(new_password)
        db.session.commit()
        
        print(f"✅ Password changed for professor: {current_user.email}")
        
        return jsonify({
            'message': 'Password changed successfully'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        print(f"Error changing professor password: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

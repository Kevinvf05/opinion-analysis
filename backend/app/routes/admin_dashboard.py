from flask import Blueprint, jsonify, request
from ..models import db, User, Student, Professor, Admin, Survey, Comment, Subject, GroupClass, ActivityLog
from ..config import Config
from datetime import datetime
import jwt
from functools import wraps
from ..routes import token_required

# Blueprint for admin dashboard routes
admin_bp = Blueprint('admin_dashboard', __name__, url_prefix='/api/admin')


@admin_bp.route('/dashboard/stats', methods=['GET'])
@token_required
def get_dashboard_stats(current_user):
    """Get statistics for admin dashboard"""
    try:
        # Check if user is admin
        if current_user.role != 'admin':
            return jsonify({'error': 'Unauthorized - Admin access required'}), 403
        
        # Total counts
        total_students = Student.query.count()
        total_professors = Professor.query.count()
        total_admins = Admin.query.count()
        total_users = User.query.filter_by(is_active=True).count()
        
        # Survey statistics
        total_surveys = Survey.query.count()
        completed_surveys = Survey.query.filter_by(status='completed').count()
        pending_surveys = Survey.query.filter_by(status='pending').count()
        
        # Calculate unique students who completed surveys for participation rate
        students_with_surveys = db.session.query(Survey.student_id).filter(
            Survey.status == 'completed'
        ).distinct().count()
        
        # Get subjects and groups
        total_subjects = Subject.query.count()
        total_groups = GroupClass.query.count()
        
        # Recent activity (last 10 activities)
        recent_activities = ActivityLog.query.order_by(
            ActivityLog.created_at.desc()
        ).limit(10).all()
        
        activities_list = [{
            'id': log.id,
            'user_type': log.user_type,
            'action_type': log.action_type,
            'description': log.description,
            'created_at': log.created_at.isoformat() if log.created_at else None
        } for log in recent_activities]
        
        return jsonify({
            'stats': {
                'total_users': total_users,
                'total_students': total_students,
                'total_professors': total_professors,
                'total_admins': total_admins,
                'total_subjects': total_subjects,
                'total_groups': total_groups,
                'total_surveys': total_surveys,
                'completed_surveys': completed_surveys,
                'pending_surveys': pending_surveys,
                'students_with_surveys': students_with_surveys
            },
            'recent_activities': activities_list
        }), 200
        
    except Exception as e:
        print(f"Dashboard stats error: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500


@admin_bp.route('/professors', methods=['GET'])
@token_required
def get_all_professors(current_user):
    """Get all professors with their ratings and sentiment analysis"""
    try:
        if current_user.role != 'admin':
            return jsonify({'error': 'Unauthorized'}), 403
        
        professors = Professor.query.all()
        
        professors_list = []
        for prof in professors:
            user = prof.user
            
            # Get all surveys for this professor (using user.id since professor_id references users table)
            surveys = Survey.query.filter_by(professor_id=user.id, status='completed').all()
            
            # Get all comments for this professor's surveys
            survey_ids = [s.id for s in surveys]
            comments = Comment.query.filter(Comment.survey_id.in_(survey_ids)).all() if survey_ids else []
            
            # Count sentiments
            positive_count = len([c for c in comments if c.sentiment == 'positive'])
            neutral_count = len([c for c in comments if c.sentiment == 'neutral'])
            negative_count = len([c for c in comments if c.sentiment == 'negative'])
            
            # Calculate average rating (placeholder for now)
            avg_rating = 0
            total_ratings = len(comments)
            
            # Get subjects assigned to this professor
            subjects = Subject.query.filter_by(professor_id=prof.id).all()
            subjects_list = [{'id': s.id, 'code': s.code, 'name': s.name} for s in subjects]
            
            professors_list.append({
                'id': prof.id,
                'user_id': user.id,
                'name': f"{user.first_name} {user.last_name}",
                'email': prof.email,
                'department': prof.department,
                'office': prof.office,
                'specialization': prof.specialization,
                'average_rating': round(avg_rating, 2),
                'total_ratings': total_ratings,
                'is_active': user.is_active,
                'subjects': subjects_list,
                'sentiment_counts': {
                    'positive': positive_count,
                    'neutral': neutral_count,
                    'negative': negative_count
                }
            })
        
        return jsonify({
            'professors': professors_list,
            'total': len(professors_list)
        }), 200
        
    except Exception as e:
        print(f"Get professors error: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500


@admin_bp.route('/professors/<int:professor_id>', methods=['PUT'])
@token_required
def update_professor(current_user, professor_id):
    """Update professor information"""
    try:
        if current_user.role != 'admin':
            return jsonify({'error': 'Unauthorized'}), 403
        
        professor = Professor.query.get(professor_id)
        if not professor:
            return jsonify({'error': 'Professor not found'}), 404
        
        data = request.get_json()
        user = professor.user
        
        print(f"========== UPDATE PROFESSOR {professor_id} ==========")
        print(f"Current professor: {user.first_name} {user.last_name}")
        print(f"Update data received: {data}")
        
        # Update user basic info
        if 'first_name' in data:
            user.first_name = data['first_name']
        if 'last_name' in data:
            user.last_name = data['last_name']
        
        # Update email
        if 'email' in data:
            # Check if email is already in use by another user
            existing = User.query.filter(
                User.email == data['email'].lower(), 
                User.id != user.id
            ).first()
            if existing:
                return jsonify({'error': 'Email already in use'}), 409
            
            user.email = data['email'].lower()
            professor.email = data['email'].lower()
        
        # Update professor-specific fields
        if 'department' in data:
            professor.department = data['department']
        if 'office' in data:
            professor.office = data['office']
        if 'specialization' in data:
            professor.specialization = data['specialization']
        
        # Update password if provided
        if 'password' in data and data['password']:
            user.set_password(data['password'])
        
        # Update active status
        if 'is_active' in data:
            user.is_active = data['is_active']
            professor.status = 'active' if data['is_active'] else 'inactive'
        
        db.session.commit()
        
        print(f"Professor updated successfully")
        print(f"==========================================")
        
        # Log activity
        log = ActivityLog(
            user_id=current_user.id,
            user_type='admin',
            action_type='user_updated',
            description=f'Updated professor: {user.first_name} {user.last_name}'
        )
        db.session.add(log)
        db.session.commit()
        
        return jsonify({
            'message': 'Professor updated successfully',
            'professor': {
                'id': professor.id,
                'user_id': user.id,
                'name': f"{user.first_name} {user.last_name}",
                'email': professor.email,
                'department': professor.department,
                'office': professor.office,
                'specialization': professor.specialization,
                'is_active': user.is_active
            }
        }), 200
        
    except Exception as e:
        db.session.rollback()
        print(f"Update professor error: {str(e)}")
        return jsonify({'error': f'Internal server error: {str(e)}'}), 500


@admin_bp.route('/students', methods=['GET'])
@token_required
def get_all_students(current_user):
    """Get all students"""
    try:
        if current_user.role != 'admin':
            return jsonify({'error': 'Unauthorized'}), 403
        
        students = Student.query.all()
        
        students_list = [{
            'id': student.id,
            'matricula': student.matricula,
            'name': f"{student.user.first_name} {student.user.last_name}",
            'semester': student.semester,
            'career': student.career,
            'group': student.group,
            'has_completed_survey': student.has_completed_survey,
            'is_active': student.user.is_active
        } for student in students]
        
        return jsonify({
            'students': students_list,
            'total': len(students_list)
        }), 200
        
    except Exception as e:
        print(f"Get students error: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500


@admin_bp.route('/users/create', methods=['POST'])
@token_required
def create_user(current_user):
    """Create a new user (student, professor, or admin)"""
    try:
        if current_user.role != 'admin':
            return jsonify({'error': 'Unauthorized'}), 403
        
        data = request.get_json()
        
        print(f"========== CREATE USER ==========")
        print(f"Request data: {data}")
        
        # Validate required fields
        required_fields = ['first_name', 'last_name', 'role']
        if not all(field in data for field in required_fields):
            return jsonify({'error': 'Missing required fields'}), 400
        
        # Validate role
        if data['role'] not in ['student', 'professor', 'admin']:
            return jsonify({'error': 'Invalid role. Must be student, professor, or admin'}), 400
        
        # Create user
        new_user = User(
            first_name=data['first_name'],
            last_name=data['last_name'],
            role=data['role'],
            is_active=True
        )
        
        # Set email and password for staff (professor/admin)
        if data['role'] in ['professor', 'admin']:
            if 'email' not in data or 'password' not in data:
                return jsonify({'error': 'Email and password required for staff'}), 400
            
            # Check if email already exists
            existing_user = User.query.filter_by(email=data['email']).first()
            if existing_user:
                return jsonify({'error': 'User with this email already exists'}), 409
            
            new_user.email = data['email'].lower()
            new_user.set_password(data['password'])
        
        # Set matricula for students
        if data['role'] == 'student':
            if 'matricula' not in data:
                return jsonify({'error': 'Matricula required for students'}), 400
            
            # Check if matricula already exists
            existing_user = User.query.filter_by(matricula=data['matricula'].upper()).first()
            if existing_user:
                return jsonify({'error': 'Student with this matricula already exists'}), 409
            
            new_user.matricula = data['matricula'].upper()
            # For students, password_hash can be empty string hash
            import hashlib
            new_user.password_hash = hashlib.sha256(''.encode()).hexdigest()
        
        db.session.add(new_user)
        db.session.flush()  # Get the user ID
        
        # Create role-specific record
        if data['role'] == 'student':
            student = Student(
                user_id=new_user.id,
                matricula=data['matricula'].upper(),
                semester=data.get('semester', 1),
                career=data.get('career', ''),
                group=data.get('group', ''),
                has_completed_survey=False,
                status='active'
            )
            db.session.add(student)
            
        elif data['role'] == 'professor':
            professor = Professor(
                user_id=new_user.id,
                email=data['email'].lower(),
                department=data.get('department', ''),
                office=data.get('office', ''),
                specialization=data.get('specialization', ''),
                status='active'
            )
            db.session.add(professor)
            
        elif data['role'] == 'admin':
            admin = Admin(
                user_id=new_user.id,
                department=data.get('department', 'Administration'),
                permissions=data.get('permissions')
            )
            db.session.add(admin)
        
        db.session.commit()
        
        print(f"User created successfully: ID={new_user.id}, Name={new_user.first_name} {new_user.last_name}, Role={new_user.role}")
        print(f"=====================================")
        
        # Log the activity
        log = ActivityLog(
            user_id=current_user.id,
            user_type='admin',
            action_type='user_created',
            description=f'Created new {data["role"]}: {new_user.first_name} {new_user.last_name}'
        )
        db.session.add(log)
        db.session.commit()
        
        return jsonify({
            'message': 'User created successfully',
            'user': {
                'id': new_user.id,
                'email': new_user.email,
                'name': f"{new_user.first_name} {new_user.last_name}",
                'role': new_user.role,
                'matricula': new_user.matricula
            }
        }), 201
        
    except Exception as e:
        db.session.rollback()
        print(f"Create user error: {str(e)}")
        import traceback
        traceback.print_exc()
        return jsonify({'error': f'Internal server error: {str(e)}'}), 500


@admin_bp.route('/users', methods=['GET'])
@token_required
def get_all_users(current_user):
    """Get all users with pagination and filtering"""
    try:
        if current_user.role != 'admin':
            return jsonify({'error': 'Unauthorized'}), 403
        
        # Get query parameters for filtering
        role_filter = request.args.get('role', 'all')
        search_term = request.args.get('search', '').lower()
        
        # Build query
        query = User.query
        
        # Filter by role
        if role_filter != 'all':
            query = query.filter_by(role=role_filter)
        
        # Search by name or email
        if search_term:
            query = query.filter(
                db.or_(
                    User.first_name.ilike(f'%{search_term}%'),
                    User.last_name.ilike(f'%{search_term}%'),
                    User.email.ilike(f'%{search_term}%'),
                    User.matricula.ilike(f'%{search_term}%')
                )
            )
        
        users = query.all()
        
        users_list = []
        for user in users:
            user_data = {
                'id': user.id,
                'first_name': user.first_name,
                'last_name': user.last_name,
                'email': user.email,
                'matricula': user.matricula,
                'role': user.role,
                'is_active': user.is_active,
                'created_at': user.created_at.isoformat() if user.created_at else None
            }
            
            # Add role-specific data
            if user.role == 'student':
                student = Student.query.filter_by(user_id=user.id).first()
                if student:
                    user_data['semester'] = student.semester
                    user_data['career'] = student.career
                    user_data['group'] = student.group
                    
            elif user.role == 'professor':
                professor = Professor.query.filter_by(user_id=user.id).first()
                if professor:
                    user_data['department'] = professor.department
                    user_data['office'] = professor.office
                    user_data['specialization'] = professor.specialization
                    
            elif user.role == 'admin':
                admin = Admin.query.filter_by(user_id=user.id).first()
                if admin:
                    user_data['department'] = admin.department
            
            users_list.append(user_data)
        
        return jsonify({
            'users': users_list,
            'total': len(users_list)
        }), 200
        
    except Exception as e:
        print(f"Get users error: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500


@admin_bp.route('/users/<int:user_id>', methods=['PUT'])
@token_required
def update_user(current_user, user_id):
    """Update user information"""
    try:
        if current_user.role != 'admin':
            return jsonify({'error': 'Unauthorized'}), 403
        
        user = User.query.get(user_id)
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        data = request.get_json()
        
        print(f"========== UPDATE USER {user_id} ==========")
        print(f"Current user data: {user.first_name} {user.last_name}, is_active={user.is_active}")
        print(f"Update data received: {data}")
        
        # Update basic user fields
        if 'first_name' in data:
            user.first_name = data['first_name']
        if 'last_name' in data:
            user.last_name = data['last_name']
        if 'is_active' in data:
            # Check if trying to deactivate the last active admin
            if user.role == 'admin' and not data['is_active']:
                active_admins = User.query.filter_by(role='admin', is_active=True).count()
                if active_admins <= 1:
                    return jsonify({'error': 'Cannot deactivate the last active admin'}), 400
            
            print(f"Changing is_active from {user.is_active} to {data['is_active']}")
            user.is_active = data['is_active']
        
        # Update email for staff
        if 'email' in data and user.role in ['professor', 'admin']:
            # Check if email is already in use by another user
            existing = User.query.filter(User.email == data['email'].lower(), User.id != user_id).first()
            if existing:
                return jsonify({'error': 'Email already in use'}), 409
            user.email = data['email'].lower()
        
        # Update password if provided
        if 'password' in data and data['password']:
            user.set_password(data['password'])
        
        # Update role-specific data
        if user.role == 'student':
            student = Student.query.filter_by(user_id=user.id).first()
            if student:
                if 'semester' in data:
                    student.semester = data['semester']
                if 'career' in data:
                    student.career = data['career']
                if 'group' in data:
                    student.group = data['group']
                    
        elif user.role == 'professor':
            professor = Professor.query.filter_by(user_id=user.id).first()
            if professor:
                if 'department' in data:
                    professor.department = data['department']
                if 'office' in data:
                    professor.office = data['office']
                if 'specialization' in data:
                    professor.specialization = data['specialization']
                if 'email' in data:
                    professor.email = data['email'].lower()
        
        db.session.commit()
        
        print(f"User updated successfully. New is_active value: {user.is_active}")
        print(f"==========================================")
        
        # Log activity
        log = ActivityLog(
            user_id=current_user.id,
            user_type='admin',
            action_type='user_updated',
            description=f'Updated user: {user.first_name} {user.last_name}'
        )
        db.session.add(log)
        db.session.commit()
        
        return jsonify({
            'message': 'User updated successfully',
            'user': {
                'id': user.id,
                'name': f"{user.first_name} {user.last_name}",
                'email': user.email,
                'role': user.role,
                'is_active': user.is_active
            }
        }), 200
        
    except Exception as e:
        db.session.rollback()
        print(f"Update user error: {str(e)}")
        return jsonify({'error': f'Internal server error: {str(e)}'}), 500


@admin_bp.route('/users/<int:user_id>', methods=['DELETE'])
@token_required
def delete_user(current_user, user_id):
    """Delete a user"""
    try:
        if current_user.role != 'admin':
            return jsonify({'error': 'Unauthorized'}), 403
        
        user = User.query.get(user_id)
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        print(f"========== DELETE USER {user_id} ==========")
        print(f"User to delete: {user.first_name} {user.last_name}, role={user.role}")
        
        # Check if trying to delete the last admin
        if user.role == 'admin':
            admin_count = User.query.filter_by(role='admin').count()
            print(f"Admin count: {admin_count}")
            if admin_count <= 1:
                return jsonify({'error': 'Cannot delete the last admin in the system'}), 400
        
        # Store user info before deletion
        user_name = f"{user.first_name} {user.last_name}"
        user_role = user.role
        
        # Explicitly delete role-specific records first to avoid FK constraint issues
        if user.role == 'student':
            student = Student.query.filter_by(user_id=user_id).first()
            if student:
                print(f"Deleting student record: {student.matricula}")
                db.session.delete(student)
        elif user.role == 'professor':
            professor = Professor.query.filter_by(user_id=user_id).first()
            if professor:
                print(f"Deleting professor record: {professor.email}")
                db.session.delete(professor)
        elif user.role == 'admin':
            admin = Admin.query.filter_by(user_id=user_id).first()
            if admin:
                print(f"Deleting admin record: {admin.id}")
                db.session.delete(admin)
        
        # Now delete the user
        db.session.delete(user)
        db.session.commit()
        
        print(f"User deleted successfully: {user_name}")
        print(f"==========================================")
        
        # Log activity
        log = ActivityLog(
            user_id=current_user.id,
            user_type='admin',
            action_type='user_deleted',
            description=f'Deleted {user_role}: {user_name}'
        )
        db.session.add(log)
        db.session.commit()
        
        return jsonify({
            'message': 'User deleted successfully'
        }), 200
        
    except Exception as e:
        db.session.rollback()
        print(f"Delete user error: {str(e)}")
        return jsonify({'error': f'Internal server error: {str(e)}'}), 500


@admin_bp.route('/subjects', methods=['GET'])
@token_required
def get_all_subjects(current_user):
    """Get all subjects"""
    try:
        if current_user.role != 'admin':
            return jsonify({'error': 'Unauthorized'}), 403
        
        subjects = Subject.query.all()
        subjects_list = []
        
        for subject in subjects:
            # Get professor info
            professor = Professor.query.get(subject.professor_id) if subject.professor_id else None
            professor_name = None
            if professor:
                prof_user = User.query.get(professor.user_id)
                professor_name = f"{prof_user.first_name} {prof_user.last_name}" if prof_user else None
            
            # Get groups count
            groups_count = GroupClass.query.filter_by(subject_id=subject.id).count()
            
            subjects_list.append({
                'id': subject.id,
                'name': subject.name,
                'code': subject.code,
                'professor_id': subject.professor_id,
                'professor_name': professor_name,
                'semester': subject.semester,
                'is_active': subject.is_active,
                'groups_count': groups_count,
                'created_at': subject.created_at.isoformat() if subject.created_at else None
            })
        
        return jsonify({'subjects': subjects_list}), 200
        
    except Exception as e:
        print(f"Get subjects error: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500


@admin_bp.route('/subjects', methods=['POST'])
@token_required
def create_subject(current_user):
    """Create a new subject"""
    try:
        if current_user.role != 'admin':
            return jsonify({'error': 'Unauthorized'}), 403
        
        data = request.get_json()
        print(f"Creating subject with data: {data}")
        
        # Validate required fields
        required_fields = ['name', 'code']
        for field in required_fields:
            if field not in data or not data[field]:
                return jsonify({'error': f'Missing required field: {field}'}), 400
        
        # Check if subject code already exists
        existing_subject = Subject.query.filter_by(code=data['code']).first()
        if existing_subject:
            return jsonify({'error': 'Subject code already exists'}), 400
        
        # Create new subject
        new_subject = Subject(
            name=data['name'],
            code=data['code'],
            professor_id=data.get('professor_id'),
            semester=data.get('semester'),
            is_active=data.get('is_active', True)
        )
        
        db.session.add(new_subject)
        db.session.commit()
        
        # Assign subject to existing groups if provided
        group_ids = data.get('group_ids', [])
        updated_groups = []
        
        if group_ids:
            for group_id in group_ids:
                try:
                    group = GroupClass.query.get(group_id)
                    if group:
                        group.subject_id = new_subject.id
                        updated_groups.append(group.group_name)
                except Exception as group_error:
                    print(f"Error assigning group {group_id}: {str(group_error)}")
            
            if updated_groups:
                db.session.commit()
                print(f"Assigned subject to {len(updated_groups)} groups")
        
        print(f"Subject created successfully: {new_subject.code}")
        
        # Log activity
        log = ActivityLog(
            user_id=current_user.id,
            user_type='admin',
            action_type='subject_created',
            description=f'Created subject: {new_subject.code} - {new_subject.name}'
        )
        db.session.add(log)
        db.session.commit()
        
        return jsonify({
            'message': 'Subject created successfully',
            'subject': {
                'id': new_subject.id,
                'name': new_subject.name,
                'code': new_subject.code,
                'professor_id': new_subject.professor_id,
                'semester': new_subject.semester,
                'is_active': new_subject.is_active
            }
        }), 201
        
    except Exception as e:
        db.session.rollback()
        print(f"Create subject error: {str(e)}")
        return jsonify({'error': f'Internal server error: {str(e)}'}), 500


@admin_bp.route('/subjects/<int:subject_id>', methods=['PUT'])
@token_required
def update_subject(current_user, subject_id):
    """Update a subject (mainly for assigning/unassigning professors)"""
    try:
        if current_user.role != 'admin':
            return jsonify({'error': 'Unauthorized'}), 403
        
        subject = Subject.query.get(subject_id)
        if not subject:
            return jsonify({'error': 'Subject not found'}), 404
        
        data = request.get_json()
        print(f"Updating subject {subject_id} with data: {data}")
        
        # If assigning a professor, validate the professor exists and is active
        if 'professor_id' in data:
            if data['professor_id'] is not None:
                professor = Professor.query.get(data['professor_id'])
                if not professor:
                    return jsonify({'error': 'Professor not found'}), 404
                
                # Allow assignment to inactive professors (removed is_active check)
                subject.professor_id = data['professor_id']
            else:
                # Unassign professor
                subject.professor_id = None
        
        # Update other fields if provided
        if 'name' in data:
            subject.name = data['name']
        if 'code' in data:
            # Check if new code conflicts with existing subjects
            existing = Subject.query.filter_by(code=data['code']).first()
            if existing and existing.id != subject_id:
                return jsonify({'error': 'Subject code already exists'}), 400
            subject.code = data['code']
        if 'semester' in data:
            subject.semester = data['semester']
        if 'is_active' in data:
            subject.is_active = data['is_active']
        
        db.session.commit()
        
        print(f"Subject updated successfully: {subject.code}")
        
        # Log activity
        log = ActivityLog(
            user_id=current_user.id,
            user_type='admin',
            action_type='subject_updated',
            description=f'Updated subject: {subject.code} - {subject.name}'
        )
        db.session.add(log)
        db.session.commit()
        
        # Get updated professor info
        professor_name = None
        if subject.professor_id:
            professor = Professor.query.get(subject.professor_id)
            if professor:
                prof_user = User.query.get(professor.user_id)
                professor_name = f"{prof_user.first_name} {prof_user.last_name}" if prof_user else None
        
        return jsonify({
            'message': 'Subject updated successfully',
            'subject': {
                'id': subject.id,
                'name': subject.name,
                'code': subject.code,
                'professor_id': subject.professor_id,
                'professor_name': professor_name,
                'semester': subject.semester,
                'is_active': subject.is_active
            }
        }), 200
        
    except Exception as e:
        db.session.rollback()
        print(f"Update subject error: {str(e)}")
        return jsonify({'error': f'Internal server error: {str(e)}'}), 500


@admin_bp.route('/subjects/<int:subject_id>', methods=['DELETE'])
@token_required
def delete_subject(current_user, subject_id):
    """Delete a subject and unbind all relationships"""
    try:
        if current_user.role != 'admin':
            return jsonify({'error': 'Unauthorized'}), 403
        
        subject = Subject.query.get(subject_id)
        if not subject:
            return jsonify({'error': 'Subject not found'}), 404
        
        subject_code = subject.code
        subject_name = subject.name
        
        # Unbind groups from this subject (set subject_id to NULL)
        groups = GroupClass.query.filter_by(subject_id=subject_id).all()
        groups_count = len(groups)
        for group in groups:
            group.subject_id = None
        
        # Unbind surveys from this subject (delete surveys for this subject)
        # This will cascade delete related comments
        surveys = Survey.query.filter_by(subject_id=subject_id).all()
        surveys_count = len(surveys)
        for survey in surveys:
            db.session.delete(survey)
        
        # Delete the subject itself
        db.session.delete(subject)
        db.session.commit()
        
        # Log the activity
        log = ActivityLog(
            user_id=current_user.id,
            user_type='admin',
            action_type='subject_deleted',
            description=f'Deleted subject: {subject_code} - {subject_name} (unbound from {groups_count} group(s), deleted {surveys_count} survey(s))'
        )
        db.session.add(log)
        db.session.commit()
        
        return jsonify({
            'message': 'Subject deleted successfully',
            'groups_unbound': groups_count,
            'surveys_deleted': surveys_count
        }), 200
        
    except Exception as e:
        db.session.rollback()
        print(f"Delete subject error: {str(e)}")
        return jsonify({'error': f'Internal server error: {str(e)}'}), 500


@admin_bp.route('/groups', methods=['GET'])
@token_required
def get_all_groups(current_user):
    """Get all group classes"""
    try:
        if current_user.role != 'admin':
            return jsonify({'error': 'Unauthorized'}), 403
        
        groups = GroupClass.query.all()
        groups_list = []
        
        for group in groups:
            # Get subject info
            subject = Subject.query.get(group.subject_id)
            
            # Get professor info
            professor = Professor.query.get(group.professor_id) if group.professor_id else None
            professor_name = None
            if professor:
                prof_user = User.query.get(professor.user_id)
                professor_name = f"{prof_user.first_name} {prof_user.last_name}" if prof_user else None
            
            groups_list.append({
                'id': group.id,
                'subject_id': group.subject_id,
                'subject_name': subject.name if subject else None,
                'subject_code': subject.code if subject else None,
                'professor_id': group.professor_id,
                'professor_name': professor_name,
                'group_name': group.group_name,
                'semester_period': group.semester_period,
                'schedule': group.schedule,
                'classroom': group.classroom,
                'max_students': group.max_students,
                'current_students': group.current_students,
                'is_active': group.is_active,
                'created_at': group.created_at.isoformat() if group.created_at else None
            })
        
        return jsonify({'groups': groups_list}), 200
        
    except Exception as e:
        print(f"Get groups error: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500


@admin_bp.route('/groups', methods=['POST'])
@token_required
def create_group(current_user):
    """Create a new group class"""
    try:
        if current_user.role != 'admin':
            return jsonify({'error': 'Unauthorized'}), 403
        
        data = request.get_json()
        print(f"Creating group with data: {data}")
        
        # Validate required fields (only group_name and semester_period are required)
        required_fields = ['group_name', 'semester_period']
        for field in required_fields:
            if field not in data or not data[field]:
                return jsonify({'error': f'Missing required field: {field}'}), 400
        
        # Validate subject exists if provided
        if data.get('subject_id'):
            subject = Subject.query.get(data['subject_id'])
            if not subject:
                return jsonify({'error': 'Subject not found'}), 404
        
        # Validate professor exists if provided
        if data.get('professor_id'):
            professor = Professor.query.get(data['professor_id'])
            if not professor:
                return jsonify({'error': 'Professor not found'}), 404
        
        # Check if group already exists (group_name + semester_period should be unique)
        existing_group = GroupClass.query.filter_by(
            group_name=data['group_name'],
            semester_period=data['semester_period']
        ).first()
        if existing_group:
            return jsonify({'error': 'Group with this name already exists for this semester'}), 400
        
        # Create new group
        new_group = GroupClass(
            subject_id=data.get('subject_id'),  # Can be null
            professor_id=data.get('professor_id'),  # Can be null
            group_name=data['group_name'],
            semester_period=data['semester_period'],
            schedule=data.get('schedule'),
            classroom=data.get('classroom'),
            max_students=data.get('max_students', 30),
            current_students=data.get('current_students', 0),
            is_active=data.get('is_active', True)
        )
        
        db.session.add(new_group)
        db.session.commit()
        
        # Add students to group if provided
        student_ids = data.get('student_ids', [])
        if student_ids:
            from app.models import Student
            for student_id in student_ids:
                # Validate student exists
                student = Student.query.get(student_id)
                if student:
                    # Insert into student_groups junction table
                    db.session.execute(
                        'INSERT INTO student_groups (student_id, group_id) VALUES (:student_id, :group_id)',
                        {'student_id': student_id, 'group_id': new_group.id}
                    )
            db.session.commit()
            print(f"Added {len(student_ids)} students to group {new_group.group_name}")
        
        print(f"Group created successfully: {new_group.group_name}")
        
        # Log activity
        log = ActivityLog(
            user_id=current_user.id,
            user_type='admin',
            action_type='group_created',
            description=f'Created group: {subject.code} - {new_group.group_name}'
        )
        db.session.add(log)
        db.session.commit()
        
        return jsonify({
            'message': 'Group created successfully',
            'group': {
                'id': new_group.id,
                'subject_id': new_group.subject_id,
                'professor_id': new_group.professor_id,
                'group_name': new_group.group_name,
                'semester_period': new_group.semester_period,
                'schedule': new_group.schedule,
                'classroom': new_group.classroom,
                'max_students': new_group.max_students,
                'current_students': new_group.current_students,
                'is_active': new_group.is_active
            }
        }), 201
        
    except Exception as e:
        db.session.rollback()
        print(f"Create group error: {str(e)}")
        return jsonify({'error': f'Internal server error: {str(e)}'}), 500

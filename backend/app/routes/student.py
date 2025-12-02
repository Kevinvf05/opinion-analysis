"""
Student routes
Handles student-specific operations like viewing and submitting surveys
"""
from flask import Blueprint, request, jsonify
from ..models import db, User, Student, Survey, Comment, Professor, Subject
from ..routes import token_required
from datetime import datetime
from ..utils.sentiment_classifier import classify_comment

student_bp = Blueprint('student', __name__, url_prefix='/api/student')


def analyze_sentiment(text):
    """
    Analyze sentiment of text using BETO fine-tuned model
    Returns sentiment (positive/neutral/negative) and confidence score
    """
    try:
        sentiment, confidence = classify_comment(text)
        return sentiment, confidence
    except Exception as e:
        print(f"Sentiment analysis error: {str(e)}")
        # Default to neutral with low confidence if analysis fails
        return 'neutral', 0.5


@student_bp.route('/surveys', methods=['GET'])
@token_required
def get_student_surveys(current_user):
    """
    Get all surveys (pending and completed) for the authenticated student
    Returns surveys with professor and subject information
    """
    try:
        # Ensure the user is a student
        if current_user.role != 'student':
            return jsonify({'error': 'Access denied - Students only'}), 403
        
        # Get all surveys for this student
        surveys = Survey.query.filter_by(student_id=current_user.id).all()
        
        survey_list = []
        for survey in surveys:
            # Get professor info
            professor_user = User.query.get(survey.professor_id)
            if not professor_user:
                continue
                
            # Get subject info
            subject = Subject.query.get(survey.subject_id)
            if not subject:
                continue
            
            survey_data = {
                'id': survey.id,
                'status': survey.status,
                'created_at': survey.created_at.isoformat() if survey.created_at else None,
                'completed_at': survey.completed_at.isoformat() if survey.completed_at else None,
                'professor': {
                    'id': professor_user.id,
                    'name': f"{professor_user.first_name} {professor_user.last_name}",
                    'department': professor_user.professor.department if professor_user.professor else None
                },
                'subject': {
                    'id': subject.id,
                    'name': subject.name,
                    'code': subject.code
                }
            }
            survey_list.append(survey_data)
        
        return jsonify({
            'surveys': survey_list,
            'total': len(survey_list)
        }), 200
        
    except Exception as e:
        print(f"Error fetching student surveys: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500


@student_bp.route('/surveys/<int:survey_id>', methods=['GET'])
@token_required
def get_survey_details(current_user, survey_id):
    """
    Get detailed information about a specific survey
    """
    try:
        # Ensure the user is a student
        if current_user.role != 'student':
            return jsonify({'error': 'Access denied - Students only'}), 403
        
        # Get the survey
        survey = Survey.query.get(survey_id)
        
        if not survey:
            return jsonify({'error': 'Survey not found'}), 404
        
        # Ensure this survey belongs to the current student
        if survey.student_id != current_user.id:
            return jsonify({'error': 'Access denied - Not your survey'}), 403
        
        # Get professor info
        professor_user = User.query.get(survey.professor_id)
        
        # Get subject info
        subject = Subject.query.get(survey.subject_id)
        
        # Get comments if survey is completed
        comments = []
        if survey.status == 'completed':
            survey_comments = Comment.query.filter_by(survey_id=survey.id).all()
            comments = [{
                'text': comment.text,
                'sentiment': comment.sentiment,
                'confidence_score': comment.confidence_score
            } for comment in survey_comments]
        
        survey_data = {
            'id': survey.id,
            'status': survey.status,
            'created_at': survey.created_at.isoformat() if survey.created_at else None,
            'completed_at': survey.completed_at.isoformat() if survey.completed_at else None,
            'professor': {
                'id': professor_user.id,
                'name': f"{professor_user.first_name} {professor_user.last_name}",
                'department': professor_user.professor.department if professor_user.professor else None
            },
            'subject': {
                'id': subject.id,
                'name': subject.name,
                'code': subject.code
            } if subject else None,
            'comments': comments
        }
        
        return jsonify(survey_data), 200
        
    except Exception as e:
        print(f"Error fetching survey details: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500


@student_bp.route('/surveys/<int:survey_id>/submit', methods=['POST'])
@token_required
def submit_survey(current_user, survey_id):
    """
    Submit a completed survey with ratings and comments
    Updates survey status and creates comment records with sentiment analysis
    
    Expected request body:
    {
        "answers": {
            "1": 5,  // question_id: rating (1-5)
            "2": 4,
            ...
        },
        "comment": "General comment about the professor"
    }
    """
    try:
        # Ensure the user is a student
        if current_user.role != 'student':
            return jsonify({'error': 'Access denied - Students only'}), 403
        
        # Get the survey
        survey = Survey.query.get(survey_id)
        
        if not survey:
            return jsonify({'error': 'Survey not found'}), 404
        
        # Ensure this survey belongs to the current student
        if survey.student_id != current_user.id:
            return jsonify({'error': 'Access denied - Not your survey'}), 403
        
        # Check if survey is already completed
        if survey.status == 'completed':
            return jsonify({'error': 'Survey already completed'}), 400
        
        # Check if survey is not canceled
        if survey.status == 'canceled':
            return jsonify({'error': 'Cannot submit a canceled survey'}), 400
        
        # Get request data
        data = request.get_json()
        
        if not data:
            return jsonify({'error': 'No data provided'}), 400
        
        answers = data.get('answers', {})
        comment_text = data.get('comment', '').strip()
        
        # Validate that we have answers
        if not answers:
            return jsonify({'error': 'No answers provided'}), 400
        
        # Validate comment (minimum 10 characters)
        if not comment_text or len(comment_text) < 10:
            return jsonify({'error': 'Comment must be at least 10 characters'}), 400
        
        # Perform sentiment analysis on the comment
        sentiment, confidence = analyze_sentiment(comment_text)
        
        # Create comment record
        comment = Comment(
            survey_id=survey.id,
            text=comment_text,
            sentiment=sentiment,
            confidence_score=confidence,
            created_at=datetime.utcnow()
        )
        db.session.add(comment)
        
        # Update survey status
        survey.status = 'completed'
        survey.completed_at = datetime.utcnow()
        
        # Commit changes
        db.session.commit()
        
        print(f"✅ Survey {survey_id} submitted successfully by student {current_user.id}")
        print(f"   Sentiment: {sentiment} (confidence: {confidence:.2f})")
        print(f"   Comment: {comment_text[:50]}...")
        
        return jsonify({
            'message': 'Survey submitted successfully',
            'survey_id': survey.id,
            'status': survey.status,
            'sentiment': sentiment,
            'confidence': confidence
        }), 200
        
    except Exception as e:
        db.session.rollback()
        print(f"Error submitting survey: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500


@student_bp.route('/professors', methods=['GET'])
@token_required
def get_student_professors(current_user):
    """
    Get all professors that the student needs to evaluate
    Returns professors with their subjects and survey status
    """
    try:
        # Ensure the user is a student
        if current_user.role != 'student':
            return jsonify({'error': 'Access denied - Students only'}), 403
        
        # Get all surveys for this student
        surveys = Survey.query.filter_by(student_id=current_user.id).all()
        
        # Group by professor
        professors_data = {}
        
        for survey in surveys:
            professor_user = User.query.get(survey.professor_id)
            if not professor_user:
                continue
            
            subject = Subject.query.get(survey.subject_id)
            if not subject:
                continue
            
            prof_id = professor_user.id
            
            if prof_id not in professors_data:
                professors_data[prof_id] = {
                    'id': prof_id,
                    'name': f"{professor_user.first_name} {professor_user.last_name}",
                    'department': professor_user.professor.department if professor_user.professor else None,
                    'subjects': []
                }
            
            professors_data[prof_id]['subjects'].append({
                'id': subject.id,
                'name': subject.name,
                'code': subject.code,
                'survey_id': survey.id,
                'survey_status': survey.status
            })
        
        professors_list = list(professors_data.values())
        
        return jsonify({
            'professors': professors_list,
            'total': len(professors_list)
        }), 200
        
    except Exception as e:
        print(f"Error fetching student professors: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

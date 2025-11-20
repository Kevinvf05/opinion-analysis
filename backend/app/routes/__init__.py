"""
Authentication routes
"""
from flask import Blueprint, request, jsonify
from ..models import db, User, Student, Professor, Admin
from ..config import Config
from datetime import datetime
import jwt
from functools import wraps

auth_bp = Blueprint('auth', __name__, url_prefix='/api/auth')

def token_required(f):
    """Decorator to protect routes that require authentication"""
    # wraps: is used to preserve the original function's metadata,
    # such as its name and docstring, when it is wrapped by another function.
    # basically, it makes sure that the decorated function looks like the original function.
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None
        
        # Get token from header
        if 'Authorization' in request.headers:
            auth_header = request.headers['Authorization']
            try:
                token = auth_header.split(" ")[1]  # Bearer <token>
            except IndexError:
                return jsonify({'error': 'Invalid token format'}), 401
        
        if not token:
            return jsonify({'error': 'Token is missing'}), 401
        
        try:
            # Decode token
            data = jwt.decode(token, Config.SECRET_KEY, algorithms=["HS256"])
            current_user = User.query.filter_by(id=data['user_id']).first()
            
            if not current_user or not current_user.is_active:
                return jsonify({'error': 'Invalid token or user inactive'}), 401
                
        except jwt.ExpiredSignatureError:
            return jsonify({'error': 'Token has expired'}), 401
        except jwt.InvalidTokenError:
            return jsonify({'error': 'Invalid token'}), 401
        
        return f(current_user, *args, **kwargs)
    
    return decorated


@auth_bp.route('/login', methods=['POST'])
def login():
    """Login endpoint for all user types"""
    try:
        data = request.get_json()
        print(data)
        if not data:
            return jsonify({'error': 'No data provided'}), 400
        
        role = data.get('role')  # 'student' or 'staff'
        
        if role == 'student':
            # Student login with matricula and name (NO password)
            matricula = data.get('matricula')
            name = data.get('name')
            
            if not matricula or not name:
                return jsonify({'error': 'Matricula and name are required'}), 400
            
            # Clean and normalize the input name (remove accents and special chars)
            import unicodedata
            
            def normalize_name(text):
                """Remove accents and special characters, keep only letters and spaces"""
                # Normalize unicode characters (convert á to a, etc.)
                nfkd = unicodedata.normalize('NFKD', text)
                # Remove accents/diacritics
                ascii_text = ''.join([c for c in nfkd if not unicodedata.combining(c)])
                # Remove any non-alphanumeric except spaces
                cleaned = ''.join(c for c in ascii_text if c.isalnum() or c.isspace())
                return cleaned.strip().lower()
            
            name_cleaned = normalize_name(name)
            
            # Find user by matricula
            user = User.query.filter_by(matricula=matricula.upper(), role='student').first()
            
            if not user:
                return jsonify({'error': 'Student not found'}), 404
            
            if not user.is_active:
                return jsonify({'error': 'Account is inactive'}), 403
            
            # For students, verify the name matches (normalize both for comparison)
            full_name_db = f"{user.first_name} {user.last_name}"
            full_name_db_cleaned = normalize_name(full_name_db)
            
            if name_cleaned != full_name_db_cleaned:
                return jsonify({'error': 'Name does not match records'}), 401
            
        else:
            # Staff login (professor, admin ONLY) with email and password
            email = data.get('email')
            password = data.get('password')
            
            if not email or not password:
                return jsonify({'error': 'Email and password are required'}), 400
            
            # Find user by email (must be professor or admin, NOT student)
            user = User.query.filter_by(email=email.lower()).first()
            
            if not user or user.role not in ['professor', 'admin']:
                return jsonify({'error': 'Invalid credentials'}), 401
            
            if not user.is_active:
                return jsonify({'error': 'Account is inactive'}), 403
            
            # Verify password
            if not user.check_password(password):
                return jsonify({'error': 'Invalid credentials'}), 401
        
        # Update last login
        user.last_login = datetime.utcnow()
        db.session.commit()
        
        # Generate JWT token
        token = jwt.encode(
            {
                'user_id': user.id,
                'role': user.role,
                'exp': datetime.utcnow() + Config.JWT_ACCESS_TOKEN_EXPIRES
            },
            Config.SECRET_KEY,
            algorithm="HS256"
        )
        
        # Get role-specific data
        role_data = {}
        if user.role == 'student' and hasattr(user, 'student'):
            student = user.student
            role_data = {
                'matricula': student.matricula,
                'semester': student.semester,
                'career': student.career,
                'group': student.group,
                'has_completed_survey': student.has_completed_survey
            }
        elif user.role == 'professor' and hasattr(user, 'professor'):
            professor = user.professor
            role_data = {
                'department': professor.department,
                'office': professor.office,
                'specialization': professor.specialization
            }
        elif user.role == 'admin' and hasattr(user, 'admin'):
            admin = user.admin
            role_data = {
                'department': admin.department,
                'permissions': admin.permissions
            }
        
        response_data = {
            'message': 'Login successful',
            'token': token,
            'user': {
                **user.to_dict(),
                **role_data
            }
        }
        
        return jsonify(response_data), 200
        
    except Exception as e:
        print(f"Login error: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500


@auth_bp.route('/me', methods=['GET'])
@token_required
def get_current_user(current_user):
    """Get current authenticated user information"""
    return jsonify({
        'user': current_user.to_dict()
    }), 200


@auth_bp.route('/logout', methods=['POST'])
@token_required
def logout(current_user):
    """Logout endpoint (client should discard token)"""
    return jsonify({
        'message': 'Logout successful'
    }), 200

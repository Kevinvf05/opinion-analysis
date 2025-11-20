"""
UAEM Teacher Opinion Analysis System - Backend Application
Main application package initialization
"""
from flask import Flask, jsonify
from flask_cors import CORS
from .models import db
from .routes import auth_bp
from .routes.admin_dashboard import admin_bp
from .routes.student import student_bp
from .routes.professor import professor_bp
import os

__version__ = '2.0.0'


def create_app():
    """Application factory"""
    from .config import Config
    
    app = Flask(__name__)
    
    # Load configuration
    app.config.from_object(Config)
    
    # Initialize extensions
    db.init_app(app)
    CORS(app, 
         resources={r"/api/*": {"origins": "*"}},
         supports_credentials=True,
         allow_headers=["Content-Type", "Authorization"],
         methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"])
    
    # Register blueprints
    app.register_blueprint(auth_bp)
    app.register_blueprint(admin_bp)
    app.register_blueprint(student_bp)
    app.register_blueprint(professor_bp)
    
    # Health check endpoint
    @app.route('/api/health', methods=['GET'])
    def health_check():
        return jsonify({
            'status': 'healthy',
            'message': 'UAEM Evaluation System API'
        }), 200
    
    # Root endpoint
    @app.route('/', methods=['GET'])
    def root():
        return jsonify({
            'message': 'UAEM Teacher Opinion Analysis System API',
            'version': __version__,
            'endpoints': {
                'health': '/api/health',
                'login': '/api/auth/login',
                'current_user': '/api/auth/me',
                'logout': '/api/auth/logout',
                'admin_dashboard': '/api/admin/dashboard/stats',
                'admin_professors': '/api/admin/professors',
                'admin_students': '/api/admin/students',
                'admin_subjects': '/api/admin/subjects',
                'admin_create_user': '/api/admin/users/create'
            }
        }), 200
    
    # Error handlers
    @app.errorhandler(404)
    def not_found(error):
        return jsonify({'error': 'Resource not found'}), 404
    
    @app.errorhandler(500)
    def internal_error(error):
        return jsonify({'error': 'Internal server error'}), 500
    
    return app

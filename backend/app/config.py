"""
Application configuration settings
"""
import os
from datetime import timedelta


class Config:
    """Base configuration"""
    # The secret key is used for session management and JWT encoding
    SECRET_KEY = os.environ.get('SECRET_KEY', 'dev-secret-key-change-in-production')
    # Database configuration
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL', 
                                             'postgresql://postgres:Password123@localhost:5430/uaem_evaluation')
    # Track modifications flag is for SQLAlchemy event system
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    # SQLAlchemy echo flag for debugging
    SQLALCHEMY_ECHO = False
    
    # JWT Configuration
    JWT_SECRET_KEY = SECRET_KEY
    # The access token is for 24 hours
    # Basically, this means users will need to re-authenticate after 24 hours
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(hours=24)
    JWT_EXPIRATION_DELTA = timedelta(hours=24)  # Alias for compatibility
    
    # CORS Configuration - Allow frontend origins
    CORS_ORIGINS = ['http://localhost:8080', 'http://localhost:3000', 'http://localhost:80']

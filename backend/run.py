"""
UAEM Teacher Opinion Analysis System - Main Entry Point
Run this file to start the Flask application
"""
import os
from app import create_app
from app.models import db


if __name__ == '__main__':
    app = create_app()
    
    print("Starting UAEM Evaluation System API...")
    print("Server running on http://0.0.0.0:5000")
    
    app.run(
        host='0.0.0.0',
        port=5000,
        debug=os.environ.get('FLASK_ENV') == 'development'
    )

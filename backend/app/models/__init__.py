"""
Database models package
"""
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
import hashlib

# Initialize SQLAlchemy
db = SQLAlchemy()


# The db.Model is the base for all models
# It provides the basic CRUD operations and query capabilities
"""
C: Create
R: Read
U: Update
D: Delete
The basic operations are implemented through methods like add(), query(), commit(), delete(), etc.
"""
class User(db.Model):
    """Unified user model for all user types"""
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=True)
    password_hash = db.Column(db.String(255), nullable=False)
    first_name = db.Column(db.String(100), nullable=False)
    last_name = db.Column(db.String(100), nullable=False)
    role = db.Column(db.String(20), nullable=False)  # admin, professor, student
    matricula = db.Column(db.String(20), unique=True, nullable=True)
    is_active = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    last_login = db.Column(db.DateTime)
    
    def set_password(self, password):
        """Hash and set the password"""
        self.password_hash = hashlib.sha256(password.encode()).hexdigest()
    
    def check_password(self, password):
        """Verify password against hash"""
        return self.password_hash == hashlib.sha256(password.encode()).hexdigest()
    
    def to_dict(self):
        """Convert user to dictionary"""
        return {
            'id': self.id,
            'email': self.email,
            'first_name': self.first_name,
            'last_name': self.last_name,
            'full_name': f"{self.first_name} {self.last_name}",
            'role': self.role,
            'matricula': self.matricula,
            'is_active': self.is_active,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'last_login': self.last_login.isoformat() if self.last_login else None
        }
    
    def __repr__(self):
        return f'<User {self.email or self.matricula} - {self.role}>'


class Student(db.Model):
    """Student-specific data"""
    __tablename__ = 'students'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id', ondelete='CASCADE'), unique=True, nullable=False)
    matricula = db.Column(db.String(20), unique=True, nullable=False)
    semester = db.Column(db.Integer)
    career = db.Column(db.String(100))
    group = db.Column('group', db.String(20))
    has_completed_survey = db.Column(db.Boolean, default=False)
    survey_completed_at = db.Column(db.DateTime)
    status = db.Column(db.String(20), default='active')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationship
    user = db.relationship('User', backref=db.backref('student', uselist=False), passive_deletes=True)
    
    def __repr__(self):
        return f'<Student {self.matricula}>'


class Professor(db.Model):
    """Professor-specific data"""
    __tablename__ = 'professors'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id', ondelete='CASCADE'), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    department = db.Column(db.String(100))
    office = db.Column(db.String(50))
    phone = db.Column(db.String(20))
    specialization = db.Column(db.String(200))
    status = db.Column(db.String(20), default='active')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationship
    user = db.relationship('User', backref=db.backref('professor', uselist=False), passive_deletes=True)
    
    def __repr__(self):
        return f'<Professor {self.email}>'


class Admin(db.Model):
    """Admin-specific data"""
    __tablename__ = 'admins'
    
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id', ondelete='CASCADE'), unique=True, nullable=False)
    department = db.Column(db.String(100))
    permissions = db.Column(db.JSON)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationship
    user = db.relationship('User', backref=db.backref('admin', uselist=False), passive_deletes=True)
    
    def __repr__(self):
        return f'<Admin {self.user_id}>'

class Survey(db.Model):
    """ Survey """
    __tablename__ = 'surveys'
    id = db.Column(db.Integer, primary_key=True)
    student_id = db.Column(db.Integer, db.ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    professor_id = db.Column(db.Integer, db.ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    subject_id = db.Column(db.Integer, db.ForeignKey('subjects.id', ondelete='CASCADE'), nullable=False)
    status = db.Column(
        db.Enum('pending', 'completed', 'canceled', name='survey_status'),
        default='pending',
        nullable=False
    )
    created_at = db.Column(db.DateTime, default=datetime.now)
    completed_at = db.Column(db.DateTime)
    
    __table_args__ = (
        db.UniqueConstraint('student_id', 'professor_id', 'subject_id', name='unique_student_professor_subject'),
        # SQLAlchemy automatically creates indexes for Foreign Keys, 
        # but you can add specific index declarations if needed:
        # db.Index('idx_surveys_status', 'status'), 
    )
    
    def __repr__(self):
        return f'<Survey {self.id} Status: {self.status}>'
    
class Comment(db.Model):
    __tablename__ = 'comments'
    id = db.Column(db.Integer, primary_key=True)
    survey_id = db.Column(db.Integer, db.ForeignKey('surveys.id', ondelete='CASCADE'), nullable=False)
    text = db.Column(db.Text, nullable=False)
    sentiment = db.Column(
        db.Enum('positive', 'neutral', 'negative', name='sentiment_type'),
        nullable=False
    )
    confidence_score = db.Column(db.Float, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.now)
    
    def __repr__(self):
        return f'<Comment {self.id} Sentiment: {self.sentiment}>'
    
class Subject(db.Model):
    __tablename__ = 'subjects'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(200), nullable=False)
    code = db.Column(db.String(20), unique=True, nullable=False)
    professor_id = db.Column(db.Integer, db.ForeignKey('professors.id', ondelete='SET NULL'))
    semester = db.Column(db.Integer)
    is_active = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.now)
    
    def __repr__(self):
        return f'<Subject {self.code} - {self.name}>'
    
class GroupClass(db.Model):
    __tablename__ = 'group_classes'

    id = db.Column(db.Integer, primary_key=True)
    subject_id = db.Column(db.Integer, db.ForeignKey('subjects.id', ondelete='CASCADE'), nullable=False)
    professor_id = db.Column(db.Integer, db.ForeignKey('professors.id', ondelete='CASCADE'), nullable=False)
    group_name = db.Column(db.String(20), nullable=False)
    semester_period= db.Column(db.String(20))
    schedule = db.Column(db.String(200))
    classroom = db.Column(db.String(50))
    max_students = db.Column(db.Integer, default=30)
    current_students = db.Column(db.Integer, default=0)
    is_active = db.Column(db.Boolean, default=True)
    created_at = db.Column(db.DateTime, default=datetime.now)
    updated_at = db.Column(db.DateTime, default=datetime.now, onupdate=datetime.now)
    
    __table_args__ = (
        db.UniqueConstraint('subject_id', 'group_name', 'semester_period', name='unique_subject_group_semester'),
    ) 
    
    def __repr__(self):
        return f'<GroupClass {self.group_name} for Subject ID {self.subject_id}>'

class ActivityLog(db.Model):
    __tablename__ = 'activity_logs'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id', ondelete='CASCADE'), nullable=False)
    user_type = db.Column(db.Enum('admin', 'professor', 'student'),
                          nullable=False)
    action_type = db.Column(db.String(50), nullable=False)
    description = db.Column(db.String(255), nullable=False)
    target_id = db.Column(db.Integer)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

# Export all models
__all__ = ['db', 'User', 'Student', 'Professor', 'Admin', 'Survey', 'Comment', 'Subject', 'GroupClass']

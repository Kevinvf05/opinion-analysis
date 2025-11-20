"""
Seed initial data for testing
Run this after the database is created
"""
from app import create_app
from app.models import db, User, Student, Professor, Admin

def seed_data():
    """Create sample users for testing"""
    app = create_app()
    
    with app.app_context():
        print("Seeding database...")
        
        # Check if data already exists
        if User.query.first():
            print("Database already has data. Skipping seed.")
            return
        
        # Create Admin
        admin_user = User(
            email='admin@uaem.mx',
            first_name='Admin',
            last_name='Sistema',
            role='admin',
            is_active=True
        )
        admin_user.set_password('admin123')
        db.session.add(admin_user)
        db.session.flush()
        
        admin_profile = Admin(
            user_id=admin_user.id,
            department='Administración',
            permissions={'all': True}
        )
        db.session.add(admin_profile)
        
        # Create Professor
        prof_user = User(
            email='profesor@uaem.mx',
            first_name='Juan',
            last_name='Pérez',
            role='professor',
            is_active=True
        )
        prof_user.set_password('profesor123')
        db.session.add(prof_user)
        db.session.flush()
        
        prof_profile = Professor(
            user_id=prof_user.id,
            email='profesor@uaem.mx',
            department='Ingeniería',
            office='A-101',
            phone='555-1234',
            specialization='Ciencias de la Computación',
            status='active'
        )
        db.session.add(prof_profile)
        
        # Create Student
        student_user = User(
            email=None,
            first_name='María',
            last_name='González',
            role='student',
            matricula='A12345678',
            is_active=True
        )
        student_user.set_password('student123')  # Not used for student login, but required
        db.session.add(student_user)
        db.session.flush()
        
        student_profile = Student(
            user_id=student_user.id,
            matricula='A12345678',
            semester=5,
            career='Ingeniería en Computación',
            group='501',
            status='active',
            has_completed_survey=False
        )
        db.session.add(student_profile)
        
        # Create another student for testing
        student_user2 = User(
            email=None,
            first_name='Carlos',
            last_name='Ramírez',
            role='student',
            matricula='A87654321',
            is_active=True
        )
        student_user2.set_password('student123')
        db.session.add(student_user2)
        db.session.flush()
        
        student_profile2 = Student(
            user_id=student_user2.id,
            matricula='A87654321',
            semester=3,
            career='Ingeniería en Sistemas',
            group='301',
            status='active',
            has_completed_survey=False
        )
        db.session.add(student_profile2)
        
        # Commit all changes
        db.session.commit()
        
        print("✓ Seed data created successfully!")
        print("\nTest credentials:")
        print("-" * 50)
        print("ADMIN:")
        print("  Email: admin@uaem.mx")
        print("  Password: admin123")
        print("\nPROFESSOR:")
        print("  Email: profesor@uaem.mx")
        print("  Password: profesor123")
        print("\nSTUDENT 1:")
        print("  Matricula: A12345678")
        print("  Name: María González")
        print("\nSTUDENT 2:")
        print("  Matricula: A87654321")
        print("  Name: Carlos Ramírez")
        print("-" * 50)


if __name__ == '__main__':
    seed_data()

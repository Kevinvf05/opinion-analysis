"""
Test script to verify login functionality
Run this to test the authentication logic
"""
import re
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

def test_student_name_matching():
    """Test that student names with special characters are properly matched"""
    
    # Simulated database names
    test_cases = [
        ("María González", "María González", True),   # Exact match
        ("María González", "Maria Gonzalez", True),   # Without accents
        ("María González", "maria gonzalez", True),   # Lowercase
        ("Carlos Ramírez", "Carlos Ramirez", True),   # Without accent
        ("José Luis O'Brien", "Jose Luis OBrien", True), # Without apostrophe
        ("José Luis O'Brien", "José Luis O'Brien", True),# With apostrophe
        ("Ana María Pérez", "Ana Maria Perez", True),  # Without accents
        ("María González", "Wrong Name", False)       # Should not match
    ]
    
    print("🧪 Testing Student Name Matching\n")
    print("=" * 60)
    
    for db_name, input_name, should_match in test_cases:
        db_cleaned = normalize_name(db_name)
        input_cleaned = normalize_name(input_name)
        matches = (input_cleaned == db_cleaned)
        
        if matches == should_match:
            status = "✅ PASS"
        else:
            status = "❌ FAIL"
        
        print(f"{status}: DB: '{db_name}' ({db_cleaned})")
        print(f"       Input: '{input_name}' ({input_cleaned})")
        print(f"       Match: {matches} (Expected: {should_match})\n")

def test_matricula_validation():
    """Test matricula format validation"""
    
    test_cases = [
        ("A12345678", True),   # Valid
        ("a12345678", True),   # Valid (lowercase)
        ("B87654321", True),   # Valid
        ("12345678A", False),  # Invalid (number first)
        ("AA2345678", False),  # Invalid (two letters)
        ("A1234567", False),   # Invalid (too short)
        ("A123456789", False), # Invalid (too long)
        ("", False)            # Invalid (empty)
    ]
    
    print("\n\n🧪 Testing Matricula Validation\n")
    print("=" * 60)
    
    pattern = r'^[A-Za-z][0-9]{8}$'
    
    for matricula, should_be_valid in test_cases:
        is_valid = bool(re.match(pattern, matricula))
        
        if is_valid == should_be_valid:
            status = "✅ PASS"
        else:
            status = "❌ FAIL"
        
        print(f"{status}: '{matricula}' → {'Valid' if is_valid else 'Invalid'}")

def test_email_validation():
    """Test email format validation"""
    
    test_cases = [
        ("admin@uaem.mx", True),
        ("profesor@uaem.mx", True),
        ("test.user@university.edu", True),
        ("invalid-email", False),
        ("@uaem.mx", False),
        ("user@", False),
        ("", False)
    ]
    
    print("\n\n🧪 Testing Email Validation\n")
    print("=" * 60)
    
    pattern = r'^[^\s@]+@[^\s@]+\.[^\s@]+$'
    
    for email, should_be_valid in test_cases:
        is_valid = bool(re.match(pattern, email))
        
        if is_valid == should_be_valid:
            status = "✅ PASS"
        else:
            status = "❌ FAIL"
        
        print(f"{status}: '{email}' → {'Valid' if is_valid else 'Invalid'}")

if __name__ == '__main__':
    test_student_name_matching()
    test_matricula_validation()
    test_email_validation()
    
    print("\n" + "=" * 60)
    print("✅ All tests completed!")
    print("=" * 60)

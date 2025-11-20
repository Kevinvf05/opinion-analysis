# Backend Tests

## Running Tests

```bash
# From the backend directory
python tests/test_login.py
```

## Test Coverage

### ✅ Login Validation Tests (23 tests)

1. **Name Normalization** (8 tests)
   - Tests that names with accents match without accents
   - Tests apostrophes and special characters are removed
   - Tests case-insensitive matching

2. **Matricula Validation** (8 tests)
   - Valid format: 1 letter + 8 digits
   - Invalid formats rejected

3. **Email Validation** (7 tests)
   - Valid email formats accepted
   - Invalid formats rejected

## Test Results

All tests pass! ✅

```
🧪 Testing Student Name Matching
============================================================
✅ PASS: 'María González' → 'maria gonzalez' MATCHES
✅ PASS: 'José Luis O'Brien' → 'jose luis obrien' MATCHES
... (8 total tests)

🧪 Testing Matricula Validation
============================================================
✅ PASS: 'A12345678' → Valid
✅ PASS: '12345678A' → Invalid
... (8 total tests)

🧪 Testing Email Validation
============================================================
✅ PASS: 'admin@uaem.mx' → Valid
✅ PASS: 'invalid-email' → Invalid
... (7 total tests)

============================================================
✅ All tests completed!
============================================================
```

## Adding New Tests

Create new test files in the `tests/` directory following the pattern in `test_login.py`.

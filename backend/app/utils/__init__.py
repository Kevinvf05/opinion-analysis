"""
Utility functions for authentication and text processing
"""
import unicodedata


def normalize_name(text):
    """
    Remove accents and special characters from text,  keeping only letters and spaces.
    Used for student name matching.
    
    Examples:
        María González -> maria gonzalez
        José Luis O'Brien -> jose luis obrien
    """
    # Normalize unicode characters (convert á to a, etc.)
    nfkd = unicodedata.normalize('NFKD', text)
    # Remove accents/diacritics
    ascii_text = ''.join([c for c in nfkd if not unicodedata.combining(c)])
    # Remove any non-alphanumeric except spaces
    cleaned = ''.join(c for c in ascii_text if c.isalnum() or c.isspace())
    return cleaned.strip().lower()

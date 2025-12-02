"""
BETO Sentiment Classification Utility
Uses the fine-tuned BETO model to classify professor comments
"""
import os
import re
import torch
from transformers import AutoModelForSequenceClassification, AutoTokenizer
import json


class SentimentClassifier:
    """Singleton class for BETO sentiment classification"""
    
    _instance = None
    _model = None
    _tokenizer = None
    _label_mapping = None
    _model_loaded = False
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(SentimentClassifier, cls).__new__(cls)
        return cls._instance
    
    def __init__(self):
        """Initialize the classifier (lazy loading)"""
        pass
    
    @classmethod
    def load_model(cls, model_path="final_model"):
        """
        Load the BETO model and tokenizer
        Only loads once (singleton pattern)
        """
        if cls._model_loaded:
            return True
        
        try:
            print(f"Loading BETO model from: {model_path}")
            
            # Load the model
            cls._model = AutoModelForSequenceClassification.from_pretrained(model_path)
            cls._tokenizer = AutoTokenizer.from_pretrained(model_path)
            
            # Load label mappings
            label_file = os.path.join(model_path, "label_mappings.json")
            if os.path.exists(label_file):
                with open(label_file, 'r', encoding='utf-8') as f:
                    label_info = json.load(f)
                    cls._label_mapping = label_info.get("label_encoder_classes", ["BUENO", "MALO", "REGULAR"])
            else:
                # Default labels
                cls._label_mapping = ["BUENO", "MALO", "REGULAR"]
            
            cls._model_loaded = True
            print(f"✓ Model loaded successfully. Labels: {cls._label_mapping}")
            return True
            
        except Exception as e:
            print(f"✗ Error loading BETO model: {str(e)}")
            cls._model_loaded = False
            return False
    
    @staticmethod
    def clean_text(text):
        """
        Clean and preprocess the comment text
        Same preprocessing used during training
        """
        # Convert to lowercase
        text = text.lower()
        
        # Remove special characters but keep letters, numbers, and spaces
        text = re.sub(r'[^a-záéíóúñü0-9\s]', '', text)
        
        # Remove extra whitespace
        text = re.sub(r'\s+', ' ', text).strip()
        
        return text
    
    @classmethod
    def classify(cls, text):
        """
        Classify a comment using the BETO model
        
        Args:
            text (str): The comment text to classify
            
        Returns:
            tuple: (sentiment, confidence, probabilities)
                - sentiment: str ('positive', 'negative', or 'neutral')
                - confidence: float (0-1, confidence of the prediction)
                - probabilities: dict with all class probabilities
        """
        # Ensure model is loaded
        if not cls._model_loaded:
            if not cls.load_model():
                # Fallback to a default if model fails to load
                print("⚠ Using default sentiment due to model loading failure")
                return 'neutral', 0.5, {'positive': 0.33, 'neutral': 0.34, 'negative': 0.33}
        
        try:
            # Clean the text
            cleaned_text = cls.clean_text(text)
            
            # Tokenize
            inputs = cls._tokenizer(
                cleaned_text,
                return_tensors="pt",
                truncation=True,
                max_length=192,
                padding=True
            )
            
            # Get prediction
            with torch.no_grad():
                outputs = cls._model(**inputs)
                logits = outputs.logits
                probs = torch.nn.functional.softmax(logits, dim=-1)[0]
            
            # Get predicted class
            predicted_class = torch.argmax(probs).item()
            confidence = float(probs[predicted_class].item())
            label = cls._label_mapping[predicted_class]
            
            # Map BETO labels to database sentiment values
            # BUENO -> positive, MALO -> negative, REGULAR -> neutral
            sentiment_map = {
                'BUENO': 'positive',
                'MALO': 'negative',
                'REGULAR': 'neutral'
            }
            sentiment = sentiment_map.get(label, 'neutral')
            
            # Create probabilities dict with database sentiment keys
            probabilities = {
                'positive': float(probs[cls._label_mapping.index('BUENO')].item()) if 'BUENO' in cls._label_mapping else 0.0,
                'negative': float(probs[cls._label_mapping.index('MALO')].item()) if 'MALO' in cls._label_mapping else 0.0,
                'neutral': float(probs[cls._label_mapping.index('REGULAR')].item()) if 'REGULAR' in cls._label_mapping else 0.0
            }
            
            return sentiment, confidence, probabilities
            
        except Exception as e:
            print(f"✗ Error during classification: {str(e)}")
            # Fallback to neutral sentiment
            return 'neutral', 0.5, {'positive': 0.33, 'neutral': 0.34, 'negative': 0.33}


# Global instance
sentiment_classifier = SentimentClassifier()


def classify_comment(text):
    """
    Convenience function to classify a comment
    
    Args:
        text (str): The comment text to classify
        
    Returns:
        tuple: (sentiment, confidence)
            - sentiment: str ('positive', 'negative', or 'neutral')
            - confidence: float (0-1)
    """
    sentiment, confidence, _ = sentiment_classifier.classify(text)
    return sentiment, confidence

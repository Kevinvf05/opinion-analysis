"""
Test script for BETO sentiment classification model
Tests if the model weights are working correctly for professor comment classification
"""

import torch
import json
import os
import re
from transformers import AutoModelForSequenceClassification, AutoTokenizer


def limpiar_com(comentario):
    """
    Clean and preprocess comment text
    """
    if not comentario or not isinstance(comentario, str):
        return ""
    
    # Convert to lowercase
    comentario = comentario.lower()
    
    # Remove special characters but keep Spanish characters
    comentario = re.sub(r'[^a-záéíóúñü\s]', '', comentario)
    
    # Remove extra whitespace
    comentario = ' '.join(comentario.split())
    
    return comentario.strip()


def classify_new_comment(comment_text, model_path="/final_model"):
    """
    Load the saved model and classify a professor comment.
    This function can be used in any Python application.
    
    Args:
        comment_text: The professor comment to classify
        model_path: Path to the saved model directory
    
    Returns:
        dict: Classification result with label, confidence, and probabilities
              Label can be: BUENO, MALO, or REGULAR
    """
    
    # Check if model exists
    if not os.path.exists(model_path):
        raise FileNotFoundError(f"Model not found at: {model_path}")
    
    print(f"Loading model from: {model_path}")
    
    # Load model and tokenizer
    model = AutoModelForSequenceClassification.from_pretrained(model_path)
    tokenizer = AutoTokenizer.from_pretrained(model_path)
    
    # Load label mappings
    label_mappings_path = os.path.join(model_path, "label_mappings.json")
    if not os.path.exists(label_mappings_path):
        raise FileNotFoundError(f"Label mappings not found at: {label_mappings_path}")
    
    with open(label_mappings_path, "r", encoding="utf-8") as f:
        label_info = json.load(f)
    
    print(f"Label classes: {label_info['label_encoder_classes']}")
    
    # Preprocess
    clean_text = limpiar_com(comment_text)
    print(f"Original: {comment_text}")
    print(f"Cleaned: {clean_text}")
    
    # Tokenize
    inputs = tokenizer(
        clean_text, 
        truncation=True, 
        padding="max_length", 
        max_length=192, 
        return_tensors="pt"
    )
    
    # Predict
    model.eval()
    with torch.no_grad():
        outputs = model(**inputs)
        probs = torch.nn.functional.softmax(outputs.logits, dim=1)[0]
        predicted_class = torch.argmax(probs).item()
    
    return {
        "label": label_info["label_encoder_classes"][predicted_class],
        "confidence": float(probs[predicted_class].item()),
        "probabilities": {
            label_info["label_encoder_classes"][i]: float(probs[i].item())
            for i in range(len(probs))
        }
    }


def test_multiple_comments(model_path="final_model"):
    """
    Test the model with multiple example comments
    """
    
    test_comments = [
        # Positive comments (expected: BUENO)
        "El profesor explica muy bien la materia y siempre resuelve dudas",
        "Excelente docente, muy dedicado y paciente con los estudiantes",
        "Me encanta su clase, aprendo mucho y es muy claro en sus explicaciones",
        
        # Negative comments (expected: MALO)
        "No explica bien, es aburrido y no resuelve dudas",
        "Pésimo profesor, no enseña nada y siempre llega tarde",
        "No me gusta su forma de enseñar, muy confuso",
        
        # Neutral comments (expected: REGULAR)
        "La clase es normal, nada extraordinario",
        "Cumple con su trabajo pero podría mejorar",
        "Es un profesor promedio, ni bueno ni malo"
    ]
    
    print("="*80)
    print("TESTING BETO SENTIMENT CLASSIFICATION MODEL")
    print("="*80)
    print()
    
    for i, comment in enumerate(test_comments, 1):
        print(f"\n--- Test {i} ---")
        try:
            result = classify_new_comment(comment, model_path)
            print(f"\n✓ Prediction: {result['label']} (Confidence: {result['confidence']:.2%})")
            print(f"  Probabilities:")
            for label, prob in result['probabilities'].items():
                print(f"    - {label}: {prob:.2%}")
        except Exception as e:
            print(f"✗ Error: {str(e)}")
        print("-"*80)


def test_single_comment(comment_text, model_path="out_beto/final_model"):
    """
    Test a single comment
    """
    print("="*80)
    print("TESTING SINGLE COMMENT")
    print("="*80)
    print()
    
    try:
        result = classify_new_comment(comment_text, model_path)
        print(f"Comment: {comment_text}")
        print(f"\nPrediction: {result['label']} ({result['confidence']:.2%})")
        print(f"\nAll probabilities:")
        for label, prob in result['probabilities'].items():
            print(f"  {label}: {prob:.2%}")
        return result
    except Exception as e:
        print(f"Error: {str(e)}")
        import traceback
        traceback.print_exc()
        return None


def verify_model_files(model_path="out_beto/final_model"):
    """
    Verify that all required model files exist
    """
    print("="*80)
    print("VERIFYING MODEL FILES")
    print("="*80)
    
    required_files = [
        "config.json",
        "tokenizer_config.json",
        "vocab.txt",
        "label_mappings.json"
    ]
    
    # Check for either pytorch_model.bin or model.safetensors
    model_file_options = ["pytorch_model.bin", "model.safetensors"]
    
    print(f"\nChecking directory: {model_path}")
    
    if not os.path.exists(model_path):
        print(f"✗ Model directory does not exist: {model_path}")
        return False
    
    all_exist = True
    for file in required_files:
        file_path = os.path.join(model_path, file)
        exists = os.path.exists(file_path)
        status = "✓" if exists else "✗"
        print(f"{status} {file}")
        if not exists:
            all_exist = False
    
    # Check for model weights file
    model_file_exists = False
    for model_file in model_file_options:
        if os.path.exists(os.path.join(model_path, model_file)):
            print(f"✓ {model_file}")
            model_file_exists = True
            break
    
    if not model_file_exists:
        print(f"✗ No model weights found (looking for: {', '.join(model_file_options)})")
        all_exist = False
    
    print()
    if all_exist:
        print("✓ All required files found!")
    else:
        print("✗ Some files are missing. Please check the model path.")
    
    return all_exist


if __name__ == "__main__":
    import sys
    
    # Default model path
    model_path = "final_model"
    
    # Allow custom model path via command line
    if len(sys.argv) > 1:
        model_path = sys.argv[1]
    
    print(f"\nUsing model path: {model_path}\n")
    
    # Step 1: Verify files
    if not verify_model_files(model_path):
        print("\n⚠ Model files verification failed!")
        print("Please ensure the model is in the correct directory.")
        sys.exit(1)
    
    print("\n")
    
    # Step 2: Test single comment
    test_comment = "El profesor explica muy bien la materia y siempre resuelve dudas"
    test_single_comment(test_comment, model_path)
    
    print("\n\n")
    
    # Step 3: Test multiple comments
    test_multiple_comments(model_path)
    
    print("\n")
    print("="*80)
    print("TESTING COMPLETE")
    print("="*80)

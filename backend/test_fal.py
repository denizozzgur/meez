
import os
import base64
from ai_pipeline import AIProcessor

# Mock a small white image
dummy_image = b'\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1f\x15\xc4\x89\x00\x00\x00\nIDATx\x9cc\xfc\xff\xff?\x03\x05\x00\x01\x02\x00\x01\x00\x00\x00\x00\x01\x2f\xae\x91\xff\x00\x00\x00\x00IEND\xaeB`\x82'

print("Initializing AIProcessor...")
processor = AIProcessor()

print("Testing Fal.ai call...")
b64 = base64.b64encode(dummy_image).decode('utf-8')
result = processor.call_fal_seedream(b64, "Test prompt", "Negative", 0.5, 7.5)

if result:
    print(f"SUCCESS: {result}")
else:
    print("FAILURE")

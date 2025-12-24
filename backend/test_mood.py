
import os
import sys

# Add backend to path
sys.path.append(os.path.join(os.path.dirname(__file__), "."))

from ai_pipeline import AIProcessor
from sticker_templates import MASTER_STICKER_LIBRARY

def test_mood_logic():
    print("--- Testing Image Mood Logic ---")
    processor = AIProcessor()
    
    # Test Roast
    print("\nTesting Tone: 'roast'")
    plan = processor.generate_captions("neutral", "test_user", tone="roast")
    
    roast_keywords = ["bad", "clown", "dead", "skill issue", "side-eye", "roast"]
    
    hit_count = 0
    for item in plan:
        print(f"  - Item ID: {item['id']} Tags: {item.get('tags', 'N/A')}")
        # Note: item in plan is normalized, tags might not be there depending on implementation
        # But we can check if the ID corresponds to a roast item in MASTER_LIBRARY if we searched for it
        # Or checking text/caption
        obj = next((x for x in MASTER_STICKER_LIBRARY if x["id"] == item["id"]), None)
        if obj:
            print(f"    Tags: {obj.get('tags')}")
            if any(k in obj.get("tags", []) for k in ["roast", "funny", "mocking"]):
                hit_count += 1
    
    print(f"Roast Hits: {hit_count}/{len(plan)}")
    if hit_count > 0:
        print("✅ Roast tone successfully influenced selection")
    else:
        print("❌ Roast tone failed to select relevant stickers")

    # Test Text Prompt
    print("\n--- Testing Text Prompt Logic ---")
    prompts = processor.generate_text_sticker_prompts("dog", tone="roast")
    print(f"Generated Subject: {prompts.get('subject')}")
    # We can't easily assert on OpenAI output without mocking, but we can check if it ran without error
    # and maybe print the first prompt to see if logic injected correctly
    
    if prompts and "prompts" in prompts:
        print(f"✅ Text Prompt Generation Successful. Count: {len(prompts['prompts'])}")
    else:
        print("❌ Text Prompt Generation Failed")

if __name__ == "__main__":
    try:
        test_mood_logic()
    except Exception as e:
        print(f"Test Failed: {e}")

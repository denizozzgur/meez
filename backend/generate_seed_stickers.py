#!/usr/bin/env python3
"""
Seed Sticker Generator for Meez Production Launch
Generates real AI stickers for 10 sample packs
Run this script ONCE before production launch
"""

import os
import json
import sys
from dotenv import load_dotenv

# Load environment
load_dotenv()

# Import AI pipeline
from ai_pipeline import AIProcessor

# Seed pack themes - each will generate 3 stickers
SEED_THEMES = [
    {
        "id": "seed_pack_001",
        "title": "Monday Moods",
        "user_id": "user_alpha_monday",
        "likes": 2847,
        "prompts": [
            {"id": "s1_1", "caption": "Need Coffee", "prompt": "Cute sleepy coffee cup character yawning, exhausted expression, 3D render style, isolated on white background, no text"},
            {"id": "s1_2", "caption": "Send Help", "prompt": "Cute overwhelmed calendar mascot with Monday highlighted, stressed expression, 3D render style, isolated on white background, no text"},
            {"id": "s1_3", "caption": "Not Today", "prompt": "Cute grumpy alarm clock character covering its eyes, refusing to wake up, 3D render style, isolated on white background, no text"},
        ]
    },
    {
        "id": "seed_pack_002",
        "title": "Work From Home",
        "user_id": "user_beta_remote",
        "likes": 1923,
        "prompts": [
            {"id": "s2_1", "caption": "On Mute", "prompt": "Cute laptop character with microphone icon muted, finger on lips gesture, 3D render style, isolated on white background, no text"},
            {"id": "s2_2", "caption": "Camera Off", "prompt": "Cute webcam character with closed eye/lens, shy expression hiding, 3D render style, isolated on white background, no text"},
            {"id": "s2_3", "caption": "BRB", "prompt": "Cute office chair character spinning away happily, carefree expression, 3D render style, isolated on white background, no text"},
        ]
    },
    {
        "id": "seed_pack_003",
        "title": "Cat Reactions",
        "user_id": "user_gamma_cats",
        "likes": 5421,
        "prompts": [
            {"id": "s3_1", "caption": "Judging You", "prompt": "Cute fluffy cat with narrowed suspicious eyes, judgemental expression, 3D render style, isolated on white background, no text"},
            {"id": "s3_2", "caption": "Feed Me", "prompt": "Cute hungry cat with big pleading eyes, begging pose paws together, 3D render style, isolated on white background, no text"},
            {"id": "s3_3", "caption": "Nope", "prompt": "Cute cat walking away with tail up, dismissive back turned pose, 3D render style, isolated on white background, no text"},
        ]
    },
    {
        "id": "seed_pack_004",
        "title": "Gym Life",
        "user_id": "user_delta_gym",
        "likes": 1256,
        "prompts": [
            {"id": "s4_1", "caption": "No Pain", "prompt": "Cute dumbbell character flexing with determined expression, muscular pose, 3D render style, isolated on white background, no text"},
            {"id": "s4_2", "caption": "Leg Day", "prompt": "Cute gym shorts character looking scared and sweating, nervous expression, 3D render style, isolated on white background, no text"},
            {"id": "s4_3", "caption": "One More", "prompt": "Cute protein shake character cheering encouragingly, motivational pose, 3D render style, isolated on white background, no text"},
        ]
    },
    {
        "id": "seed_pack_005",
        "title": "Love & Hearts",
        "user_id": "user_epsilon_love",
        "likes": 3789,
        "prompts": [
            {"id": "s5_1", "caption": "Miss You", "prompt": "Cute heart character looking sad and lonely, tears forming, 3D render style, isolated on white background, no text"},
            {"id": "s5_2", "caption": "Love You", "prompt": "Cute heart character with happy blushing cheeks, eyes closed smiling, 3D render style, isolated on white background, no text"},
            {"id": "s5_3", "caption": "Hugs", "prompt": "Two cute heart characters hugging each other warmly, joyful expression, 3D render style, isolated on white background, no text"},
        ]
    },
    {
        "id": "seed_pack_006",
        "title": "Foodie Vibes",
        "user_id": "user_zeta_food",
        "likes": 2134,
        "prompts": [
            {"id": "s6_1", "caption": "Hungry", "prompt": "Cute empty plate character with drooling expression, starving look, 3D render style, isolated on white background, no text"},
            {"id": "s6_2", "caption": "Yummy", "prompt": "Cute pizza slice character licking lips satisfied, delicious expression, 3D render style, isolated on white background, no text"},
            {"id": "s6_3", "caption": "Diet Tomorrow", "prompt": "Cute donut character winking mischievously, tempting expression, 3D render style, isolated on white background, no text"},
        ]
    },
    {
        "id": "seed_pack_007",
        "title": "Party Time",
        "user_id": "user_eta_party",
        "likes": 4567,
        "prompts": [
            {"id": "s7_1", "caption": "Let's Go", "prompt": "Cute disco ball character with excited expression, party energy, 3D render style, isolated on white background, no text"},
            {"id": "s7_2", "caption": "TGIF", "prompt": "Cute champagne bottle character celebrating, popping cork expression, 3D render style, isolated on white background, no text"},
            {"id": "s7_3", "caption": "Weekend!", "prompt": "Cute confetti character jumping with joy, ecstatic expression, 3D render style, isolated on white background, no text"},
        ]
    },
    {
        "id": "seed_pack_008",
        "title": "Sleepy Vibes",
        "user_id": "user_theta_sleep",
        "likes": 1876,
        "prompts": [
            {"id": "s8_1", "caption": "So Tired", "prompt": "Cute pillow character with droopy exhausted eyes, yawning expression, 3D render style, isolated on white background, no text"},
            {"id": "s8_2", "caption": "5 More Min", "prompt": "Cute blanket character curled up refusing to move, cozy stubborn expression, 3D render style, isolated on white background, no text"},
            {"id": "s8_3", "caption": "Zzz", "prompt": "Cute moon character peacefully sleeping with cute expression, dreamy face, 3D render style, isolated on white background, no text"},
        ]
    },
    {
        "id": "seed_pack_009",
        "title": "Sarcasm Club",
        "user_id": "user_iota_sarcasm",
        "likes": 6234,
        "prompts": [
            {"id": "s9_1", "caption": "Sure Jan", "prompt": "Cute eye roll emoji character with skeptical unimpressed expression, 3D render style, isolated on white background, no text"},
            {"id": "s9_2", "caption": "Oh Really", "prompt": "Cute raised eyebrow face character with sarcastic doubtful expression, 3D render style, isolated on white background, no text"},
            {"id": "s9_3", "caption": "Cool Story", "prompt": "Cute yawning face character looking bored and uninterested, dismissive expression, 3D render style, isolated on white background, no text"},
        ]
    },
    {
        "id": "seed_pack_010",
        "title": "Boss Mode",
        "user_id": "user_kappa_boss",
        "likes": 3456,
        "prompts": [
            {"id": "s10_1", "caption": "On It", "prompt": "Cute clipboard character with determined focused expression, ready for action, 3D render style, isolated on white background, no text"},
            {"id": "s10_2", "caption": "Done", "prompt": "Cute checkmark character with satisfied proud expression, accomplished pose, 3D render style, isolated on white background, no text"},
            {"id": "s10_3", "caption": "Easy", "prompt": "Cute sunglasses emoji character with confident cool expression, relaxed pose, 3D render style, isolated on white background, no text"},
        ]
    },
]


def generate_seed_stickers():
    """Generate all seed stickers using AI pipeline"""
    processor = AIProcessor()
    all_packs = []
    
    for pack_idx, pack in enumerate(SEED_THEMES):
        print(f"\n{'='*50}")
        print(f"Generating Pack {pack_idx + 1}/10: {pack['title']}")
        print(f"{'='*50}")
        
        stickers = []
        for prompt_data in pack["prompts"]:
            print(f"  → Generating: {prompt_data['caption']}")
            
            try:
                # Generate sticker image
                image_url = processor.call_fal_seedream_text(prompt_data["prompt"])
                
                if image_url:
                    # Post-process with caption
                    final_url = processor.post_processor.process_sticker(
                        image_url,
                        prompt_data["caption"],
                        add_outline=True,
                        add_shadow=True
                    )
                else:
                    print(f"    ⚠ Failed, using placeholder")
                    final_url = f"https://via.placeholder.com/512?text={prompt_data['caption'].replace(' ', '+')}"
                
                stickers.append({
                    "id": prompt_data["id"],
                    "imageUrl": final_url,
                    "caption": prompt_data["caption"],
                    "type": "sticker"
                })
                print(f"    ✓ Done: {final_url[:50]}...")
                
            except Exception as e:
                print(f"    ✗ Error: {e}")
                stickers.append({
                    "id": prompt_data["id"],
                    "imageUrl": f"https://via.placeholder.com/512?text={prompt_data['caption'].replace(' ', '+')}",
                    "caption": prompt_data["caption"],
                    "type": "sticker"
                })
        
        all_packs.append({
            "id": pack["id"],
            "title": pack["title"],
            "user_id": pack["user_id"],
            "likes": pack["likes"],
            "stickers": stickers
        })
        print(f"✓ Pack {pack['title']} complete with {len(stickers)} stickers")
    
    return all_packs


def save_to_json(packs, filename="seed_stickers.json"):
    """Save generated packs to JSON file"""
    filepath = os.path.join(os.path.dirname(__file__), filename)
    with open(filepath, 'w') as f:
        json.dump(packs, f, indent=2)
    print(f"\n✅ Saved {len(packs)} packs to {filepath}")
    return filepath


if __name__ == "__main__":
    print("🚀 Meez Seed Sticker Generator")
    print("=" * 50)
    print("This will generate 30 real AI stickers (10 packs × 3 stickers)")
    print("Estimated time: 5-10 minutes")
    print("=" * 50)
    
    # Generate
    packs = generate_seed_stickers()
    
    # Save
    filepath = save_to_json(packs)
    
    print("\n" + "=" * 50)
    print("✅ GENERATION COMPLETE!")
    print(f"📁 Output: {filepath}")
    print("💡 Restart backend to load the new stickers")
    print("=" * 50)

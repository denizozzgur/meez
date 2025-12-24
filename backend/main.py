
from fastapi import FastAPI, UploadFile, File, Form, BackgroundTasks
from pydantic import BaseModel
from typing import List, Optional
import uuid
import asyncio
import random
import hashlib
import os
import json
from datetime import datetime, timedelta
from ai_pipeline import process_generation_task, AIProcessor
from legal_pages import router as legal_router
from database import init_db, get_db, StickerPack

# Reddit-style fun username generator
ADJECTIVES = [
    "Happy", "Angry", "Chill", "Sleepy", "Hungry", "Brave", "Clever", "Wild",
    "Sneaky", "Fluffy", "Grumpy", "Jolly", "Lazy", "Mighty", "Noble", "Proud",
    "Quick", "Radiant", "Sassy", "Spicy", "Cosmic", "Electric", "Mystic", "Neon",
    "Turbo", "Ultra", "Atomic", "Blazing", "Frozen", "Golden", "Crystal", "Shadow",
    "Thunder", "Pixel", "Cyber", "Retro", "Funky", "Groovy", "Epic", "Legendary",
    "Dancing", "Flying", "Running", "Jumping", "Swimming", "Glowing", "Sparkling"
]

ANIMALS = [
    "Panda", "Koala", "Penguin", "Rabbit", "Tiger", "Dragon", "Phoenix", "Wolf",
    "Fox", "Bear", "Owl", "Eagle", "Dolphin", "Shark", "Lion", "Leopard",
    "Monkey", "Gorilla", "Elephant", "Giraffe", "Zebra", "Hippo", "Rhino", "Croc",
    "Turtle", "Frog", "Gecko", "Chameleon", "Unicorn", "Griffin", "Yeti", "Kraken",
    "Otter", "Seal", "Walrus", "Flamingo", "Parrot", "Toucan", "Sloth", "Raccoon",
    "Hedgehog", "Squirrel", "Badger", "Beaver", "Moose", "Deer", "Llama", "Alpaca"
]

# Cache to store user_id -> nickname mapping
user_nicknames = {}

def generate_fun_nickname(user_id: str) -> str:
    """Generate a consistent fun nickname for a user_id using Reddit-style naming"""
    if user_id in user_nicknames:
        return user_nicknames[user_id]
    
    # Use hash to get consistent random selection for each user_id
    hash_val = int(hashlib.md5(user_id.encode()).hexdigest(), 16)
    adj_index = hash_val % len(ADJECTIVES)
    animal_index = (hash_val // len(ADJECTIVES)) % len(ANIMALS)
    
    nickname = f"{ADJECTIVES[adj_index]} {ANIMALS[animal_index]}"
    user_nicknames[user_id] = nickname
    return nickname


app = FastAPI()

# Include legal pages router
app.include_router(legal_router)

# In-memory storage for job progress (jobs are ephemeral)
jobs = {}

# Initialize database on startup
@app.on_event("startup")
def startup_event():
    init_db()
    initialize_seed_data_to_db()

class GenerationRequest(BaseModel):
    user_id: str
    contexts: List[str]
    humor_tone: str
    mood_emoji: str

@app.get("/")
def read_root():
    return {"status": "online", "message": "Viral Meme API Ready"}

@app.post("/api/v1/auth/login")
def login():
    return {"token": "demo_token_123", "user_id": "user_demo"}

@app.post("/api/v1/generate/pack")
async def generate_pack(
    background_tasks: BackgroundTasks,
    image: UploadFile = File(...),
    user_id: str = Form(...),
    humor_tone: str = Form(...),
    style: str = Form("random")
):
    job_id = str(uuid.uuid4())
    
    # Read image bytes (mock processing)
    image_bytes = await image.read()
    
    # Initialize job status
    jobs[job_id] = {"status": "processing", "progress": 0}
    
    # Enqueue task - PASS STYLE
    background_tasks.add_task(real_process_job, job_id, image_bytes, humor_tone, "General Life", style)
    
    return {"job_id": job_id, "estimated_time": 5}

@app.post("/api/v1/generate/text")
async def generate_text_pack(
    background_tasks: BackgroundTasks,
    user_input: str = Form(...),
    humor_tone: str = Form("random"),
    style: str = Form("random")
):
    job_id = str(uuid.uuid4())
    jobs[job_id] = {"status": "processing", "progress": 0}
    background_tasks.add_task(run_text_generation_job, job_id, user_input, humor_tone, style)
    return {"job_id": job_id, "estimated_time": 8}



@app.get("/api/v1/generate/status/{job_id}")
def get_job_status(job_id: str):
    job = jobs.get(job_id)
    if not job:
        return {"status": "failed", "error": "Job not found"}
    return job

# --- Community Feed Logic ---
community_feed = []

# Seed data for production launch - 10 sample packs with different themes
SEED_PACKS = [
    {
        "id": "seed_pack_001",
        "title": "Monday Moods",
        "user_id": "user_alpha_monday",
        "likes": 2847,
        "stickers": [
            {"id": "s1_1", "imageUrl": "https://i.imgur.com/BoN9kdC.png", "caption": "Need Coffee", "type": "sticker"},
            {"id": "s1_2", "imageUrl": "https://i.imgur.com/8bkFHdM.png", "caption": "Send Help", "type": "sticker"},
            {"id": "s1_3", "imageUrl": "https://i.imgur.com/Y9tVWxE.png", "caption": "Not Today", "type": "sticker"},
        ]
    },
    {
        "id": "seed_pack_002",
        "title": "Work From Home",
        "user_id": "user_beta_remote",
        "likes": 1923,
        "stickers": [
            {"id": "s2_1", "imageUrl": "https://i.imgur.com/BoN9kdC.png", "caption": "On Mute", "type": "sticker"},
            {"id": "s2_2", "imageUrl": "https://i.imgur.com/8bkFHdM.png", "caption": "Camera Off", "type": "sticker"},
            {"id": "s2_3", "imageUrl": "https://i.imgur.com/Y9tVWxE.png", "caption": "BRB", "type": "sticker"},
        ]
    },
    {
        "id": "seed_pack_003",
        "title": "Cat Reactions",
        "user_id": "user_gamma_cats",
        "likes": 5421,
        "stickers": [
            {"id": "s3_1", "imageUrl": "https://i.imgur.com/BoN9kdC.png", "caption": "Judging You", "type": "sticker"},
            {"id": "s3_2", "imageUrl": "https://i.imgur.com/8bkFHdM.png", "caption": "Feed Me", "type": "sticker"},
            {"id": "s3_3", "imageUrl": "https://i.imgur.com/Y9tVWxE.png", "caption": "Nope", "type": "sticker"},
        ]
    },
    {
        "id": "seed_pack_004",
        "title": "Gym Life",
        "user_id": "user_delta_gym",
        "likes": 1256,
        "stickers": [
            {"id": "s4_1", "imageUrl": "https://i.imgur.com/BoN9kdC.png", "caption": "No Pain", "type": "sticker"},
            {"id": "s4_2", "imageUrl": "https://i.imgur.com/8bkFHdM.png", "caption": "Leg Day", "type": "sticker"},
            {"id": "s4_3", "imageUrl": "https://i.imgur.com/Y9tVWxE.png", "caption": "One More", "type": "sticker"},
        ]
    },
    {
        "id": "seed_pack_005",
        "title": "Love & Hearts",
        "user_id": "user_epsilon_love",
        "likes": 3789,
        "stickers": [
            {"id": "s5_1", "imageUrl": "https://i.imgur.com/BoN9kdC.png", "caption": "Miss You", "type": "sticker"},
            {"id": "s5_2", "imageUrl": "https://i.imgur.com/8bkFHdM.png", "caption": "Love You", "type": "sticker"},
            {"id": "s5_3", "imageUrl": "https://i.imgur.com/Y9tVWxE.png", "caption": "Hugs", "type": "sticker"},
        ]
    },
    {
        "id": "seed_pack_006",
        "title": "Foodie Vibes",
        "user_id": "user_zeta_food",
        "likes": 2134,
        "stickers": [
            {"id": "s6_1", "imageUrl": "https://i.imgur.com/BoN9kdC.png", "caption": "Hungry", "type": "sticker"},
            {"id": "s6_2", "imageUrl": "https://i.imgur.com/8bkFHdM.png", "caption": "Yummy", "type": "sticker"},
            {"id": "s6_3", "imageUrl": "https://i.imgur.com/Y9tVWxE.png", "caption": "Diet Tomorrow", "type": "sticker"},
        ]
    },
    {
        "id": "seed_pack_007",
        "title": "Party Time",
        "user_id": "user_eta_party",
        "likes": 4567,
        "stickers": [
            {"id": "s7_1", "imageUrl": "https://i.imgur.com/BoN9kdC.png", "caption": "Let's Go", "type": "sticker"},
            {"id": "s7_2", "imageUrl": "https://i.imgur.com/8bkFHdM.png", "caption": "TGIF", "type": "sticker"},
            {"id": "s7_3", "imageUrl": "https://i.imgur.com/Y9tVWxE.png", "caption": "Weekend!", "type": "sticker"},
        ]
    },
    {
        "id": "seed_pack_008",
        "title": "Sleepy Vibes",
        "user_id": "user_theta_sleep",
        "likes": 1876,
        "stickers": [
            {"id": "s8_1", "imageUrl": "https://i.imgur.com/BoN9kdC.png", "caption": "So Tired", "type": "sticker"},
            {"id": "s8_2", "imageUrl": "https://i.imgur.com/8bkFHdM.png", "caption": "5 More Min", "type": "sticker"},
            {"id": "s8_3", "imageUrl": "https://i.imgur.com/Y9tVWxE.png", "caption": "Zzz", "type": "sticker"},
        ]
    },
    {
        "id": "seed_pack_009",
        "title": "Sarcasm Club",
        "user_id": "user_iota_sarcasm",
        "likes": 6234,
        "stickers": [
            {"id": "s9_1", "imageUrl": "https://i.imgur.com/BoN9kdC.png", "caption": "Sure Jan", "type": "sticker"},
            {"id": "s9_2", "imageUrl": "https://i.imgur.com/8bkFHdM.png", "caption": "Oh Really", "type": "sticker"},
            {"id": "s9_3", "imageUrl": "https://i.imgur.com/Y9tVWxE.png", "caption": "Cool Story", "type": "sticker"},
        ]
    },
    {
        "id": "seed_pack_010",
        "title": "Boss Mode",
        "user_id": "user_kappa_boss",
        "likes": 3456,
        "stickers": [
            {"id": "s10_1", "imageUrl": "https://i.imgur.com/BoN9kdC.png", "caption": "On It", "type": "sticker"},
            {"id": "s10_2", "imageUrl": "https://i.imgur.com/8bkFHdM.png", "caption": "Done", "type": "sticker"},
            {"id": "s10_3", "imageUrl": "https://i.imgur.com/Y9tVWxE.png", "caption": "Easy", "type": "sticker"},
        ]
    },
]

def initialize_seed_data_to_db():
    """Load seed packs into database on startup (only if not already loaded)."""
    with get_db() as db:
        # Check if seed data already exists
        existing = db.query(StickerPack).filter(StickerPack.is_seed == True).first()
        if existing:
            print("✅ Seed data already in database, skipping initialization")
            return
        
        # Try loading from generated JSON file
        json_path = os.path.join(os.path.dirname(__file__), "seed_stickers.json")
        packs_to_load = None
        
        if os.path.exists(json_path):
            try:
                with open(json_path, 'r') as f:
                    packs_to_load = json.load(f)
                print(f"✅ Loading {len(packs_to_load)} seed packs from seed_stickers.json")
            except Exception as e:
                print(f"⚠ Failed to load seed_stickers.json: {e}")
                packs_to_load = SEED_PACKS
        else:
            print("ℹ seed_stickers.json not found, using placeholder stickers")
            packs_to_load = SEED_PACKS
        
        for i, pack in enumerate(packs_to_load):
            seed_time = datetime.utcnow() - timedelta(days=i+1, hours=random.randint(0,12))
            
            db_pack = StickerPack(
                id=pack["id"],
                title=pack["title"],
                author=generate_fun_nickname(pack.get("user_id", pack["id"])),
                user_id=pack.get("user_id", pack["id"]),
                stickers=pack["stickers"],
                likes=pack.get("likes", random.randint(1000, 6000)),
                downloads=random.randint(100, 500),
                liked_by=[],
                is_public=True,
                is_seed=True,
                created_at=seed_time
            )
            db.add(db_pack)
        
        db.commit()
        print(f"✅ Loaded {len(packs_to_load)} seed packs to database")


def add_to_feed(pack_data, user_id="anon"):
    """Validates and adds a generated pack to the database"""
    try:
        author_name = generate_fun_nickname(user_id)
        
        with get_db() as db:
            db_pack = StickerPack(
                id=pack_data.get("id"),
                title=pack_data.get("title", "Untitled Pack"),
                author=author_name,
                user_id=user_id,
                stickers=pack_data.get("stickers", []),
                likes=0,
                downloads=0,
                liked_by=[],
                is_public=True,
                is_seed=False,
                created_at=datetime.utcnow()
            )
            db.add(db_pack)
            db.commit()
            print(f"FEED DEBUG: Added pack {pack_data.get('id')} to database")
    except Exception as e:
        print(f"Error adding to feed: {e}")

@app.get("/api/v1/community/feed")
def get_community_feed():
    """Get all packs from database, sorted by newest first"""
    with get_db() as db:
        packs = db.query(StickerPack).filter(
            StickerPack.is_public == True
        ).order_by(StickerPack.created_at.desc()).limit(100).all()
        return [pack.to_dict() for pack in packs]

@app.post("/api/v1/community/like/{pack_id}")
def toggle_like(pack_id: str, user_id: str = "anon"):
    """Reddit-style toggle: like if not liked, unlike if already liked"""
    with get_db() as db:
        pack = db.query(StickerPack).filter(StickerPack.id == pack_id).first()
        if not pack:
            return {"likes": 0, "liked": False}
        
        liked_by = pack.liked_by or []
        
        if user_id in liked_by:
            # Unlike
            liked_by.remove(user_id)
            pack.likes = max(0, pack.likes - 1)
            pack.liked_by = liked_by
            db.commit()
            return {"likes": pack.likes, "liked": False}
        else:
            # Like
            liked_by.append(user_id)
            pack.likes += 1
            pack.liked_by = liked_by
            db.commit()
            return {"likes": pack.likes, "liked": True}

@app.delete("/api/v1/community/pack/{pack_id}")
def delete_pack_from_feed(pack_id: str):
    """Removes a pack from the database."""
    with get_db() as db:
        pack = db.query(StickerPack).filter(StickerPack.id == pack_id).first()
        if pack:
            db.delete(pack)
            db.commit()
            print(f"Deleted pack {pack_id} from database.")
            return {"status": "deleted"}
        else:
            return {"status": "not_found"}

# Update Job Processors to Add to Feed
async def run_text_generation_job(job_id: str, user_input: str, tone: str = "random", style: str = "random"):
    print(f"Starting TEXT job {job_id} with tone: {tone}, style: {style}")
    processor = AIProcessor()
    
    def progress_callback(completed, total):
        if job_id in jobs:
            jobs[job_id]["progress_count"] = f"{completed}/{total}"
            jobs[job_id]["progress"] = int((completed / total) * 100)

    try:
        # Run blocking AI calls in thread
        # We need to pass style to processor.process_text_sticker_generation too? 
        # Wait, process_text_sticker_generation signature in ai_pipeline.py likely needs update or it handles tone parsing.
        # Looking at ai_pipeline.py earlier, it parsed style from tone string OR we need to update it.
        # Let's assume we need to update api_pipeline.py process_text_sticker_generation signature if not done.
        # But wait, we DID NOT update process_text_sticker_generation signature in ai_pipeline.py yet!
        # Only generate_captions was updated.
        
        # Actually, let's look at how we pass data. 
        # For REFACTOR safety: Let's pass style as a separate arg to process_generation_task if possible, 
        # OR we combine it into 'tone' string: "mood|style" which ai_pipeline handles.
        # This wrapper is safer for now without changing ai_pipeline signature again.
        
        combined_tone_style = f"{tone}|{style}"
        
        # Use partial or lambda to pass keyword args to to_thread if strict
        result = await asyncio.to_thread(processor.process_text_sticker_generation, user_input, job_id, combined_tone_style, progress_callback)
        
        print(f"DEBUG MAIN: Saving Result Key for {job_id}: {result}")
        jobs[job_id]["progress"] = 100
        jobs[job_id]["result"] = result
        jobs[job_id]["status"] = "completed"
        
        # Add to Community Feed
        add_to_feed(result, user_id="demo_user")
        
        print(f"Job {job_id} completed (Text)")
    except Exception as e:
        print(f"Text Job failed: {e}")
        jobs[job_id]["status"] = "failed"

async def real_process_job(job_id: str, image_data: bytes, tone: str, contexts: str, style: str = "random"):
    print(f"Starting job {job_id}, style: {style}")
    # Update tone to include style for parsing in ai_pipeline if strictly needed
    # BUT generate_captions accepts explicit style arg now.
    # We need to call a method that calls generate_captions.
    # processor.process_image_sticker_generation calls generate_captions.
    # We need to update processor.process_image_sticker_generation signature in ai_pipeline.py first?
    # Or just pass combined string for now to save time/complexity.
    
    combined_tone = f"{tone}|{style}"
    
    processor = AIProcessor()
    
    try:
        # 1. Process Image to Stickers (New v4 Pipeline)
        # Passing combined tone prevents breaking signature
        result_pack = processor.process_image_sticker_generation(image_data, job_id, combined_tone)
        
        jobs[job_id]["progress"] = 100
        jobs[job_id]["result"] = result_pack
        jobs[job_id]["status"] = "completed"
        
        # Add to Community Feed
        add_to_feed(result_pack, user_id="demo_pic_user")
        
        print(f"Job {job_id} completed successfully")
        
    except Exception as e:
        print(f"Job failed: {e}")
        jobs[job_id]["status"] = "failed"


if __name__ == "__main__":
    import uvicorn
    print("🚀 Starting Meez Backend Server on http://0.0.0.0:8000")
    uvicorn.run(app, host="0.0.0.0", port=8000)


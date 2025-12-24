
import os
import base64
import json
import time
from dotenv import load_dotenv

# Ensure we have the environment variables
load_dotenv()

class AIProcessor:
    def __init__(self):
        from sticker_templates import MASTER_STICKER_LIBRARY, get_translated_caption
        self.MASTER_LIBRARY = MASTER_STICKER_LIBRARY
        self.get_translated_caption = get_translated_caption
        
        # Import post-processor for Pillow effects
        from sticker_post_processor import StickerPostProcessor
        self.post_processor = StickerPostProcessor()
        
        # NEGATIVE PROMPT: Prevent style changes AND identity loss
        # Updated to be stricter on identity preservation
        current_neg_profile = (
            "illustration, cartoon, anime, vector, emoji, graphic styles, flat colors, "
            "outlines as illustration, simplified facial features, LINE-style, chibi, "
            "drawing, painting, 3d render, clay, plastic, artificial, sketch, "
            "completely different person, different face, face swap, identity change, "
            "unrecognizable subject, distorted features, warped face"
        )
        
        # THEMES: Each has expression-specific guidance for viral sticker creation
        # Using lower strength (0.40) for identity preservation with creative expression changes
        self.THEMES = {
            "p1_exhausted": {
                "name": "Exhausted",
                "settings": {"strength": 0.40, "guidance": 5.0},
                "prompts": [
                    {
                        "id": "p1_1", 
                        "text": "I'm dead", 
                        "prompt": "Transform this photo into a viral WhatsApp reaction sticker. Adjust the subject's expression to look exhausted: slightly droopy eyelids, relaxed brow, soft unfocused gaze, low energy posture. Keep the person 100% recognizable - same face, same identity. Photorealistic style only. Isolated on white background.",
                        "neg": current_neg_profile
                    }
                ]
            },
            "p2_confused": {
                "name": "Confused",
                "settings": {"strength": 0.40, "guidance": 5.0},
                "prompts": [
                    {
                        "id": "p2_1", 
                        "text": "Wait what?", 
                        "prompt": "Transform this photo into a viral WhatsApp reaction sticker. Adjust the subject's expression to look confused: furrowed brow, slightly squinted eyes, head tilted, lips slightly parted, questioning expression. Keep the person 100% recognizable - same face, same identity. Photorealistic style only. Isolated on white background.",
                        "neg": current_neg_profile
                    }
                ]
            },
            "p3_sideeye": {
                "name": "Side Eye",
                "settings": {"strength": 0.40, "guidance": 5.0},
                "prompts": [
                    {
                        "id": "p3_1", 
                        "text": "Be serious", 
                        "prompt": "Transform this photo into a viral WhatsApp reaction sticker. Adjust the subject's expression to give side-eye: eyes glancing sideways, one eyebrow slightly raised, pursed lips, unimpressed expression, subtle judgment. Keep the person 100% recognizable - same face, same identity. Photorealistic style only. Isolated on white background.",
                        "neg": current_neg_profile
                    }
                ]
            },
            "p4_confident": {
                "name": "Confident",
                "settings": {"strength": 0.40, "guidance": 5.0},
                "prompts": [
                    {
                        "id": "p4_1", 
                        "text": "Told you", 
                        "prompt": "Transform this photo into a viral WhatsApp reaction sticker. Adjust the subject's expression to look confident: slight smirk, chin slightly raised, relaxed confident posture, knowing look in eyes. Keep the person 100% recognizable - same face, same identity. Photorealistic style only. Isolated on white background.",
                        "neg": current_neg_profile
                    }
                ]
            },
            "p5_amused": {
                "name": "Amused",
                "settings": {"strength": 0.40, "guidance": 5.0},
                "prompts": [
                    {
                        "id": "p5_1", 
                        "text": "I can't", 
                        "prompt": "Transform this photo into a viral WhatsApp reaction sticker. Adjust the subject's expression to look amused: genuine smile, crinkled eye corners, natural laugh expression, relaxed face. Keep the person 100% recognizable - same face, same identity. Photorealistic style only. Isolated on white background.",
                        "neg": current_neg_profile
                    }
                ]
            },
            "p6_resigned": {
                "name": "Resigned",
                "settings": {"strength": 0.40, "guidance": 5.0},
                "prompts": [
                    {
                        "id": "p6_1", 
                        "text": "Of course", 
                        "prompt": "Transform this photo into a viral WhatsApp reaction sticker. Adjust the subject's expression to look resigned: slow blink expression, neutral mouth, slightly lowered gaze, calm acceptance. Keep the person 100% recognizable - same face, same identity. Photorealistic style only. Isolated on white background.",
                        "neg": current_neg_profile
                    }
                ]
            }
        }


    def pre_process_image(self, image_data):
        """
        Step 1: Detect face & Crop (Mocking this for now, relying on model's ability to focus or BE generic crop)
        Ideally, we would run a face detector here and crop to a square.
        """
        return image_data

    def generate_captions(self, emotion, user_context, tone="Relatable", style="random"):
        """
        New engine: Selects random stickers from the MASTER_STICKER_LIBRARY.
        If 'tone' (mood) is provided, it attempts to prioritize matching tags.
        If 'style' is provided, it modifies the visual descriptions to match.
        """
        import random
        
        plan = []
        
        # Parse tones/tags
        target_mood_tags = []
        clean_tone = tone if isinstance(tone, str) else str(tone)
        
        # Explicit mapping for Mood Chips
        mood_map = {
            "roast": ["roast", "mocking", "funny", "side-eye", "judgmental", "clown", "insult", "sarcastic"],
            "cool": ["cool", "slang", "confident", "chill", "w", "drip", "based", "respect"],
            "cute": ["cute", "love", "wholesome", "happy", "aww", "sweet", "excited", "friendly"],
            "work": ["tired", "exhausted", "confused", "dead", "stress", "monday", "bored", "work"],
            "random": []
        }

        # 1. Parse Mood
        if "," in clean_tone:
            # Handle multiple moods "roast,funny"
            for t in clean_tone.split(","):
                t = t.strip().lower()
                if t in mood_map:
                    target_mood_tags.extend(mood_map[t])
                else:
                     target_mood_tags.append(t)
        elif clean_tone in mood_map:
            target_mood_tags = mood_map[clean_tone]
        elif clean_tone and clean_tone != "random":
             target_mood_tags = [clean_tone.lower()]
             
        # 2. Parse Styles (Multi-select support)
        raw_style_input = style
        target_styles = [] # List of valid styles to rotate through

        # Define strong style modifiers FIRST so we can validate keys
        style_map = {
            "anime": ", anime style, Japanese animation, vibrant colors, cel shaded, studio ghibli aesthetic, 2D flat",
            "cartoon": ", western cartoon style, bold thick outlines, flat vector art, cartoon network aesthetic, expressive",
            "3d": ", 3D render, Pixar style, C4D, octane render, clay material, smooth rounded shapes, cute 3D character",
            "real": ", photorealistic, high detail, 8k resolution, raw photography, cinematic lighting, realistic texture"
        }

        # Handle "random" or empty input
        if raw_style_input == "random" or not raw_style_input:
            # Fallback check if style was embedded in tone "mood|style" (legacy)
            if "|" in clean_tone:
                parts = clean_tone.split("|")
                if len(parts) > 1:
                    raw_style_input = parts[1]
        
        # Parse potential multi-style input "Anime, 3D" -> collect ALL valid
        if raw_style_input and raw_style_input != "random":
             parts = [p.strip().lower() for p in raw_style_input.split(',')]
             for p in parts:
                 if p in style_map:
                     target_styles.append(p)
        
        # If no valid styles found (or random), leave list empty (will mean no injection or random)
        print(f"Filtering by moods: {target_mood_tags}, Parsed Styles: {target_styles}")
        
        # Filter library candidates by mood tags
        candidates = []
        
        # A. Try to find matches based on tags if provided
        if target_mood_tags:
            for item in self.MASTER_LIBRARY:
                item_tags = set(item.get("tags", []))
                # Check for overlap
                if any(t in item_tags for t in target_mood_tags):
                     candidates.append(item)
        
        # B. If candidates list is too small, fill with random non-duplicates
        if len(candidates) < 10:
            remaining = [x for x in self.MASTER_LIBRARY if x not in candidates]
            random.shuffle(remaining)
            candidates.extend(remaining)
            
        # C. Select 6 items with UNIQUE captions
        unique_candidates = []
        seen_ids = set()
        seen_captions = set()
        
        random.shuffle(candidates)
        
        for c in candidates:
            caption_lower = c["text"].lower()
            if c["id"] not in seen_ids and caption_lower not in seen_captions:
                
                # --- STYLE INJECTION LOGIC (ROUND ROBIN) ---
                item_copy = c.copy()
                original_visual = item_copy["visual"]
                
                current_assigned_style = None
                
                # If we have selected styles, pick one based on current index
                if target_styles:
                    style_index = len(unique_candidates) % len(target_styles)
                    current_assigned_style = target_styles[style_index]
                    
                    if current_assigned_style in style_map:
                         modifier = style_map[current_assigned_style]
                         
                         if current_assigned_style == "real":
                             # Ensure it says photorealistic
                             if "Photorealistic" not in original_visual:
                                 item_copy["visual"] = original_visual + modifier
                         else:
                             # For non-real styles, REMOVE "Photorealistic" constraints
                             clean_visual = original_visual.replace("Photorealistic style only.", "").replace("Photorealistic", "")
                             item_copy["visual"] = clean_visual + modifier
                
                # Store assigned style for negative prompt logic later
                item_copy["_assigned_style"] = current_assigned_style
                
                unique_candidates.append(item_copy)
                seen_ids.add(c["id"])
                seen_captions.add(caption_lower)
            
            if len(unique_candidates) >= 6:
                break
        
        selected_items = unique_candidates[:6]
        
        # D. Construct plan
        for item in selected_items:
            # Recreate default neg profile
            neg_profile = (
                "illustration, cartoon, anime, vector, emoji, graphic styles, flat colors, "
                "outlines as illustration, simplified facial features, LINE-style, chibi, "
                "drawing, painting, 3d render, clay, plastic, artificial, sketch, "
                "completely different person, different face, face swap, identity change, "
                "unrecognizable subject, distorted features, warped face"
            )
            
            # Use the specific style assigned to this sticker
            assigned_style = item.get("_assigned_style")
            
            # If style is explicitly NOT real, we should relax the negative prompt
            if assigned_style and assigned_style in ["anime", "cartoon", "3d"]:
                 # Remove style-related negatives
                 neg_profile = neg_profile.replace("illustration, cartoon, anime, vector, emoji, graphic styles, flat colors, ", "")
                 neg_profile = neg_profile.replace("drawing, painting, 3d render, clay, plastic, artificial, sketch, ", "")

            plan.append({
                "theme": assigned_style if assigned_style else "random",
                "id": item["id"],
                "visual": item["visual"],
                "text": item["text"],
                "neg": neg_profile,
                "settings": item["settings"]
            })
            
        print(f"Generated Plan with Styles '{target_styles}': {[x['id'] for x in plan]}")
        return plan

    # Method to generate a smart title using VLM
    def generate_smart_title(self, image_b64):
        import fal_client
        try:
            image_url_input = f"data:image/jpeg;base64,{image_b64}"
            print("--- Generating Smart Title ---")
            
            handler = fal_client.submit(
                "fal-ai/llava-next",
                arguments={
                    "image_url": image_url_input,
                    "prompt": "Describe the person in this image in 2-4 words for a sticker pack title. Examples: 'Girl with Blue Hair', 'Guy in Suit', 'Happy Gamer'. Return ONLY the title, nothing else.",
                    "max_tokens": 20
                },
            )
            result = handler.get()
            if result and "output" in result:
                title = result["output"].strip().strip('"').strip("'")
                print(f"Smart Title: {title}")
                return title
            return "My Cool Stickers"
        except Exception as e:
            print(f"Smart Title Error: {e}")
            return "Funny Mascot Character"

    # Method to remove background using Bria or Rembg
    def remove_background(self, image_url):
        import fal_client
        try:
            # Using Bria AI for better background removal (preserves text/details better)
            handler = fal_client.submit(
                "fal-ai/bria/background/remove",
                arguments={
                    "image_url": image_url
                },
            )
            result = handler.get()
            if result and "image" in result and "url" in result["image"]:
                return result["image"]["url"]
            return image_url
        except Exception as e:
            print(f"Rembg Error: {e}")
            return image_url

    def _get_mime_type(self, data: bytes) -> str:
        if data.startswith(b'\x89PNG\r\n\x1a\n'):
            return 'image/png'
        elif data.startswith(b'\xff\xd8'):
            return 'image/jpeg'
        return 'image/jpeg' # Default fallback

    def call_fal_flux(self, image_b64, prompt, neg_prompt, strength, guidance, mime_type="image/jpeg"):
        """
        Uses Flux Dev for true photorealism, then removes background.
        """
        import fal_client
        try:
            image_url_input = f"data:{mime_type};base64,{image_b64}"
            print(f"--- MEEZ ENGINE (FLUX): {prompt[:30]}... ---")

            handler = fal_client.submit(
                "fal-ai/flux/dev/image-to-image",
                arguments={
                    "image_url": image_url_input,
                    "prompt": prompt + ", isolated on white background, high quality",
                    "negative_prompt": neg_prompt,
                    "strength": strength, 
                    "guidance_scale": guidance,
                    "num_inference_steps": 28,
                    "seed": int(time.time() * 1000) % 4294967295 # Randomize seed for variety
                },
            )
            result = handler.get()
            raw_url = None
            if result and "images" in result and len(result["images"]) > 0:
                raw_url = result["images"][0]["url"]
            
            if raw_url:
                print("--- Removing Background (from Flux) ---")
                clean_url = self.remove_background(raw_url)
                return clean_url
            return None
        except Exception as e:
            print(f"MEEZ ENGINE ERROR (Flux): {e}")
            return None

    def call_fal_seedream(self, image_b64, prompt, neg_prompt, strength, guidance, mime_type="image/jpeg"):
        """
        Step 3: Call seedream/v4/edit AND Remove Background. 
        Kept ONLY for the cartoon/vector style.
        """
        import fal_client
        
        try:
            image_url_input = f"data:{mime_type};base64,{image_b64}"
            
            print(f"--- MEEZ ENGINE (SEEDREAM): {prompt[:30]}... [S:{strength} G:{guidance}] ---")

            # SUPER STRONG NEGATIVE PROMPT
            final_negative = neg_prompt + ", low quality, jpeg artifacts, watermark, signature"

            handler = fal_client.submit(
                "fal-ai/bytedance/seedream/v4/edit",
                arguments={
                    "image_urls": [image_url_input],
                    "prompt": prompt,
                    "negative_prompt": final_negative,
                    "strength": strength, 
                    "guidance_scale": guidance,
                    "seed": 42, 
                    "num_inference_steps": 20
                },
            )
            
            result = handler.get()
            raw_url = None
            if result and "images" in result and len(result["images"]) > 0:
                raw_url = result["images"][0]["url"]
            
            if raw_url:
                # Chain Background Removal
                print("--- Removing Background ---")
                clean_url = self.remove_background(raw_url)
                return clean_url
                
            return None
        except Exception as e:
            import traceback
            print(f"MEEZ ENGINE ERROR (Fal): {e}")
            traceback.print_exc()
            return None

    def create_sticker_assets(self, face_image_bytes, plan, language="en"):
        """
        Create sticker assets using Seedream v4/edit + Post-processing pipeline:
        1. Seedream v4/edit for expression transformation
        2. Background removal (Bria)
        3. Post-processing (white outline, shadow, caption)
        """
        import concurrent.futures
        import time
        
        assets = []
        
        # Optimize: reuse base64 encoding
        b64_image = base64.b64encode(face_image_bytes).decode('utf-8')
        mime_type = self._get_mime_type(face_image_bytes)
        
        # Helper for parallel execution with translation
        def process_sticker_item(item):
            prompt = item["visual"]
            neg = item["neg"]
            settings = item["settings"]
            english_caption = item["text"]
            
            # If language is empty, captions are disabled - use empty string
            if not language:
                caption_text = ""
                print(f"--- Processing: '{english_caption}' (captions DISABLED) ---")
            else:
                # Translate caption based on language
                caption_text = self.get_translated_caption(english_caption, language)
                print(f"--- Processing: '{english_caption}' -> '{caption_text}' (lang: {language}) ---")
            
            # Step 1: Generate with Seedream v4/edit (expression transformation)
            image_url = self.call_fal_seedream(
                b64_image, 
                prompt, 
                neg, 
                strength=settings["strength"], 
                guidance=settings["guidance"],
                mime_type=mime_type
            )
            
            if not image_url:
                print(f"Seedream failed for {caption_text}, using placeholder")
                return {
                    "id": item["id"],
                    "caption": caption_text,
                    "type": "sticker",
                    "imageUrl": "https://via.placeholder.com/512?text=Error",
                    "theme": item["theme"]
                }
            
            # Step 2: Post-process with Pillow (outline, shadow, caption)
            try:
                final_url = self.post_processor.process_sticker(
                    image_url, 
                    caption_text,
                    add_outline=True,
                    add_shadow=True
                )
            except Exception as e:
                print(f"Post-processing failed: {e}, using raw AI output")
                final_url = image_url
            
            return {
                "id": item["id"],
                "caption": caption_text,
                "type": "sticker",
                "imageUrl": final_url,
                "theme": item["theme"]
            }

        # Run concurrently
        print(f"--- Starting {len(plan)} parallel sticker generations (Seedream + Post-process) ---")
        with concurrent.futures.ThreadPoolExecutor(max_workers=6) as executor:
            future_to_item = {executor.submit(process_sticker_item, item): item for item in plan}
            for future in concurrent.futures.as_completed(future_to_item):
                try:
                    result = future.result()
                    assets.append(result)
                except Exception as exc:
                    print(f"Item generation failed: {exc}")
        
        # Sort back to original plan order if needed, or just return shuffled (it's fine)
        return assets
    
    # Legacy helper for manual text if needed, preserving just in case
    def add_text_to_image(self, img_bytes, text):
        return "data:image/png;base64,"


    def generate_text_sticker_prompts(self, user_input, tone="random", language="en"):
        from openai import OpenAI
        from datetime import datetime
        client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
        
        # Language-specific caption examples - GENUINE everyday WhatsApp expressions
        language_caption_guidance = {
            "tr": """
CAPTION LANGUAGE: TURKISH (Türkçe)
Generate captions like a Turkish person would ACTUALLY type on WhatsApp!
GENUINE Turkish WhatsApp phrases: "Yok ya", "Off ya", "Ayyy", "Ben ölüyorum", "Çok iyii", "Yaa niye", "Tamam tamam", "Şaka mı bu", "İnanamıyorum", "Dur bi", "Aa çok tatlı", "Yeter artık", "Oldu mu şimdi", "Hadi ya", "Koptum", "Bitane daha", "Yemezler", "Ne alaka", "Sus", "Çok fena", "Ama nasıl", "Bir dakika", "E tabii", "Vallaa", "Yo", "Hee"
""",
            "es": """
CAPTION LANGUAGE: SPANISH (Español)  
Generate captions like a Spanish person would ACTUALLY type on WhatsApp!
GENUINE Spanish WhatsApp phrases: "Ay no", "Jajaja qué", "Me muero", "Qué dices", "Pero cómo", "Es broma", "No me lo creo", "Eso me pasa", "Qué fuertee", "Buenoo", "Ostras tío", "No puedo", "Madre mía", "Anda ya", "Para ya", "Qué mono", "Me encanta", "Fatal", "Nada nada", "Vale vale"
""",
            "de": """
CAPTION LANGUAGE: GERMAN (Deutsch)
Generate captions like a German person would ACTUALLY type on WhatsApp!
GENUINE German WhatsApp phrases: "Nee oder", "Haha was", "Echt jetzt", "Oh nein", "Ja mann", "Krass ey", "Wie süß", "Alter nein", "Digga was", "Ich kann nicht", "So true", "Muss los", "Warte kurz", "Läuft", "Klar", "Keine Ahnung", "Na toll", "Okaay", "Mhmm", "Joa"
""",
            "fr": """
CAPTION LANGUAGE: FRENCH (Français)
Generate captions like a French person would ACTUALLY type on WhatsApp!
GENUINE French WhatsApp phrases: "Mdrrr quoi", "Mais non", "Trop mignon", "Jsuis mort", "C'est ouf", "Attends quoi", "Ah non", "Genre", "Grave", "Trop bien", "Sah quel", "J'avoue", "Mais pourquoi", "Oklm", "Tranquille", "La flemme", "Chelou", "C'est çaaa", "Pas mal", "Wsh"
""",
            "en": """
CAPTION LANGUAGE: ENGLISH
Generate captions like someone would ACTUALLY type on WhatsApp!
GENUINE English WhatsApp phrases: "Lmaoo what", "I can't", "So me", "Wait no", "Stoppp", "Help", "This is me", "Same tbh", "Literally me", "Not me doing this", "The accuracy", "Why tho", "Send help", "Mood", "Facts", "No way", "Crying rn", "Pls", "Bruh", "Okay but"
"""
        }
        
        caption_guidance = language_caption_guidance.get(language, language_caption_guidance["en"])
        
        # Parse mood|style format
        mood_part = "random"
        style_part = "random"
        
        if tone and "|" in tone:
            parts = tone.split("|")
            mood_part = parts[0] if len(parts) > 0 else "random"
            style_part = parts[1] if len(parts) > 1 else "random"
        elif tone:
            mood_part = tone
        
        # Style mappings for visual description
        style_descriptions = {
            "anime": "Japanese anime style, big expressive eyes, vibrant colors, anime shading, manga aesthetic",
            "cartoon": "Western cartoon style, bold outlines, exaggerated features, Cartoon Network aesthetic, flat colors",
            "3d": "3D rendered Pixar/Disney style, soft lighting, smooth surfaces, cute 3D character, high fidelity render",
            "real": "Photorealistic style, detailed textures, natural lighting, hyper-realistic, 8k resolution",
            "sticker": "Classic die-cut sticker art, bold white border, vector art style, clean lines, flat shading",
            "pixel": "Retro 8-bit pixel art style, arcade aesthetic, blocky, nostalgic game asset",
            "handdrawn": "Hand-drawn sketch style, doodle aesthetic, pencil or marker texture, casual and messy",
            "clay": "Claymation style, plasticine texture, stop-motion look, rounded soft edges, handmade feel",
            "painting": "Oil painting style, visible brush strokes, artistic texture, rich colors, expressive",
            "realistic": "Photorealistic style, detailed textures, natural lighting, hyper-realistic, 8k resolution"
        }
        
        # Get style description (default to mixed if random)
        if style_part == "random" or style_part not in style_descriptions:
            style_desc = "3D render or illustrated cartoon style, cute and expressive, high quality sticker"
        else:
            style_desc = style_descriptions.get(style_part, "3D render style")
        
        # Mood guidance
        mood_guidance = ""
        if mood_part != "random":
            moods = mood_part.split(",")
            guidance_parts = []
            
            if "roast" in moods or "sarcastic" in moods:
                guidance_parts.append("Tone: Sarcastic/Roast - Use slang like 'Skill Issue', 'Clown', 'Side Eye'. Emotions: Judgmental, Mocking, Unimpressed.")
            if "funny" in moods:
                 guidance_parts.append("Tone: Funny/Comedy - Use memes, 'Lol', 'Lmao', 'Bruh'. Emotions: Laughing, Silly, Trolling.")
            if "happy" in moods or "excited" in moods:
                guidance_parts.append("Tone: Happy/Excited - Use 'Lets Gooo', 'W', 'Hype'. Emotions: Joyful, Cheerful, Energetic, Starry-eyed.")
            if "cute" in moods or "romantic" in moods:
                guidance_parts.append("Tone: Cute/Love - Use 'Aww', 'Love u', 'Baby'. Emotions: Wholesome, Adorable, Blushing, Hearts.")
            if "cool" in moods or "chill" in moods:
                guidance_parts.append("Tone: Cool/Chill - Use 'Based', 'Bet', 'Vibe'. Emotions: Confident, Relaxed, Sunglasses, Smooth.")
            if "angry" in moods:
                 guidance_parts.append("Tone: Angry/Rage - Use 'Bruh', 'Why', 'Stop'. Emotions: Furious, Fire, Red face, Screaming.")
            if "sad" in moods:
                 guidance_parts.append("Tone: Sad/Crying - Use 'Pain', 'Rip', 'Crying'. Emotions: Teary, Depressed, Rain, Broken heart.")
            if "work" in moods:
                guidance_parts.append("Tone: Work/Tired - Use 'Dead', 'Monday', 'Exhausted'. Emotions: Melting, Bags under eyes, Coffee needed.")
            
            mood_guidance = " ".join(guidance_parts)
        else:
            mood_guidance = "Mix of emotions - some happy, some tired, some side-eye. Use Gen-Z slang variety."
        
        # Get current date for context
        current_year = datetime.now().year
        next_year = current_year + 1
        
        system_prompt = f"""You are a viral WhatsApp sticker caption expert.

CURRENT DATE: December {current_year}. We are entering {next_year}.

USER'S TOPIC: "{user_input}"

Generate 6 sticker prompts that show THE ACTUAL "{user_input}" - NOT humans/people.

CRITICAL RULES:
1. If user says "dog" → show an ACTUAL DOG, not a person
2. If user says "cat" → show an ACTUAL CAT, not a person  
3. If user says "coffee" → show coffee/cup, not a barista
4. ONLY show humans if user specifically asks for "person" or "human"
5. If mentioning years, use {next_year}
6. EACH STICKER MUST HAVE A UNIQUE CAPTION - NO DUPLICATES

VISUAL STYLE:
{style_desc}
White/transparent background, no text overlays on image.

{mood_guidance}

{caption_guidance}

🔥 CAPTION RULES (SUPER IMPORTANT):
- MAXIMUM 3 WORDS
- NO emojis in caption
- Captions must be REACTIONS/EXPRESSIONS in the specified language
- Use NATIVE slang, NOT literal translations
- NOT descriptive labels like "Shopping", "Working", "Eating"

GOOD CAPTION EXAMPLES:
- For shopping dog: "Take my money", "Broke but happy", "Retail therapy"
- For tired dog: "I'm dead", "Send help", "Monday mood"
- For excited dog: "LET'S GOOO", "Finally!", "Yaaaas"
- For confused dog: "Wait what", "Huh??", "Make it make sense"

BAD CAPTIONS (TOO GENERIC - AVOID):
- "Shopping", "Working", "Sleeping", "Eating", "Running" (just activity labels)
- "Dog", "Happy dog", "Cute puppy" (just descriptions)

Generate 6 stickers showing "{user_input}" with different emotions:

OUTPUT (JSON only):
{{
  "subject": "{user_input}",
  "prompts": [
    {{ "id": 1, "caption": "<reaction phrase>", "prompt": "<visual about {user_input} in {style_desc}>" }},
    {{ "id": 2, "caption": "<reaction phrase>", "prompt": "<visual about {user_input} in {style_desc}>" }},
    {{ "id": 3, "caption": "<reaction phrase>", "prompt": "<visual about {user_input} in {style_desc}>" }},
    {{ "id": 4, "caption": "<reaction phrase>", "prompt": "<visual about {user_input} in {style_desc}>" }},
    {{ "id": 5, "caption": "<reaction phrase>", "prompt": "<visual about {user_input} in {style_desc}>" }},
    {{ "id": 6, "caption": "<reaction phrase>", "prompt": "<visual about {user_input} in {style_desc}>" }}
  ]
}}
"""

        try:
            print(f"Generating Prompts for: {user_input}")
            completion = client.chat.completions.create(
                model="gpt-3.5-turbo-0125",
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": f"Generate prompts for: {user_input}"}
                ],
                response_format={"type": "json_object"}
            )
            content = completion.choices[0].message.content
            # Clean potential markdown
            content = content.replace("```json", "").replace("```", "").strip()
            return json.loads(content)
        except Exception as e:
            print(f"OpenAI Error: {e}")
            # Fallback - topic-focused cute illustrated stickers
            return {
                "subject": user_input,
                "prompts": [
                    {"id": 1, "caption": "let's goooo", "prompt": f"Cute excited {user_input} themed mascot character celebrating, happy joyful expression, 3D render style, isolated on pure white background, no text"},
                    {"id": 2, "caption": "pls no", "prompt": f"Cute overwhelmed {user_input} themed mascot character, tired exhausted expression, illustrated style, isolated on pure white background, no text"},
                    {"id": 3, "caption": "wait what", "prompt": f"Cute confused {user_input} themed mascot character, shocked bewildered expression, illustrated style, isolated on pure white background, no text"},
                    {"id": 4, "caption": "slay", "prompt": f"Cute confident {user_input} themed mascot character, proud flex pose, 3D render style, isolated on pure white background, no text"},
                    {"id": 5, "caption": "I can't", "prompt": f"Cute laughing {user_input} themed mascot character, chaotic amused energy, illustrated style, isolated on pure white background, no text"},
                    {"id": 6, "caption": "it's fine", "prompt": f"Cute resigned {user_input} themed mascot character, calm acceptance expression, illustrated style, isolated on pure white background, no text"}
                ]
            }


    def call_fal_seedream_text(self, prompt):
        import fal_client
        import random
        try:
            # Random seed for variety
            seed = random.randint(1, 999999)
            print(f"--- SEEDREAM TEXT: {prompt[:50]}... (seed={seed}) ---")
            handler = fal_client.submit(
                "fal-ai/bytedance/seedream/v4/text-to-image",
                arguments={
                    "prompt": prompt,
                    "negative_prompt": "human, person, people, man, woman, girl, boy, face, portrait, realistic human, photograph of person, low quality, blurry, watermark, signature, bad anatomy, cropped, cut off, text",
                    "image_size": "square_hd",
                    "seed": seed,
                    "num_inference_steps": 20,
                    "guidance_scale": 9.0
                },
            )
            result = handler.get()
            if result and "images" in result and len(result["images"]) > 0:
                img_url = result["images"][0]["url"]
                print("--- Removing Background (Seedream) ---")
                return self.remove_background(img_url)
            return None
        except Exception as e:
            print(f"Fal Seedream Text Error: {e}")
            return None

    def process_text_sticker_generation(self, user_input, job_id, tone="random", progress_callback=None):
        """
        Text-to-Sticker Pipeline:
        1. Generate Seedream image (no text in prompt)
        2. Remove background
        3. Post-process with Pillow (outline, shadow, caption)
        """
        import concurrent.futures

        assets = []
        completed_count = 0
        
        # Parse tone|style|language from combined string
        parts = tone.split("|") if isinstance(tone, str) else ["random", "random", "en"]
        actual_tone = parts[0] if len(parts) > 0 else "random"
        style = parts[1] if len(parts) > 1 else "random"
        language = parts[2] if len(parts) > 2 else "en"
        
        print(f"Text generation - tone: {actual_tone}, style: {style}, language: {language}")
        
        # Helper for execution - with post-processing
        def process_text_item(item):
            prompt_text = item["prompt"]
            native_caption = item.get("caption", "")
            
            # If language is empty, captions are disabled - use empty string
            if not language:
                caption = ""
                print(f"--- Processing text sticker (captions DISABLED) ---")
            else:
                # Caption is already in NATIVE language (generated by AI or from native_generic_captions)
                caption = native_caption
                print(f"--- Processing: '{caption}' (native {language}) ---")
            
            # Step 1: Generate image with Seedream (NO text in prompt)
            image_url = self.call_fal_seedream_text(prompt_text)
            
            if not image_url:
                print(f"Seedream failed for '{caption}', using placeholder")
                return {
                    "id": str(item["id"]),
                    "caption": caption,
                    "type": "sticker",
                    "imageUrl": "https://via.placeholder.com/512?text=Error",
                    "theme": "custom"
                }
            
            # Step 2: Post-process with Pillow (outline, shadow, caption)
            try:
                final_url = self.post_processor.process_sticker(
                    image_url, 
                    caption,
                    add_outline=True,
                    add_shadow=True
                )
            except Exception as e:
                print(f"Post-processing failed: {e}, using raw image")
                final_url = image_url
            
            return {
                "id": str(item["id"]),
                "caption": caption,
                "type": "sticker",
                "imageUrl": final_url,
                "theme": "custom"
            }

        # Native generic captions per language
        native_generic_captions = {
            "tr": [("Haydiii", "gen_1"), ("Yapamam", "gen_2")],
            "es": [("Vamoos", "gen_1"), ("No puedo", "gen_2")],
            "de": [("Los gehts", "gen_1"), ("Kein Bock", "gen_2")],
            "fr": [("C'est parti", "gen_1"), ("La flemme", "gen_2")],
            "en": [("Let's goooo", "gen_1"), ("Pls no", "gen_2")],
        }
        
        lang_captions = native_generic_captions.get(language, native_generic_captions["en"])
        
        # Generic prompts - topic-focused, cute illustrated style with NATIVE captions
        generic_prompts = [
            {
                "id": lang_captions[0][1], 
                "caption": lang_captions[0][0], 
                "prompt": f"Cute excited {user_input} themed character or mascot, happy celebration pose, 3D render style, expressive, isolated on pure white background, no text"
            },
            {
                "id": lang_captions[1][1], 
                "caption": lang_captions[1][0], 
                "prompt": f"Cute overwhelmed {user_input} themed character or mascot, tired exhausted expression, illustrated style, isolated on pure white background, no text"
            }
        ]
        
        # Use one executor for both phases
        executor = concurrent.futures.ThreadPoolExecutor(max_workers=6)
        future_optimistic = {executor.submit(process_text_item, item): item for item in generic_prompts}

        # Parallel: Call OpenAI for smart prompts with NATIVE language captions
        plan = self.generate_text_sticker_prompts(user_input, tone, language)
        smart_prompts = plan.get("prompts", [])[:4]  # Take top 4 to make total 6
        
        # Fix IDs for smart prompts
        for idx, p in enumerate(smart_prompts):
            p["id"] = f"smart_{idx}"
            
        print(f"--- Launching {len(smart_prompts)} Smart Jobs ---")
        future_smart = {executor.submit(process_text_item, item): item for item in smart_prompts}
        
        # Collect Results
        all_futures = {**future_optimistic, **future_smart}
        total_tasks = len(all_futures)
        
        for future in concurrent.futures.as_completed(all_futures):
            try:
                result = future.result()
                assets.append(result)
            except Exception as exc:
                print(f"Text item generation failed: {exc}")
            
            completed_count += 1
            if progress_callback:
                try:
                    progress_callback(completed_count, total_tasks)
                except:
                    pass

        executor.shutdown()

        return {
            "id": job_id,
            "title": plan.get("subject", user_input).title(),
            "stickers": assets
        }

    
    def process_image_sticker_generation(self, image_bytes, job_id, tone="funny"):
        import concurrent.futures

        # Parse tone|style|language from combined string
        parts = tone.split("|") if isinstance(tone, str) else ["funny", "random", "en"]
        actual_tone = parts[0] if len(parts) > 0 else "funny"
        style = parts[1] if len(parts) > 1 else "random"
        language = parts[2] if len(parts) > 2 else "en"
        
        print(f"Image generation - tone: {actual_tone}, style: {style}, language: {language}")

        # 1. Setup Base64
        b64_image = base64.b64encode(image_bytes).decode('utf-8')
        print(f"--- STARTING PARALLEL IMAGE PIPELINE for {job_id} ---")
        
        # 2. Define Tasks
        def task_smart_title():
            try:
                return self.generate_smart_title(b64_image)
            except:
                return "New Sticker Pack"

        def task_sticker_gen():
            # Plan - use actual_tone (without style/language)
            plan = self.generate_captions(emotion=None, user_context=None, tone=f"{actual_tone}|{style}")
            # Execute with language
            return self.create_sticker_assets(image_bytes, plan, language)

        # 3. Parallel Execution
        assets_result = []
        title_result = "New Sticker Pack"
        
        with concurrent.futures.ThreadPoolExecutor(max_workers=2) as executor:
            future_title = executor.submit(task_smart_title)
            future_stickers = executor.submit(task_sticker_gen)
            
            # Wait for both
            try:
                title_result = future_title.result()
            except Exception as e:
                print(f"Title Gen Error: {e}")
                
            try:
                assets_result = future_stickers.result()
            except Exception as e:
                print(f"Sticker Gen Error: {e}")

        # 4. Combine
        title = title_result if title_result else "New Sticker Pack"
        
        return {
            "id": job_id,
            "title": title.title(),
            "stickers": assets_result
        }

def process_generation_task(task_id, image_data, preferences):
    pass



"""
Master Sticker Library for Meez
Contains 100+ Gen-Z / WhatsApp style sticker templates for randomization.
"""

# Common negative prompt for identity preservation
NEG_PROFILE = (
    "illustration, cartoon, anime, vector, emoji, graphic styles, flat colors, "
    "outlines as illustration, simplified facial features, LINE-style, chibi, "
    "drawing, painting, 3d render, clay, plastic, artificial, sketch, "
    "completely different person, different face, face swap, identity change, "
    "unrecognizable subject, distorted features, warped face"
)

# Theme settings
DEFAULT_SETTINGS = {"strength": 0.40, "guidance": 5.0}

MASTER_STICKER_LIBRARY = [
    # ---------------------------------------------------------
    # EMOTIONS / REACTIONS (40 items)
    # ---------------------------------------------------------
    {
        "id": "react_001",
        "text": "I'm dead",
        "visual": "Transform this photo into a viral WhatsApp reaction sticker. Adjust the subject's expression to look exhausted: slightly droopy eyelids, relaxed brow, soft unfocused gaze, low energy posture. Keep the person 100% recognizable - same face, same identity. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["tired", "funny", "exhausted"]
    },
    {
        "id": "react_002",
        "text": "Wait what?",
        "visual": "Transform this photo into a viral WhatsApp reaction sticker. Adjust the subject's expression to look confused: furrowed brow, slightly squinted eyes, head tilted, lips slightly parted, questioning expression. Keep the person 100% recognizable. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["confused", "question", "surprised"]
    },
    {
        "id": "react_003",
        "text": "Be serious",
        "visual": "Transform this photo into a viral WhatsApp reaction sticker. Adjust the subject's expression to give side-eye: eyes glancing sideways, one eyebrow slightly raised, pursed lips, unimpressed expression, subtle judgment. Keep the person 100% recognizable. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["sideeye", "judgmental", "serious"]
    },
    {
        "id": "react_004",
        "text": "Told you",
        "visual": "Transform this photo into a viral WhatsApp reaction sticker. Adjust the subject's expression to look confident: slight smirk, chin slightly raised, relaxed confident posture, knowing look in eyes. Keep the person 100% recognizable. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["confident", "happy", "smug"]
    },
    {
        "id": "react_005",
        "text": "I can't",
        "visual": "Transform this photo into a viral WhatsApp reaction sticker. Adjust the subject's expression to look amused: genuine smile, crinkled eye corners, natural laugh expression, relaxed face. Keep the person 100% recognizable. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["funny", "happy", "laughing"]
    },
    {
        "id": "react_006",
        "text": "Of course",
        "visual": "Transform this photo into a viral WhatsApp reaction sticker. Adjust the subject's expression to look resigned: slow blink expression, neutral mouth, slightly lowered gaze, calm acceptance. Keep the person 100% recognizable. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["tired", "resigned", "done"]
    },
    {
        "id": "react_007",
        "text": "Slay",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject showing sass and confidence, hand on hip or snapping fingers gesture, fierce expression. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["confident", "slang", "happy"]
    },
    {
        "id": "react_008",
        "text": "Bet",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject giving a confident nod or thumbs up, determined expression, ready for action. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["slang", "agree", "confident"]
    },
    {
        "id": "react_009",
        "text": "Cap",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject looking skeptical, one eyebrow raised high, doubting expression, hand potentially near chin. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["slang", "doubt", "sideeye"]
    },
    {
        "id": "react_010",
        "text": "No cap",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject looking very serious and honest, hands open or hand on heart, sincere expression. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["slang", "serious", "honest"]
    },
    {
        "id": "react_011",
        "text": "Side eye",
        "visual": "Transform this photo into a viral WhatsApp sticker. Extreme side eye glance, suspicious expression, lips pressed together, judgment. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["sideeye", "judgmental", "suspicious"]
    },
    {
        "id": "react_012",
        "text": "Cringe",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject wincing or grimacing, teeth clenched, looking away as if seeing something awkward. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["negative", "awkward", "disgust"]
    },
    {
        "id": "react_013",
        "text": "Real",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject pointing at camera or nodding solemnly, deep agreement expression. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["slang", "agree", "serious"]
    },
    {
        "id": "react_014",
        "text": "Hype",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject looking incredibly excited, mouth open shouting yay, arms raised or pumping fist. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["happy", "excited", "party"]
    },
    {
        "id": "react_015",
        "text": "Clown",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject making a silly face, perhaps sticking tongue out slightly or crossing eyes, self-deprecating humor. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["funny", "silly", "clown"]
    },
    {
        "id": "react_016",
        "text": "Ghosted",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject fading or looking transparent/shocked, holding a phone, looking at screen with disbelief. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["sad", "shocked", "dating"]
    },
    {
        "id": "react_017",
        "text": "Rizz",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject giving a charming wink, finger gun gesture, smooth confident smile. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["slang", "flirty", "confident"]
    },
    {
        "id": "react_018",
        "text": "POV",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject looking extremely close to the camera (fisheye effect style), big nose perspective, funny intense stare. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["slang", "funny", "meme"]
    },
    {
        "id": "react_019",
        "text": "Main Character",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject posing dramatically with wind in hair look, spotlight effect on face, glowing ambition. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["slang", "confident", "star"]
    },
    {
        "id": "react_020",
        "text": "NPC",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject standing stiffly, blank expression, staring forward void of thought, idle animation pose. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["slang", "funny", "robot"]
    },
    {
        "id": "react_021",
        "text": "It's giving",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject striking a specific pose, analyzing something with hand on chin, judging the vibe. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["slang", "judgmental", "thinking"]
    },
    {
        "id": "react_022",
        "text": "Period",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject emphasizing a point with hand gesture (clap or point down), decisive final expression. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["slang", "serious", "final"]
    },
    {
        "id": "react_023",
        "text": "Mood",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject replicating a relatable vibe (e.g., staring into distance, or lying head on desk), deeply relatable expression. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["slang", "relatable", "tired"]
    },
    {
        "id": "react_024",
        "text": "Sus",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject squinting eyes suspiciously, looking sideways, chin tucked in, untrusting. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["slang", "suspicious", "amongus"]
    },
    {
        "id": "react_025",
        "text": "L",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject holding fingers in L shape on forehead or looking defeated/sad, loser vibe. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["slang", "sad", "lose"]
    },
    {
        "id": "react_026",
        "text": "W",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject holding up W sign with hands, champion pose, big winning smile. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["slang", "happy", "win"]
    },
    {
        "id": "react_027",
        "text": "Ratio",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject holding up a chart or doing a calculating gesture, smug intellectual look. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["slang", "argument", "smug"]
    },
    {
        "id": "react_028",
        "text": "Touch grass",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject pointing outside or holding a leaf, look of concern/disgust for someone online too much. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["slang", "insult", "funny"]
    },
    {
        "id": "react_029",
        "text": "Let him cook",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject making a 'wait' gesture with hand, watching intently with respect/anticipation. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["slang", "wait", "anticipation"]
    },
    {
        "id": "react_030",
        "text": "Skill issue",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject shrugging shoulders, mocking smile, dismissive hand wave. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["slang", "mocking", "funny"]
    },
    {
        "id": "react_031",
        "text": "Based",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject giving a firm handshake or salute, expression of utmost respect and agreement. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["slang", "respect", "agree"]
    },
    {
        "id": "react_032",
        "text": "Down bad",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject looking incredibly desperate or thirsty, pleading eyes, hands together begging. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["slang", "desperate", "simping"]
    },
    {
        "id": "react_033",
        "text": "Rent free",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject tapping temple/head, looking annoyed or obsessed, thinking hard. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["slang", "thinking", "obsessed"]
    },
    {
        "id": "react_034",
        "text": "Ick",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject recoiling in disgust, nose wrinkled, hands up to block view, repulsed expression. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["slang", "disgust", "negative"]
    },
    {
        "id": "react_035",
        "text": "Delulu",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject looking dreamy and detached from reality, staring at stars/ceiling, spiral eyes effect optional. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["slang", "crazy", "dreamy"]
    },
    {
        "id": "react_036",
        "text": "Gatekeep",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject holding arms crossed in 'stop' motion, secretive expression, refusing to share. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["slang", "secret", "stop"]
    },
    {
        "id": "react_037",
        "text": "Gaslight",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject holding a flame or lighter (metaphorical), looking innocent and manipulative, fake smile. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["slang", "toxic", "manipulative"]
    },
    {
        "id": "react_038",
        "text": "Girlboss",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject in power suit pose, arms crossed, confident leader stare, conquering the world vibe. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["slang", "confident", "work"]
    },
    {
        "id": "react_039",
        "text": "Sip tea",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject holding a teacup, sipping dramatically while looking sideways, enjoying drama. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["slang", "drama", "gossip"]
    },
    {
        "id": "react_040",
        "text": "Side quest",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject looking confused and wandering off direction, holding a map or looking at phone map, distracted. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["slang", "confused", "distracted"]
    },

    # ---------------------------------------------------------
    # ACTIVITIES / SITUATIONS (30 items)
    # ---------------------------------------------------------
    {
        "id": "act_001",
        "text": "Working hard?",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject sleeping at a desk or looking incredibly bored at work/computer, slack jaw. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["work", "tired", "lazy"]
    },
    {
        "id": "act_002",
        "text": "Gym rat",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject flexing biceps excessively, straining face, sweatband on head, gym vibe. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["gym", "flex", "strong"]
    },
    {
        "id": "act_003",
        "text": "Gamer moment",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject wearing headset, intense focus on invisible screen, rage quit shout expression. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["gaming", "rage", "focus"]
    },
    {
        "id": "act_004",
        "text": "Food coma",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject rubbing belly, looking full and sleepy, satisfied expression, perhaps holding a fork. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["food", "full", "sleepy"]
    },
    {
        "id": "act_005",
        "text": "Late again",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject looking at wrist watch in panic, running motion blur, stressed expression. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["time", "panic", "late"]
    },
    {
        "id": "act_006",
        "text": "Broke",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject pulling out empty pockets, sad pouting face, moth flying out metaphor. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["money", "sad", "poor"]
    },
    {
        "id": "act_007",
        "text": "Rich flex",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject fanning self with money (or paper), sunglasses on, looking expensive and boujee. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["money", "rich", "cool"]
    },
    {
        "id": "act_008",
        "text": "Studying",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject surrounded by books, pulling hair out in stress, wide eyed panic, coffee cup nearby. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["school", "stress", "study"]
    },
    {
        "id": "act_009",
        "text": "Driving",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject holding imaginary steering wheel, road rage shouting expression or cool cruising vibe. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["car", "travel", "angry"]
    },
    {
        "id": "act_010",
        "text": "Shopping",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject holding many shopping bags, big smile, walking strut, retail therapy. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["shop", "happy", "money"]
    },
    {
        "id": "act_011",
        "text": "Cleaning",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject holding a broom or spray bottle, looking determined or disgusted by mess, maid outfit vibe optional. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["chores", "clean", "work"]
    },
    {
        "id": "act_012",
        "text": "Cooking",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject wearing chef hat, kissing fingers like an Italian chef, perfect taste expression. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["cook", "food", "chef"]
    },
    {
        "id": "act_013",
        "text": "Party",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject wearing party hat, blowing a noisemaker, confetti falling around, celebrating. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["celebrate", "party", "happy"]
    },
    {
        "id": "act_014",
        "text": "Sick",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject with thermometer in mouth, wrapped in blanket, looking miserable and green. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["sick", "sad", "health"]
    },
    {
        "id": "act_015",
        "text": "Vacation",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject wearing tropical shirt/lei, holding coconut drink, relaxed paradise expression. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["travel", "relax", "happy"]
    },
    {
        "id": "act_016",
        "text": "Monday",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject faceplanting on desk or pillow, zombie-like expression, hating life. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["tired", "sad", "work"]
    },
    {
        "id": "act_017",
        "text": "Friday",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject sliding on knees or jumping, pure freedom and joy expression, weekend vibes. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["happy", "excited", "weekend"]
    },
    {
        "id": "act_018",
        "text": "Coffee",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject clutching a giant coffee cup, wide wired eyes, vibrating energy. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["energy", "drink", "morning"]
    },
    {
        "id": "act_019",
        "text": "Vibing",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject with headphones on, eyes closed, bobbing head to music, peaceful flow state. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["music", "chill", "happy"]
    },
    {
        "id": "act_020",
        "text": "Selfie",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject holding phone high for a selfie, doing a duck face or peace sign pose. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["photo", "vain", "happy"]
    },
    {
        "id": "act_021",
        "text": "Texting",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject typing furiously on phone, intense focus or laughing at screen. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["phone", "busy", "funny"]
    },
    {
        "id": "act_022",
        "text": "Waiting",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject looking at watch, tapping foot impatiently, skeleton waiting vibe. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["bored", "impatient", "time"]
    },
    {
        "id": "act_023",
        "text": "Cold",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject shivering, wrapped in many layers/scarves, blue tint, freezing. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["weather", "uncomfortable", "winter"]
    },
    {
        "id": "act_024",
        "text": "Hot",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject sweating profusely, fanning self, melting posture, red tint, heatwave. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["weather", "uncomfortable", "summer"]
    },
    {
        "id": "act_025",
        "text": "Shower thoughts",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject with towel on head, looking philosophical and deep in thought, epiphany face. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["thinking", "confused", "clean"]
    },
    {
        "id": "act_026",
        "text": "Binge watch",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject staring at screen/TV with popcorn, dark circles under eyes, addicted look. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["lazy", "movie", "tired"]
    },
    {
        "id": "act_027",
        "text": "Online shopping",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject looking guilty but happy at laptop, credit card in hand, impulse buy face. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["shop", "guilty", "happy"]
    },
    {
        "id": "act_028",
        "text": "Debugging",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject staring at computer/code, pulling hair, matrix code reflection, confused technical look. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["tech", "confused", "work"]
    },
    {
        "id": "act_029",
        "text": "Deadline",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject buried under papers or calendars, screaming in terror, clock ticking. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["stress", "work", "panic"]
    },
    {
        "id": "act_030",
        "text": "Payday",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject eyes turning into dollar signs, big grin, holding check/money, wealthy feeling. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["money", "happy", "rich"]
    },

    # ---------------------------------------------------------
    # ABSTRACT / MEME VIBES (30 items)
    # ---------------------------------------------------------
    {
        "id": "meme_001",
        "text": "This is fine",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject sitting calmly while background suggests chaos/fire (implied), smiling through pain. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["meme", "funny", "denial"]
    },
    {
        "id": "meme_002",
        "text": "Brain big",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject tapping large forehead, looking genius, calculating physics, galaxy brain vibe. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["smart", "meme", "thinking"]
    },
    {
        "id": "meme_003",
        "text": "Smooth brain",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject looking completely blank, no thoughts behind eyes, drooling slightly, dumb moment. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["dumb", "meme", "funny"]
    },
    {
        "id": "meme_004",
        "text": "Stonks",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject standing next to upward trend arrow, wearing suit, confident business look. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["money", "meme", "success"]
    },
    {
        "id": "meme_005",
        "text": "Not stonks",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject looking at downward trend arrow, panicked business look, financial ruin. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["money", "meme", "fail"]
    },
    {
        "id": "meme_006",
        "text": "Aliens",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject holding hands up explaining conspiracy theory, wild hair, intense crazy look. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["crazy", "meme", "explain"]
    },
    {
        "id": "meme_007",
        "text": "Shut up and take my money",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject thrusting handful of cash forward, eager expression, wanting to buy. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["money", "meme", "excited"]
    },
    {
        "id": "meme_008",
        "text": "Y tho",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject holding hands out in 'why' gesture, pained confused face, texture of vintage meme. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["question", "meme", "confused"]
    },
    {
        "id": "meme_009",
        "text": "Distracted boyfriend",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject looking back over shoulder at something attractive, whistling, unfaithful look. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["meme", "funny", "dating"]
    },
    {
        "id": "meme_010",
        "text": "Change my mind",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject sitting at a table with a mug, smug confident expression, ready to debate. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["debate", "meme", "smug"]
    },
    {
        "id": "meme_011",
        "text": "Success kid",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject making a determined fist pump, lips pressed tight, victory expression. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["success", "meme", "win"]
    },
    {
        "id": "meme_012",
        "text": "Disaster girl",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject smiling creepily at camera while looking back (implied fire behind), chaotic evil vibe. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["evil", "meme", "funny"]
    },
    {
        "id": "meme_013",
        "text": "Mocking spongebob",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject doing the mocking chicken pose, face distorted, silly mocking expression. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["mocking", "meme", "funny"]
    },
    {
        "id": "meme_014",
        "text": "Thinking guy",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject tapping temple knowingly, giving smart advice, clever expression. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["smart", "meme", "advice"]
    },
    {
        "id": "meme_015",
        "text": "Two buttons",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject sweating nervously looking between two choices (left and right), indecisive panic. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["panic", "meme", "choice"]
    },
    {
        "id": "meme_016",
        "text": "Drake no",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject holding hand up to block/reject something, looking away with disgust. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["no", "meme", "reject"]
    },
    {
        "id": "meme_017",
        "text": "Drake yes",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject pointing finger with approval, smiling warmly, nodding yes. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["yes", "meme", "approve"]
    },
    {
        "id": "meme_018",
        "text": "Expanding brain",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject looking enlightened, eyes glowing (implied), ascending to higher plane of thought. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["smart", "meme", "wow"]
    },
    {
        "id": "meme_019",
        "text": "Is this a pigeon",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject gesturing to a butterfly (implied) or nothing, looking confused and innocent. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["confused", "meme", "anime"]
    },
    {
        "id": "meme_020",
        "text": "Woman yelling at cat",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject screaming and pointing finger accusingly, emotional outburst, crying. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["angry", "meme", "yell"]
    },
    {
        "id": "meme_021",
        "text": "Surprised Pikachu",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject with mouth open in O shape, shocked expression, stunned disbelief. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["shocked", "meme", "surprise"]
    },
    {
        "id": "meme_022",
        "text": "Kermit sipping tea",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject engaging in passive aggression, neutral face sipping drink, 'but that's none of my business'. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["judgmental", "meme", "tea"]
    },
    {
        "id": "meme_023",
        "text": "Facepalm",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject covering face with hand, looking disappointed and ashamed, 'why' expression. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["disappointed", "meme", "fail"]
    },
    {
        "id": "meme_024",
        "text": "Salt bae",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject sprinkling salt with flair, elbow raised, sunglasses, cool cooking vibe. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["cool", "meme", "cook"]
    },
    {
        "id": "meme_025",
        "text": "Math lady",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject looking confused with equations floating (implied), calculating complex geometry, bewildered. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["confused", "meme", "math"]
    },
    {
        "id": "meme_026",
        "text": "Hide the pain Harold",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject forcing a pained smile, eyes looking sad while mouth smiles, suppressing trauma. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["sad", "meme", "fake"]
    },
    {
        "id": "meme_027",
        "text": "Squinting woman",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject hands on knees, squinting at something far away, trying to find the point. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["looking", "meme", "search"]
    },
    {
        "id": "meme_028",
        "text": "Blinking guy",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject with eyes mid-blink or wide open then squinting, processing information slowly. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["confused", "meme", "wait"]
    },
    {
        "id": "meme_029",
        "text": "Checking out",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject lowering sunglasses to look at something, appreciative or scrutinizing look. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["looking", "meme", "cool"]
    },
    {
        "id": "meme_030",
        "text": "Thumbs up crying",
        "visual": "Transform this photo into a viral WhatsApp sticker. Subject giving thumbs up while streaming tears, 'I'm okay' (not okay) vibe. Photorealistic style only. Isolated on white background.",
        "settings": DEFAULT_SETTINGS,
        "tags": ["sad", "meme", "ok"]
    }
]

# =============================================================================
# MULTI-LANGUAGE CAPTION TRANSLATIONS
# Native slang translations for common sticker captions
# Supported: tr (Turkish), es (Spanish), de (German), fr (French)
# =============================================================================

CAPTION_TRANSLATIONS = {
    # Reactions / Emotions
    "I'm dead": {"tr": "Öldüm", "es": "Estoy muerto", "de": "Ich bin tot", "fr": "Je suis mort"},
    "Wait what?": {"tr": "Nasıl yani?", "es": "¿Qué?", "de": "Warte was?", "fr": "Quoi?"},
    "Be serious": {"tr": "Ciddi ol", "es": "En serio", "de": "Sei ernst", "fr": "Sois sérieux"},
    "Told you": {"tr": "Demiştim", "es": "Te lo dije", "de": "Hab's gesagt", "fr": "Je t'avais dit"},
    "I can't": {"tr": "Yapamam", "es": "No puedo", "de": "Ich kann nicht", "fr": "Je peux pas"},
    "Of course": {"tr": "Tabii ki", "es": "Por supuesto", "de": "Natürlich", "fr": "Bien sûr"},
    "Slay": {"tr": "Efsane", "es": "Arrasar", "de": "Hammer", "fr": "Trop bien"},
    "Bet": {"tr": "Tamam", "es": "Dale", "de": "Abgemacht", "fr": "Banco"},
    "Cap": {"tr": "Yalan", "es": "Mentira", "de": "Lüge", "fr": "Mytho"},
    "No cap": {"tr": "Vallahi", "es": "En serio", "de": "Echt jetzt", "fr": "Vraiment"},
    "Side eye": {"tr": "Yan bakış", "es": "Mirando", "de": "Seitenblick", "fr": "Regard"},
    "LOL": {"tr": "AHAHA", "es": "JAJA", "de": "LOL", "fr": "MDR"},
    "OMG": {"tr": "OHAAA", "es": "DIOS MÍO", "de": "OMG", "fr": "OMG"},
    "W": {"tr": "Helal", "es": "Victoria", "de": "Gewonnen", "fr": "Victoire"},
    "L": {"tr": "Rezalet", "es": "Perdiste", "de": "Verloren", "fr": "Perdu"},
    "Facts": {"tr": "Gerçek", "es": "Hechos", "de": "Fakten", "fr": "Vrai"},
    "I'm out": {"tr": "Ben gidiyom", "es": "Me voy", "de": "Ich bin raus", "fr": "Je me casse"},
    "Mood": {"tr": "Aynen", "es": "Estado", "de": "Stimmung", "fr": "Mood"},
    "Legend": {"tr": "Efsane", "es": "Leyenda", "de": "Legende", "fr": "Légende"},
    
    # Sarcasm / Roast
    "Sure Jan": {"tr": "Tabi canım", "es": "Sí claro", "de": "Ja klar", "fr": "Ouais c'est ça"},
    "Yikes": {"tr": "Eyvah", "es": "Ups", "de": "Autsch", "fr": "Aïe"},
    "How cute": {"tr": "Ne tatlı", "es": "Qué lindo", "de": "Wie süß", "fr": "Trop mignon"},
    "Okay then": {"tr": "Peki o zaman", "es": "Bueno pues", "de": "Na gut", "fr": "Bon bah"},
    "My face when": {"tr": "Ben o an", "es": "Mi cara cuando", "de": "Mein Gesicht", "fr": "Ma tête quand"},
    
    # Cool / Confident
    "I woke up like this": {"tr": "Böyle uyandım", "es": "Me desperté así", "de": "So aufgewacht", "fr": "Réveillé comme ça"},
    "Unbothered": {"tr": "Umurumda değil", "es": "Sin preocupaciones", "de": "Unberührt", "fr": "Tranquille"},
    "Main character": {"tr": "Baş karakter", "es": "Protagonista", "de": "Hauptrolle", "fr": "Perso principal"},
    "It's giving...": {"tr": "Diyor ki...", "es": "Da vibes de...", "de": "Es gibt...", "fr": "Ça donne..."},
    "Period.": {"tr": "Nokta.", "es": "Punto.", "de": "Punkt.", "fr": "Point."},
    
    # Tired / Work
    "Send help": {"tr": "Yardım gönderin", "es": "Ayuda", "de": "Hilfe", "fr": "À l'aide"},
    "Loading...": {"tr": "Yükleniyor...", "es": "Cargando...", "de": "Laden...", "fr": "Chargement..."},
    "In a meeting": {"tr": "Toplantıdayım", "es": "En reunión", "de": "Im Meeting", "fr": "En réunion"},
    "Need coffee": {"tr": "Kahve lazım", "es": "Necesito café", "de": "Brauche Kaffee", "fr": "Besoin de café"},
    "Not today": {"tr": "Bugün değil", "es": "Hoy no", "de": "Nicht heute", "fr": "Pas aujourd'hui"},
    "Done": {"tr": "Bitti", "es": "Listo", "de": "Fertig", "fr": "Fini"},
    "Exhausted": {"tr": "Bitkinim", "es": "Agotado", "de": "Erschöpft", "fr": "Épuisé"},
    "Why me": {"tr": "Neden ben", "es": "Por qué yo", "de": "Warum ich", "fr": "Pourquoi moi"},
    "Mentally out": {"tr": "Kafam başka yerde", "es": "Mentalmente lejos", "de": "Geistig weg", "fr": "Ailleurs"},
    
    # Love / Cute
    "Love you": {"tr": "Seni seviyorum", "es": "Te quiero", "de": "Liebe dich", "fr": "Je t'aime"},
    "Sending love": {"tr": "Sevgilerle", "es": "Con amor", "de": "Liebe senden", "fr": "Bisous"},
    "You're the best": {"tr": "En iyisi sensin", "es": "Eres el mejor", "de": "Du bist der Beste", "fr": "T'es le meilleur"},
    "Blessed": {"tr": "Şanslıyım", "es": "Bendecido", "de": "Gesegnet", "fr": "Béni"},
    "Thankful": {"tr": "Minnettarım", "es": "Agradecido", "de": "Dankbar", "fr": "Reconnaissant"},
    
    # Party / Celebrations
    "Let's go": {"tr": "Haydi", "es": "Vamos", "de": "Los geht's", "fr": "C'est parti"},
    "Let's goooo": {"tr": "Haydiii", "es": "Vamooos", "de": "Los geht's!", "fr": "C'est partiii"},
    "Weekend vibes": {"tr": "Hafta sonu havası", "es": "Vibes de finde", "de": "Wochenend-Vibes", "fr": "Ambiance weekend"},
    "TGIF": {"tr": "Cuma geldi", "es": "Por fin viernes", "de": "Endlich Freitag", "fr": "Enfin vendredi"},
    "Party time": {"tr": "Parti zamanı", "es": "Hora de fiesta", "de": "Partyzeit", "fr": "C'est la fête"},
    "Cheers": {"tr": "Şerefe", "es": "Salud", "de": "Prost", "fr": "Santé"},
    
    # Pet / Dog Related
    "Feeling ruff": {"tr": "Zor günler", "es": "Día de perros", "de": "Rauer Tag", "fr": "Journée rude"},
    "Side-eye alert": {"tr": "Yan bakış", "es": "Mirada asesina", "de": "Seitenblick", "fr": "Regard suspect"},
    "Pawsitively happy": {"tr": "Çok mutlu", "es": "Super feliz", "de": "Mega happy", "fr": "Trop content"},
    "Zoomies incoming": {"tr": "Koşturma zamanı", "es": "A correr", "de": "Sausezeit", "fr": "Mode turbo"},
    "Paw-some day": {"tr": "Harika gün", "es": "Día genial", "de": "Toller Tag", "fr": "Super journée"},
    "Woof vibes": {"tr": "Hav havalar", "es": "Vibras perrunas", "de": "Wuff Stimmung", "fr": "Ambiance ouaf"},
    "Sassy bark": {"tr": "Sert havlama", "es": "Ladrido sassy", "de": "Freches Bellen", "fr": "Aboiement sassy"},
    "Good boy": {"tr": "Uslu çocuk", "es": "Buen chico", "de": "Braver Hund", "fr": "Bon chien"},
    "Good girl": {"tr": "Uslu kız", "es": "Buena chica", "de": "Brave Hündin", "fr": "Bonne fille"},
    "Treat time": {"tr": "Ödül zamanı", "es": "Hora del premio", "de": "Leckerli Zeit", "fr": "L'heure du gâteau"},
    "Nap time": {"tr": "Uyku zamanı", "es": "Hora de siesta", "de": "Schlafenszeit", "fr": "Heure de la sieste"},
    "Walk time": {"tr": "Yürüyüş zamanı", "es": "Hora del paseo", "de": "Gassi Zeit", "fr": "Heure de promenade"},
    "Belly rubs": {"tr": "Göbek kaşıma", "es": "Caricias", "de": "Bauchkraulen", "fr": "Gratouilles"},
    "Puppy eyes": {"tr": "Köpek bakışı", "es": "Ojos de cachorro", "de": "Hundeblick", "fr": "Yeux de chiot"},
    "No thoughts": {"tr": "Hiç düşünce yok", "es": "Sin pensamientos", "de": "Keine Gedanken", "fr": "Aucune pensée"},
    "Just vibin": {"tr": "Takılıyorum", "es": "Solo vibrando", "de": "Chillen", "fr": "Je profite"},
    
    # Generic / Misc
    "Yes": {"tr": "Evet", "es": "Sí", "de": "Ja", "fr": "Oui"},
    "No": {"tr": "Hayır", "es": "No", "de": "Nein", "fr": "Non"},
    "Maybe": {"tr": "Belki", "es": "Quizás", "de": "Vielleicht", "fr": "Peut-être"},
    "IDK": {"tr": "Bilmiyorum", "es": "No sé", "de": "Keine Ahnung", "fr": "Je sais pas"},
    "BRB": {"tr": "Hemen dönerim", "es": "Vuelvo", "de": "Bin gleich zurück", "fr": "Je reviens"},
    "OK": {"tr": "Tamam", "es": "OK", "de": "OK", "fr": "OK"},
    "Thanks": {"tr": "Teşekkürler", "es": "Gracias", "de": "Danke", "fr": "Merci"},
    "Please": {"tr": "Lütfen", "es": "Por favor", "de": "Bitte", "fr": "S'il te plaît"},
    "Sorry": {"tr": "Özür dilerim", "es": "Perdón", "de": "Entschuldigung", "fr": "Désolé"},
    "Bye": {"tr": "Hoşçakal", "es": "Adiós", "de": "Tschüss", "fr": "Ciao"},
    "Pls no": {"tr": "Lütfen hayır", "es": "Por favor no", "de": "Bitte nicht", "fr": "Pitié non"},
}


def get_translated_caption(english_caption: str, language: str = "en") -> str:
    """
    Get translated caption for given language.
    Falls back to English if translation not found.
    
    Args:
        english_caption: The original English caption
        language: Target language code (en, tr, es, de, fr)
    
    Returns:
        Translated caption or original if not found
    """
    if language == "en" or not language:
        return english_caption
    
    # Try exact match
    if english_caption in CAPTION_TRANSLATIONS:
        translations = CAPTION_TRANSLATIONS[english_caption]
        if language in translations:
            return translations[language]
    
    # Try case-insensitive match
    for key, translations in CAPTION_TRANSLATIONS.items():
        if key.lower() == english_caption.lower():
            if language in translations:
                return translations[language]
    
    # Fallback to English
    return english_caption

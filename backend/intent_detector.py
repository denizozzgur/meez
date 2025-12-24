"""
Intent Detection System for Smart Sticker Generation
Detects user input type: subject, caption, emoji, or scenario
"""

class IntentDetector:
    # WhatsApp expressions database - actual phrases people use (all lowercase for matching)
    WHATSAPP_EXPRESSIONS = {
        "tr": {
            # Excited/Happy
            "çok iyii", "olley", "haydiii", "yessss", "sonunda", "aşırı mutlu", "bayıldım", "müthiş",
            # Tired/Done
            "yapamam", "bittim", "off ya", "yeter artık", "yoruldum", "pes", "öldüm", "yandım",
            # Shocked/Surprised
            "yok ya", "şaka mı bu", "inanamıyorum", "nasıl ya", "olamaz", "vay be", "şok", "oha", "yok artık",
            # Annoyed/Meh
            "yaa niye", "ne alaka", "sus", "tamam tamam", "anladık", "bıktım", "sinir", "olmaz",
            # Laughing/Fun
            "koptum", "ben ölüyorum", "çok komik", "gülmekten öldüm", "çıldırıcam", "delirdim",
            # Cute/Soft
            "aa çok tatlı", "tatlılık", "çok şeker", "aww", "minik", "ponçik", "aşkım", "canım",
            # Casual
            "vallaa", "e tabii", "hee", "yo", "hmm", "bilmem", "bakalım", "neyse"
        },
        "es": {
            "vamoos", "qué guay", "me encanta", "genial", "perfecto", "brutal",
            "no puedo", "estoy muerto", "qué pereza", "fatal", "agotado",
            "madre mía", "qué fuerte", "no me lo creo", "anda ya", "ostras",
            "ay no", "para ya", "basta", "vale vale",
            "jajaja qué", "me muero de risa", "qué risa",
            "qué mono", "precioso", "hermoso", "adorable",
            "buenoo", "a ver", "puede ser", "oye", "mira"
        },
        "de": {
            "los gehts", "mega", "hammer", "geil", "super", "perfekt", "endlich",
            "kein bock", "ich kann nicht", "fertig", "platt", "tot", "kaputt",
            "echt jetzt", "nee oder", "was", "krass", "heftig", "alter",
            "lass mal", "nervt", "jaja", "na toll", "egal",
            "haha was", "ich lach mich tot", "zu gut",
            "wie süß", "aww", "so niedlich", "süßi", "schatz",
            "läuft", "klar", "okaay", "mal sehen", "joa"
        },
        "fr": {
            "c'est parti", "trop bien", "génial", "parfait", "incroyable", "ouiii",
            "la flemme", "je peux plus", "jsuis mort", "épuisé", "dead", "fini",
            "c'est ouf", "quoi", "mais non", "impossible", "sérieux", "oh non",
            "relou", "chelou", "ah non", "stop", "osef", "bref",
            "mdrrr quoi", "trop drôle", "ptdr", "jpleure",
            "trop mignon", "aww", "adorable", "mon coeur", "bisous",
            "oklm", "tranquille", "j'avoue", "genre", "pas mal", "bon"
        },
        "en": {
            "let's goooo", "yesss", "finally", "love this", "so good", "perfect", "amazing",
            "i can't", "i'm dead", "help", "done", "over it", "so tired", "nope", "exhausted",
            "wait what", "no way", "excuse me", "omg", "shook", "shocked",
            "why tho", "pls no", "stoppp", "ugh", "whatever", "meh", "gross",
            "lmaoo what", "i'm crying", "so funny", "hahaha", "dead", "screaming",
            "so cute", "aww", "adorable", "precious", "my heart", "love you",
            "same tbh", "mood", "facts", "literally me", "honestly", "lowkey"
        }
    }
    
    # Emoji to scenario mapping
    EMOJI_SCENARIOS = {
        "😭": "crying/sad",
        "🔥": "fire/hype",
        "💀": "dead/shocked",
        "😂": "laughing/funny",
        "👀": "suspicious/watching",
        "❤️": "love/heart",
        "😍": "love/adore",
        "🤔": "thinking/confused",
        "😱": "shocked/scared",
        "🥺": "pleading/cute",
        "😤": "frustrated/angry",
        "🤯": "mind-blown/shocked",
        "🙄": "eye-roll/annoyed",
        "😴": "sleepy/tired",
        "🤡": "clown/silly",
        "👻": "ghost/spooky",
        "🎉": "party/celebration",
        "💩": "poop/funny",
        "🤮": "sick/disgusting",
        "😎": "cool/confident"
    }
    
    def is_emoji_only(self, text):
        """Check if input is just emoji(s)"""
        import emoji
        # Remove all emojis and check if anything is left
        without_emoji = emoji.replace_emoji(text, '').strip()
        return len(without_emoji) == 0 and len(text) > 0
    
    def is_expression(self, text, language):
        """Check if text is a known WhatsApp expression"""
        text_lower = text.lower().strip()
        
        # Check in specified language
        if language in self.WHATSAPP_EXPRESSIONS:
            if text_lower in self.WHATSAPP_EXPRESSIONS[language]:
                return True
        
        # Check in all languages as fallback
        for lang_expressions in self.WHATSAPP_EXPRESSIONS.values():
            if text_lower in lang_expressions:
                return True
        
        return False
    
    def detect_intent(self, user_input, language="en"):
        """
        Detect user intent from input
        Returns: "emoji", "caption_first", "scenario", or "subject"
        """
        user_input = user_input.strip()
        
        # 1. Check for emoji-only
        if self.is_emoji_only(user_input):
            print(f"🎯 Intent: EMOJI - {user_input}")
            return "emoji"
        
        # 2. Check for known expressions (caption-first)
        if self.is_expression(user_input, language):
            print(f"🎯 Intent: CAPTION_FIRST - '{user_input}'")
            return "caption_first"
        
        # 3. Check for scenarios (TODO: expand this)
        scenario_keywords = {
            "tr": ["geç kaldım", "doğum günü", "işe gitti", "toplantı"],
            "en": ["running late", "birthday", "meeting", "work"],
            "es": ["tarde", "cumpleaños", "reunión", "trabajo"],
            "de": ["zu spät", "geburtstag", "meeting", "arbeit"],
            "fr": ["en retard", "anniversaire", "réunion", "travail"]
        }
        
        if language in scenario_keywords:
            for keyword in scenario_keywords[language]:
                if keyword.lower() in user_input.lower():
                    print(f"🎯 Intent: SCENARIO - '{user_input}'")
                    return "scenario"
        
        # 4. Default: subject-based
        print(f"🎯 Intent: SUBJECT - '{user_input}'")
        return "subject"
    
    def get_emoji_scenario(self, emoji):
        """Get scenario for an emoji"""
        return self.EMOJI_SCENARIOS.get(emoji, "general")

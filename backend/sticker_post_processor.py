"""
Sticker Post-Processor Module
Handles Pillow-based post-processing for WhatsApp stickers:
- White outline around subject
- Drop shadow for depth
- Caption text overlay
- Square format with proper sizing
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageOps
import requests
from io import BytesIO
import base64
import os

class StickerPostProcessor:
    def __init__(self):
        # Try to load a bold font, fallback to default if not found
        self.caption_font = None
        self.caption_font_size = 56
        
        # Try common font paths
        font_paths = [
            "/System/Library/Fonts/Supplemental/Impact.ttf",  # macOS
            "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",  # Linux
            "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf",  # Linux alt
            "C:\\Windows\\Fonts\\impact.ttf",  # Windows
        ]
        
        for path in font_paths:
            if os.path.exists(path):
                try:
                    self.caption_font = ImageFont.truetype(path, self.caption_font_size)
                    print(f"Loaded font: {path}")
                    break
                except:
                    continue
        
        if not self.caption_font:
            print("Warning: Using default font (may not look ideal)")
            self.caption_font = ImageFont.load_default()
    
    def download_image(self, url):
        """Download image from URL and return PIL Image in RGBA mode"""
        try:
            response = requests.get(url, timeout=30)
            response.raise_for_status()
            img = Image.open(BytesIO(response.content))
            return img.convert("RGBA")
        except Exception as e:
            print(f"Error downloading image: {e}")
            return None
    
    def ensure_square_format(self, img, target_size=512, subject_fill=0.75):
        """
        Ensure 1:1 aspect ratio with subject filling ~65-80% of frame.
        Adds transparent padding if needed.
        """
        width, height = img.size
        
        # Determine the size needed to fit the subject at desired fill ratio
        max_dim = max(width, height)
        new_size = int(max_dim / subject_fill)
        
        # Cap at target size
        new_size = min(new_size, target_size)
        
        # Create new transparent square canvas
        canvas = Image.new("RGBA", (new_size, new_size), (0, 0, 0, 0))
        
        # Scale image to fit within the fill ratio
        scale = (new_size * subject_fill) / max_dim
        new_width = int(width * scale)
        new_height = int(height * scale)
        
        img_resized = img.resize((new_width, new_height), Image.Resampling.LANCZOS)
        
        # Center the image on canvas
        x = (new_size - new_width) // 2
        y = (new_size - new_height) // 2
        
        canvas.paste(img_resized, (x, y), img_resized)
        
        return canvas
    
    def add_white_outline(self, img, outline_width=20):
        """
        Add thick white outline around transparent subject.
        Uses alpha channel dilation technique.
        """
        # Split into channels
        r, g, b, a = img.split()
        
        # Create outline by dilating alpha channel
        # We'll create multiple offsets and combine
        outline_img = Image.new("RGBA", img.size, (0, 0, 0, 0))
        
        # Create white version of the subject shape
        for dx in range(-outline_width, outline_width + 1, 2):
            for dy in range(-outline_width, outline_width + 1, 2):
                if dx*dx + dy*dy <= outline_width*outline_width:
                    # Shift the alpha channel
                    shifted = Image.new("L", img.size, 0)
                    shifted.paste(a, (dx, dy))
                    
                    # Create white pixel where alpha exists
                    white_layer = Image.new("RGBA", img.size, (255, 255, 255, 0))
                    white_layer.putalpha(shifted)
                    
                    outline_img = Image.alpha_composite(outline_img, white_layer)
        
        # Composite: outline behind, original on top
        result = Image.alpha_composite(outline_img, img)
        
        return result
    
    def add_drop_shadow(self, img, offset=(6, 6), blur_radius=10, shadow_opacity=0.35):
        """
        Add subtle drop shadow for depth.
        """
        # Get alpha channel
        r, g, b, a = img.split()
        
        # Create shadow layer (black with alpha from original)
        shadow = Image.new("RGBA", img.size, (0, 0, 0, 0))
        shadow_alpha = a.copy()
        
        # Apply blur to shadow
        shadow_alpha = shadow_alpha.filter(ImageFilter.GaussianBlur(blur_radius))
        
        # Reduce opacity
        shadow_alpha = shadow_alpha.point(lambda x: int(x * shadow_opacity))
        
        # Create the shadow image
        shadow_layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
        black_layer = Image.new("RGB", img.size, (0, 0, 0))
        shadow_layer = Image.merge("RGBA", (*black_layer.split(), shadow_alpha))
        
        # Create larger canvas to accommodate offset
        new_width = img.size[0] + abs(offset[0]) + blur_radius
        new_height = img.size[1] + abs(offset[1]) + blur_radius
        
        result = Image.new("RGBA", (new_width, new_height), (0, 0, 0, 0))
        
        # Paste shadow with offset
        shadow_x = max(0, offset[0])
        shadow_y = max(0, offset[1])
        result.paste(shadow_layer, (shadow_x, shadow_y), shadow_layer)
        
        # Paste original on top
        orig_x = max(0, -offset[0])
        orig_y = max(0, -offset[1])
        result.paste(img, (orig_x, orig_y), img)
        
        return result
    
    def add_caption_text(self, img, text, position='bottom'):
        """
        Overlay caption text with white fill and black outline.
        Uses manual outline drawing for maximum font compatibility.
        """
        if not text or not text.strip():
            return img  # Skip if empty text
            
        draw = ImageDraw.Draw(img)
        caption = text.upper()
        
        # Get text bounding box
        bbox = draw.textbbox((0, 0), caption, font=self.caption_font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        
        # Calculate position (centered horizontally)
        img_width, img_height = img.size
        x = (img_width - text_width) // 2
        
        if position == 'bottom':
            y = img_height - text_height - 25  # Padding from bottom
        elif position == 'top':
            y = 20
        else:
            y = (img_height - text_height) // 2
        
        # Draw black outline manually (8 directions) for VISIBLE white-on-black style
        outline_range = 5  # Increased for more visible outline
        print(f"📝 Adding caption '{caption}' with thick black outline (outline_range={outline_range})")
        for dx in range(-outline_range, outline_range + 1):
            for dy in range(-outline_range, outline_range + 1):
                if dx != 0 or dy != 0:
                    draw.text((x + dx, y + dy), caption, font=self.caption_font, fill=(0, 0, 0, 255))
        
        # Draw white text on top
        draw.text((x, y), caption, font=self.caption_font, fill=(255, 255, 255, 255))
        
        return img
    
    def image_to_base64_url(self, img, format="PNG"):
        """Convert PIL Image to base64 data URL"""
        buffer = BytesIO()
        img.save(buffer, format=format)
        b64 = base64.b64encode(buffer.getvalue()).decode('utf-8')
        return f"data:image/png;base64,{b64}"
    
    def process_sticker(self, image_url, caption_text, add_outline=True, add_shadow=True):
        """
        Complete post-processing pipeline:
        1. Download image
        2. Ensure square format
        3. Add white outline
        4. Add drop shadow  
        5. Add caption text
        
        Returns: base64 data URL of processed image
        """
        print(f"Post-processing sticker: '{caption_text}'")
        
        # Step 1: Download
        img = self.download_image(image_url)
        if img is None:
            print("Failed to download image, returning original URL")
            return image_url
        
        try:
            # Step 2: Square format with proper sizing - subject fills 95% of frame
            img = self.ensure_square_format(img, target_size=512, subject_fill=0.95)
            
            # Step 3: White outline
            if add_outline:
                img = self.add_white_outline(img, outline_width=10)
            
            # Step 4: Drop shadow
            if add_shadow:
                img = self.add_drop_shadow(img, offset=(5, 5), blur_radius=8, shadow_opacity=0.30)
            
            # Re-ensure square after shadow (shadow adds size) - keep subject large
            img = self.ensure_square_format(img, target_size=512, subject_fill=0.90)
            
            # Step 5: Caption text
            if caption_text:
                img = self.add_caption_text(img, caption_text, position='bottom')
            
            # Convert to base64 URL
            result_url = self.image_to_base64_url(img)
            print(f"Post-processing complete for '{caption_text}'")
            
            return result_url
            
        except Exception as e:
            print(f"Post-processing error: {e}")
            import traceback
            traceback.print_exc()
            return image_url  # Return original on error


# Quick test
if __name__ == "__main__":
    processor = StickerPostProcessor()
    
    # Test with a sample transparent PNG URL
    test_url = "https://fal.media/files/example.png"  # Replace with real URL
    result = processor.process_sticker(test_url, "I'm dead")
    print(f"Result: {result[:100]}...")

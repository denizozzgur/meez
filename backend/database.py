"""
Database models and connection for Meez backend.
Uses SQLAlchemy with PostgreSQL on Railway.
"""

import os
from datetime import datetime
from sqlalchemy import create_engine, Column, String, Integer, Text, DateTime, Boolean, JSON
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from contextlib import contextmanager

# Get database URL from Railway (auto-injected) or use SQLite for local dev
DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./meez_local.db")

# Railway uses postgres:// but SQLAlchemy needs postgresql://
if DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)

# Create engine with connection pooling
engine = create_engine(
    DATABASE_URL,
    pool_size=5,
    max_overflow=10,
    pool_pre_ping=True,  # Check connection health
    echo=False  # Set True for SQL debugging
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


class StickerPack(Base):
    """Model for storing sticker packs in the database."""
    __tablename__ = "sticker_packs"
    
    id = Column(String(255), primary_key=True)
    title = Column(String(255), nullable=False)
    author = Column(String(255), nullable=False)
    user_id = Column(String(255), nullable=True)  # For tracking ownership
    stickers = Column(JSON, nullable=False)  # List of sticker objects
    likes = Column(Integer, default=0)
    downloads = Column(Integer, default=0)
    liked_by = Column(JSON, default=list)  # List of user_ids who liked
    is_public = Column(Boolean, default=True)
    is_seed = Column(Boolean, default=False)  # True for pre-seeded packs
    created_at = Column(DateTime, default=datetime.utcnow)
    
    def to_dict(self):
        """Convert to dictionary for API response."""
        # Calculate relative time
        time_diff = datetime.utcnow() - self.created_at
        if time_diff.days > 0:
            created_at_str = f"{time_diff.days}d ago"
        elif time_diff.seconds >= 3600:
            created_at_str = f"{time_diff.seconds // 3600}h ago"
        else:
            created_at_str = "Just now"
        
        return {
            "id": self.id,
            "title": self.title,
            "author": self.author,
            "stickers": self.stickers,
            "likes": self.likes,
            "downloads": self.downloads,
            "createdAt": created_at_str,
            "created_at": self.created_at.isoformat(),
            "category": "Community",
            "tags": [],
            "isPublic": self.is_public
        }


def init_db():
    """Initialize database tables."""
    Base.metadata.create_all(bind=engine)
    print("✅ Database tables initialized")


@contextmanager
def get_db():
    """Get database session with automatic cleanup."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def get_db_session():
    """Get a new database session (for dependency injection)."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

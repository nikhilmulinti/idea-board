from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from sqlalchemy import create_engine, Column, Integer, String, DateTime, text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from datetime import datetime
import os
from typing import List

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://postgres:postgres@localhost:5432/ideaboard")

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

class Idea(Base):
    __tablename__ = "ideas"

    id = Column(Integer, primary_key=True, index=True)
    content = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

class IdeaCreate(BaseModel):
    content: str

class IdeaResponse(BaseModel):
    id: int
    content: str
    created_at: datetime

    class Config:
        from_attributes = True

app = FastAPI(title="Idea Board API", root_path="/api")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
def startup_event():
    Base.metadata.create_all(bind=engine)

@app.get("/health")
def health_check():
    return {"status": "healthy"}

@app.get("/ideas", response_model=List[IdeaResponse])
def get_ideas():
    db = SessionLocal()
    try:
        ideas = db.query(Idea).order_by(Idea.created_at.desc()).all()
        return ideas
    finally:
        db.close()

@app.post("/ideas", response_model=IdeaResponse)
def create_idea(idea: IdeaCreate):
    if not idea.content.strip():
        raise HTTPException(status_code=400, detail="Idea content cannot be empty")

    db = SessionLocal()
    try:
        db_idea = Idea(content=idea.content.strip())
        db.add(db_idea)
        db.commit()
        db.refresh(db_idea)
        return db_idea
    finally:
        db.close()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
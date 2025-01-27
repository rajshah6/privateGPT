from typing import Union
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime
from pydantic import BaseModel
from chatbot import SunlifeChatbot


app = FastAPI()

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

bot = SunlifeChatbot()

class Message(BaseModel):
    message: str

@app.post("/chat")
async def chat(message: Message):
    response = bot.extract_email(message.message)
    return response
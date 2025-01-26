from typing import Union

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# class Message:
#     def __init__(self, message: str):
#         self.message = message

@app.post("/chat")
async def chat(message: Message):
    return {
        "reply": f"Echo: {message.message}",
        "timestamp": datetime.now().isoformat()
    }
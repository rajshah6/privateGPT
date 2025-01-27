import openai
import os
from dotenv import load_dotenv
from typing import Dict

load_dotenv()

class SunlifeChatbot:
    def __init__(self):
        # Set your OpenAI API Key from environment variables
        self.api_key = os.getenv("OPENAI_API_KEY", "YOUR_API_KEY")
        if self.api_key == "YOUR_API_KEY":
            raise ValueError("Please set your OpenAI API Key in the environment variables.")
        openai.api_key = self.api_key

    def extract_email(self, message: str) -> Dict:
        """
        Extracts an email address from the given message using OpenAI's Chat Completion API
        and returns it in structured JSON format.
        """
        try:
            response = openai.ChatCompletion.create(
                model="gpt-4",
                messages=[
                    {"role": "system", "content": "You are a helpful assistant."},
                    {"role": "user", "content": message}
                ],
            )
            content = response["choices"][0]["message"]["content"]
            return {"reply": content}
        except Exception as e:
            return {"error": str(e)}

    # Example usage
    if __name__ == "__main__":
        chatbot = SunlifeChatbot()
        user_message = "Feeling stuck? Send a message to help@mycompany.com."
        response = chatbot.extract_email(user_message)
        print(response)
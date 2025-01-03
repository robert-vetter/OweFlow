from flask import Flask, request, jsonify
from flask_cors import CORS
import whisper
import os
import torch
from openai import OpenAI
from dotenv import load_dotenv

# --- Flask-App einrichten ---
app = Flask(__name__)
CORS(app)

# --- API-Schlüssel und Whisper-Modell laden ---
load_dotenv()
api_key = os.getenv("OPENAI_API_KEY")

if not api_key:
    raise ValueError("❌ API-Schlüssel nicht gefunden! Stelle sicher, dass OPENAI_API_KEY in .env vorhanden ist.")

client = OpenAI(api_key=api_key)

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
print(f"🎯 Verwendetes Gerät: {device}")

model = whisper.load_model('base', device=device)

# --- Endpunkt: Audio-Datei empfangen und analysieren ---
@app.route('/transcribe', methods=['POST'])
def transcribe_audio():
    try:
        # 📥 Audio empfangen
        audio_file = request.files.get('audio')
        if not audio_file:
            return jsonify({"error": "Keine Audiodatei hochgeladen."}), 400

        # 📂 Datei speichern
        audio_path = 'temp_audio.mp3'
        audio_file.save(audio_path)

        # 🎙️ Transkription
        result = model.transcribe(audio_path)
        transcribed_text = result['text']
        print(f"📝 Transkribierter Text: {transcribed_text}")

        # 📊 Datenextraktion mit OpenAI GPT
        message_extract_data = (
            "You are a highly skilled data extraction assistant specialized in analyzing financial and expense-related text. "
            "Your task is to parse the given text and extract structured financial data in JSON format with the following keys:\n"
            "\n"
            "1️⃣ **intent**: Identify the main action or goal described in the text. Choose one of the following options:\n"
            "   - 'AddExpense': Adding a new expense entry.\n"
            "   - 'SplitExpense': Dividing an expense among multiple people.\n"
            "   - 'ShowSummary': Requesting an overview of current expenses.\n"
            "   - 'DeleteExpense': Removing an existing expense entry.\n"
            "\n"
            "2️⃣ **amount**: The monetary amount involved in the transaction as a number (e.g., 20.5).\n"
            "3️⃣ **currency**: The currency of the amount (e.g., 'EUR', 'USD'). If not explicitly mentioned, set to 'EUR'.\n"
            "4️⃣ **payer**: The name of the person who made the payment.\n"
            "5️⃣ **recipients**: A list of people who benefited from the payment (e.g., ['Alice', 'Bob']). If no recipients are mentioned, return an empty array [].\n"
            "6️⃣ **purpose**: A brief description of the purpose of the payment (e.g., 'Pizza', 'Hotel').\n"
            "7️⃣ **group**: The name of a specific group associated with this transaction (e.g., 'Vacation Mallorca'). If not mentioned, set to null.\n"
            "8️⃣ **date**: The date of the transaction in ISO format (YYYY-MM-DD). If not mentioned, set to null.\n"
            "\n"
            "📦 **Output Format:**\n"
            "```\n"
            "{\n"
            "  \"intent\": \"[AddExpense|SplitExpense|ShowSummary|DeleteExpense|null]\",\n"
            "  \"amount\": [Number|null],\n"
            "  \"currency\": \"[Currency, default EUR]\",\n"
            "  \"payer\": \"[Name|null]\",\n"
            "  \"recipients\": [\"[Name of recipient 1]\", \"[Name of recipient 2]\", ...],\n"
            "  \"purpose\": \"[Purpose|null]\",\n"
            "  \"group\": \"[Group|null]\",\n"
            "  \"date\": \"[YYYY-MM-DD|null]\"\n"
            "}\n"
            "```\n"
            "\n"
            "Now analyze the following text:\n"
            + transcribed_text
        )

        response = client.chat.completions.create(
            model="gpt-4",
            messages=[{"role": "user", "content": message_extract_data}]
        )
        
        extracted_data = response.choices[0].message.content.strip()
        print("📊 Extrahierte Daten:", extracted_data)

        # 🧹 Temporäre Audiodatei löschen
        os.remove(audio_path)

        return jsonify({"transcribed_text": transcribed_text, "extracted_data": extracted_data})

    except Exception as e:
        return jsonify({"error": str(e)}), 500

# --- Server starten ---
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

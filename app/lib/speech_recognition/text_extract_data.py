import os
from openai import OpenAI
from dotenv import load_dotenv

current_dir = os.path.dirname(os.path.abspath(__file__))
env_path = os.path.join(current_dir, '.env')
print(f"🔑 Verwende .env-Datei unter: {env_path}")


load_dotenv(dotenv_path=env_path, override=True)

api_key = os.getenv("OPENAI_API_KEY")


client = OpenAI(api_key=api_key)

text_file = os.path.join(current_dir, 'full_text.txt')

try:
    with open(text_file, 'r', encoding='utf-8') as f:
        full_text = f.read()
        print("✅ Text erfolgreich aus .txt-Datei geladen.")
except FileNotFoundError:
    raise FileNotFoundError(f"❌ Textdatei nicht gefunden: {text_file}")

def chat_gpt(prompt):
    response = client.chat.completions.create(
        model="gpt-4",
        messages=[{"role": "user", "content": prompt}]
    )
    return response.choices[0].message.content.strip()

message_extract_data = (
    "You are an assistant that extracts structured financial data from text. Your task is to analyze the text and output the results in a JSON format. "
    "The JSON object must contain the following keys:\n"
    "\n"
    "- **intent**: The intent of the text (e.g., 'AddExpense', 'SplitExpense', 'ShowSummary', 'DeleteExpense').\n"
    "- **amount**: The monetary amount mentioned in the text.\n"
    "- **currency**: The currency of the amount (default is 'EUR' if not specified).\n"
    "- **payer**: The person who made the payment.\n"
    "- **recipients**: A list of people who benefited from the payment.\n"
    "- **purpose**: The reason or purpose of the payment (e.g., 'Pizza', 'Groceries').\n"
    "- **group**: The name of a group if specified (e.g., 'Vacation Mallorca').\n"
    "- **date**: The date of the transaction if mentioned, otherwise null.\n"
    "\n"
    "If a specific piece of information is not present in the text, set its value to null.\n"
    "\n"
    "Always return the result in the following JSON format, and do not add any extra text:\n"
    "```\n"
    "{\n"
    "  \"intent\": \"[AddExpense|SplitExpense|ShowSummary|DeleteExpense]\",\n"
    "  \"amount\": [Number],\n"
    "  \"currency\": \"[Currency, default EUR]\",\n"
    "  \"payer\": \"[Name of the payer]\",\n"
    "  \"recipients\": [\"[Name of recipient 1]\", \"[Name of recipient 2]\", ...],\n"
    "  \"purpose\": \"[Purpose of the payment]\",\n"
    "  \"group\": \"[Group name, if specified]\",\n"
    "  \"date\": \"[YYYY-MM-DD] or null\"\n"
    "}\n"
    "```\n"
    "\n"
    "Text to analyze:\n"
    + full_text
)


# Analyse durchführen
try:
    topics_and_subtopics = chat_gpt(message_extract_data)
    print("✅ Identified Topics and Subtopics:")
    print(topics_and_subtopics)
except Exception as e:
    print(f"❌ Fehler bei der Analyse: {e}")

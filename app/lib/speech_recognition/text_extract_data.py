import os
from openai import OpenAI
from dotenv import load_dotenv

current_dir = os.path.dirname(os.path.abspath(__file__))

text_file = os.path.join(current_dir, 'full_text.txt')

try:
    with open(text_file, 'r', encoding='utf-8') as f:
        full_text = f.read()
        print("✅ Text erfolgreich aus .txt-Datei geladen.")
except FileNotFoundError:
    raise FileNotFoundError(f"❌ Textdatei nicht gefunden: {text_file}")

client = OpenAI(
    api_key = "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"
)


def chat_gpt(prompt):
    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{"role": "user", "content": prompt}]
    )
    return response.choices[0].message.content.strip()

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
    "🔑 **Additional Instructions:**\n"
    "- If a field is not explicitly mentioned in the text, set its value to null (except for 'recipients', which should be an empty array []).\n"
    "- Extract only relevant financial data. Ignore unrelated information.\n"
    "- Ensure that all extracted data adheres to the specified JSON schema.\n"
    "- If the intent is unclear, set 'intent' to null.\n"
    "\n"
    "📦 **Output Format:**\n"
    "Always return the result in the exact following JSON structure without adding any explanations, extra text, or formatting:\n"
    "\n"
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
    "Example Input:\n"
    "\"I paid 50 euros for pizza and drinks for Alice and Bob during our trip to Mallorca on 2024-04-25.\"\n"
    "\n"
    "Example Output:\n"
    "```\n"
    "{\n"
    "  \"intent\": \"AddExpense\",\n"
    "  \"amount\": 50,\n"
    "  \"currency\": \"EUR\",\n"
    "  \"payer\": \"I\",\n"
    "  \"recipients\": [\"Alice\", \"Bob\"],\n"
    "  \"purpose\": \"Pizza and drinks\",\n"
    "  \"group\": \"Mallorca\",\n"
    "  \"date\": \"2024-04-25\"\n"
    "}\n"
    "```\n"
    "\n"
    "Now analyze the following text:\n"
    + full_text
)


# Analyse durchführen
try:
    topics_and_subtopics = chat_gpt(message_extract_data)
    print("✅ Identified Topics and Subtopics:")
    print(topics_and_subtopics)
except Exception as e:
    print(f"❌ Fehler bei der Analyse: {e}")

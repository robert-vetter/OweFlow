import whisper
import os
import torch
import time
import warnings

warnings.filterwarnings("ignore")


print("CUDA verfügbar:", torch.cuda.is_available())
print("Aktuelles CUDA-Gerät:", torch.cuda.current_device())
print("CUDA-Gerät-Name:", torch.cuda.get_device_name(0) if torch.cuda.is_available() else "Keine GPU erkannt")

# --- CUDA überprüfen ---
print(torch.cuda.is_available())
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
print(f"Verwendetes Gerät: {device}")
if device == 'cuda':
    print(f"GPU-Name: {torch.cuda.get_device_name(0)}")

torch.backends.cudnn.benchmark = True
torch.backends.cudnn.enabled = True

# --- Whisper-Modell laden ---
model = whisper.load_model('turbo').to(device)

# --- Audiodatei vorbereiten ---
current_dir = os.path.dirname(os.path.abspath(__file__))
audio_file = os.path.join(current_dir, 'test3.mp3')
text_file = os.path.join(current_dir, 'full_text.txt')

print("🎙️ Starting to transcribe...")

# --- Transkription ---
start_time = time.time()
result = model.transcribe(audio_file, fp16=True)
transcription_time = time.time() - start_time
print(f"⏱️ Transkriptionszeit: {transcription_time:.2f} Sekunden")

# --- Transkription speichern ---
transcribed_text = result['text']
print("📝 Transkription:", transcribed_text)

# Speichere den Text in einer .txt-Datei
with open(text_file, 'w', encoding='utf-8') as f:
    f.write(transcribed_text)
    print(f"✅ Transkription gespeichert in: {text_file}")

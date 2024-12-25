import whisper
import os
import torch
import time
import warnings
warnings.filterwarnings("ignore")

print(torch.cuda.is_available())
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
print(f"Verwendetes Gerät: {device}")
print(f"GPU-Name: {torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'Keine GPU'}")

torch.backends.cudnn.benchmark = True
torch.backends.cudnn.enabled = True

# ggf. anderes Modell, 'turbo' irgendwie bei mir ziemlich langsam, auch wenn es eig. das zweitschnellste sein soll
model = whisper.load_model('turbo', device=device)

current_dir = os.path.dirname(os.path.abspath(__file__))
audio_file = os.path.join(current_dir, 'test3.mp3')
print("Starting to transcribe...")

start_time = time.time()
result = model.transcribe(audio_file)
transcription_time = time.time() - start_time
print(f"Transkriptionszeit: {transcription_time:.2f} Sekunden")

print("Transkription:", result['text'])
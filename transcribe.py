import os
import sys
from google import genai
from bidi.algorithm import get_display

MODEL = "models/gemini-3-pro-preview"
# MODEL = "models/gemini-3-flash-preview"

if len(sys.argv) < 2:
    print(f"Usage: python {sys.argv[0]} <audio_file>")
    sys.exit(1)

audio_path = sys.argv[1]

# 1. Initialize the client
# If using AI Studio, provide the API key
client = genai.Client(api_key=os.environ.get("GOOGLE_API_KEY"))

# 2. Upload the local file
# The Files API handles MP3, WAV, and other audio formats
print(f"Uploading file: {audio_path}")
audio_file = client.files.upload(file=audio_path)

# 3. Transcribe using a 2025 model (like Gemini 2.0 Flash)
print("Transcribing...")
response = client.models.generate_content(
    model=MODEL,
    contents=[
        """Transcribe this audio file exactly as spoken.
Use a clean verbatim transcription in Hebrew.
Produce the transcription text only, do not add any other preamble or postamble text to the transcription.
Transcribe only the speaker, if there is a song, do not transcribe the song.""",
        audio_file,
    ],
)

print(f"\n--- Transcript using model {MODEL} ---\n")
# Print the transcription RTL to the console (Hebrew)
for line in response.text.split("\n"):
    print(line)
    # print(get_display(line))

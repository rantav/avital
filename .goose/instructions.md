# Instructions for creating a new blog posts
Your goal is to create a new blog post for each new mp3 file.

## Finding new mp3 files
- New mp3 files are added to the git repository. Use git status to check for new files. The files are in the _assets/audio directory.
- For each new mp3 file, create a new blog post, but check first - does it already have a blog post? If it does, do not create a new one. Check the existing post and if necessary improve it.

## Workflow
For every new mp3 file:
1. Transcribe the file.
2. Create a new blog post using the date of the mp3 file creation date and a short word slug derived from the mp3 file name.
3. Use existing image if an image with the name "avitalxx.jpg" already exists. If not - tell me and I will create a new image. Anyway the blog post must refer to that image, even if it still does not exist.
4. In the blog post: link to the MP3 file and to the image. Add the transcription after the "<!--more-->" placeholder. Do not add any other text to the blog post before the "<!--more-->" placeholder.

## Transcription
Transcription instructions:
Use a clean verbatim transcription in Hebrew.
Use Gemini for transcription like so:
`uv run python transcribe.py`
Read the output and use it for the blog post.

Based on the transcription, create a new blog post.

## Blog post creation
Requirements:
- Use the same front-matter structure as existing posts
- Keep it authentic, not over-polished. Use the same tone as the existing posts.
- Do not invent content not in the recording
- Title is exactly the same as the file name but without the previx "avitalxx" and the suffix ".mp3". For example: "avital26 הילד שהחליק.mp3" -> "הילד שהחליק".
- File name is a translation of the title from Hebrew to English and make it very short, e.g. "הילד שהחליק" -> "slipped".

Save the file under _posts with the mp3's file date.
- Posts must be in Hebrew (RTL)
- Do not over-edit spoken language
- Never hallucinate facts

## Episode number
Episode number instructions:
- Each episode has a unique number within a season.
- The numbers should be sequential and follow the previous episode number.
- If two episodes are published on the same day, the second episode should have a higher number.

## Episode photos
- Each episode has a unique photo.
- The photo should be in the _assets/img directory.
- The photo's name should be "avitalxx.jpg" where xx is the episode number taken from the mp3 file name.
- If creating a new blog post, leave the "photo-caption" empty.
- If updating an existing blog post do not change the photo or it's photo-caption.
setup:
	bundle install

serve:
	bundle exec jekyll serve

build:
	bundle exec jekyll build

# Check image dimensions
check-images:
	@./scripts/images.sh check

# Resize podcast images to 3000x3000 square format (center crop, no stretching)
resize-images:
	@./scripts/images.sh resize

# Resize podcast images to 3000x3000 with letterbox/padding (adds white borders)
resize-images-pad:
	@./scripts/images.sh resize-pad

goose:
	goose run -i .goose/instructions.md

add-episodes: goose resize-images serve



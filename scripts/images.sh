#!/bin/bash

# Podcast image management script
# iTunes/Apple Podcasts requirements:
# - Minimum: 1400x1400 pixels
# - Recommended: 3000x3000 pixels
# - Square (1:1 aspect ratio)
# - JPEG or PNG format

set -e

IMAGES_DIR="assets/img"
TARGET_SIZE=3000

check_images() {
    echo "Checking podcast image dimensions..."
    echo ""
    
    find "$IMAGES_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) ! -name "favicon.ico" | while read img; do
        width=$(sips -g pixelWidth "$img" 2>/dev/null | grep pixelWidth | awk '{print $2}')
        height=$(sips -g pixelHeight "$img" 2>/dev/null | grep pixelHeight | awk '{print $2}')
        size=$(ls -lh "$img" | awk '{print $5}')
        
        if [ -n "$width" ] && [ -n "$height" ]; then
            if [ "$width" = "$height" ]; then
                status="✓"
            else
                status="✗ NOT SQUARE"
            fi
            echo "$status $img: ${width} x ${height} ($size)"
        fi
    done
}

resize_images_crop() {
    echo "Resizing podcast images to ${TARGET_SIZE}x${TARGET_SIZE} (center crop)..."
    echo ""
    
    find "$IMAGES_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) ! -name "favicon.ico" | while read img; do
        echo "Processing $img..."
        
        width=$(sips -g pixelWidth "$img" 2>/dev/null | grep pixelWidth | awk '{print $2}')
        height=$(sips -g pixelHeight "$img" 2>/dev/null | grep pixelHeight | awk '{print $2}')
        
        if [ -n "$width" ] && [ -n "$height" ]; then
            if [ "$width" = "$TARGET_SIZE" ] && [ "$height" = "$TARGET_SIZE" ]; then
                echo "  ✓ Already ${TARGET_SIZE}x${TARGET_SIZE}"
                continue
            fi
            
            # Determine the smaller dimension for square crop
            if [ "$width" -lt "$height" ]; then
                crop_size=$width
            else
                crop_size=$height
            fi
            
            # Step 1: Center crop to square
            if sips --cropToHeightWidth "$crop_size" "$crop_size" "$img" --out "$img.tmp" 2>/dev/null; then
                # Step 2: Resize to target size
                if sips -z "$TARGET_SIZE" "$TARGET_SIZE" "$img.tmp" --out "$img.tmp2" 2>/dev/null; then
                    mv "$img.tmp2" "$img"
                    rm -f "$img.tmp"
                    echo "  ✓ Cropped and resized to ${TARGET_SIZE}x${TARGET_SIZE}"
                else
                    rm -f "$img.tmp" "$img.tmp2"
                    echo "  ✗ Failed to resize"
                fi
            else
                echo "  ✗ Failed to crop"
            fi
        fi
    done
    
    echo ""
    echo "Done!"
}

resize_images_pad() {
    echo "Resizing podcast images to ${TARGET_SIZE}x${TARGET_SIZE} (letterbox/pad)..."
    echo ""
    
    find "$IMAGES_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) ! -name "favicon.ico" | while read img; do
        echo "Processing $img..."
        
        width=$(sips -g pixelWidth "$img" 2>/dev/null | grep pixelWidth | awk '{print $2}')
        height=$(sips -g pixelHeight "$img" 2>/dev/null | grep pixelHeight | awk '{print $2}')
        
        if [ -n "$width" ] && [ -n "$height" ]; then
            if [ "$width" = "$TARGET_SIZE" ] && [ "$height" = "$TARGET_SIZE" ]; then
                echo "  ✓ Already ${TARGET_SIZE}x${TARGET_SIZE}"
                continue
            fi
            
            # Determine the larger dimension
            if [ "$width" -gt "$height" ]; then
                max_dim=$width
            else
                max_dim=$height
            fi
            
            # Step 1: Pad to square (adds white padding)
            if sips --padToHeightWidth "$max_dim" "$max_dim" "$img" --out "$img.tmp" 2>/dev/null; then
                # Step 2: Resize to target size
                if sips -z "$TARGET_SIZE" "$TARGET_SIZE" "$img.tmp" --out "$img.tmp2" 2>/dev/null; then
                    mv "$img.tmp2" "$img"
                    rm -f "$img.tmp"
                    echo "  ✓ Padded and resized to ${TARGET_SIZE}x${TARGET_SIZE}"
                else
                    rm -f "$img.tmp" "$img.tmp2"
                    echo "  ✗ Failed to resize"
                fi
            else
                echo "  ✗ Failed to pad"
            fi
        fi
    done
    
    echo ""
    echo "Done!"
}

usage() {
    echo "Usage: $0 <command>"
    echo ""
    echo "Commands:"
    echo "  check       - Check image dimensions and report which need resizing"
    echo "  resize      - Resize images using center crop (default, no stretching)"
    echo "  resize-pad  - Resize images using letterbox/padding (adds white borders)"
    echo ""
    echo "iTunes/Apple Podcasts requirements:"
    echo "  - Minimum: 1400x1400 pixels"
    echo "  - Recommended: 3000x3000 pixels"
    echo "  - Square (1:1 aspect ratio)"
    echo "  - JPEG or PNG format"
}

# Main
case "${1:-}" in
    check)
        check_images
        ;;
    resize)
        resize_images_crop
        ;;
    resize-pad)
        resize_images_pad
        ;;
    *)
        usage
        exit 1
        ;;
esac

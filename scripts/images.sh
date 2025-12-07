#!/bin/bash

# Podcast image management script
# iTunes/Apple Podcasts requirements:
# - Minimum: 1400x1400 pixels
# - Recommended: 3000x3000 pixels
# - Square (1:1 aspect ratio)
# - JPEG or PNG format
# - File size: under 512 KB recommended

set -e

IMAGES_DIR="assets/img"
TARGET_SIZE=3000
MAX_FILE_SIZE_KB=512
JPEG_QUALITY=30  # Adjust to get under 512KB at 3000x3000

check_images() {
    echo "Checking podcast image dimensions and file sizes..."
    echo ""
    
    find "$IMAGES_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) ! -name "favicon.ico" | while read img; do
        width=$(sips -g pixelWidth "$img" 2>/dev/null | grep pixelWidth | awk '{print $2}')
        height=$(sips -g pixelHeight "$img" 2>/dev/null | grep pixelHeight | awk '{print $2}')
        size_bytes=$(stat -f%z "$img" 2>/dev/null || stat -c%s "$img" 2>/dev/null)
        size_kb=$((size_bytes / 1024))
        size_human=$(ls -lh "$img" | awk '{print $5}')
        
        if [ -n "$width" ] && [ -n "$height" ]; then
            # Check dimensions
            if [ "$width" = "$height" ]; then
                dim_status="✓"
            else
                dim_status="✗ NOT SQUARE"
            fi
            
            # Check file size
            if [ "$size_kb" -le "$MAX_FILE_SIZE_KB" ]; then
                size_status="✓"
            else
                size_status="✗ TOO LARGE"
            fi
            
            echo "$dim_status $size_status $img: ${width}x${height} ($size_human)"
        fi
    done
}

compress_jpeg() {
    local input="$1"
    local output="$2"
    local quality="$3"
    
    # Convert to JPEG with specified quality
    sips -s format jpeg -s formatOptions "$quality" "$input" --out "$output" 2>/dev/null
}

resize_images_crop() {
    echo "Resizing podcast images to ${TARGET_SIZE}x${TARGET_SIZE} (center crop, compressed)..."
    echo ""
    
    find "$IMAGES_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) ! -name "favicon.ico" | while read img; do
        echo "Processing $img..."
        
        width=$(sips -g pixelWidth "$img" 2>/dev/null | grep pixelWidth | awk '{print $2}')
        height=$(sips -g pixelHeight "$img" 2>/dev/null | grep pixelHeight | awk '{print $2}')
        
        if [ -n "$width" ] && [ -n "$height" ]; then
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
                    # Step 3: Compress to JPEG under 512KB
                    # Get the base name without extension for output
                    base_name="${img%.*}"
                    output_file="${base_name}.jpg"
                    
                    if compress_jpeg "$img.tmp2" "$img.tmp3" "$JPEG_QUALITY"; then
                        # Check if we need to remove the original (different extension)
                        if [ "$img" != "$output_file" ]; then
                            rm -f "$img"
                        fi
                        mv "$img.tmp3" "$output_file"
                        rm -f "$img.tmp" "$img.tmp2"
                        
                        # Report final size
                        final_size=$(ls -lh "$output_file" | awk '{print $5}')
                        echo "  ✓ Cropped, resized to ${TARGET_SIZE}x${TARGET_SIZE}, compressed ($final_size)"
                    else
                        rm -f "$img.tmp" "$img.tmp2" "$img.tmp3"
                        echo "  ✗ Failed to compress"
                    fi
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
    echo "Resizing podcast images to ${TARGET_SIZE}x${TARGET_SIZE} (letterbox/pad, compressed)..."
    echo ""
    
    find "$IMAGES_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) ! -name "favicon.ico" | while read img; do
        echo "Processing $img..."
        
        width=$(sips -g pixelWidth "$img" 2>/dev/null | grep pixelWidth | awk '{print $2}')
        height=$(sips -g pixelHeight "$img" 2>/dev/null | grep pixelHeight | awk '{print $2}')
        
        if [ -n "$width" ] && [ -n "$height" ]; then
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
                    # Step 3: Compress to JPEG under 512KB
                    base_name="${img%.*}"
                    output_file="${base_name}.jpg"
                    
                    if compress_jpeg "$img.tmp2" "$img.tmp3" "$JPEG_QUALITY"; then
                        if [ "$img" != "$output_file" ]; then
                            rm -f "$img"
                        fi
                        mv "$img.tmp3" "$output_file"
                        rm -f "$img.tmp" "$img.tmp2"
                        
                        final_size=$(ls -lh "$output_file" | awk '{print $5}')
                        echo "  ✓ Padded, resized to ${TARGET_SIZE}x${TARGET_SIZE}, compressed ($final_size)"
                    else
                        rm -f "$img.tmp" "$img.tmp2" "$img.tmp3"
                        echo "  ✗ Failed to compress"
                    fi
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
    echo "  check       - Check image dimensions and file sizes"
    echo "  resize      - Resize images using center crop (converts to compressed JPEG)"
    echo "  resize-pad  - Resize images using letterbox/padding (converts to compressed JPEG)"
    echo ""
    echo "iTunes/Apple Podcasts requirements:"
    echo "  - Minimum: 1400x1400 pixels"
    echo "  - Recommended: 3000x3000 pixels"
    echo "  - Square (1:1 aspect ratio)"
    echo "  - JPEG or PNG format"
    echo "  - File size: under 512 KB recommended"
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

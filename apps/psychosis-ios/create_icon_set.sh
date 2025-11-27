#!/bin/bash

# Script to generate iOS App Icon set from source image
# Usage: ./create_icon_set.sh <source_image> <output_dir>

SOURCE_IMAGE="$1"
OUTPUT_DIR="$2"

if [ -z "$SOURCE_IMAGE" ] || [ -z "$OUTPUT_DIR" ]; then
    echo "Usage: $0 <source_image> <output_dir>"
    exit 1
fi

if [ ! -f "$SOURCE_IMAGE" ]; then
    echo "Error: Source image not found: $SOURCE_IMAGE"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

echo "Generating iOS App Icon set from $SOURCE_IMAGE..."

# iOS App Icon sizes (in pixels)
# Format: size filename scale
declare -a SIZES=(
    "40 AppIcon-20@2x.png 2x"
    "60 AppIcon-20@3x.png 3x"
    "58 AppIcon-29@2x.png 2x"
    "87 AppIcon-29@3x.png 3x"
    "80 AppIcon-40@2x.png 2x"
    "120 AppIcon-40@3x.png 3x"
    "120 AppIcon-60@2x.png 2x"
    "180 AppIcon-60@3x.png 3x"
    "76 AppIcon-76@1x.png 1x"
    "152 AppIcon-76@2x.png 2x"
    "167 AppIcon-83.5@2x.png 2x"
    "1024 AppIcon-1024.png 1x"
)

for size_info in "${SIZES[@]}"; do
    read -r size filename scale <<< "$size_info"
    output_path="$OUTPUT_DIR/$filename"
    
    echo "  Generating $filename ($size x $size)..."
    sips -z $size $size "$SOURCE_IMAGE" --out "$output_path" > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        echo "    ✓ Created $filename"
    else
        echo "    ✗ Failed to create $filename"
    fi
done

echo ""
echo "Icon set generation complete!"
echo "Icons saved to: $OUTPUT_DIR"


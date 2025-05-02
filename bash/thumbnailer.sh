#!/bin/bash

# Check if exactly two arguments are passed
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <input-folder> <output-folder>"
  exit 1
fi

# Assign arguments to variables
INPUT_FOLDER="$1"
OUTPUT_FOLDER="$2"

# Check if folder1 exists and is a directory
if [ ! -d "$INPUT_FOLDER" ]; then
  echo "Error: '$INPUT_FOLDER' is not a directory"
  exit 1
fi

# Ensure output folder exists
mkdir -p "$OUTPUT_FOLDER"

# Number of thumbnails to extract (e.g., 6x6 = 36)
NUM_THUMBS=49
ROWS=7
COLS=7

# Process each video file in the input folder
for video in "$INPUT_FOLDER"/*.mp4 "$INPUT_FOLDER"/*.ts "$INPUT_FOLDER"/*.mkv; do
    if [[ ! -f "$video" ]]; then
        continue
    fi

    # Get filename without extension
    video_name=$(basename "$video")
    video_name="${video_name%.*}"
    
    # Create a temporary folder for thumbnails
    temp_folder="$OUTPUT_FOLDER/$video_name"
    mkdir -p "$temp_folder"

    # Extract video duration in seconds (FIXED)
    duration=$(ffprobe -v error -select_streams v:0 -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$video" | awk '{print int($1)}')

    # Debugging output
    echo "Processing: $video"
    echo "Duration: $duration seconds"

    # Check if duration is valid
    if [[ -z "$duration" || "$duration" -le 0 ]]; then
        echo "Skipping $video (could not determine duration)"
        continue
    fi

    # Calculate interval for evenly spaced frames
    interval=$(echo "$duration / ($NUM_THUMBS + 1)" | bc)

    echo "Extracting thumbnails from $video..."

    # Extract 36 evenly spaced thumbnails
    for i in $(seq 1 $NUM_THUMBS); do
        timestamp=$(echo "$i * $interval" | bc)
        ffmpeg -ss "$timestamp" -i "$video" -frames:v 1 -q:v 2 -vf "scale=iw*0.2:ih*0.2" "$temp_folder/thumb_$(printf "%02d" $i).jpg" -hide_banner -loglevel error
    done

    # Create a 6x6 collage using ImageMagick
    collage_output="$OUTPUT_FOLDER/${video_name}_collage.jpg"
    montage "$temp_folder/thumb_*.jpg" -tile "${COLS}x${ROWS}" -geometry +2+2 "$collage_output"

    echo "Collage created: $collage_output"

    # Cleanup temporary folder
    rm -rf "$temp_folder"
done

echo "✅ All videos processed!"

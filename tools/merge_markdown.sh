#!/bin/bash

# Initialize default values
output_folder=""
output_filename="merged_markdown.md"

# Function to display usage help
usage() {
  echo "Usage: $0 -i <input_folder> [-o <output_folder>] [-n <output_filename>]"
  exit 1
}

# Parse command line options
while getopts "i:o:n:" opt; do
  case $opt in
    i) input_folder="$OPTARG" ;;
    o) output_folder="$OPTARG" ;;
    n) output_filename="$OPTARG" ;;
    ?) usage ;;
  esac
done

# Check if input folder was provided
if [ -z "$input_folder" ]; then
  echo "Input folder is required."
  usage
fi

# Check if the input folder exists
if [ ! -d "$input_folder" ]; then
  echo "The input directory $input_folder does not exist."
  exit 1
fi

# If output folder wasn't provided, use input folder
if [ -z "$output_folder" ]; then
  output_folder="$input_folder"
fi

# Ensure output folder exists, if not, create it
if [ ! -d "$output_folder" ]; then
  echo "The output directory $output_folder does not exist. Creating it now."
  mkdir -p "$output_folder"
fi

# Define the output file path
output_file="$output_folder/$output_filename"

# Check if output file exists in the input folder, abort to avoid infinite loop
if [ "$input_folder" == "$output_folder" ]; then
  if [ -f "$output_file" ]; then
    echo "The output file cannot be in the input directory. This would cause an infinite loop."
    exit 1
  fi
fi

# Create or clear the output file
> "$output_file"

# Loop through the .md files and append them to the output file
for file in "$input_folder"/*.md; do
  # Skip if the file is the output file (useful if output folder is same as input)
  if [ "$(realpath "$file")" == "$(realpath "$output_file")" ]; then
    continue
  fi

  # Check if the file variable points to an actual file
  if [ -f "$file" ]; then
    echo "Appending $file to $output_file"
    cat "$file" >> "$output_file"
    # Optional: Add a newline between files
    echo -e "\n" >> "$output_file"
  fi
done

echo "Merging complete! Output file: $output_file"

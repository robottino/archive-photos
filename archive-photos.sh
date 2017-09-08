#!/bin/bash

# SYNOPSIS:
# archive-photos <source_dir> <target_dir>

SRC_DIR="$1"
TARGET_DIR="$2"

# Copy every file in a temp dir

echo "Copying files into temporary folder: ${WORK_DIR}..."
WORK_DIR="$(mktemp -d -p . -t XXXXXXXX)"
exiftool -o . -filename="${WORK_DIR}"/%d%f.%e -if '($filetype eq "JPEG")' -r "${SRC_DIR}"

#Update any photo that doesn't have DateTimeOriginal to have it based on file modify date

echo "Fixing pictures without exif data..."
exiftool '-datetimeoriginal<filemodifydate' -if '(not $datetimeoriginal or ($datetimeoriginal eq "0000:00:00 00:00:00")) and ($filetype eq "JPEG")' -r "${WORK_DIR}"

#Backup images

echo "Backup..."
exiftool -o . '-FileName<DateTimeOriginal' -if '($filetype eq "JPEG")' -d "${TARGET_DIR}/%Y-%m-%d/%Y-%m-%d_%H.%M.%S%%-.2c.jpg" -r "${WORK_DIR}"

rm -rf "${WORK_DIR}"

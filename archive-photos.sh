#!/bin/bash

# SYNOPSIS:
# archive-photos <source_dir> <target_dir>

SRC_DIR="$1"
TARGET_DIR="$2"

if [ -d "${TARGET_DIR}" ]; then
	read -p "Directory \"${TARGET_DIR}\" already exists: overwrite (Y/*)?" yn;
	case $yn in
		""|"Y"|"y") echo "yes";;
		*) echo "no"; exit 0;;
	esac
fi

# Copy every file in a temp dir

WORK_DIR="$(mktemp -d -p . -t XXXXXXXX)"
echo "Copying files into temporary folder: ${WORK_DIR}..."
exiftool -o . -v0 -progress -filename="${WORK_DIR}"/%d%f.%e -if '($filetype eq "JPEG")' -r "${SRC_DIR}"

#remove duplicates
echo "Removing duplicates..."
fdupes -rdN "${WORK_DIR}"

#Update any photo that doesn't have DateTimeOriginal to have it based on file modify date

echo "Fixing pictures without exif data..."
exiftool -v0 -progress '-datetimeoriginal<filemodifydate' -if '(not $datetimeoriginal or ($datetimeoriginal eq "0000:00:00 00:00:00")) and ($filetype eq "JPEG")' -r "${WORK_DIR}"

#Backup images

echo "Backup..."
exiftool -o . -v0 -progress '-FileName<DateTimeOriginal' -if '($filetype eq "JPEG")' -d "${TARGET_DIR}/%Y-%m/%Y-%m-%d_%H.%M.%S%%-.2c.jpg" -r "${WORK_DIR}"

rm -rf "${WORK_DIR}"

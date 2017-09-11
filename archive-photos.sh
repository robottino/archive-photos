#!/bin/bash

# SYNOPSIS:
# archive-photos <source_dir> <target_dir> <file_type>

SRC_DIR="$1"
TARGET_DIR="$2"
FILE_TYPE="$3"

#set proper extension
case ${FILE_TYPE} in
	"JPEG") FILE_EXTENSION="jpg"; DESIRED_MIME="image/jpeg" ;;
	"MP4") FILE_EXTENSION="mp4"; DESIRED_MIME="video/mp4" ;;
	*) echo "Supported file types: JPEG, MP4."; exit 0;;
esac

if [ -d "${TARGET_DIR}" ]; then
	read -p "Directory \"${TARGET_DIR}\" already exists: overwrite [(Y)es/(m)erge/*]?" yn;
	case $yn in
		""|"Y"|"y") rm -rf "${TARGET_DIR}";;
		"M"|"m") ;;
		*) exit 0;;
	esac
fi

#echo "continue program"; exit 0;

# Copy every file in a temp dir

WORK_DIR="$(mktemp -d -p . -t XXXXXXXX)"
echo "Copying files into temporary folder: ${WORK_DIR}..."
#exiftool -o . -v0 -progress -filename="${WORK_DIR}"/%d%f.%e -if '($filetype eq "'${FILE_TYPE}'")' -r "${SRC_DIR}"

export DESIRED_MIME
export WORK_DIR
export N=1
find "${SRC_DIR}" -type f -exec bash -c 'MIME=$(file -bi "{}" | cut -d\; -f1); if [ "${MIME}" == "${DESIRED_MIME}" ]; then echo -n "."; cp --parents "{}" "${WORK_DIR}"; fi' \;

#remove duplicates
echo "Removing duplicates..."
fdupes -rdN "${WORK_DIR}"

#Update any photo that doesn't have DateTimeOriginal to have it based on file modify date
#echo "Fixing pictures without exif data..."
#exiftool -v0 -progress '-datetimeoriginal<CreateDate' -if '(not $datetimeoriginal or ($datetimeoriginal eq "0000:00:00 00:00:00")) and ($filetype eq "'${FILE_TYPE}'")' -r "${WORK_DIR}"

#Backup images

echo "Backup files without TAG DateTimeOriginal (using TAG CreateDate instead)..."
exiftool -v0 -progress '-FileName<CreateDate' -if '(not $datetimeoriginal or ($datetimeoriginal eq "0000:00:00 00:00:00")) and ($filetype eq "'${FILE_TYPE}'")' -d "${TARGET_DIR}/%Y-%m/%Y-%m-%d_%H.%M.%S%%-.2c.${FILE_EXTENSION}" -r "${WORK_DIR}"

echo "Backup files with proper TAG DateTimeOriginal..."
exiftool -v0 -progress '-FileName<DateTimeOriginal' -if '($filetype eq "'${FILE_TYPE}'")' -d "${TARGET_DIR}/%Y-%m/%Y-%m-%d_%H.%M.%S%%-.2c.${FILE_EXTENSION}" -r "${WORK_DIR}"


rm -rf "${WORK_DIR}"

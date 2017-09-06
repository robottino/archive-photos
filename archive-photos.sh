#!/bin/bash

DIR="$1"
echo "DIR=${DIR}"

#remove duplicates
#fdupes -rdN "${DIR}"

#copy jpgs and apply naming convention

PHASE1_DIR="archive-pictures.phase1"

if [ -d "${PHASE1_DIR}" ]; then rm -rf "${PHASE1_DIR}"; fi
mkdir "${PHASE1_DIR}"

archive () {
	#archive <filename> <destination_dir>
	FILE="$1"
	DEST_DIR="$2"
	echo "DD=${DEST_DIR}"
	FILENAME_PATTERN="%Y-%m-%d/%Y-%m-%d_%H.%M.%S"
	
	COUNTER=0
	COUNTER_PAD=$(printf "%03d\n" ${COUNTER})
	TARGET_FILE_NAME_BASE=$(exiftool -json -dateformat "${DEST_DIR}/${FILENAME_PATTERN}" "${FILE}" | jq --raw-output '.[].DateTimeOriginal')
	echo "TFNB=${TARGET_FILE_NAME_BASE}"
	
	if [ "${TARGET_FILE_NAME_BASE}" != "null" ]; then
	
		TARGET_FILE_NAME="${TARGET_FILE_NAME_BASE}-${COUNTER_PAD}.jpg"
		echo "C=${COUNTER}, TFN=${TARGET_FILE_NAME}"
		
		while [ -f "${TARGET_FILE_NAME}" ]; do
			COUNTER=$((${COUNTER} + 1))
			COUNTER_PAD=$(printf "%03d\n" ${COUNTER})
			echo ${COUNTER_PAD}
			TARGET_FILE_NAME="${TARGET_FILE_NAME_BASE}-${COUNTER_PAD}.jpg"
			echo "+1 (${COUNTER}), ${TARGET_FILE_NAME}"
		done
	
		echo "copying ${FILE} --> ${TARGET_FILE_NAME}"
		echo mkdir -p "${TARGET_FILE_NAME}"
		mkdir -p "${TARGET_FILE_NAME}"
		cp "${FILE}" "${TARGET_FILE_NAME}"
		
		read -p "pausa"
		
	else
		echo "nuuuuuuuuuuuuuuuuuuuuuulll"
		echo ${FILE} >> errors
	fi
}
export -f archive

find "${DIR}" -iname '*.jpg' -type f -exec bash -c 'archive "{}" '"${PHASE1_DIR}" \;


exit 0

find "${DIR}" -iname '*.jpg' -type f | while read FILE; do
	echo "FILE=${FILE}"
	
	COUNTER=0
	COUNTER_PAD=$(printf "%03d\n" ${COUNTER})
	TARGET_FILE_NAME_BASE=$(exiftool -json -dateformat "${PHASE1_DIR}/${FILENAME_PATTERN}" "${FILE}" | jq --raw-output '.[].DateTimeOriginal')
	echo "TFNB=${TARGET_FILE_NAME_BASE}"
	
	if [ "${TARGET_FILE_NAME_BASE}" != "null" ]; then
	
		TARGET_FILE_NAME="${TARGET_FILE_NAME_BASE}-${COUNTER_PAD}.jpg"
		echo "C=${COUNTER}, TFN=${TARGET_FILE_NAME}"
		
		while [ -f "${TARGET_FILE_NAME}" ]; do
			COUNTER=$((${COUNTER} + 1))
			COUNTER_PAD=$(printf "%03d\n" ${COUNTER})
			echo ${COUNTER_PAD}
			TARGET_FILE_NAME="${TARGET_FILE_NAME_BASE}-${COUNTER_PAD}.jpg"
			echo "+1 (${COUNTER}), ${TARGET_FILE_NAME}"
		done
	
		echo "copying ${FILE} --> ${TARGET_FILE_NAME}"
		echo mkdir -p "${TARGET_FILE_NAME}"
		mkdir -p "${TARGET_FILE_NAME}"
		cp "${FILE}" "${TARGET_FILE_NAME}"
		
	else
		echo "nuuuuuuuuuuuuuuuuuuuuuulll"
		echo ${FILE} >> errors
	fi
	
done

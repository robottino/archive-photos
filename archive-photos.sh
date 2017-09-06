#!/bin/bash

FILENAME_PATTERN="%Y-%m-%d/%Y-%m-%d_%H.%M.%S"
#echo ${FILENAME_PATTERN}
DIR="$1"


#remove duplicates
#fdupes -rdN "${DIR}"

#copy jpgs and apply naming convention

PHASE1_DIR="archive-pictures.phase1"
if [ -d "${PHASE1_DIR}" ]; then rm -rf "${PHASE1_DIR}"; fi
mkdir "${PHASE1_DIR}"

find "${DIR}" -iname \*.jpg -type f | while read FILE; do
	echo ${FILE}
	
	COUNTER=0
	COUNTER_PAD=$(printf "%03d\n" ${COUNTER})
	TARGET_FILE_NAME_BASE=$(exiftool -json -dateformat "${PHASE1_DIR}/${FILENAME_PATTERN}" "${FILE}" | jq --raw-output '.[].DateTimeOriginal')
	
	if [ ${TARGET_FILE_NAME_BASE} != "null" ]; then
	
		TARGET_FILE_NAME="${TARGET_FILE_NAME_BASE}-${COUNTER_PAD}.jpg"
		echo "(${COUNTER}), ${TARGET_FILE_NAME}"
		
		while [ -f ${TARGET_FILE_NAME} ]; do
			COUNTER=$((${COUNTER} + 1))
			COUNTER_PAD=$(printf "%03d\n" ${COUNTER})
			echo ${COUNTER_PAD}
			TARGET_FILE_NAME="${TARGET_FILE_NAME_BASE}-${COUNTER_PAD}.jpg"
			echo "+1 (${COUNTER}), ${TARGET_FILE_NAME}"
		done
	
		echo ${TARGET_FILE_NAME}
		mkdir -p "${TARGET_FILE_NAME}" && cp "${FILE}" "${TARGET_FILE_NAME}"

	else
		echo "nuuuuuuuuuuuuuuuuuuuuuulll"
		echo ${FILE} >> errors
	fi
	
done

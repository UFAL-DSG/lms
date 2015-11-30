#!/usr/bin/env bash

LANG=$1
TMP=$2

export IRSTLM=./tools/
BIN_PATH=./tools/bin

mkdir -p $TMP

SOURCE="xzcat ${TMP}/${LANG}.xz"
#SOURCE="xzcat ${TMP}/${LANG}.xz | head -n 1000000"
FILTER="LC_ALL=C.UTF-8 tr '[:lower:]' '[:upper:]' | LC_ALL=C.UTF-8 tr 'ěščřžýáíéůúóďťňöäëü' 'ĚŠČŘŽÝÁÍÉŮÚÓĎŤŇÖÄËÜ'"

[ ! -f "$TMP/${LANG}.xz" ] && wget http://data.statmt.org/ngrams/deduped/${LANG}.xz -O $TMP/${LANG}.xz

[ ! -f "${TMP}/01_dict.full" ] && ${BIN_PATH}/dict -i="$SOURCE | $FILTER | ${BIN_PATH}/add-start-end.sh" \
    -o=${TMP}/01_dict.full -f=y -sort=y

[ ! -f "${TMP}/02_dict.small" ] && ./src/clean_dict.py -n 120000 -l $LANG ${TMP}/01_dict.full ${TMP}/02_dict.small

[ ! -f "${TMP}/03_ilm.gz" ] && ${BIN_PATH}/build-lm.sh -b -s improved-shift-beta \
    -i "$SOURCE | $FILTER | ${BIN_PATH}/add-start-end.sh" \
    -n 5 -o ${TMP}/03_ilm.gz -k 5 -p \
    -t ${TMP}/stat

[ ! -f "${TMP}/04_lm_filtered.arpa" ] && ${BIN_PATH}/compile-lm ${TMP}/03_ilm.gz ${TMP}/04_lm_filtered.arpa \
    --filter=${TMP}/02_dict.small --keepunigrams=no --text=yes

[ ! -f "${TMP}/05_lm_pruned.arpa" ] && ${BIN_PATH}/prune-lm --threshold=1e-7 ${TMP}/04_lm_filtered.arpa ${TMP}/05_lm_pruned.arpa

cp ${TMP}/05_lm_pruned.arpa ./lang/${LANG}.arpa

echo "LMS finished OK!"
exit 0

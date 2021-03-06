#!/usr/bin/env bash

LANG=$1
TMP=$2
NW=$3
NS=$4

export IRSTLM=./tools/
BIN_PATH=./tools/bin


mkdir -p $TMP

SOURCE="xzcat -Q ${TMP}/${LANG}.xz"
SOURCE="xzcat -Q ${TMP}/${LANG}.xz | head -n $NS"
#FILTER="LC_ALL=${LOCALE}.UTF-8 tr '[:lower:]' '[:upper:]' | LC_ALL=C.UTF-8 tr '?,.:ěščřžýáíéůúóďťňöäëüïÿåõñìèàîîêôôûâçòæ' '    ĚŠČŘŽÝÁÍÉŮÚÓĎŤŇÖÄËÜÏŸÅÕÑÌÈÀÎÎÊÔÔÛÂÇÒÆ'"
FILTER="python3 ./src/upper.py"

[ ! -f "$TMP/${LANG}.xz" ] && wget http://data.statmt.org/ngrams/deduped/${LANG}.xz -O $TMP/${LANG}.xz

[ ! -f "${TMP}/01_dict.full" ] && ${BIN_PATH}/dict -i="$SOURCE | $FILTER | ${BIN_PATH}/add-start-end.sh" \
    -o=${TMP}/01_dict.full -f=y -sort=y

[ ! -f "${TMP}/02_dict.small" ] && ./src/clean_dict.py -n $NW -l $LANG ${TMP}/01_dict.full ${TMP}/02_dict.small

[ ! -f "${TMP}/03_ilm.gz" ] && ${BIN_PATH}/build-lm.sh \
    -b \
    -i "$SOURCE | $FILTER | ${BIN_PATH}/add-start-end.sh" \
    -n 5 -o ${TMP}/03_ilm.gz \
    -k 6 \
    -p \
    -t ${TMP}/stat \
    -d ${TMP}/02_dict.small

[ ! -f "${TMP}/04_lm_filtered.arpa" ] && ${BIN_PATH}/compile-lm ${TMP}/03_ilm.gz /dev/stdout \
    --filter=${TMP}/02_dict.small \
    --keepunigrams=no --text=yes | gzip -c > ${TMP}/04_lm_filtered.arpa.gz

[ ! -f "${TMP}/05_lm_pruned.arpa.gz" ] && ${BIN_PATH}/prune-lm --threshold=1e-7 ${TMP}/04_lm_filtered.arpa.gz /dev/stdout | gzip -c > ${TMP}/05_lm_pruned.arpa.gz

[ -f "${TMP}/05_lm_pruned.arpa.gz" ] && cp ${TMP}/05_lm_pruned.arpa.gz ./lang/${LANG}.arpa.gz

echo "LMS finished OK!"
exit 0

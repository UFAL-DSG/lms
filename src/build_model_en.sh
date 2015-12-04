#!/usr/bin/env bash

LANG=en
TMP=tmp/en
NW=$1
NS=$2

export IRSTLM=./tools/
BIN_PATH=./tools/bin


mkdir -p $TMP

SOURCE="xzcat -Q ${TMP}/en.10.xz ${TMP}/en.90.xz | head -n $NS"
FILTER="python3 ./src/upper.py"

[ ! -f "$TMP/en.10.xz" ] && wget http://data.statmt.org/ngrams/deduped_en/en.10.xz -O $TMP/en.10.xz
[ ! -f "$TMP/en.90.xz" ] && wget http://data.statmt.org/ngrams/deduped_en/en.90.xz -O $TMP/en.90.xz

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

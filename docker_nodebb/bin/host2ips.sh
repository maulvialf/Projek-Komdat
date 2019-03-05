#!/bin/bash -e
SEPARATOR=" "
SERVER=""
while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    --separator)
    SEPARATOR="$2"
    shift
    ;;
    --server)
    SERVER="$2"
    shift
    ;;
    *)
      # unknown option
    ;;
esac
shift # past argument or value
done

HOST="$1"
if [[ -z "${HOST}" ]]; then
    echo -e "Usage:\n$0 --separator SEPARATOR HOST" && exit 1
fi
EXPANDED_HOSTS=""
ADDRESSES="$(nslookup "${HOST}" ${SERVER}| sed -En 's|Address: (.*)|\1|p')"
MUSTSEPARATE=0
for IP in ${ADDRESSES}; do
  test ${MUSTSEPARATE} -eq 1 && EXPANDED_HOSTS="${EXPANDED_HOSTS}${SEPARATOR}"
  EXPANDED_HOSTS="${EXPANDED_HOSTS}${IP}"
  MUSTSEPARATE=1
done

echo ${EXPANDED_HOSTS}
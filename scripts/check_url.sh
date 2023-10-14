#!/bin/bash
#
# Simple script to wait HTTP 200 Status Code from defined URL
#
set -euo pipefail

URL="$1"
STATUS_CODE=""

while [ "$STATUS_CODE" != "200" ]; do
    RESPONSE=$(
        curl -kL -m 5 --write-out '%{http_code}\n %{exitcode}\n %{errormsg}\n'\
         --silent --output /dev/null "${URL}"
    ) || echo -n ""; # It's workaround for GitLab pipelines avoid exit code 1

    TIMESTAMP=$(date);
    STATUS_CODE="$(echo "$RESPONSE" | sed -n '1p')"
    EXIT_CODE="$(echo "$RESPONSE" | sed -n '2p')"
    MESSAGE="$(echo "$RESPONSE" | sed -n '3p')"
    
    echo "$TIMESTAMP $URL $STATUS_CODE $EXIT_CODE $MESSAGE" ;
    sleep 10;
done

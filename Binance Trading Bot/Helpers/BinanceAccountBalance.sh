#!/bin/bash
SIGNATURE=$(echo -n "timestamp=$TIMESTAMP" | \
    openssl dgst -sha256 -sign "$BN_API_PRIVATE_KEY_PATH" -passin pass:"$BN_API_PASS" | \
    openssl enc -base64 -A)

BALANCE=$(curl -H "X-MBX-APIKEY: $API_KEY" -X GET "https://api.binance.com/api/v3/papi/v1/balance?timestamp=$TIMESTAMP&signature=$SIGNATURE")
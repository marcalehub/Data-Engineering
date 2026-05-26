# !/bin/bash
TIMESTAMP="$(date +%s%3N)"
SIGNATURE=$(echo -n "timestamp=$TIMESTAMP" | \
    openssl dgst -sha256 -sign "$BN_API_PRIVATE_KEY_PATH" -passin pass:"$BN_API_PASS" | \
    openssl enc -base64 -A)

RESPONSE=$(curl -H "X-MBX-APIKEY: $API_KEY" -X GET "https://api.binance.com/api/v3/papi/v1/balance?timestamp=$TIMESTAMP&signature=$SIGNATURE")

BALANCE=$(echo $RESPONSE | jq -r '.balance' | awk '{printf "%.4f", $0}')

if [[ $(echo "$BALANCE < 0" | bc -l) ]]; then
    BALANCE="0.0000"
fi

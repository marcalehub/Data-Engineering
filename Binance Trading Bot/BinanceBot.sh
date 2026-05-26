#!/bin/bash
SYMBOL="BTCUSDT"
TYPE="MARKET"
BALANCE=$(bash "$PWD/Helpers/BinanceAccountBalance.sh" | jq -r '.balance')
QUANTITY="0.001"
QUANTITY_DECIMAL=$(echo "$QUANTITY" | bc)
ENDPOINT="https://api.binance.com/api/v3/order"
LOCATION="$PWD"
VENV_PYTHON="$LOCATION/binance/bin/python3"
mkdir -p "$LOCATION/DATA" && mkdir -p "$LOCATION/DATA/PPO"

# if [[ "$BALANCE" -le "$QUANTITY_DECIMAL" ]]; then
#     echo "Insufficient balance to trade. Exiting."
#     exit
# fi

while true
do
    curl -s "https://api.binance.com/api/v3/klines?symbol=$SYMBOL&interval=1m&limit=100" > "$LOCATION/DATA/KLINE.json"

    prediction=$("$VENV_PYTHON" -u "$LOCATION/Models/RL/BinancePredict.py")
    echo "ML Prediction: $prediction"

    TIMESTAMP="$(date +%s%3N)"
    
    if [[ "$prediction" == "1" || "$prediction" == "2" ]];then
        SIDE="BUY"
        [[ "$prediction" == "2" ]] && SIDE="SELL"
        echo "ML $SIDE $SYMBOL at $(date)"

        # QUERY_STRING="symbol=$SYMBOL&side=$SIDE&type=$TYPE&quantity=$QUANTITY&timestamp=$TIMESTAMP"

        # SIGNATURE=$(echo -n "$QUERY_STRING" | \
        #     openssl dgst -sha256 -sign "$BN_API_PRIVATE_KEY_PATH" -passin pass:"$BN_API_PASS" | \
        #     openssl enc -base64 -A)

        # RESPONSE=$(curl -H "X-MBX-APIKEY: $API_KEY" -X POST "$ENDPOINT" \
        #     -d "$QUERY_STRING&signature=$SIGNATURE")
        
        # echo "Binance Response: $RESPONSE"

    else
        echo "ML HOLD $SYMBOL at $(date)"
    
    fi
    
    sleep 60

done
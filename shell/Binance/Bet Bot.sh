digital_coin="BTCUSDT"
bet_quantity=0.001
query_string="timestamp=$(date +%s%3N)"
signature=$(echo -n "$query_string" | \
            openssl dgst -sha256 -sign "$BN_API_PRIVATE_KEY_PATH" -passin pass:"$BN_API_PASS" | \
            openssl enc -base64 -A)

#curl -H "X-MBX-APIKEY: $BN_API_KEY" -X GET \
#"https://api.binance.com/api/v3/account?$query_string&signature=$signature"

while true
do
    location="$PWD"
    curl -s "https://api.binance.com/api/v3/klines?symbol=$digital_coin&interval=1m&limit=100" > "$location/shell/Binance/api data/$digital_coin KLINE DATA.json"
    #prediction=$(python3 -c binance_machine_learning_reinforcement_learning.py)
    predition=1
    if[ $prediction == "1" ]; then
        echo "ML Buying $digital_coin"
        #curl -X POST "https://api.binance.com/api/v3/order" \
        #-d "symbol=$digital_coin&timeInForce=GTC&side=BUY&type=MARKET&quantity=$bet_quantity"

    elif [ $prediction == "2" ]; then
        echo "ML Selling $digital_coin"
        #curl -X POST "https://api.binance.com/api/v3/order" \
        #-d "symbol=$digital_coin&timeInForce=GTC&side=SELL&type=MARKET&quantity=$bet_quantity"
    
    else
        echo "ML Holding $digital_coin"
        
    fi
    sleep 120 # wait for 120 seconds before the next request
done
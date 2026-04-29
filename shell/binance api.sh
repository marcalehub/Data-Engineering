#Binance API examples using curl

curl https://api.binance.com # Get api status
curl https://api.binance.com/api/v3/ping # Check connectivity
curl https://api.binance.com/api/v3/time # Get server time
curl https://api.binance.com/api/v3/exchangeInfo # Get exchange information adding symbol=BTCUSDT to get specific symbol information
curl https://api.binance.com/api/v3/ticker/price # Get latest price for all symbols adding symbol=BTCUSDT to get specific symbol price
curl https://api.binance.com/api/v3/ticker/24hr # Get 24hr price change statistics for all symbols
curl https://api.binance.com/api/v3/depth?symbol=BTCUSDT > shell/"binance data samples"/depth.json # Get order book depth for a symbol
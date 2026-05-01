from libraries import *
import BinaceTraining

BinaceTraining

path = getcwd()

def predict():
    try:
        model = PPO.load(f"{path}/DATA/PPO/PPO_TRADING_STRATEGY")
    except:
        print(0)
        return
    try:
        raw_data = read_json(f"{path}/DATA/KLINE.json", orient="records")[[1, 2, 3, 4, 5]]
        raw_data.columns = ["Open", "High", "Low", "Close", "Volume"]
        
        input_data = raw_data[['Open', 'High', 'Low', 'Close', 'Volume']].tail(5).values.astype(np.float32)
        action, _ = model.predict(input_data, deterministic=True)
    
        print(action)

    except Exception as e:
        print(0)

if __name__ == "__main__":
    predict()
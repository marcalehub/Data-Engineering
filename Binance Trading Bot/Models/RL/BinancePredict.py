from os import getcwd
from pandas import read_json, DataFrame
import numpy as np
from stable_baselines3 import PPO
import BinaceTraining

BinaceTraining

path = getcwd()

def predict():
    try:
        model = PPO.load(f"{path}/Data/PPO/PPO_BTCUSDT_STRATEGY")
    except:
        print(0)
        return
    try:
        raw_data = read_json(f"{path}/Data/BTCUSDT KLINE DATA.json", orient="records")[[1, 2, 3, 4, 5]]
        raw_data.columns = ["open", "high", "low", "close", "volume"]
        
        input_data = raw_data[['open', 'high', 'low', 'close', 'volume']].tail(5).values.astype(np.float32)
        action, _ = model.predict(input_data, deterministic=True)
    
        print(action)

    except Exception as e:
        print(0)

if __name__ == "__main__":
    predict()
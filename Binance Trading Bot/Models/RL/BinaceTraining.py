from os import getcwd
from datetime import datetime as dt
from stable_baselines3 import PPO
from BianceTradingEnv import BinanceTradingEnv
from pandas import read_json

# 1. Load your data (Fetched via curl previously)
path = getcwd()
df = read_json(f"{path}/Data/BTCUSDT KLINE DATA.json", orient="records")[[1, 2, 3, 4, 5]]
df.columns = ["Open", "High", "Low", "Close", "Volume"]

# 2. Initialize Environment
env = BinanceTradingEnv(df)

# 3. Define the Model (The "Brain")
model = PPO("MlpPolicy", env, verbose=0, tensorboard_log=f"{path}/Data/PPO/PPO_BTCUSDT_TB")

# # 4. Train the "Gambler"
model.learn(total_timesteps=10000)

# # # 5. Save the strategy
model.save(f"{path}/Data/PPO/PPO_BTCUSDT_STRATEGY")
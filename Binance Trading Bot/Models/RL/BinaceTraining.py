from libraries import *
from BianceTradingEnv import BinanceTradingEnv

# 1. Load your data (Fetched via curl previously)
path = getcwd()
df = read_json(f"{path}/DATA/KLINE.json", orient="records")[[1, 2, 3, 4, 5]]
df.columns = ["Open", "High", "Low", "Close", "Volume"]

# 2. Initialize Environment
env = BinanceTradingEnv(df)

# 3. Define the Model (The "Brain")
model = PPO("MlpPolicy", env, verbose=0, tensorboard_log=f"{path}/DATA/PPO/PPO_TRADING_TB")

# # 4. Train the "Gambler"
model.learn(total_timesteps=100000)

# # # 5. Save the strategy
model.save(f"{path}/DATA/PPO/PPO_TRADING_STRATEGY")
from libraries import *

class BinanceTradingEnv(gym.Env):
    def __init__(self, df):
        super(BinanceTradingEnv, self).__init__()
        self.df = df
        self.reward_range = (-np.inf, np.inf)
        
        # Actions: 0 = Hold, 1 = Buy, 2 = Sell
        self.action_space = spaces.Discrete(3)
        
        # Observation: Open, High, Low, Close, Volume (last 5 intervals)
        self.observation_space = spaces.Box(low=-np.inf, high=np.inf, shape=(5, 5), dtype=np.float32)

    def reset(self, seed=None, options=None):
        super().reset(seed=seed)
        self.current_step = 5
        self.balance = 1000  # Start with $1000
        self.shares_held = 0
        return self._get_observation(), {}

    def _get_observation(self):
        # Returns the last 5 rows of OHLCV data
        return self.df.iloc[self.current_step-5:self.current_step].values.astype(np.float32)

    def step(self, action):
        current_price = self.df.iloc[self.current_step]['Close']
        reward = 0
        
        if action == 1: # Buy
            self.shares_held += self.balance / current_price
            self.balance = 0
            
        elif action == 2: # Sell
            self.balance += self.shares_held * current_price
            self.shares_held = 0
            
        self.current_step += 1
        done = self.current_step >= len(self.df) - 1
        
        # Reward is the change in total net worth
        net_worth = self.balance + (self.shares_held * current_price)
        reward = net_worth - 1000 
        
        return self._get_observation(), reward, done, False, {}
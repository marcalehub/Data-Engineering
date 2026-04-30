def REMOVE_NULLS(df):
    df = df.replace({NaT: None, np.nan: None, None: None, np.inf: None, 'NaT':None})
    return df
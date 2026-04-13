def COLUMNS_VALIDATION(df = None, columns = None):
    df = df.reindex(columns = columns)
    df = df.loc[:, columns]
    return df
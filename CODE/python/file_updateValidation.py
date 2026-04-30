def UPDATE_FILE_DAILY(file):
    try:
        validation = Path(file)
        file_timestamp = validation.stat().st_mtime
        update = dt.fromtimestamp(file_timestamp).strftime('%Y-%m-%d')
    except:
        update = '0000-00-00'
    return update

def UPDATE_FILE_MONTHLY(file):
    try:
        validation = Path(file)
        file_timestamp = validation.stat().st_mtime
        days = dt.fromtimestamp(file_timestamp).strftime('%d')
        if int(days) <= 3:
            update = (dt.fromtimestamp(file_timestamp) - relativedelta(months=1)).strftime('%B')
        else:
            update = dt.fromtimestamp(file_timestamp).strftime('%B')
    except:
        update = 'ABC'
    return update

def UPDATE_FILE_YEAR(file):
    try:
        validation = Path(file)
        file_timestamp = validation.stat().st_mtime
        days = dt.fromtimestamp(file_timestamp).strftime('%d')
        if int(days) <= 3:
            update = (dt.fromtimestamp(file_timestamp) - relativedelta(months=1)).strftime('%Y')
        else:
            update = dt.fromtimestamp(file_timestamp).strftime('%Y')
    except:
        update = '0000'
    return update
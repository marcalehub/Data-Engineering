def WORKDAY_ADJUSTMENT(df, field):
    workday_adjustment = [
        {
            'day':'Saturday',
            'ahead':2
        },
        {
            'day':'Sunday',
            'ahead':1
        }
    ]
    for adjustment in workday_adjustment:
        day_place = adjustment['day']
        add_day = adjustment['ahead']
        df.loc[df[field].dt.day_name() == day_place, field] = df[field] + Timedelta(days=add_day)
        
def SET_DATE_FIELDS(df, type):
    columns = df.columns.to_list()
    for column in columns:
        try:
            if (regexp.search('Date', column, regexp.IGNORECASE)) and type == 'ms':
                df[column] = to_datetime(df[column].astype('int64'), unit='ms')
            
            elif (regexp.search('Date', column, regexp.IGNORECASE)) and type == 'str':
                df[column] = df[column].astype(str)
            
            elif (regexp.search('Date', column, regexp.IGNORECASE)) and type == 'dt':
                df[column] = to_datetime(df[column])
        
            elif (regexp.search('Date', column, regexp.IGNORECASE)) and type == 'dt_ns':
                df[column] = df[column].astype('datetime64[ns]')
        except:
            pass
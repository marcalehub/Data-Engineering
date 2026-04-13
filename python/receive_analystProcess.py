def INTRANSIT_ANALYST(location, Type, ListFile):
    alldata = []
    Target = ['Target']
    status = "Target"
    
    file = f"{ListFile}.json"
    with open(file, 'r', encoding='utf-8-sig') as f:
        data = json.load(f)
    part = DataFrame(data)
    part =  part.loc[(notnull(part['Attribute'])) & (part['Quantity'] > 0)]
    part.drop('CurrentQuantity', inplace=True, axis=1)
    
    file = f"ORD.parquet"
    rd_file = read_parquet(file)
    orders = DataFrame(rd_file)
   
    file = f"INV.parquet"
    rd_file = read_parquet(file)
    inventory = DataFrame(rd_file)

    for part in part['part'].tolist():
        for method in Target:
            main = orders.query('`part` == @part and `Target` == @method and `Item Status` == @status')
            secondary = inventory.query('`Target` == @method and `part` == @part')
            if main.empty:
                pass
            else:
                priority_position = DataFrame(main, columns=['part', 'Target', 'Place'])
                inventory_data = merge(secondary, priority_position, how='left', on=['part', 'Target'])
                inventory_data = inventory_data.groupby(by=['part'], as_index=False).min()
                main_data = merge(main, inventory_data, how='left', on=['part', 'Target', 'Place'])
                main_data['Available'] = main_data['Available'].ffill()
                main_data['Available'] = main_data['Available'] - main_data['Item Quantity Open'].cumsum()            
                main_data.loc[(main_data['Available'] >= 0) & (main_data['Type'] == Type), 'Rec. Y/N'] = 'Y'
                main_data['Rec. Y/N'] = main_data['Rec. Y/N'].fillna('N')
                alldata.extend(main_data.values.tolist())
    output = DataFrame(alldata, columns=['Target', 'Order', 'Item', 'Material', 'part', 'Quantity', 'Rec. Y/N'])
    file = f"RECEIVE_ANALYST.parquet"
    output.to_parquet(file, engine='pyarrow', index=False)
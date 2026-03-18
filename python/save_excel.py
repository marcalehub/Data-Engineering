def SAVE_AS_EXCEL(table, file):
    for record in table:
        records = record['df'].shape[0]
    if records <= 1048580:
        with ExcelWriter(file, engine='xlsxwriter', date_format='mm/dd/yy', datetime_format='mm/dd/yy') as writer:
            for excel in table:
                excel['df'].to_excel(writer, sheet_name=excel['tab'], index=False)
                columns = [{'header':column} for column in excel['df'].columns]
                (max_row, max_col) = excel['df'].shape
                sheet_data = [
                    {
                        'sheet':excel['tab'],
                        'row':max_row,
                        'col':max_col,
                        'headers':columns,
                        'df':excel['df']
                    }
                    ]
                for sheet in sheet_data:
                    workbook = writer.book
                    sheets = sheet['sheet']
                    row = sheet['row']
                    col = sheet['col']
                    headers = sheet['headers']
                    dataframe = sheet['df']
                    workbook_sheet = writer.sheets[f'{sheets}']
                    formatting_num = workbook.add_format({'num_format':'#,##0'})
                    workbook_sheet.add_table(0, 0, row, col -1, {'columns':headers, 'style':'Table Style Medium 16'})
                    workbook_sheet.hide_gridlines(2)
                    for i, column in enumerate(dataframe.columns):
                        column_len = max(dataframe[column].astype(str).str.len().max(), len(column) + 2)
                        workbook_sheet.set_column(i, i, column_len, formatting_num)
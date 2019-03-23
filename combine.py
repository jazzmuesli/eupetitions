import json
import pandas as pd
js=json.loads(open('241584.json').read())
pbc=js['data']['attributes']['signatures_by_constituency']
signatures_df=pd.DataFrame([ [x['name'], x['ons_code'],x['signature_count']] for x in pbc],columns=("constituency","ons_code","signature_count"))

xl_file=pd.ExcelFile('eureferendum_constitunecy.xlsx')
data=xl_file.parse('DATA')
euref_df=pd.DataFrame([[row[data.columns[0]],row[data.columns[5]]] for index, row in data.iterrows()],columns=("ons_code","euref"))


electorate_df=pd.read_json('ge2017-electorate.json')
combined=euref_df.merge(signatures_df, left_on='ons_code',right_on='ons_code')
combined=combined.merge(electorate_df, left_on='constituency',right_on='constituency')
combined.to_csv('combined.csv')

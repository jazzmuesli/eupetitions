import json
import pandas as pd
def load_signatures(fname,column):
  js=json.loads(open(fname).read())
  pbc=js['data']['attributes']['signatures_by_constituency']
  return pd.DataFrame([ [x['mp'],x['name'], x['ons_code'],x['signature_count']] for x in pbc],columns=('mp',"constituency","ons_code",column))

xl_file=pd.ExcelFile('eureferendum_constitunecy.xlsx')
data=xl_file.parse('DATA')
euref_df=pd.DataFrame([[row[data.columns[0]],row[data.columns[5]]] for index, row in data.iterrows()],columns=("ons_code","euref"))


electorate_df=pd.read_json('ge2017-electorate.json')
pro_eu_signatures_df=load_signatures('241584.json','revoke_sign_count')
nodeal_signatures_df=load_signatures('229963.json','nodeal_sign_count')
signatures_df=pro_eu_signatures_df.merge(nodeal_signatures_df, left_on=['mp','constituency','ons_code'],right_on=['mp','constituency','ons_code'])

combined=euref_df.merge(signatures_df, left_on='ons_code',right_on='ons_code')
combined=combined.merge(electorate_df, left_on='constituency',right_on='constituency')
combined.to_csv('combined.csv')

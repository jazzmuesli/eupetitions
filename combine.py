import json
import pandas as pd
from fuzzywuzzy import fuzz
import urllib.request
import os.path

def read_votes(key,id):
    fname=str(id)+ '.json'
    url='http://lda.data.parliament.uk/commonsdivisions/id/'+ fname
    if not os.path.isfile(fname):
        urllib.request.urlretrieve(url, fname)
    body=open(fname).read()
    js=json.loads(body)
    results=[{'mp':x['memberPrinted']['_value'], key:x['type'].split('#')[1]} for x in js['result']['primaryTopic']['vote']]
    return results

def get_mp_match(mp,mps):
    results=[]
    for x in mps:
        if str(x).rstrip().lstrip() != 'nan':
            ratio=fuzz.ratio(mp, x)
            results.append((x,ratio))
    return sorted(results,key=lambda x: x[1],reverse=True)[0]

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

divisions=dict()
# confirmatory people's vote
divisions['iv2_e']=1108906
# customs union
divisions['iv2_c']=1108905
# commons market 2.0
divisions['iv2_d']=1108904
# parliamentary supremacy
divisions['iv2_g']=1108907
# no deal
divisions['iv1_b']=1105521
# common market 2.0
divisions['iv1_d']=1105524
# efta and eea
divisions['iv1_h']=1105526
# customs union
divisions['iv1_j']=1105527
# labour plan
divisions['iv1_k']=1105529
# revocation to avoid no deal
divisions['iv1_l']=1105530
# people's vote
divisions['iv1_l']=1105532
# preferential arrangements
divisions['iv1_o']=1105533
divisions['mv3']=1107737
divisions['mv2']=1086876
divisions['mv1']=1041567



votes=pd.DataFrame()
for key in divisions:
    ret=pd.DataFrame(data=read_votes(key,divisions[key]))
    if len(votes) == 0:
        votes=ret
    else:
        votes=votes.merge(ret, left_on='mp', right_on='mp',how='outer')

# in Hansard they use different naming convention for MPs
mps_hansard=votes['mp'].tolist()
mps_petitions=combined['mp'].tolist()
mps_map=[(x, get_mp_match(x, mps_petitions)) for x in mps_hansard]

vcombined=combined.merge(pd.DataFrame(data=[{'mp_name':x[0], 'mp':x[1][0], 'mp_name_match':x[1][1]} for x in mps_map]), left_on='mp',right_on='mp',how='left')
vcombined=vcombined.merge(votes,left_on='mp_name',right_on='mp',how='left')
vcombined.to_csv('vcombined.csv')


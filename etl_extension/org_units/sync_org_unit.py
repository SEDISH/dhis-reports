import requests
import MySQLdb
import argparse
import warnings

parser = argparse.ArgumentParser()
parser.add_argument("db_password")
parser.add_argument("dhis2_admin_password")
parser.add_argument("dhis2_url_port")
args = parser.parse_args()

USER = 'admin'
PASSWORD = args.dhis2_admin_password
URL = args.dhis2_url_port

class Unit:
    """Unit class"""

    def __init__(self, id, code):
        self.id = id
        self.code = code

def getScript(filename):
    fd = open(filename, 'r')
    script = fd.read()
    fd.close()
    return script

def executeInsertScript(script, data):
    try:
        cursor.execute(script, data)
    except MySQLdb.Error as e:
        print("Error %d: %s" % (e.args[0], e.args[1]))

def fetchCodes(orgUnits):
    for unit in orgUnits:
        wholeUnit = requests.get('http://' + URL + '/api/26/organisationUnits/' + unit['id'], auth=(USER, PASSWORD))
        unitParams = wholeUnit.json()
        try:
            unit['code'] = unitParams['code']
        except KeyError:
            unit['code'] = None
        print(unit)
    return orgUnits

DB_HOST = 'localhost'
DB_USER = 'root'
DB_PASSWORD = args.db_password
ISANTEPLUS = 'isanteplus'
warnings.filterwarnings('ignore', category=MySQLdb.Warning)

# connect with the database
con = MySQLdb.connect(DB_HOST, DB_USER, DB_PASSWORD, ISANTEPLUS)
cursor = con.cursor()

# prepare all scripts
create_org_code_id = getScript('etl_extension/org_units/create_org_code_id_table.sql')
insert_org_code_id = getScript('etl_extension/org_units/insert_org_code_id.sql')
select_org_code_id = getScript('etl_extension/org_units/select_all_org_code_id.sql')

# fetch list of organisation
response = requests.get('http://' + URL + '/api/26/organisationUnits?pageSize=10000', auth=(USER, PASSWORD))
data = response.json()
orgUnits = data['organisationUnits']

# create table if not exists
cursor.execute(create_org_code_id)

# select all organisations from the database
dbValues = []
cursor.execute(select_org_code_id)
for (id, code) in cursor:
    dbValues.append(Unit(id, code))

# fetch only those which were not fetched before
toFetch = []
for unit in orgUnits:
    dbUnit = next((x for x in dbValues if x.id == unit['id']), None)
    if dbUnit is None:
        toFetch.append(unit)

orgUnits = fetchCodes(toFetch)

# insert new organisations
for unit in orgUnits:
    data = (unit['id'], unit['code'])
    executeInsertScript(insert_org_code_id, data)

con.commit()
cursor.close()
con.close()

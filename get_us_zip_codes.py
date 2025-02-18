import pgeocode
import pandas as pd
import json
from sqlalchemy import create_engine


nomi = pgeocode.Nominatim('US')

us_zip_codes = nomi._data

# Database connection parameters are read from the database_config.json file 
# with open('database_config.json', 'r') as file:
#     config = json.load(file)

### Set database connection parameters received from the database_config.json file 
server = 'localhost:5432'
username = 'admin'
password = 'admin'
database = 'postgresDB'


# Connect to the Database using create_engine from sqlAlchemy, using above parameters
engine = create_engine(f'postgresql+psycopg2://{username}:{password}@{server}/{database}')
print('Created Database Engine: ' + str(engine))

##If the table does not exist it creates a table itself in the database and puts records into the table.
##Else, we need to truncate this table and run this script to get the fresh records into the table. The table already exists in the database and the zip codes has already been pulled.
us_zip_codes.to_sql('dbo.us_zip_codes', engine, if_exists='append', index=False)

print('Completed adding to the zip codes table')

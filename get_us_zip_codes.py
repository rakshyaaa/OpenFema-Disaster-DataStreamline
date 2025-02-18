import pgeocode
import pandas as pd
from sqlalchemy import create_engine

# Get US zip code data
nomi = pgeocode.Nominatim('US')
us_zip_codes = nomi._data

# Database connection parameters
server = 'localhost'  # Remove the port from server name
port = '5432'
username = 'admin'
password = 'admin'
database = 'postgresDB'

# Create the connection string
connection_string = f'postgresql://{username}:{password}@{server}:{port}/{database}'

try:
    # Create engine
    engine = create_engine(connection_string)
    print('Created Database Engine: ' + str(engine))
    
    # Write to database 
    us_zip_codes.to_sql(
        'us_zip_codes',  # table will be created in public schema
        engine,
        if_exists='replace',  # 'replace' will drop and recreate the table
        index=False,
        schema='public'  # Explicitly specify the schema otherwise the table will be created in default schema which is public
    )
    
    print('Completed adding to the zip codes table')
    
except Exception as e:
    print(f"An error occurred: {str(e)}")
finally:
    # Close the engine connection
    engine.dispose()
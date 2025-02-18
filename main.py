import pandas as pd
import requests
import sys
import json
from sqlalchemy import create_engine,text


# Requests library in the python hits the ApiURL, gets the records and then returns a pandas dataframe with those records.
def apiurl_to_df(ApiUrl,name):
    r = requests.get(ApiUrl)
    json_data = r.json()
    df = pd.DataFrame(json_data[name])
    print(f"Number of records in returned for {name}: ", len(df.axes[0]))
    return df


if __name__ == '__main__':

    # Get disasteNumbers text file from the system arguments  
    if  len(sys.argv) < 2:
        print("No disasterNumber file provided")
        sys.exit(1)

    else:
        print(sys.argv)
        disaster_number_file_name  = sys.argv[1]
        print(disaster_number_file_name)

    
    try:
        # Open the text file with disasternumbers as a part of system argument we provide while running the script.
        with open(disaster_number_file_name,'r') as file:
            disaster_numbers = file.read().splitlines()
            print('Disaster Numbers: ',disaster_numbers)

            disaster_numbers_str = ",".join(disaster_numbers)
            api_filter_string = '(' + disaster_numbers_str + ')'
            print('Disater Number API String: ', api_filter_string)

        # Declare the API Urls. The disasterNumbers provided via text file are appended to the URLS below
        disaster_apiurl = 'https://www.fema.gov/api/open/v1/FemaWebDisasterDeclarations?$filter=disasterNumber in '+ api_filter_string
        disaster_declaration_summary_apiurl = 'https://www.fema.gov/api/open/v2/DisasterDeclarationsSummaries?$filter=disasterNumber in '+ api_filter_string

        # Database connection parameters are read from the database_config.json file 
        with open('database_config.json', 'r') as file:
            config = json.load(file)

        # Set database connection parameters received from the database_config.json file 
        server = config["server"]
        username = config["username"]
        password = config["password"]
        database = config["database"]

        # Connect to the Database using create_engine from sqlAlchemy, using above parameters
        engine = create_engine(f'mssql+pyodbc://{username}:{password}@{server}/{database}?driver=ODBC Driver 17 for SQL Server')
        print('Created Database Engine: ' + str(engine))
    
        # Truncate exisiting tables in the database using SQL alchemy
        with engine.connect() as connection:
            connection.execute(text("TRUNCATE TABLE DisasterDeclarations"))
            connection.execute(text("TRUNCATE TABLE DisasterDeclarationsSummaries"))
            connection.commit()
        print("Tables have been truncated")
    
        # Load to disaster table in database
        disaster_df = apiurl_to_df(disaster_apiurl,'FemaWebDisasterDeclarations')
        disaster_df.to_sql('DisasterDeclarations', engine, if_exists='append', index=False)
        print('Completed Adding to Disaster Table in  SQL server')
    
    
        # Load to disaster declaration summary table in database
        disaster_declare_summary_df = apiurl_to_df(disaster_declaration_summary_apiurl,'DisasterDeclarationsSummaries')
        disaster_declare_summary_df.to_sql('DisasterDeclarationsSummaries', engine, if_exists='append', index=False)
        print('Completed Adding to Disaster Declaration Summary Table in  SQL server')
    

    
    except FileNotFoundError:
        print(f"Error: File '{disaster_number_file_name}' not found.")
        sys.exit(1)

    except Exception as e:
        print(f"Error Occured: {e}")
        sys.exit(1)  




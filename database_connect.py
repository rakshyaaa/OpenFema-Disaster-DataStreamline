import sys
import json
import pandas as pd
from sqlalchemy import create_engine,text


class DatabaseConnection:
    def __init__(self, config_path: str):
        with open(config_path, 'r') as f:
            config = json.load(f)
            connection_string = f"postgresql://{config['username']}:{config['password']}@{config['server']}:{config['port']}/{config['database']}"
            self.engine = create_engine(connection_string)


    def truncate_tables(self, table_names: list):
        with self.engine.connect() as connection:
            for table in table_names:
                connection.execute(text(f'TRUNCATE TABLE "{table}"'))

            connection.commit()
        print("Tables have been truncated")

    def insert_dataframe(self, df, table_name: str):
        df.to_sql(table_name, self.engine, if_exists='append', index=False)
        print('Completed Adding to Disaster Table in  SQL server')
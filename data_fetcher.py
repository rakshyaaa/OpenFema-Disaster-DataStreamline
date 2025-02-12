import requests
import sys
import json
import pandas as pd
from sqlalchemy import create_engine,text
import threading # To implement multithreading for Concurrent URL Fetching
from sqlalchemy import create_engine

class DataFetcher:
    def __init__(self, db_engine):
        self.result_dict = {}  #shared dictionary to sore results from threads, when multiple threads fetch data simultaneously, they need a way to store their results in a shared location, this allows each thread to sore its results independently without interfering with other threads

        self.db_engine = db_engine  # Database engine for inserting data
        self.lock = threading.Lock()  # Lock for thread-safe operations

    def fetch_data(self, url, name):
        """
          fetches data from the given url and stores the result in the share dictionary.
        """
        print(f"fetching data from {url}")

        try:
            response = requests.get(url)
            response.raise_for_status()  # Raise an error for bad status codes
            json_data = response.json()
            self.result_dict[name] = json_data[name]  # Store the result in the shared dictionary

            print(f"finished data for {name}")

        except requests.exceptions.RequestException as e:
            print(f"Error fetching data from {url}: {e}")

    def convert_to_dataframe(self, name):
        """
        convert fetched data into dataframe
        """
        print(f"Converting data for {name} to dataframe")
        with self.lock:
            data = self.result_dict.get(name, [])
        df = pd.DataFrame(data)
        print(f"Finished converting data for {name} to DataFrame")
        return df
    

    def insert_into_database(self, df, table_name):
        """
        inserts the dataframe into the specified database table
        """
        print(f"inserting data into {table_name}")

        try:
            with self.lock: #thread safe database operation
                df.to_sql(table_name, self.db_engine, if_exists='append', index= False)
            print(f"Finished inserting data into {table_name}")

        except Exception as e:
            print(f"Error inserting data into {table_name}: {e}")


    def fetch_process_insert(self, url, name, table_name):
        """
        fetch, process, and insert data concurrently using multithreading in database
        """
        #fetch data
        self.fetch_data(url, name)
        #convert data into dataframe
        df = self.convert_to_dataframe(name)
        #inser dataframe into database
        self.insert_into_database(df,table_name)

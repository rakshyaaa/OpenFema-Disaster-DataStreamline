import sys
from database_connect import DatabaseConnection
from data_fetcher import DisasterDataLoader, FemaApiClient

if __name__ == '__main__':

   
    if  len(sys.argv) < 2:
        print("Usage: python main.py <disaster_numbers_file")
        sys.exit(1)


    try:
        db_manager = DatabaseConnection('database_config.json')
        api_client = FemaApiClient

        loader = DisasterDataLoader.from_file(sys.argv[1],db_manager, api_client)
        loader.load_data()
        print("Data loading completed successfully")
        sys.exit(1)

    except Exception as e:
        print(f"Error Occured: {e}")
        sys.exit(1)  




import requests
import pandas as pd
from sqlalchemy import create_engine,text
from sqlalchemy import create_engine
from database_connect import DatabaseConnection


class FemaApiClient:
    """Handles interactions with FEMA API"""
    @staticmethod
    def fetch_data(api_url: str, data_key: str) -> pd.DataFrame:
        """Fetch data from API and return as DataFrame"""
        response = requests.get(api_url)
        response.raise_for_status()
        return pd.DataFrame(response.json()[data_key])


class DisasterDataLoader:
    """Orchestrates data loading process"""
    def __init__(self, disaster_numbers: list, db_manager: DatabaseConnection, api_client: FemaApiClient):
        self.disaster_numbers = disaster_numbers
        self.db_manager = db_manager
        self.api_client = api_client
    
    @classmethod
    def from_file(cls, file_path: str, db_manager: DatabaseConnection, api_client: FemaApiClient):
        """Alternative constructor using disaster numbers file"""
        with open(file_path) as f:
            numbers = f.read().splitlines()
        if not numbers:
            raise ValueError("No disaster numbers found in file")
        return cls(numbers, db_manager, api_client)
    
    def build_api_url(self, base_url: str) -> str:
        """Construct API URL with disaster number filter"""
        if not self.disaster_numbers:
            raise ValueError("No disaster numbers available")
        numbers_str = ",".join(self.disaster_numbers)
        return f"{base_url}?$filter=disasterNumber in ({numbers_str})"
    
    def load_data(self) -> None:
        """Main method to execute loading process"""
        try:
            # Truncate tables
            self.db_manager.truncate_tables([
                "DisasterDeclarations",
                "DisasterDeclarationsSummaries"
            ])

            # Load Disaster Declarations
            declarations_url = self.build_api_url(
                "https://www.fema.gov/api/open/v1/FemaWebDisasterDeclarations"
            )
            declarations_df = self.api_client.fetch_data(
                declarations_url, "FemaWebDisasterDeclarations"
            )
            self.db_manager.insert_dataframe(
                declarations_df, "DisasterDeclarations"
            )

            # Load Disaster Summaries
            summaries_url = self.build_api_url(
                "https://www.fema.gov/api/open/v2/DisasterDeclarationsSummaries"
            )
            summaries_df = self.api_client.fetch_data(
                summaries_url, "DisasterDeclarationsSummaries"
            )
            self.db_manager.insert_dataframe(
                summaries_df, "DisasterDeclarationsSummaries"
            )
            
        except requests.HTTPError as e:
            raise RuntimeError(f"API request failed: {str(e)}") from e
        except Exception as e:
            raise RuntimeError(f"Data loading failed: {str(e)}") from e

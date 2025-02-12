Clone the project

```bash
  git clone https://link-to-project
```

Set up database environments in the database_config.json file as below:

```bash
{
    "server": "//server-name//",
    "username": "//username//",
    "password": "//password//",
    "database": "//databasename//"
}

```

Install following dependencies on your machine

```bash
  pip install sqlalchemy
  pip install pandas
  pip install requests
  pip install pgeocode
```

Go to the project code directory

```bash
  cd DisasterExlcusion
```

Add disaterNumber in the disater_numbers.txt file and save the file

```bash
  4827
  4828
  4829
  4830
  4831
  4832
```

Run the api_script.py to get the disaster information in the tables

```bash
  python api_script.py disaster_numbers.txt
```

Run the api_script.py to get the disaster information in the tables

```bash
  python api_script.py disaster_numbers.txt
```






    


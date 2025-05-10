# OpenFEMA Disaster DataStreamline

This project provides a streamlined pipeline to extract disaster data from the [OpenFEMA API](https://www.fema.gov/openfema-data-page) using disaster numbers. When executed, the pipeline pulls data for each disaster, stores it into a SQL table, and automatically updates a database view that highlights all impacted locations for analysis or visualization.

---

## Key Features

- Fetches FEMA disaster declaration data by `disasterNumber`
- Stores raw data into structured SQL tables
- Built with `pandas`, `requests`, `sqlalchemy`, and `pgeocode`


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
  cd DataStreamline
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

Run the main.py to get the disaster information in the database tables

```bash
  python main.py disaster_numbers.txt
```







    


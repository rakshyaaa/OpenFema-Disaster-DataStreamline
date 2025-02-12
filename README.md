
# Disaster Exclusion

The purpose of the development was to get the areas that have been impacted by a national disaster, after it has been hit.
Intially, I wrote this python script to analyze the OpenFema dataset, then implemented the whole process within the script.

I wrote an equivalent SQL procedure using SQL OLE Automation procedures.


## Documentation

[Documentation](https://ullafayette.sharepoint.com/sites/UniversityAdvancementDeptTeam/SitePages/Disaster-Protocol-API-Script.aspx)

## Installation

Python should have been installed on your machine

[Download the latest version of python and set up in your machine](https://www.python.org/downloads/)

## Run the project and get the impacted areas by disasters

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

View Areas impacted in SQL view

```bash
  select * from dbo.DisasterImpacts;
```




    


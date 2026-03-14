import pandas as pd
from sqlalchemy import create_engine,text
import os 
import dotenv
from dotenv import load_dotenv

load_dotenv()

# Load database credentials from environment variables
username=os.getenv("DB_USERNAME")
password = os.getenv("DB_PASSWORD")
host = os.getenv("DB_HOST")
port = os.getenv("DB_PORT")
database_name= os.getenv("DB_NAME")

# Create the connection string
connection_string = f"mysql+pymysql://{username}:{password}@{host}:{port}/{database_name}"
engine = create_engine(connection_string, echo=True)

# Verify the connection and execute a simple query
try:
    with engine.connect() as connection:
        # Example of running a raw SQL query
        result = connection.execute(text("SHOW TABLES"))
        print("\nTables in the database:")
        for row in result:
            print(row[0])
except Exception as e:
    print(f"\nAn error occurred: {e}")

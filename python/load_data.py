import os 
import pandas as pd 
from connection import engine
import dotenv
from dotenv import load_dotenv

load_dotenv()

# get path from env
csv_folder = os.getenv("DATA_PATH")

files=os.listdir(csv_folder)


for file in files:
    df= pd.read_csv(os.path.join(csv_folder,file))
    table_name = file.replace('.csv', '')
    df.to_sql(table_name, con=engine, if_exists="replace", index=False)
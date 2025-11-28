import pandas as pd
import sqlite3

df = pd.read_csv('global_electricity_production_data.csv')
conn = sqlite3.connect("electricity.db")
df.to_sql("global_production", conn, index=False, if_exists='replace')
print("Table create with columns:", df.columns.tolist())
conn.close()
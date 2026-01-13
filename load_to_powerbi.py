# Code to include in Power BI 

import sqlite3
import pandas as pd
from pathlib import Path

project_root = Path(__file__).resolve().parent.parent
db_path = project_root / "electricity.db"
conn = sqlite3.connect(project_root)

def load_all_views(conn):
    views = {}
    cursor = conn.cursor()
    cursor.execute("SELECT name FROM sqlite_master WHERE type='view';")
    view_names = cursor.fetchall()

    for view_name in view_names:
        view_name = view_name[0]
        views[view_name] = pd.read_sql_query(f"SELECT * FROM {view_name}", conn)

    return views

views = load_all_views(conn)
conn.close()


electricity_flow = views['electricity_flow']
electricity_flow

electricity_flow_cleaned = views['electricity_flow_cleaned']
electricity_flow_cleaned

electricity_types = views['electricity_types']
electricity_types

non_renewable_types = views['non_renewables_types']
non_renewable_types

renewable_types = views['renewables_types']
renewable_types

views

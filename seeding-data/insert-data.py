import oracledb
import pandas as pd

# oracledb.init_oracle_client() 

# 1. Connect to Oracle
conn = oracledb.connect(
    user="WANDOOR",
    password="root",
    dsn="110.148.0.3:1521/WANDOOR_DB"
)
cursor = conn.cursor()

def read_auto(path):
    ext = path.lower().split(".")[-1]

    # kalau user simpan beneran csv
    if ext == "csv":
        return pd.read_csv(path)

    # coba baca sebagai excel
    try:
        return pd.read_excel(path, engine="openpyxl")
    except Exception:
        # fallback: coba baca sebagai CSV
        return pd.read_csv(path)


def insert_from_excel(path, table_name):
    df = read_auto(path)

    # generate insert SQL
    cols = ", ".join(df.columns)
    vals = ", ".join([f":{i+1}" for i in range(len(df.columns))])
    sql = f"INSERT INTO {table_name} ({cols}) VALUES ({vals})"

    print(f"Inserting {len(df)} rows into {table_name}")

    for _, row in df.iterrows():
        cleaned = []
        for val in row.values:
            # NULL values
            if pd.isna(val):
                cleaned.append(None)
                continue

            # Strip strings
            if isinstance(val, str):
                val = val.strip()
                if val == "":
                    cleaned.append(None)
                    continue

            # Fix numeric format from Excel: 62815000000.0
            if isinstance(val, float):
                if val.is_integer():
                    cleaned.append(int(val))
                else:
                    cleaned.append(val)
                continue

            cleaned.append(val)

        cursor.execute(sql, tuple(cleaned))

    conn.commit()
    print(f"✓ Done: {table_name}")

# 2. Call function for each file
insert_from_excel("out/role_management.xlsx", "ROLE_MANAGEMENT")
insert_from_excel("out/user_auth.xlsx", "USER_AUTH")
insert_from_excel("out/profile.xlsx", "PROFILE")
insert_from_excel("out/admin_profile.xlsx", "ADMIN_PROFILE")
insert_from_excel("out/accounts.xlsx", "ACCOUNT")
insert_from_excel("out/time_deposit.xlsx", "TIME_DEPOSIT_ACCOUNT")
insert_from_excel("out/dplk.xlsx", "DPLK_ACCOUNT")
insert_from_excel("out/lifegoals.xlsx", "LIFEGOALS_ACCOUNT")
insert_from_excel("out/trx_category.xlsx", "TRX_CATEGORY")
insert_from_excel("out/trx_history.xlsx", "TRX_HISTORY")
insert_from_excel("out/split_bill.xlsx", "SPLIT_BILL")
insert_from_excel("out/split_bill_member.xlsx", "SPLIT_BILL_MEMBER")

cursor.close()
conn.close()

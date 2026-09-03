#convert our xls file to csv for ingestion
#revision: don't overwrite existing file names and log errors when processing

%pip install openpyxl
dbutils.library.restartPython()


import pandas as pd
 
source_dir = "/Workspace/Users/apurvamody@live.com/apurva_synaptiq_hw/exercise_1/exercise_source_files/"
error_log_path = source_dir + "unnamed_column_log.csv"
 
xlsx_files = [f.name for f in dbutils.fs.ls(source_dir) if f.name.endswith(".xlsx")]
print(f"Found {len(xlsx_files)} xlsx file(s): {xlsx_files}")
 
error_log_rows = []
 
for filename in xlsx_files:
    src_xlsx = source_dir + filename
    dst_csv = source_dir + filename.replace(".xlsx", ".csv")
 
    if dbutils.fs.exists(dst_csv):
        print(f"Skipping {filename} — {dst_csv.split('/')[-1]} already exists")
        continue
 
    pdf = pd.read_excel(src_xlsx)
 
    unnamed_cols = [c for c in pdf.columns if str(c).startswith("Unnamed")]
    if unnamed_cols:
        # log every non-null value from the unnamed column(s) before dropping,
        # keyed by order_id (or row position if no order_id column exists)
        key_col = "order_id" if "order_id" in pdf.columns else None
        for col in unnamed_cols:
            flagged = pdf[pdf[col].notna()]
            for idx, row in flagged.iterrows():
                error_log_rows.append({
                    "source_file": filename,
                    "row_key": row[key_col] if key_col else idx,
                    "unnamed_column": col,
                    "value": row[col],
                })
        pdf = pdf.drop(columns=unnamed_cols)
        print(f"{filename}: found and logged {len(unnamed_cols)} unnamed column(s) -> {unnamed_cols}, dropped before writing CSV")
 
    pdf.to_csv(dst_csv, index=False)
    print(f"Converted {len(pdf)} rows: {filename} -> {dst_csv.split('/')[-1]}")
    display(pdf)
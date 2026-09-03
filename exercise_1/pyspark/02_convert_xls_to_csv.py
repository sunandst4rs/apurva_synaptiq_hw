#convert our xls file to csv for ingestion

%pip install openpyxl
dbutils.library.restartPython()

import pandas as pd
 
source_dir = "/Workspace/Users/apurvamody@live.com/apurva_synaptiq_hw/exercise_1/exercise_source_files/"
 
xlsx_files = [f.name for f in dbutils.fs.ls(source_dir) if f.name.endswith(".xlsx")]
print(f"{len(xlsx_files)} xlsx file(s): {xlsx_files}")
 
for filename in xlsx_files:
    src_xlsx = source_dir + filename
    dst_csv = source_dir + filename.replace(".xlsx", ".csv")
 
    pdf = pd.read_excel(src_xlsx)
    pdf.to_csv(dst_csv, index=False)
    print(f"Converted {len(pdf)} rows: {filename} -> {dst_csv.split('/')[-1]}")
    display(pdf)
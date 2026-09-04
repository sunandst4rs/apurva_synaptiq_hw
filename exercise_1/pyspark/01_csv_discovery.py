#read_csv files to discover what's in them and possibly infer schema

directory = "/Workspace/Users/apurvamody@live.com/apurva_synaptiq_hw/exercise_1/exercise_source_files/"

csv_files = [f.path for f in dbutils.fs.ls(directory) if f.name.endswith(".csv")]

rows = []
for path in csv_files:
    df = spark.read.option("header", "true").option("inferSchema", "true").csv(path)
    rows.append((
        path.split("/")[-1],
        ", ".join(df.columns),
        ", ".join(t.dataType.simpleString() for t in df.schema.fields),
    ))
 
result = spark.createDataFrame(rows, ["file_name", "header_columns", "inferred_datatypes"])
display(result)


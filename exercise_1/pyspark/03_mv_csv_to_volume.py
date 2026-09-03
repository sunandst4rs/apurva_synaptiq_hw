#move the csvs to dbx volume

source_dir = "/Workspace/Users/apurvamody@live.com/apurva_synaptiq_hw/exercise_1/exercise_source_files/"
volume_root = "/Volumes/retail_demo/bronze/landing/"

dbutils.fs.mkdirs(volume_root + "orders/")
dbutils.fs.mkdirs(volume_root + "products/")

routing = {
    "orders_2024-01-01.csv": "orders/",
    "orders_2024-01-02.csv": "orders/",
    "products.csv":          "products/",
}

for filename, subfolder in routing.items():
    src = source_dir + filename
    dst = volume_root + subfolder + filename
    dbutils.fs.cp(src, dst)
    print(f"Copied {filename} -> {dst}")
import pyarrow.csv as csv
import pyarrow.feather as feather

table = csv.read_csv("data/nyc_yellow_tripdata/yellow_tripdata_2020-01.csv")
adf = table.to_pandas()
adf
feather.write_feather(adf, 'data/nyc_yellow_tripdata/yellow_tripdata_2020-01.arrow')

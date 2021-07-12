# Data pipelines in ruby

A demonstration of data pipelines in ruby, rails, activerecord and postgresql.

## Demo

```
make
```

## talk for Ruby meetup Melbourne July 2021

- touch on chaining `then` to build out data transformations in ruby - [link](https://til.hashrocket.com/posts/f4agttd8si-chaining-then-in-ruby-26)

## TODO

- [ ] choose a data set with more than 10 million lines that is interesting
- [ ] basic repo for access and benchmarking
- [ ] basic processing pipeline
- [ ] slide show software to use this time?
- [ ] can I get a datascience analysis over the data set for fun and profit?
- [ ] benchmark using activerecord-import
- [ ] using ActiveRecord `update_all` and `upsert_all`
- [ ] getting the raw SQL `COPY` to work
- [ ] confirm the `on_duplicate` flag is in [edge rails](https://edgeapi.rubyonrails.org/classes/ActiveRecord/Persistence/ClassMethods.html#method-i-upsert_all) and NOT in current [Rails 6.1](https://api.rubyonrails.org/classes/ActiveRecord/Persistence/ClassMethods.html#method-i-upsert_all)
    ```
    # Rails Edge
    upsert_all(attributes, on_duplicate: :update, returning: nil, unique_by: nil)
    
    # Rails 6.1
    upsert_all(attributes, returning: nil, unique_by: nil)
    ```
- [ ] [pivot query example](https://stackoverflow.com/questions/68108876/postgresql-summarize-features-query?noredirect=1#comment120378290_68108876)
- [ ] [Scenic database views](https://github.com/scenic-views/scenic)

## Resources

- [Mikolaj Grygiel Nov 21, 2016 Importing Data to Database in Rails 50 Times Faster Than Normal](https://naturaily.com/blog/ruby-on-rails-fast-data-import)
- [Corey, Nov 16, 2020 Data pipelines in Ruby on Rails](https://coreym.info/data-pipelines-in-ruby-on-rails/)
- [Jaco Pretorius Mar 10, 2014 Faster CSV Imports with Rails](https://jacopretorius.net/2014/03/faster-csv-imports-with-rails.html)
- [Importing data quickly in Ruby on Rails applications](https://www.mutuallyhuman.com/blog/importing-data-quickly-in-ruby-on-rails-applications/)
- [StackOverflow Import CSV data faster in rails](https://stackoverflow.com/questions/39950842/import-csv-data-faster-in-rails)
- [Maciej Głowacki Oct 11, 2017 The Fastest Way of Importing Data with Ruby?](https://blog.daftcode.pl/the-fastest-way-of-importing-data-with-ruby-80bd9ba6274b)
- [Melissa Gonzalez Aug 15, 2017 How To Grab Data Faster in Rails](https://medium.com/adventures-in-code/how-to-grab-data-faster-in-rails-52d15885d12b)
- [Gannon McGibbon Oct 8, 2019 How to Write Fast Code in Ruby on Rails](https://shopify.engineering/write-fast-code-ruby-rails)

## Find me a data set

- https://data.gov.au/
- https://www.kaggle.com/datasets
  - cow images ? https://www.kaggle.com/afnanamin/cow-images
- https://datasetsearch.research.google.com/
- UCI machine learning repository https://archive.ics.uci.edu/ml/index.php
- https://dataverse.org/
- https://registry.opendata.aws/
- the myki data aka https://wingarc.com.au/the-myki-privacy-breach-what-it-means-for-open-data-and-how-to-release-data-safely/

## Presentation - outline

* what is a data pipeline and why you want it?
  * clean data
  * enrich with features
  * present as a model
  * consume
* what if I don't have a data pipeline?
* CSV import to DB
* use Active Record
* but it can get slow
* read all the articles
  * 50 times faster
* use ActiveRecord-import gem
* surely there is something new?
* Rails 6 brings ActiveRecord insert_all and upsert_all
* and it's faster
* for insert ✅
* what about updates?
  * insert_all does not deal with duplicates
  * ❌
  * fall back to using activerecord-import
* what about edge rails?
  * yes we can
  * can we ??? ✅
* how does this compare?
  * CSV read in postgres
  * Rust? DataFusion?
  * Java?
  * Scala? Apache Spark?
* what was it about the data pipeline?
  * ruby for clean and ingest
  * ruby for enrich
  * materlialized view and scenic for model
  * insights
  * profit $$$

* background on faster ways
  * ["Apache Arrow and the Future of Data Frames" with Wes McKinney](https://www.youtube.com/watch?v=fyj4FyH3XdU)
    - Data frames for time series and procedural processing where SQL does not fair as well, stateful
    - Arrow vs Pandas speed
      - Demo vldb-2019-apache-arrow-workshop
      - Demo NYTC Taxi
        - import pyarrow.csv as csv
        csv.read_csv("yellow_tripdata_2010-01.csv") 1.47 sec
        %%time
        vs pd.read_csv("") single threaded 30 sec
    - Julia article
      - https://towardsdatascience.com/the-great-csv-showdown-julia-vs-python-vs-r-aa77376fb96
    - direct using COPY and pandas equiv https://stackoverflow.com/questions/2987433/how-to-import-csv-file-data-into-a-postgresql-table

## Faster ways to import

### Larger data set

via https://www1.nyc.gov/site/tlc/about/tlc-trip-record-data.page

* https://nyc-tlc.s3.amazonaws.com/trip+data/yellow_tripdata_2020-12.csv ~ 128 MB
* https://nyc-tlc.s3.amazonaws.com/trip+data/yellow_tripdata_2020-01.csv ~ 550 MB
* https://s3.amazonaws.com/nyc-tlc/trip+data/yellow_tripdata_2010-01.csv ~ 2.5 GB

```
make nyc_data
```

### Plain Old Ruby

Line count with **wc** ~ _220ms_

```
time wc -l data/nyc_yellow_tripdata/yellow_tripdata_2020-01.csv

  6405009 data/nyc_yellow_tripdata/yellow_tripdata_2020-01.csv
  0.22s user 0.04s system 98% cpu 0.268 total
```

with **ruby** ~ _1500ms_ **7x slower**

```
time ruby -e 'data = File.read(
    "data/nyc_yellow_tripdata/yellow_tripdata_2020-01.csv"
  ); puts data.split("\n").count'

  6405009
  1.51s user 0.27s system 99% cpu 1.798 total

# OR

time ruby -e 'data = File.readlines(
    "data/nyc_yellow_tripdata/yellow_tripdata_2020-01.csv"
  ); puts data.count'

  6405009
  ruby -e   1.64s user 0.26s system 100% cpu 1.906 total
```

what about actually reading the CSV

```
time ruby -e 'require "CSV";
  data = CSV.read(
    "data/nyc_yellow_tripdata/yellow_tripdata_2020-01.csv",
    headers: true, row_sep: :auto
  );
  pp data.first(2);
  puts "\n..\n\n";
  pp data.last(2); # ERROR ???
  puts "\n#{data.count}"'

  ...
  170.21s user 114.98s system 74% cpu 6:21.43 total
```

how does that compare?

| library    | time       | relative |
| :--------: | ---------: | -------: |
| ruby       |   170.2 s  |    120 X |
| SQL        |     ?????? |     ???? |
| python SQL |     ?????? |     ???? |
| pandas     |     6.87 s |      5 X |
| pyarrow    |     1.45 s |      1 X |

### Python Pandas

seems reading a CSV is faster than connecting to the DB :) why even store data
in a relational DB?

### Apache Arrow

> "Apache Arrow defines a language-indepependent columnar memory format for flat
> and hierarchical data"

https://arrow.apache.org/

Optimised for multi CPU and GPU hardware.

used in things like https://rapids.ai/ (Nvidia Cuda GPU accelerated AI library)

#### pyarrow (Python)

to install PyArrow on Mac M1 silicon

- following https://uwekorn.com/2021/01/11/apache-arrow-on-the-apple-m1.html
- download from https://github.com/conda-forge/miniforge/blob/master/README.md
- `bash ~/Downloads/Miniforge3-MacOSX-arm64.sh`
- `conda install -c conda-forge pyarrow`

and

```
make conda_notebook
```

TODO: make script to download, install and use pipenv?

#### DataFusion (Rust)

https://github.com/apache/arrow-datafusion

??? what about reading CSV in Rust directly?

#### red-arrow (Ruby gem)

could attempt to write a big file in arrow format and read it? would it be faster
https://github.com/apache/arrow/tree/master/ruby/red-arrow

```{ruby}
require "arrow"

table = Arrow::Table.load("/dev/shm/data.arrow")
# Process data in table
table.save("/dev/shm/data-processed.arrow")
```

### direct CSV to and from Postgres

```
# record count
psql ruby_pipeline_demo_development \
  -c "SELECT COUNT(*) FROM stop_locations;"

   count
  -------
   27614
  (1 row)

# export to CSV file
time psql ruby_pipeline_demo_development \
  -c "COPY stop_locations TO '`pwd`/stop_locations.csv' CSV HEADER;"

  COPY 27614

  0.03s user 0.08s system 83% cpu 0.137 total

# delete records in table
psql ruby_pipeline_demo_development -c "truncate stop_locations;"

# import from CSV
time psql ruby_pipeline_demo_development -c \
  "COPY stop_locations FROM '`pwd`/stop_locations.csv' DELIMITER ',' CSV HEADER;"

  COPY 27614
  0.03s user 0.08s system 64% cpu 0.178 total
```

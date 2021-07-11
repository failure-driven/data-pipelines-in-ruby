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


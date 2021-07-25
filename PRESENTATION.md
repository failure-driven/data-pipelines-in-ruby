:data-transition-duration: 200
:skip-help: true

.. title: Data Pipelines in Ruby

:css: css/presentation.css

----

:id: start-slide

Data Pipelines in Ruby
======================

Michael Milewski
----------------

----

Where do I work?
----------------

----

:id: black-box-co-slide

Black Box Co
============

.. class:: left
.. image:: https://trello-attachments.s3.amazonaws.com/60f2768b1a31dd17dbbf36a4/480x306/8eb491bee2184369125c99e877f8f5d0/census_play_it.gif
    :width: 100%

.. class:: right
.. class:: substep

    * beef analytics

    * optimise growth

    * < carbon emissions

    * 900k cows tracked

    * 1M active cows 2022

----

:id: wide-title-slide

Data Pipelines in Ruby
======================

.. class:: substep

* What is a data pipeline?

* Ruby CSV porcessing

* Is Ruby fast enough?

----

Data Pipeline?
==============

* Data(CSV) -> Database -> Graph

----

ML Pipeline?
============

* Data collection
* Data cleaning
* Feature extraction
* Model validation
* Visualisation

----

Pipelines are everywhere
------------------------

----

TODO: paper handling example

----

unix tools
----------

.. code:: bash

  cat log/development.log | \
    grep SQL              | \
    awk '{print $2}'      | \
    sed 's/[()]//g'       | \
    head                  | \
    sort -n

----

ruby chaining
-------------

.. code:: ruby

  File.open("log/development.log")
    .each_line
    .lazy
    .map{|line| line[/SQL.*\(([\d\.]+)ms\)/, 1] }
    .compact_blank
    .first(10)
    .map(&:to_f)
    .sum

----

ruby then (yield_self)
----------------------

.. code:: ruby

  "https://ruby.org.au"
    .then{ URI.open(_1) }
    .then{ Nokogiri::HTML.parse _1 }
    .then{ _1.css("#meetup-locations li a") }
    .then{ _1.map(&:text).map(&:chomp) }

  => ["Adelaide", "Brisbane", "Melbourne",
      "Perth", "Sydney"]

----

why are pipelines good?
-----------------------

.. class:: substep

    * composable

    * separation of concerns

    * horizontally scalable

----

Data pipeline
=============

.. code::

  Data(CSV)
  -> clean data
  -> add features
  -> create model
  -> publish/visualise

----

CSV -> DB
=========

----

Read CSV
========

.. code:: ruby

    require "CSV"

    data = CSV.read(
      "yellow_tripdata_2020-01.csv",
      headers: true,
      row_sep: :auto
    );
    pp data.first(2)
    puts "\n..\n\n"
    pp data.last(2)
    puts "\n#{data.count}"
  
.. class:: substep

170s for 560Mb

----

SQL Copy
=================

.. code:: sql

    COPY yellow_tripdata(
      VendorID,tpep_pickup_datetime, ...
      congestion_surcharge
    ) FROM 'yellow_tripdata_2020-01.csv'
    DELIMITER ',' CSV HEADER;

    COPY 6405008
  
.. class:: substep

22s for 560Mb

----

FasterCSV ???
=============

.. code:: ruby

  require "fastercsv"

  FasterCSV.read()

.. class:: substep

    gems/fastercsv-1.5.5/lib/faster_csv.rb:13:in 'const_missing':
    Please switch to Ruby 1.9's standard CSV library.
    It's FasterCSV plus support for Ruby 1.9's
    m17n encoding engine. (NotImplementedError)

----

RCSV
====

*https://github.com/fiksu/rcsv*

.. code:: ruby

    require "rcsv"

    line_count = 0
    Rcsv.parse(
      File.open("yellow_tripdata_2020-01.csv"),
      buffer_size: 20 * 1024 * 1024
    ).each_with_index do |row, index|
      pp row if index < 2
      line_count += 1
    end
    pp line_count

.. class:: substep

28s for 560Mb

----

Speed to read CSV
=================

.. code:: markdown

    | library        | time       |
    | :------------- | ---------: |
    | ruby CSV       |   170.21 s |
    | ruby Rcsv      |    27.64 s |
    | SQL COPY       |    21.97 s |

----

Can we go faster?
=================

----

Python Pandas
=============

.. code:: python

    import pandas as pd

    df = pd.read_csv(
        "yellow_tripdata_2020-01.csv"
    )
    df

.. class:: substep

6.87s for 560Mb

----

Even faster?
============

.. code:: markdown

    | library        | time       |
    | :------------- | ---------: |
    | ruby CSV       |   170.21 s |
    | ruby Rcsv      |    27.64 s |
    | SQL COPY       |    21.97 s |
    | pandas         |     6.87 s |

----

Apache Arrow
============

https://arrow.apache.org/

.. code:: python

    import pyarrow.csv as csv

    table = csv.read_csv(
        "yellow_tripdata_2020-01.csv"
    )
    adf = table.to_pandas()

.. class:: substep

1.45s for 560Mb

----

red-arrow
=========

https://github.com/apache/arrow
  ruby/red-arrow

.. code:: ruby

    require "arrow"

    table = Arrow::Table.load(
      "yellow_tripdata_2020-01.arrow"
    )
    # Process data in table
    pp table
    #pp table.columns
    pp table.each_record.first
    pp table.each_record.count

.. class:: substep

2.28s for 560Mb

----

Read CSV
========

.. code:: markdown


    | library        | time       | relative   |
    | :------------- | ---------: | ---------: |
    | ruby CSV       |   170.21 s |    120   X |
    | python SQL     |    38.80 s |     27   X |
    | ruby Rcsv      |    27.64 s |     19   X |
    | SQL COPY       |    21.97 s |     15   X |
    | pandas         |     6.87 s |      5   X |
    | ruby red-arrow |     2.28 s |      1.6 X |
    | pyarrow        |     1.45 s |      1   X |

----

Write to SQL
============

----

Thank You
=========

Michael Milewski
----------------


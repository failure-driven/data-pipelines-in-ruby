
build:
	asdf install
	bundle
	bundle exec rake db:create db:migrate
	bundle exec rake import:stop_locations
	bundle exec rake import:scan_data
	bundle exec ruby app/some_stats.rb
	python -m pip install --user pipenv
	python -m pipenv run jupyter notebook --notebook-dir=notebooks

conda_notebook:
	conda install pipenv pandas psycopg2 matplotlib pyarrow
	# conda install -c conda-forge pyarrow
	# conda install -c conda-forge pipenv
	pipenv --python=$(conda run which python) --site-packages
	jupyter notebook --notebook-dir=notebooks

data/nyc_yellow_tripdata/yellow_tripdata_2020-01.arrow: nyc_data
	python ./lib/save_file_to_arrow.py

demo_ruby_arrow: data/nyc_yellow_tripdata/yellow_tripdata_2020-01.arrow
	time bundle exec ruby lib/read_arrow.rb

data/nyc_yellow_tripdata/yellow_tripdata_2020-01.csv:
	curl https://nyc-tlc.s3.amazonaws.com/trip+data/yellow_tripdata_2020-01.csv \
			--output data/nyc_yellow_tripdata/yellow_tripdata_2020-01.csv

nyc_data: data/nyc_yellow_tripdata/yellow_tripdata_2020-01.csv

demo:
	bundle exec ruby app/main.rb ${RECORD_COUNT}

import: import_stop_locations
	bundle exec rake import:scan_data

import_stop_locations:
	bundle exec rake import:stop_locations

clean_stop_locations:
	bundle exec rake import:clean_stop_locations

setup: clean
	bundle exec rake db:create db:migrate

clean:
	bundle exec rake db:drop

lint:
	bundle exec rubocop -A .


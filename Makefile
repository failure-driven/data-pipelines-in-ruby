
build:
	bundle
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



build:
	bundle
	bundle exec ruby app/main.rb ${RECORD_COUNT}

import:
	bundle exec rake import:stop_locations
	bundle exec rake import:scan_data

setup: clean
	bundle exec rake db:create db:migrate

clean:
	bundle exec rake db:drop

lint:
	bundle exec rubocop -A .


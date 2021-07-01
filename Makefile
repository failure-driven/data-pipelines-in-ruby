
build:
	bundle
	bundle exec ruby app/main.rb ${RECORD_COUNT}

setup: clean
	bundle exec rake db:create db:migrate

clean:
	bundle exec rake db:drop

lint:
	bundle exec rubocop -A .


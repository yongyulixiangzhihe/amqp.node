RABBITMQ_SRC_VERSION=rabbitmq_v3_1_3
JSON=amqp-rabbitmq-0.9.1.json
RABBITMQ_CODEGEN=https://raw.github.com/rabbitmq/rabbitmq-codegen
AMQP_JSON=$(RABBITMQ_CODEGEN)/$(RABBITMQ_SRC_VERSION)/$(JSON)

MOCHA=./node_modules/mocha/bin/mocha
_MOCHA=./node_modules/mocha/bin/_mocha
UGLIFY=./node_modules/uglify-js/bin/uglifyjs
ISTANBUL=./node_modules/istanbul/lib/cli.js

.PHONY: test test-all-nodejs all clean coverage

all: lib/defs.js

clean:
	rm lib/defs.js bin/amqp-rabbitmq-0.9.1.json
	rm -rf ./coverage

lib/defs.js: bin/generate-defs.js bin/amqp-rabbitmq-0.9.1.json
	(cd bin; node ./generate-defs.js > ../lib/defs.js)
	$(UGLIFY) ./lib/defs.js -o ./lib/defs.js \
		-c 'sequences=false' --comments \
		-b 'indent-level=2' 2>&1 | (grep -v 'WARN' || true)

test: lib/defs.js
	$(MOCHA) -u tdd test

test-all-nodejs: lib/defs.js
	for v in '0.8' '0.9' '0.10' '0.11'; \
		do nave use $$v $(MOCHA) -u tdd -R progress test; \
		done

coverage: lib/defs.js
	$(ISTANBUL) cover $(_MOCHA) -- -u tdd -R progress test/
	$(ISTANBUL) report
	@echo "HTML report at file://$$(pwd)/coverage/lcov-report/index.html"

bin/amqp-rabbitmq-0.9.1.json:
	curl $(AMQP_JSON) > $@
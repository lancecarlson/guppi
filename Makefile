all: shards build

shards:
	shards install

build:
	crystal build src/guppi.cr -o guppi # TODO: linux -> --static

install:
	cp guppi /usr/local/bin # TODO: PREFIX

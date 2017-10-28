.PHONY: build run clean

build:
	docker build -t existenz/merge-back:latest .

run:
	docker run -ti --rm existenz/merge-back:latest sh

clean:
	docker rmi existenz/merge-back:latest

test:
	bats tests.bats


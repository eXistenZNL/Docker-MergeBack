.PHONY: build run clean

build:
	docker build -t existenz/mergeback:latest .

run:
	docker run -ti --rm existenz/mergeback:latest sh

clean:
	docker rmi existenz/mergeback:latest

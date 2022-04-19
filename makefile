build:
	docker build -t test .

run:
	docker run --rm -p 8088:80 --name test test

stop:
	docker stop test

exec:
	docker exec -it test sh

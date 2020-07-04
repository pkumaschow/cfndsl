build:
	docker build -t cfndsl .
test:
	docker run -ti --rm -v `pwd`/templates/:/home/gocd/templates cfndsl -f yaml test.rb
yaml:
	docker run -ti --rm -v `pwd`/templates/:/home/gocd/templates cfndsl -f yaml $(template)


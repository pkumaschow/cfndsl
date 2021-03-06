build:
	./ci.sh
test:
	docker run -ti --rm -v `pwd`/templates/:/home/gocd/templates cfndsl -f yaml test.rb
yaml:
	@docker run -ti --rm -v `pwd`/templates/:/home/gocd/templates cfndsl -f yaml $(template)
json:
	@docker run -ti --rm -v `pwd`/templates/:/home/gocd/templates cfndsl -p -f json $(template)
validate:
	aws cloudformation validate-template --template-body file://./$(template)

.PHONY: build test yaml validate

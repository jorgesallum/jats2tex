tag=$(shell git describe --tags)

build: FORCE
	stack build

full-release: FORCE
	make release
	docker build -t jats2tex:$(tag) .
	heroku container:push

release: FORCE
	echo $(tag)
	./bin/stack-fpm jats2tex $(tag)
	github-release release -u beijaflor-io -r jats2tex -t $(tag) -n $(tag)
	make upload

upload: FORCE
	for i in dist/*$(tag)*; do \
		echo $$i; \
		github-release upload -u beijaflor-io -r jats2tex -t $(tag) -n $$i -f $$i -l $$i; \
	done

build-pdf: FORCE
	pandoc ./README.md -o ./jats2tex.pdf

build-osx: FORCE
	stack build --extra-lib-dirs=/usr/local/opt/icu4c/lib --extra-include-dirs=/usr/local/opt/icu4c/include

example: FORCE
	stack run -- -- ./examples/S0250-54602016000400001.xml --output ./example-output.tex
	./latexindent.sh ./example-output.tex > ./example-output.fmt.tex
	mv ./example-output.fmt.tex ./example-output.tex
	latex ./example-output.tex

FORCE:

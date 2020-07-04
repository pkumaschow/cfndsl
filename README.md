# cfndsl docker image

## build it

```
docker build -t cfndsl .
```

or:

```
make
```

## run it and get json

```
docker run -ti --rm -v `pwd`/templates/:/home/gocd/templates cfndsl test.rb
```

## run it and get pretty json

```
docker run -ti --rm -v `pwd`/templates/:/home/gocd/templates cfndsl -p test.rb
```

## run it and get yaml

```
docker run -ti --rm -v `pwd`/templates/:/home/gocd/templates cfndsl -f yaml test.rb
```

or if you built it as suggested above:

```
make test
```

or you specify a template:

```
make template=test.rb yaml
```

## get help

```
docker run -ti --rm cfndsl

Usage: cfndsl [options] FILE
    -o, --output FILE                Write output to file
    -y, --yaml FILE                  Import yaml file as local variables
    -j, --json FILE                  Import json file as local variables
    -p, --pretty                     Pretty-format output JSON
    -f, --format FORMAT              Specify the output format (JSON default)
    -D, --define "VARIABLE=VALUE"    Directly set local VARIABLE as VALUE
    -v, --verbose                    Turn on verbose ouptut
    -m, --disable-deep-merge         Disable deep merging of yaml
    -s, --specification-file FILE    Location of Cloudformation Resource Specification file
    -u [VERSION],                    Update the Resource Specification file to latest, or specific version
        --update-specification
    -g RESOURCE_TYPE,RESOURCE_LOGICAL_NAME,
        --generate                   Add resource type and logical name
    -a, --assetversion               Print out the specification version
    -l, --list                       List supported resources
    -h, --help                       Display this screen

```

Would you like to know more? [cfndsl](https://github.com/cfndsl/cfndsl)

They lie.. you can actually build cloudformation in yaml format...

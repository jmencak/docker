PROGRAM=hello-openshift
TAG=jmencak/$(PROGRAM)

all: $(PROGRAM)

$(PROGRAM): $(PROGRAM).go
	go build $<

static: 
	CGO_ENABLED=0 go build -a -installsuffix cgo -ldflags '-s' $<

run: $(PROGRAM).go
	go run $<

fmt format: $(PROGRAM).go
	go fmt $<

docker: static Dockerfile
	(docker build -t $(TAG) .)

push: 
	(docker push $(TAG))

strip:
	strip $(PROGRAM)

.DEFAULT: 
	PORT=$@ ./$(PROGRAM)
#	docker run -it --rm -p $@:8080 $(TAG)

clean:
	go clean

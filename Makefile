tag = 7.1

build_dir = build
VPATH = $(build_dir)

all: image

.PHONY: all clean

$(build_dir):
	mkdir $(build_dir)

image: Dockerfile scripts/docker-entrypoint.sh scripts/carte_config_master.xml scripts/carte_config_slave.xml $(build_dir)
	docker build -t xavinguer/pentaho-di:$(tag) .
	touch $(build_dir)/$@

clean: clean-image
	-rmdir $(build_dir)

clean-image:
	-docker rmi xavinguer/pentaho-di:$(tag)
	-rm $(build_dir)/image
FROM java:jre

MAINTAINER Xavi Hidalgo

ENV PDI_RELEASE=7.1 \
    PDI_VERSION=7.1.0.0-12 \
    PDI_HOME=/opt/pentaho-di \
    KETTLE_HOME=/pentaho-di

RUN mkdir -p $PDI_HOME/data-integration
COPY pentaho-di $PDI_HOME/data-integration

ENV PATH=$PDI_HOME/data-integration:$PATH

EXPOSE 8080

RUN mkdir -p $KETTLE_HOME/.kettle /docker-entrypoint.d /templates

COPY scripts /templates/
COPY scripts /

COPY src/.kettle/ $KETTLE_HOME/.kettle/
COPY src/repo/ $KETTLE_HOME/repo/

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["kitchen.sh", "-rep=my-pdi-repo",  "-dir=/",  "-job=my-job"]

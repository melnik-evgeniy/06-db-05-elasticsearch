FROM centos:7

EXPOSE 9200 9300

USER 0
RUN export ES_HOME="/var/lib/elasticsearch" && \
    yum -y install wget && \
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.2.0-x86_64.rpm && \
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.2.0-x86_64.rpm.sha512 && \
shasum -a 512 -c elasticsearch-8.2.0-x86_64.rpm.sha512 && \
sudo rpm --install elasticsearch-8.2.0-x86_64.rpm && \   
    mv elasticsearch-8.2.0 ${ES_HOME} && \
    useradd -m -u 1000 elasticsearch && \
    chown elasticsearch:elasticsearch -R ${ES_HOME} && \
    yum -y remove wget && \
    yum clean all
COPY --chown=elasticsearch:elasticsearch config/elasticsearch.yml /var/lib/elasticsearch/config/
    
USER 1000
ENV ES_HOME="/var/lib/elasticsearch" \
    ES_PATH_CONF="/var/lib/elasticsearch/config"
WORKDIR ${ES_HOME}
CMD ["sh", "-c", "${ES_HOME}/bin/elasticsearch"]

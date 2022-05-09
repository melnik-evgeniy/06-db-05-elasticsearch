### Домашнее задание к занятию "6.5. Elasticsearch"

#### Задача 1

В ответе приведите:
- текст Dockerfile манифеста
```dockerfile
FROM centos:7

EXPOSE 9200 9300

USER 0

RUN export ES_HOME="/var/lib/elasticsearch" && \
    yum -y install wget && \
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.17.0-linux-x86_64.tar.gz && \
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.17.0-linux-x86_64.tar.gz.sha512 && \
    sha512sum -c elasticsearch-7.17.0-linux-x86_64.tar.gz.sha512 && \
    tar -xzf elasticsearch-7.17.0-linux-x86_64.tar.gz && \
    rm -f elasticsearch-7.17.0-linux-x86_64.tar.gz* && \
    mv elasticsearch-7.17.0 ${ES_HOME} && \
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
```
```bash
docker build . -t melnik1988/devops-elasticsearch:7.17
```
Push to Hub
![](https://github.com/melnik-evgeniy/06-db-05-elasticsearch/blob/831196642b149009e163cefd49c345573078af68/1.jpg?raw=true)

- ссылку на образ в репозитории dockerhub
https://hub.docker.com/repository/docker/melnik1988/devops-elasticsearch
- ответ `elasticsearch` на запрос пути `/` в json виде
```bash
$ docker run --rm -d --name elastic -p 9200:9200 -p 9300:9300 melnik1988/devops-elasticsearch:7.17
$ docker ps
```
![](https://github.com/melnik-evgeniy/06-db-05-elasticsearch/blob/831196642b149009e163cefd49c345573078af68/1.jpg?raw=true)

```bash
$ curl -X GET 'localhost:9200/'
```
```json
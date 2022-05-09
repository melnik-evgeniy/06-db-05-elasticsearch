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
![](https://github.com/melnik-evgeniy/06-db-05-elasticsearch/blob/609bd60dc0b3c310c00c5c20847dc02322e2b320/1.jpg?raw=true)

- ссылку на образ в репозитории dockerhub
https://hub.docker.com/repository/docker/melnik1988/devops-elasticsearch
- ответ `elasticsearch` на запрос пути `/` в json виде
```bash
$ docker run --rm -d --name elastic -p 9200:9200 -p 9300:9300 melnik1988/devops-elasticsearch:7.17
$ docker ps
```
![](https://github.com/melnik-evgeniy/06-db-05-elasticsearch/blob/609bd60dc0b3c310c00c5c20847dc02322e2b320/2.jpg?raw=true)

```bash
$ curl -X GET 'localhost:9200/'
```
```json
{
  "name" : "ec4f21270128",
  "cluster_name" : "netology_test",
  "cluster_uuid" : "TMpyD6JUQuOLk58DT5Ee0A",
  "version" : {
    "number" : "7.17.0",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "bee86328705acaa9a6daede7140defd4d9ec56bd",
    "build_date" : "2022-01-28T08:36:04.875279988Z",
    "build_snapshot" : false,
    "lucene_version" : "8.11.1",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```

#### Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомьтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

```bash
Melnik@Melnik-E 06-db-05-elasticsearch % curl -X PUT "localhost:9200/ind-1?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0
  }
}
'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-1"
}

Melnik@Melnik-E 06-db-05-elasticsearch % curl -X PUT "localhost:9200/ind-2?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "number_of_shards": 2,
    "number_of_replicas": 1
  }
}
'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-2"
}
Melnik@Melnik-E 06-db-05-elasticsearch % curl -X PUT "localhost:9200/ind-3?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "number_of_shards": 4,
    "number_of_replicas": 2
  }
}
'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-3"
}
```
Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.
```bash
Melnik@Melnik-E 06-db-05-elasticsearch % curl 'localhost:9200/_cat/indices?v'                                             
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases w-9ftls_TZyDrcjKxq8RUQ   1   0         40            0       38mb           38mb
green  open   ind-1            rp-5Kv5KRuKyI_2mpQc-EQ   1   0          0            0       226b           226b
yellow open   ind-3            prosva40SWulKxzudGYv5w   4   2          0            0       226b           226b
yellow open   ind-2            AFlzR2YtQQ6Z40ehLqenjQ   2   1          0            0       452b           452b
```
Получите состояние кластера `elasticsearch`, используя API.
```bash
curl -X GET "localhost:9200/_cluster/health?pretty"
{
  "cluster_name" : "netology_test",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 10,
  "active_shards" : 10,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 50.0
}
```
Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?
```
Первичный шард и реплика не могут находиться на одном сервере (узле), если копия не назначена. Т.е., один узел не может размещать копии
```
Удалите все индексы.
```bash
$ curl -X DELETE 'http://localhost:9200/_all'
{"acknowledged":true}% 
```

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.


#### Задача 3
Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.
```bash
$ Melnik@Melnik-E 06-db-05-elasticsearch % docker exec -u root -it elastic bash
[root@ec4f21270128 elasticsearch]#
[root@ec4f21270128 elasticsearch]# mkdir $ES_HOME/snapshots
```
Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.
```bash
# echo path.repo: [ "/var/lib/elasticsearch/snapshots" ] >> "$ES_HOME/config/elasticsearch.yml"
# chown elasticsearch:elasticsearch /var/lib/elasticsearch/snapshots

Melnik@Melnik-E 06-db-05-elasticsearch % docker restart elastic
Melnik@Melnik-E 06-db-05-elasticsearch % curl -X PUT "localhost:9200/_snapshot/netology_backup?pretty" -H 'Content-Type: application/json' -d'
{
  "type": "fs",
  "settings": {
    "location": "/var/lib/elasticsearch/snapshots",
    "compress": true
  }
}'
{
  "acknowledged" : true
}
```
**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

```bash
$ Melnik@Melnik-E 06-db-05-elasticsearch % curl -X PUT "localhost:9200/test?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0
  }
}
'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "test"
}
Melnik@Melnik-E 06-db-05-elasticsearch % curl 'localhost:9200/_cat/indices?v'
health status index            uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .geoip_databases w-9ftls_TZyDrcjKxq8RUQ   1   0         40            0       38mb           38mb
green  open   test             eEfLDXJqTTmtM9Mp-yUAkg   1   0          0            0       226b           226b
```

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.

```bash
Melnik@Melnik-E 06-db-05-elasticsearch % curl -X PUT "localhost:9200/_snapshot/netology_backup/snapshot_1?wait_for_completion=true&pretty"
{
  "snapshot" : {
    "snapshot" : "snapshot_1",
    "uuid" : "oqFJz4V-TOKSG-a-ukCpDQ",
    "repository" : "netology_backup",
    "version_id" : 7170099,
    "version" : "7.17.0",
    "indices" : [
      ".ds-.logs-deprecation.elasticsearch-default-2022.05.09-000001",
      ".geoip_databases",
      "test",
      ".ds-ilm-history-5-2022.05.09-000001"
    ],
    "data_streams" : [
      "ilm-history-5",
      ".logs-deprecation.elasticsearch-default"
    ],
    "include_global_state" : true,
    "state" : "SUCCESS",
    "start_time" : "2022-05-09T18:33:53.192Z",
    "start_time_in_millis" : 1652121233192,
    "end_time" : "2022-05-09T18:33:54.394Z",
    "end_time_in_millis" : 1652121234394,
    "duration_in_millis" : 1202,
    "failures" : [ ],
    "shards" : {
      "total" : 4,
      "failed" : 0,
      "successful" : 4
    },
    "feature_states" : [
      {
        "feature_name" : "geoip",
        "indices" : [
          ".geoip_databases"
        ]
      }
    ]
  }
}
```
**Приведите в ответе** список файлов в директории со `snapshot`ами.
```bash
Melnik@Melnik-E 06-db-05-elasticsearch % docker exec -it elastic ls -l /var/lib/elasticsearch/snapshots/
total 28
-rw-r--r-- 1 elasticsearch elasticsearch 1422 May  9 18:33 index-0
-rw-r--r-- 1 elasticsearch elasticsearch    8 May  9 18:33 index.latest
drwxr-xr-x 6 elasticsearch elasticsearch 4096 May  9 18:33 indices
-rw-r--r-- 1 elasticsearch elasticsearch 9695 May  9 18:33 meta-oqFJz4V-TOKSG-a-ukCpDQ.dat
-rw-r--r-- 1 elasticsearch elasticsearch  455 May  9 18:33 snap-oqFJz4V-TOKSG-a-ukCpDQ.dat
```
Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

```bash
Melnik@Melnik-E 06-db-05-elasticsearch % curl -X DELETE "localhost:9200/test?pretty"
{
  "acknowledged" : true
}


Melnik@Melnik-E 06-db-05-elasticsearch % curl -X PUT "localhost:9200/test-2?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas": 0
  }
}
'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "test-2"
}

Melnik@Melnik-E 06-db-05-elasticsearch % curl 'localhost:9200/_cat/indices?pretty'
green open test-2           xHzUbb1ES7etZORUmZItMw 1 0  0 0 226b 226b
green open .geoip_databases w-9ftls_TZyDrcjKxq8RUQ 1 0 40 0 38mb 38mb
```
[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.
```bash
Melnik@Melnik-E 06-db-05-elasticsearch % curl -X POST "localhost:9200/_snapshot/netology_backup/snapshot_1/_restore?pretty" -H 'Content-Type: application/json' -d'
{
  "indices": "*",
  "include_global_state": true
}
'
{
  "accepted" : true
}
Melnik@Melnik-E 06-db-05-elasticsearch % curl 'localhost:9200/_cat/indices?pretty'
green open test-2           xHzUbb1ES7etZORUmZItMw 1 0  0 0  226b  226b
green open .geoip_databases 4zEr90w3Rn6c3Kv31Gv0Qw 1 0 40 0 5.6mb 5.6mb
green open test             gKCukERESlKdCW8R8BBhng 1 0  0 0  226b  226b
```
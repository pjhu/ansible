# roles
cadvisor-docker-compose
curator
docker-compose
docker-engine
elastalert-docker-compose
elasticsearch
filebeat
java
kibana-docker-compose
kopf
libselinux-python
logstash
logstash-docker-compose
nginx-docker-compose
repo-epel

# Prerequisite

### Ansible Installation

Ansible 2.X is preferred, you can find the very version by `cat .ansible-version`.       
You can find the installation instruction [here](http://docs.ansible.com/ansible/intro_installation.html).

# Deployment

### Elasticsearch
---    

To deploy and tuning Elasticsearch, please edit the corresponding profile vars then executes the following command

    user@machine:ScaleWorks_Analytics_Sephora$ ansible-playbook playbooks/profiles/${env}/hosts playbooks/elasticsearch.yml [-vvvv]

**Note:**

1. the ${env} is a placeholder for specific environments, if the value is dev for instance, there should be directory named dev under playbooks/profiles
2. the paraemters wrapped in "[]" is optional.
3. if ssh/sudo password is required and you don't want to put them in the repo, you can add `--ask-pass --ask-become-pass` to instruct ansible to use interactive mode.

#### Frequently used variables

* es_config: Elasticsearch config items in JSON format, a sample might look like this:

```
    {
        network.host: "0.0.0.0",
        node.name: "swa-es-1",
        cluster.name: "sephora_analytics_uat",
        discovery.zen.ping.unicast.hosts: ["127.0.0.1"],
        http.port: 9200,
        transport.tcp.port: 9300,
        node.data: true,
        node.master: true,
        bootstrap.mlockall: true,
        discovery.zen.ping.multicast.enabled: false
    }
```

* es_data_dir where elasticsearch put the data, it is especially useful if you need to mount an external volume. A sample might look like this `/opt/elasticsearch/data`

* es_log_dir where elasticsearch put the log, it is especially useful if you need to mount an external volume. A sample might look like this `/opt/elasticsearch/log`

* es_heap_size required if you set `bootstrap.mlockall` to `true`. These two config items instruct elasticsearch to lock memory when it starts up. A sample might look like this `1g`


### Redis
---

In order to deploying a single Redis server node, please edit the corresponding profile vars then executes the following command

    user@machine:ScaleWorks_Analytics_Sephora$ ansible-playbook playbooks/profiles/${env}/hosts playbooks/redis.yml [-vvvv]

#### Frequently used variables

* redis_bind: 0.0.0.0
* redis_port: 6379

**Note:** You'll now have a Redis server listening on 0.0.0.0:6379

### Logstash as a Gateway
---   

In order to deploying a single Logstash getway instance, please edit the corresponding profile vars then executes the following command

    user@machine:ScaleWorks_Analytics_Sephora$ ansible-playbook playbooks/profiles/${env}/hosts playbooks/logstash-gateway.yml [-vvvv]

#### Frequently used variables

* logstash_version: Specific logsatsh version is required installation in the system.

* logstash_inputs: Enables specific sources of event to be read by Logstash, If you collect messages from Beats, a sample read events from beats might look like this

    ```    
    beats {
      port => 5043
    }
    ```
    **Note:** In order to Logstash read events from the port, the Beats must be output events on this port

* logstash_filters: Just need to set this variable is empty, Because this Logstash instance just only used as a Gateway

* logstash_outputs: Where the events will going, here we use Redis as output, a sample might look like this

    ```    
    redis {
      host => ["redis_host:redis_port"]
      key => "redis_key_name"
      data_type => list
    }
    ```

### Logstash as an indexer
---
The Logstash indexer use docker contanier as a service, in order to deploying Logstash indexer instances, please edit the corresponding profile vars then executes the following command

    user@machine:ScaleWorks_Analytics_Sephora$ ansible-playbook playbooks/profiles/${env}/hosts playbooks/logstash-indexer.yml [-vvvv]

#### Frequently used variables

* docker_compose_dir: Put docker-compose file, and some config files needed by docker container. A sample might look like `/opt/logstash/indexer/1`, used store files needed by only a single Logstash intance

* app_configs: Config which files you need to upload in `playbooks/profiles/roles/role_name/tempaltes`, these files will be used by docker container

* app_config_files: Config which files you need to upload in `playbooks/profiles/roles/role_name/files`, these files will be used by docker container

* logstash_inputs: Enables specific sources of event to be read by Logstash, A sample might look like this

    ```    
    redis {
      host => "redis_host"
      port => redis_port
      key => "redis_key"
      data_type => list
    }
    ```

* logstash_filters: Processing events according you need, a sample look like this

    ```    
    grok {
      patterns_dir => ["patterns_dir"]
      match => { "message" => "SEPHORA_PATTERN" }
    }
    ```

    **Note:** patterns_dir specific the path where is pattern file, match specific messages pattern which compose by regular expression. Logstash ships with about 120 patterns by default, you can find them [here](https://github.com/logstash-plugins/logstash-patterns-core/tree/master/patterns)

* logstash_outputs: Where the events will going, here we use elasticsearch, a sample might look like this

    ```    
    elasticsearch {
      hosts => ["es_host:es_port"]
      index => "es_index"
      document_type => "type"
    }
    ```

* redis_key: Used by Lostash input plugin, means Logstash will read messages from this redis key

* es_index: Used by Logstash output plugin, means which Elasticsearch index will be store these output messages  


**Note:** every logstash instance need these variables

### Kibana
---   
The Kibana use docker contanier as a service, in order to deploying Kibana instances, please edit the corresponding profile vars then executes the following command

    user@machine:ScaleWorks_Analytics_Sephora$ ansible-playbook playbooks/profiles/${env}/hosts playbooks/kibana.yml [-vvvv]

As a docker container for Kibana, you just need to config docker-compose file, might look like this

```    
kibana:
  image: kibana:4.2  
  environment:
    - ELASTICSEARCH_URL=http://es_host:es_port  
  ports:
    - "kibana_port"
```

**Note:** ELASTICSEARCH_URL specific which Elasticsearch will be connected by Kibana

### Nginx
---
The Nginx use docker contanier as a service, in order to deploying Nginx instances, please edit the corresponding profile vars then executes the following command

    user@machine:ScaleWorks_Analytics_Sephora$ ansible-playbook playbooks/profiles/${env}/hosts playbooks/nginx.yml [-vvvv]

#### Frequently used variables

* app_configs: Config which files you need to upload in `playbooks/profiles/roles/role_name/tempaltes`, these files will be used by docker container

* kibana_host: Config Kibana host

### Elastalert
---
The Elastalert use docker contanier as a service, in order to deploying Elastalert instances, please edit the corresponding profile vars then executes the following command

    user@machine:ScaleWorks_Analytics_Sephora$ ansible-playbook playbooks/profiles/${env}/hosts playbooks/elastalert.yml [-vvvv]

#### Frequently used variables

* app_configs: Config which files you need to upload in `playbooks/profiles/roles/role_name/tempaltes`, these files will be used by docker container

* es_host: Config Elasticsearch host for output Elastalert messages to specific Elasticsearch

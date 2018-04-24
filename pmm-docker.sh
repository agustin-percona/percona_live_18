cleanup_started_containers()
{
    local _containers="pmm-server pmm-data cassandra1 cassandra2 cassandra3 \
                       postgresql postgresql-exporter clickhouse clickhouse-exporter"

    for container in $_containers; do
            #echo $container;
	    docker stop $container &>/dev/null
	    docker rm $container &>/dev/null
    done
    docker network rm pmm-network
}

create_network()
{
    docker network create --driver bridge pmm-network
}

create_and_start_pmm_containers()
{
   docker pull percona/pmm-server:latest

   docker create \
   -v /opt/prometheus/data \
   -v /opt/consul-data \
   -v /var/lib/mysql \
   -v /var/lib/grafana \
   --name pmm-data \
   percona/pmm-server:latest /bin/true
   
   docker run -d \
   -p 80:80 \
   --volumes-from pmm-data \
   --name pmm-server \
   --restart always \
   --network pmm-network \
   percona/pmm-server:latest
}

create_and_start_postgresql()
{
  docker run -d \
  --publish 5432:5432 \
  --name postgresql \
  --network pmm-network \
  --env POSTGRES_PASSWORD=postgres \
  --env POSTGRES_USER=postgres \
  guriandoro/postgresql-pmm:1.0

### To check if it's running correctly:
# docker run -it --rm --network pmm-network \
# --link postgresql:postgres postgres \
# psql -h postgres -U postgres
}

create_and_start_clickhouse()
{
  docker run -d \
  --name clickhouse \
  --ulimit nofile=262144:262144 \
  --network pmm-network \
  guriandoro/clickhouse-pmm:1.0

### To check if it's running correctly:
# docker run -it --rm --network pmm-network \
# --link clickhouse:clickhouse-server \
# yandex/clickhouse-client --host clickhouse-server
}

create_and_start_postgresql_exporters()
{
  docker run -d \
  --publish 9187:9187 \
  --name postgresql-exporter \
  --network pmm-network \
  --env DATA_SOURCE_NAME="postgresql://postgres:postgres@postgresql:5432/?sslmode=disable" \
  wrouesnel/postgres_exporter:latest

docker exec -it postgresql /usr/local/bin/configure-pmm-client.sh

### To check if it's running correctly
#docker exec -it postgresql pmm-admin list
}

create_and_start_clickhouse_exporters()
{
  docker run -d \
  docker run -d \
  --publish 9116:9116 \
  --name clickhouse-exporter \
  --network pmm-network \
  f1yegor/clickhouse-exporter -scrape_uri=http://clickhouse:8123/

docker exec -it clickhouse /usr/local/bin/configure-pmm-client.sh

### To check if it's running correctly
#docker exec -it clickhouse pmm-admin list
}

create_and_start_cassandra()
{
  for i in 1 2; do
    docker run --name cassandra$i \
      --network pmm-network \
      -p 127.0.0.1:${i}7400:7400 \
      -e CASSANDRA_CLUSTER_NAME=plmce \
      -d fipar/cassandra-pmm:v1
  done
#docker run --name cassandra1 -p 7400:7400 -d fipar/cassandra-pmm:v1
}

create_and_start_cassandra_exporters()
{
  for i in 1 2; do
    docker exec -ti cassandra$i /usr/local/bin/configure-pmm-client.sh
  done
}

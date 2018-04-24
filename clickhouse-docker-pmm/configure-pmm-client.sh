#!/bin/sh

pmm-admin config --server pmm-server
pmm-admin add external:metrics clickhouse clickhouse-exporter:9116


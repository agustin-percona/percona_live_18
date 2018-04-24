#!/bin/sh

pmm-admin config --server pmm-server
pmm-admin add external:metrics postgresql postgresql-exporter:9187


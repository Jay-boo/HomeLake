#!/usr/bin/env bash
# /opt/data is bind-mounted from the host, so directories baked into the image
# are hidden. Create the ones Spark expects (see conf/spark-defaults.conf)
# before handing over to the service command.
set -euo pipefail

mkdir -p /opt/data/spark-events /opt/data/warehouse

exec "$@"

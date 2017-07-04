#!/usr/bin/env bash

set -exo pipefail

docker build -t redshot_test .

REDIS_NAME=$(docker run --rm -d redis:latest --requirepass password123)
finish () {
  docker stop $REDIS_NAME
}
set +e

docker run --rm --link $REDIS_NAME:redis redshot_test  \
  || (finish; set +x; echo -e "\033[0;31mTests exited with non-zero exit code\033[0m"; tput bel; exit 1 )
  
finish;
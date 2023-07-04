#!/usr/bin/env sh

docker container stop $(docker container ls -a -q) && docker container rm $(docker container ls -a -q)
docker image rm $(docker images --filter=reference='*_backend' -a -q)
docker system prune -af
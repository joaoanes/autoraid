#!/bin/bash

set -e

echo "Removing build"
sudo rm -rf _build
sudo rm -rf deps

echo "Running docker mix release"
sudo docker run --name cyndaquil-builder -t -d -v "$PWD":/app -e MIX_ENV=prod -w /app hexpm/elixir:1.10.0-erlang-22.2-ubuntu-bionic-20200219

sudo docker exec cyndaquil-builder mix local.rebar --force
sudo docker exec cyndaquil-builder mix local.hex --force
sudo docker exec cyndaquil-builder mix deps.get
sudo docker exec cyndaquil-builder mix release prod

sudo docker rm cyndaquil-builder --force

mkdir -p deploy

echo "Moving to deploy"
sudo mv ./_build/prod/*.tar.gz ./deploy
scp ./deploy/*.tar.gz ubuntu@api.raid.network:/home/ubuntu/ 

echo "Resetting deps and _build"
sudo rm -rf _build
sudo rm -rf deps
mix deps.get

rm -rf deploy

echo "Done!"

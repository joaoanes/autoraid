#! /bin/bash

BUMP=${1:-patch}

../build_boss_registry.sh

yarn version "--$BUMP"  
REACT_APP_CYNDAQUIL_VERSION=$(cat ../mix.exs | grep -oP 'version: "\K(.*)(?=")') \
  REACT_APP_WOOLOO_VERSION=$(cat package.json | jq -r .version) \
  yarn build

$(yarn global bin)/netlify deploy --dir ./build --prod

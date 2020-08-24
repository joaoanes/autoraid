#! /bin/bash

rm -rf ./public/raid_bosses.json
curl "https://pogoapi.net/api/v1/raid_bosses.json" > ./public/raid_bosses.json
yarn build
$(yarn global bin)/netlify deploy --dir ./build --prod

#! /bin/bash

 curl "https://pogoapi.net/api/v1/raid_bosses.json" | jq ".current | values[] | .[].name"

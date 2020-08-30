#! /bin/bash
echo "Getting current raid bosses and putting them on the registry"

curl https://pogoapi.net/api/v1/raid_bosses.json | jq "
  .current |
  map(.) |
  flatten |
  map({
    key: (
      (if .tier == \"mega\" then \"Mega \" else \"\" end) +
      (if .form == \"Alola\" then \"Alolan \" else \"\" end) +
      .name +
      (if .form != \"Alola\" and .form != \"Normal\" then \" \" + .form else \"\" end)
    ),
    value: {dex_number: .id, name, form, tier, possible_shiny, max_boosted_cp, min_boosted_cp, max_unboosted_cp, min_unboosted_cp, type}
  })
  | from_entries" > ./priv/boss_registry.json

cat ./priv/boss_registry.json | jq 'to_entries | map(.key) | join (", ")'

echo "Performing wooloo transform (key by raid tier and flatten to array)"

cat ./priv/boss_registry.json | jq 'to_entries | group_by(.value.tier) | map(from_entries) | map({key: (.[].tier | tostring), value: (. | to_entries | map(.value + {boss_name: .key})) }) | from_entries' > ./wooloo/public/boss_registry_w.json

import { map, merge, reduce } from "lodash"

let listSingleton = null

export const getRaidList = async () => {
  if (listSingleton) return listSingleton

  const res = await fetch("/raid_bosses.json").then((res) => res.json()).then(
    (raids) => (
      reduce(
        map(raids.current, (mons, star) => ({
          [star]: map(mons, (mon) => ({ dexEntry: mon.id, name: mon.name, possibleShiny: mon.possible_shiny })),
        }),
        ),
        merge,
      )
    ),
  )

  listSingleton = res

  return res
}

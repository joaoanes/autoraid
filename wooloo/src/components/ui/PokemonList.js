import React from "react"
import { map, reverse, merge } from "lodash"
import IconButton from "./IconButton"

const TEST_BOSSES = { "5": [{ name: "MISSINGNO", dexEntry: 151 }] }

export const PokemonList = (props) => {
  const pokemonList = props.pokemonList || TEST_BOSSES
  const { selected, setSelected } = props

  return (
    <>
      <div style={styles.container}>
        {
          map(reverse(Object.keys(pokemonList)), (star) => {
            const mons = pokemonList[star]
            if (mons.length === 0) { return null }
            return (
              <>
                <div style={styles.number}>{`${star}*`}</div>
                <div style={merge(styles.separator, styles.number)} key={star}></div>
                <div style={styles.pokemonContainer}>
                  {
                    mons.map(({ dexEntry, name, possibleShiny }) =>
                      <div key={dexEntry} style={{ marginBottom: 10 }}>
                        <IconButton
                          key={dexEntry}
                          selected={selected ? dexEntry === selected.dexEntry : false}
                          onClick={() => setSelected({ dexEntry, name })}
                          icon={`https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${dexEntry}.png`}
                        >
                          {name + (possibleShiny ? "*" : "")}
                        </IconButton>
                      </div>,
                    )
                  }
                </div>

              </>
            )
          })
        }
      </div>
    </>
  )
}

const styles = {
  separator: {
    border: "1px solid white",
    width: "100%",
  },
  pokemonContainer: {
    marginTop: 20,
    display: "flex",
    flexShrink: 0,
    flexWrap: "wrap",
    overflowY: "scroll",
    justifyContent: "space-around",
    marginBottom: 20,
  },
  container: {

    border: "unset",
    display: "flex",
    flexDirection: "column",
    overflowY: "scroll",
    marginLeft: 50,
    marginRight: 50,
  },
  number: {
    fontSize: 30,
  },
}

export default PokemonList

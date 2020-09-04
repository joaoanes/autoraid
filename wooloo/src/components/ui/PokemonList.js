import React from "react"
import { map, reverse, merge } from "lodash"
import IconButton from "./IconButton"
import { getIcon } from '../../lib/pokemonIcons'

const TEST_BOSSES = { "5": [{ name: "MISSINGNO", dex_number: 151 }], "mega": [{ name: "Charizard", dex_number: 6, form: "X" }] }

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
              <div key={star}>
                <div style={styles.number}>{`${star}*`}</div>
                <div style={merge(styles.separator, styles.number)} key={star}></div>
                <div style={styles.pokemonContainer}>
                  {
                    mons.map((mon) => {
                      const { dex_number, boss_name, possible_shiny} = mon
                      return (
                        <div key={boss_name} style={{ marginBottom: 10 }}>
                          <IconButton
                            selected={selected ? boss_name === selected.boss_name : false}
                            onClick={() => setSelected(mon)}
                            icon={getIcon(mon)}
                          >
                            {boss_name + (possible_shiny ? "*" : "")}
                          </IconButton>
                        </div>
                      )
                    })
                  }
                </div>

              </div>
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
    justifyContent: "space-around",
    marginBottom: 20,
  },
  container: {

    border: "unset",
    display: "flex",
    flexDirection: "column",
    marginLeft: 50,
    marginRight: 50,
  },
  number: {
    fontSize: 30,
  },
}

export default PokemonList

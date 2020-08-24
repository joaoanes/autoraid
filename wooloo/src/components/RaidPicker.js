import React, { useState } from "react"

import Button from "./ui/Button"
import PokemonList from "./ui/PokemonList"

const AVAILABLE_BOSSES = [
  "Oshawott",
  "Klink",
  "Wailmer",
  "Shinx",
  "Sandshrew",
  "Magikarp",
  "Prinplup",
  "Mawile",
  "Gligar",
  "Breloom",
  "Marowak",
  "Kingler",
  "Onix",
  "Vaporeon",
  "Donphan",
  "Raichu",
  "Claydol",
  "Machamp",
  "Weezing",
  "Golem",
  "Tyranitar",
  ",Rhydon",
  "Excadrill",
  "Marowak",
  "Heatran",
]

const RaidPicker = ({ user, addToQueue, activeRaids }) => {

  const [selected, setSelected] = useState(null)
  const [hasSelected, setHasSelected] = useState(false)
  const [maxInvites, setMaxInvites] = useState(5)

  return (
    <div style={styles.container}>
      <div>{`Of course ${user.name}! Let's find you a group!`}</div>

      {
        !hasSelected && (
          <>

            <div>
              Which pokemon do you want to raid against?
            </div>

            <div style={styles.separator} />
            <div style={styles.list}>
              <PokemonList pokemonList={activeRaids} selected={selected} setSelected={setSelected} />
            </div>

            <div style={styles.separator} />
            <Button selected={selected !== null} onClick={() => addToQueue(selected)} >{selected ? `Look for a ${selected.name} raid!` : "Select a Pokemon!"}</Button>

          </>
        )
      }
    </div>
  )
}

export const styles = {
  selectButton: {
    backgroundColor: "unset",
    padding: 20,
    marginTop: 20,
    fontSize: 18,
    fontWeight: 700,
    width: "80%",
    border: "1px solid white",
    borderRadius: 20,
    color: "white",
  },
  buttonUnavailable: {
    border: "1px solid grey",
    color: "grey",
  },
  container: {
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    width: "80%",
    marginLeft: "auto",
    marginRight: "auto",
  },
  list: {
    height: 500,
    overflowY: "scroll",
    overflowX: "hidden",
  },
  separator: {
    border: "1px solid white",
    width: "100%",
  },
  track: {
    backgroundColor: "white",
  },
  dot: {
    border: "2px solid white",
    width: 28,
    height: 28,

    marginTop: -12,
  },
  maxInvites: {
    fontSize: 50,
    marginTop: 40,
    marginBottom: 40,
  },
}

export default RaidPicker

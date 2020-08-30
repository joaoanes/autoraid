import React, { useState } from "react"

import Button from "./ui/Button"
import PokemonList from "./ui/PokemonList"
import { PokemonPicker } from "./ui/PokemonPicker"

const RaidPicker = ({ user, addToQueue, activeRaids }) => {

  const [selected, setSelected] = useState(null)

  return (
    <div style={styles.container}>
      <div>{`Of course ${user.name}! Let's find you a group!`}</div>

      <div>
        Which pokemon do you want to raid against?
      </div>

      <div style={styles.separator} />
      <PokemonPicker
        select={addToQueue}
        pokemonList={activeRaids}
        selected={selected}
        setSelected={setSelected}
        buttonText={selected ? `Look for a ${selected.boss_name} raid!` : "Select a Pokemon!"}
      />

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
    height: "100%",
    marginLeft: "auto",
    marginRight: "auto",
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

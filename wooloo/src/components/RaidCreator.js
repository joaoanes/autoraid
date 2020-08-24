import React, { useState } from "react"
import Slider, { Range } from "rc-slider"
import "rc-slider/assets/index.css"

import { styles } from "./RaidPicker"
import Button from "./ui/Button"
import PokemonList from "./ui/PokemonList"

const RaidCreator = ({ user, addRaidToQueue, activeRaids }) => {

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
              <PokemonList
                pokemonList={activeRaids} selected={selected} setSelected={setSelected} />
            </div>

            <div style={styles.separator} />
            <Button selected={selected !== null} onClick={() => setHasSelected(selected !== null)} >{selected ? `Select ${selected.name}` : "Select a Pokemon!"}</Button>
          </>
        )
      }

      {
        hasSelected && (
          <>
            <div style={styles.tagline}>How many trainers can you invite?</div>
            <div style={styles.maxInvites}>{maxInvites}</div>
            <Slider min={1} max={5} value={maxInvites} onChange={setMaxInvites} handleStyle={styles.dot} dotStyle={styles.dot} trackStyle={styles.track} />
            <button style={{ ...styles.selectButton, ...(selected !== null ? {} : styles.buttonUnavailable) }} onClick={() => addRaidToQueue(selected, maxInvites)} >{`Create raid for ${selected.name}`}</button>
          </>
        )
      }
    </div>
  )
}

export default RaidCreator

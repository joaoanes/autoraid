import React, { useState } from "react"
import Slider from "rc-slider"
import "rc-slider/assets/index.css"

import { styles } from "./RaidPicker"
import PokemonPicker from "./ui/PokemonPicker"

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
            <PokemonPicker
              pokemonList={activeRaids} selected={selected} setSelected={setSelected} select={() => setHasSelected(selected !== null)} buttonText={selected ? `Select ${selected.boss_name}` : "Select a Pokemon!"} />
          </>
        )
      }

      {
        hasSelected && (
          <>
            <div style={styles.tagline}>How many trainers can you invite?</div>
            <div style={styles.maxInvites}>{maxInvites}</div>
            <Slider min={1} max={5} value={maxInvites} onChange={setMaxInvites} handleStyle={styles.dot} dotStyle={styles.dot} trackStyle={styles.track} />
            <button style={{ ...styles.selectButton, ...(selected !== null ? {} : styles.buttonUnavailable) }} onClick={() => addRaidToQueue(selected, maxInvites)} >{`Create raid for ${selected.boss_name}`}</button>
          </>
        )
      }
    </div>
  )
}

export default RaidCreator

import React, { useState } from "react"
import { getValueFromEvent } from "../lib/junkyard"

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
  "Rhydon",
  "Excadrill",
  "Marowak",
  "Heatran"
]

const RaidCreator = ({ user, socketReady, addRaidToQueue }) => {
  const [maxInvites, setMaxInvites] = useState("5")
  const [location, setLocation] = useState("")

  return (
    <div>
      <div>{`Of course ${user.name}! Let's find you some people!`}</div>

      <div>
        <div>
          Can you tell us more about the raid?
        </div>
        <br></br>
        <br></br>
        <div>
          <label>Maximum invites</label>
          <input type="text" value={maxInvites} placeholder="How many people you can invite (up to 5)" onChange={getValueFromEvent(setMaxInvites)} />
        </div>
        <div>
          <label>Raid location</label>
          <input type="text" value={location} placeholder="The raid location. Optional" onChange={getValueFromEvent(setLocation)} />
          <div><small>Please be careful here, I have 0 validation for these fields. Don't break my server.</small></div>
        </div>
        <br></br>
        <br></br>
        <div>
          <form>
            <div >
              {
                AVAILABLE_BOSSES.map((boss) => (
                  <div key={boss}>
                    <button disabled={!socketReady} onClick={(e) => { e.preventDefault(); addRaidToQueue(boss, maxInvites, location) }}>{boss}</button>
                  </div>
                ))
              }
            </div>
          </form>
        </div>
      </div>
    </div>
  )
}

export default RaidCreator

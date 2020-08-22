import React, { useState } from "react"
import { getValueFromEvent } from "../lib/junkyard"

const AVAILABLE_BOSSES = ["MISSINGNO", "MEW"]

const RaidCreator = ({ user, socketReady, addRaidToQueue }) => {
  const [maxInvites, setMaxInvites] = useState("")
  const [location, setLocation] = useState("")

  return (
    <div>
      <div>{`Of course ${user.name}! Let's get you going!`}</div>

      <div>
        <div>
        Can you tell us more about the raid?
        </div>

        <input type="text" value={maxInvites} placeholder="How many people you can invite (up to 5)" onChange={getValueFromEvent(setMaxInvites)} />
        <input type="text" value={location} placeholder="The raid location. Optional" onChange={getValueFromEvent(setLocation)} />

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
  ) }

export default RaidCreator

import React from "react"

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

const RaidPicker = ({ user, addToQueue, socketReady }) =>
  (
    <div>
      <div>{`Of course ${user.name}! Let's find you a group!`}</div>

      <div>
        <div>
          Which pokemon do you want to raid against?
        </div>
        <br></br>

        <div>
          <form>
            <div >
              {
                AVAILABLE_BOSSES.map((boss) => (
                  <div key={boss}>
                    <button disabled={!socketReady} onClick={(e) => { e.preventDefault(); addToQueue(boss) }}>{boss}</button>
                  </div>
                ))
              }
            </div>
          </form>
        </div>
      </div>
    </div>
  )

export default RaidPicker

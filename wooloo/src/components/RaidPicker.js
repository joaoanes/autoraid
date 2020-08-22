import React from "react"

const AVAILABLE_BOSSES = ["MISSINGNO", "MEW"]

const RaidPicker = ({ user, addToQueue, socketReady }) =>
  (
    <div>
      <div>{`Of course ${user.name}! Let's get you going!`}</div>

      <div>
        <div>
              Which pokemon do you want to raid against?
        </div>

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

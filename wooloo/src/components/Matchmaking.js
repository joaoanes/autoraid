import React from "react"

const Matchmaking = ({ _stats, _started_at, activeSearch, ownedRaid, currentStats, stop }) => {
  const { bossName } = activeSearch ? activeSearch : ownedRaid
  const stats = (currentStats || {})[bossName]
  debugger
  return (
    <div>
      You're matchmaking!
      <div>
        {(`Finding ${ownedRaid ? "users" : "raids"} for ${bossName}`)}
      </div>

      <br></br>
      <div>You can open the game now. Follow the notification for more updates (or open this page!).</div>
      <br></br>
      <br></br>

      {
        currentStats && <div>
          <div>{`People looking for this raid: ${stats.queued}`}</div>
          <div>{`Raids looking for users: ${stats.rooms}`}</div>
        </div>
      }
      <button onClick={() => stop()}>Stop matchmaking</button>
    </div>
  )
}

export default Matchmaking

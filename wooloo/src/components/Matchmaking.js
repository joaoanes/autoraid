import React from "react"

const Matchmaking = ({ _stats, _started_at, activeSearch, currentStats }) => (
  <div>
        You're matchmaking!
    <div>
      {JSON.stringify(activeSearch)}
    </div>

    <div>
      <h4>Current raid queue statistics</h4>
      {Object.keys(currentStats).map((boss) => (
        <div key={boss}>
          <h3>{boss}</h3>
          <div>{`Queued: ${currentStats[boss].queued}`}</div>
          <div>{`Raids looking for group: ${currentStats[boss].rooms}`}</div>
        </div>
      ))}
    </div>
  </div>
)

export default Matchmaking

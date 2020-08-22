
import React from "react"

const Room = ({ _stats, _started_at, room }) => (
  <div>
        You're matched!
    <div>
      {JSON.stringify(room)}
    </div>

  </div>
)

export default Room

import React, { useState } from "react"
import { every } from "lodash"
import { getValueFromEvent } from "../lib/junkyard"
import { setNotification } from "../lib/notifications"

const checkAndGo = (name, fc, level, setUser, setAppState) => {
  if ([name, fc, level], every((thing) => thing !== "")) {
    setUser({ name, level, fc })
    setAppState("home")
  }
}

const f = (e) => {
  e.preventDefault()
  setNotification("Raid.network", "Test notification!", "wooloo-rest")
}

const Login = ({ setUser, setAppState }) => {
  setUser(null)
  const [name, setName] = useState("")
  const [fc, setFC] = useState("")
  const [level, setLevel] = useState("")

  console.log({ name, fc, level })

  return (
    <div>
      <p>Not so fast! A Taurus is blocking your path!</p>
      <p>Please create an account here!</p>
      <button>Test notification</button>
      <small>This information is ONLY saved on your cellphone. All data you send is eventually deleted after a couple of minutes.</small>
      <div>
        <input type="text" value={name} placeholder="Your in-game name" onChange={getValueFromEvent(setName)} />
        <input type="text" value={fc} placeholder="Your in-game friendcode" onChange={getValueFromEvent(setFC)} />
        <input type="text" value={level} placeholder="Your level" onChange={getValueFromEvent(setLevel)} />
      </div>
      <button onClick={() => checkAndGo(name, fc, level, setUser, setAppState)}>Ok, let's go!</button>
    </div>
  )
}

export default Login

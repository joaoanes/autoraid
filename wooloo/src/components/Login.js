import React, { useState } from "react"
import { every } from "lodash"
import { getValueFromEvent } from "../lib/junkyard"

import Button from "./ui/Button"

const checkAndGo = (name, fc, level, setUser, setAppState) => {
  if ([name, fc, level], every((thing) => thing !== "")) {
    setUser({ name, level, fc })
    setAppState("home")
  }
}

const isReady = (name, fc, level) => {
  const validators = [
    () => name !== "" && name.length <= 16,
    () => fc !== "" && fc.length === 12,
    () => Number.parseInt(level, 0) > 0 && Number.parseInt(level, 0) <= 40,
  ]
  try {
    return every(validators, (fn) => fn())
  }
  catch {
    return false
  }
}

const setFCIfValid = (setFC, oldFC) => (value) => {
  if (value.trim() === oldFC) { return }
  if (value.charAt(value.length - 1) === " ") { return }
  if (oldFC.length === 12) { return }
  if (isNaN(Number.parseInt(value.charAt(value.length - 1), 0))) { return }
  setFC(value)
}

const LoginWithState = ({setUser, setAppState}) => {
  setUser(null)
  const [name, setName] = useState("")
  const [fc, setFC] = useState("")
  const [level, setLevel] = useState("")

  return (
    <Login 
      {...{
        name,
        setName,
        fc,
        setFC,
        level,
        setLevel,
        setAppState,
        setUser
      }}
    />
  )
}

export const Login = ({ setUser, setAppState, name, setName, fc, setFC, level, setLevel }) => {
  setUser(null)

  const localIsReady = isReady(name, fc, level)
  const localSetFCisValid = setFCIfValid(setFC, fc)

  return (
    <div style={styles.container}>
      <img style={styles.tauros} src={`https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${128}.png`}></img>
      <p>Not so fast! A Tauros is blocking your path!</p>
      <p>But while you're here, tell us about yourself!</p>
      <div style={styles.inputContainer}>
        <input style={styles.input} type="text" value={name} placeholder="Your in-game name" onChange={getValueFromEvent(setName)} />
        <input style={styles.input} type="text" value={fc} placeholder="Your in-game friendcode (12 characters)" onChange={getValueFromEvent(localSetFCisValid)} />
        <input style={styles.input} type="text" value={level} placeholder="Your level" onChange={getValueFromEvent(setLevel)} />
        <small>This information is ONLY saved on your cellphone. All data you send is eventually deleted after a couple of minutes.</small>
      </div>
      <div style={styles.buttonContainer}>
        <Button selected={localIsReady} onClick={() => checkAndGo(name, fc, level, setUser, setAppState)}>{localIsReady ? "Let's get raiding!" : "Please fill in above"}</Button>
      </div>
    </div>
  )
}

const styles = {
  buttonContainer: {
    display: "flex",
    marginTop: "auto",
    marginBottom: "auto",
    width: "100%",
    justifyContent: "center",
  },
  inputContainer: {
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    textAlign: "center",
  },
  container: {
    width: "80%",
    height: "100%",
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    marginLeft: "auto",
    marginRight: "auto",
  },
  tauros: {
    minHeight: 96,
  },
  input: {
    border: "unset",
    backgroundColor: "unset",
    color: "white",
    borderBottom: "1px solid white",
    margin: 20,
    width: "100%",
    fontSize: 16,
  },
}

export default LoginWithState

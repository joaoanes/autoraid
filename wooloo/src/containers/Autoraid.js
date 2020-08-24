import React, { useState, useEffect } from "react"

import { getUser, setUser } from "../lib/setUser"
import Matchmaking from "../components/Matchmaking"
import RaidPicker from "../components/RaidPicker"

import Home from "../components/Home"
import Login from "../components/Login"
import Header from "../components/Header"
import Room from "../components/Room"
import { socketForQueues, addUserToQueue, addRaidToQueue } from "../lib/ws"
import { setNotification, hasPermission, setupPWAInstall, confirmPWAInstall } from "../lib/notifications"
import RaidCreator from "../components/RaidCreator"
import { getRaidList } from "../lib/pokemonList"

const stateMapping = {
  init: Home,
  login: Login,
  home: Home,
  raidPicker: RaidPicker,
  raidCreator: RaidCreator,
  matchmaking: Matchmaking,
  room: Room,
}

const setUserPermanent = (stateChanger) => (user) => {
  stateChanger(user)
  setUser(user)
}

const messageHandler = (setCurrentStats, setActiveRoom) => (message) => {
  console.log(message, "wooo")
  const { data, type } = message

  switch (type) {
    case "stats":
      setCurrentStats(data)
      break
    case "receipt":
      setActiveRoom(data)
      break
    default:
      break
  }
}

const setActiveRoom = (setAppState, setActiveRoom) => (room) => {
  setActiveRoom(room)
  setAppState("room")
}

const requireSocket = (setSocket, setCurrentStats, setRooms) => () => (
  setSocket({
    socket: socketForQueues(
      messageHandler(setCurrentStats, setRooms),
      ({ target: socket }) => {
        setSocket({ socket, ready: true })
      },
      (err) => setSocket({ error: err }),
    ),
  })
)

const setAppState = (setInnerAppState, requireSocket, socket) => (newAppState) => {
  setInnerAppState(newAppState)
  if (newAppState === "login") {
    hasPermission()
  }
  if (["init", "login"].indexOf(newAppState) === -1) {
    if (!socket) { requireSocket() }
  }
}

const addToQueue = (socket, setActiveSearch, setAppState, me) => ({ name, dexEntry }) => {
  addUserToQueue(socket, name, me)
  setActiveSearch({ bossName: name, dexEntry })
  setAppState("matchmaking")
}

const raidToQueue = (socket, setOwnedRaid, setAppState, me) => ({ name, dexEntry }, maxInvites, location) => {
  addRaidToQueue(socket, name, location, maxInvites, me)
  setOwnedRaid({ dexEntry, bossName: name })
  setAppState("matchmaking")
}

const stop = () => {
  window.location.reload()
}

const installPWA = (prompt, setAccepted) => {

  confirmPWAInstall(prompt, setAccepted)
}

const Background = ({ matchmaking }) => (
  <div style={styles.backgroundContainer}>
    <img style={{ ...styles.backgroundLogo, ...(matchmaking ? styles.matchmaking : {}) }} src="/logo512.png" />
    <div style={styles.backgroundStars} />
  </div>
)

// Shit, I accidentally built a stateful router.
export const Autoraid = (props) => {
  const { state, ...extraProps } = props
  const [user, setInnerUser] = useState(getUser())
  const [socketOrError, setSocketOrError] = useState({})
  const [appState, setInnerAppState] = useState(state || "init")
  const [activeSearch, setActiveSearch] = useState(null)
  const [ownedRaid, setOwnedRaid] = useState(null)

  const [currentStats, setCurrentStats] = useState(null)
  const [activeRoom, setRoom] = useState(null)

  const [prompt, setPrompt] = useState(null)
  const [acceptedInstall, setAccepted] = useState(false)

  const [activeRaids, setActiveRaids] = useState(null)

  const { socket, error: socketError, ready } = socketOrError

  console.log("Update", appState, user, socketOrError)

  const StateComponent = stateMapping[appState]
  // next time just declare const functions in-body jfc

  const localSetSocketOrError = (socket) => ready ? () => (null) : setSocketOrError(socket)
  const localSetAppState = setAppState(setInnerAppState, requireSocket(localSetSocketOrError, setCurrentStats, setActiveRoom(setInnerAppState, setRoom)))
  const localAddToQueue = addToQueue(socket, setActiveSearch, localSetAppState, user)
  const localRaidToQueue = raidToQueue(socket, setOwnedRaid, localSetAppState, user)

  useEffect(() => setupPWAInstall(setPrompt))

  useEffect(() => {
    if (activeRoom) {
      setNotification("Raid ready!", `Add FC ${activeRoom.raid.leader.fc}`, "wooloo-raidready")
    }
  }, [activeRoom])

  useEffect(() => {
    if (activeSearch && currentStats && !activeRoom) {
      const stats = currentStats[activeSearch.bossName]
      setNotification("Searching for raid", `Raids: ${stats.rooms}, People: ${stats.queued}`, "wooloo-raidmatch", false)
    }
  }, [activeSearch, currentStats])

  useEffect(() => {
    getRaidList().then(setActiveRaids)
  }, [])

  return (
    <div style={styles.appContainer}>

      <Header user={user} setAppState={setAppState} />
      <StateComponent activeRaids={activeRaids} stop={stop} ownedRaid={ownedRaid} currentStats={currentStats} socketReady={ready} user={user} addRaidToQueue={localRaidToQueue} addToQueue={localAddToQueue} activeSearch={activeSearch} setUser={setUserPermanent(setInnerUser)} setAppState={localSetAppState} />
      {prompt && !acceptedInstall && <button onClick={() => installPWA(prompt, setAccepted)}>Add to homescreen</button>}
      {prompt && acceptedInstall && <div>{"Thank you! <3"}</div>}

      <footer style={styles.footer}>
        <small>{"Autoraid 2020 (wooloo v.0.1.1 cyndaquil v.1.0.4)"}</small>
        <small>built with &lt;3 by <a style={styles.link} href="https://www.github.com/joaoanes">@joaoanes</a></small>
        {socket && <div style={{ ...styles.socket, ...(ready ? { opacity: 1 } : { animation: "fade infinite 0.5s alternate backwards" }), ...(socketError ? styles.error : {}) }}><img src="/connected.svg" /></div>}
      </footer>
      <Background matchmaking={activeSearch || ownedRaid} />
    </div>
  )
}

const styles = {
  // background
  backgroundContainer: {
    position: "absolute",
    top: 0,
    bottom: 0,
    left: 0,
    right: 0,
    background: "linear-gradient(230deg, #15234B 0%, #0A1733 100%)",
    zIndex: -200,
  },
  appContainer: {
    display: "flex",
    flexDirection: "column",
    maxWidth: 920,
  },
  backgroundLogo: {
    position: "absolute",
    left: "-18%",
    opacity: 0.1,
    width: "75%",
    animation: "App-logo-spin infinite 250s linear",
    bottom: "-12%",
    transition: "all",
  },
  backgroundLogoFast: {
    animation: "App-logo-spin infinite 75s linear",
  },
  backgroundStars: {
    position: "absolute",
    top: 0,
    bottom: 0,
    left: 0,
    right: 0,
    opacity: 0.5,
    "-webkit-mask-image": "linear-gradient(45deg, transparent 15%, black 50%)",
    maskImage: "linear-gradient(45deg, transparent 15%, black 50%)",

    animation: "heartbeat infinite 60s alternate backwards",
    transformOrigin: "bottom left",
    backgroundImage: "url(/stars.png)",
    backgroundSize: "contain",
  },
  matchmaking: {
    opacity: 0.3,
    width: "80%",
    animation: "App-logo-spin infinite 20s linear",
    bottom: "-8%",
    left: "-8%",
  },
  // component
  footer: {
    position: "absolute",
    bottom: 0,
    left: 0,
    display: "flex",
    flexDirection: "column",
    padding: 10,
    width: "100%",
  },
  link: {
    color: "orange",
  },
  socket: {
    width: 40,
    fill: "white",
    position: "absolute",
    right: 20,
    opacity: 0.2,
    bottom: 0,
  },
  error: {
    backgroundColor: "red",
    opacity: 0.8,
  },
}

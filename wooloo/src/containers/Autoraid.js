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

const addToQueue = (socket, setActiveSearch, setAppState, me) => (bossName) => {
  addUserToQueue(socket, bossName, me)
  setActiveSearch({ bossName })
  setAppState("matchmaking")
}

const raidToQueue = (socket, setOwnedRaid, setAppState, me) => (bossName, maxInvites, location) => {
  addRaidToQueue(socket, bossName, location, maxInvites, me)
  setOwnedRaid({ bossName })
  setAppState("matchmaking")
}

const stop = () => {
  window.location.reload();
}

const installPWA = (prompt, setAccepted) => {

  confirmPWAInstall(prompt, setAccepted)
}

export const Autoraid = (props) => {
  const { state, ...extraProps } = props
  const [user, setInnerUser] = useState(getUser())
  const [socketOrError, setSocketOrError] = useState({})
  const [appState, setInnerAppState] = useState(state || "init")
  const [activeSearch, setActiveSearch] = useState(null)
  const [ownedRaid, setOwnedRaid] = useState(null)

  const [currentStats, setCurrentStats] = useState(null)
  const [activeRoom, setRoom] = useState(null)

  const { socket, error: socketError, ready } = socketOrError

  console.log("Update", appState, user, socketOrError)

  const StateComponent = stateMapping[appState]
  const localSetSocketOrError = (socket) => ready ? () => (null) : setSocketOrError(socket)
  const localSetAppState = setAppState(setInnerAppState, requireSocket(localSetSocketOrError, setCurrentStats, setActiveRoom(setInnerAppState, setRoom)))
  const localAddToQueue = addToQueue(socket, setActiveSearch, localSetAppState, user)
  const localRaidToQueue = raidToQueue(socket, setOwnedRaid, localSetAppState, user)
  const [prompt, setPrompt] = useState(null)
  const [acceptedInstall, setAccepted] = useState(false)

  useEffect(() => setupPWAInstall(setPrompt))

  useEffect(() => {
    if (activeRoom) {
      setNotification(`Raid ready!`, `Add FC ${activeRoom.raid.leader.fc}`, "wooloo-raidready")
    }
  }, [activeRoom])

  useEffect(() => {
    if (activeSearch && currentStats && !activeRoom) {
      const stats = currentStats[activeSearch.bossName]
      setNotification("Searching for raid", `Raids: ${stats.rooms}, People: ${stats.queued}`, "wooloo-raidmatch", false)
    }
  }, [activeSearch])

  return (
    <div>
      <Header user={user} setAppState={setAppState} />
      <StateComponent stop={stop} ownedRaid={ownedRaid} currentStats={currentStats} socketReady={ready} user={user} addRaidToQueue={localRaidToQueue} addToQueue={localAddToQueue} activeSearch={activeSearch} setUser={setUserPermanent(setInnerUser)} setAppState={localSetAppState} />
      {prompt && !acceptedInstall && <button onClick={() => installPWA(prompt, setAccepted)}>Add to homescreen</button>}
      {prompt && acceptedInstall && <div>{"Thank you! <3"}</div>}

      {socket && ready && <small>Connected to raid matchmaker!</small>}
      {socketError && <div>Connection error! {JSON.stringify(socketError)}</div>}
      <footer><small>{"Autoraid 2020 (wooloo v.0.1.1 cyndaquil v.1.0.4) built with <3 by a frustrated asshole"}</small></footer>
    </div>
  )
}

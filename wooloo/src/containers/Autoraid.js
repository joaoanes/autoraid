import React, { useState } from "react"

import { getUser, setUser } from "../lib/setUser"
import Matchmaking from "../components/Matchmaking"
import RaidPicker from "../components/RaidPicker"

import Home from "../components/Home"
import Login from "../components/Login"
import Header from "../components/Header"
import Room from "../components/Room"
import { socketForQueues, addUserToQueue, addRaidToQueue } from "../lib/ws"
import { setNotification, hasPermission } from "../lib/notifications"
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

  setNotification(`Autoraid raid ready! ${room.raid.leader.fc}`)
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

  if (newAppState === "matchmaking") {
    setNotification("Autoraid searching for raid!")
  }

  if (newAppState === "room") {
    setNotification("Autoraid ready!", "Friend code 0000 0000 0000")
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

export const Autoraid = (props) => {
  const { state, ...extraProps } = props
  const [user, setInnerUser] = useState(getUser())
  const [socketOrError, setSocketOrError] = useState({})
  const [appState, setInnerAppState] = useState(state || "init")
  const [activeSearch, setActiveSearch] = useState(null)
  const [ownedRaid, setOwnedRaid] = useState(null)

  const [currentStats, setCurrentStats] = useState({})
  const [activeRoom, setRoom] = useState([])

  const { socket, error: socketError, ready } = socketOrError

  console.log("Update", appState, user, socketOrError)

  const StateComponent = stateMapping[appState]
  const localSetSocketOrError = (socket) => ready ? () => (null) : setSocketOrError(socket)
  const localSetAppState = setAppState(setInnerAppState, requireSocket(localSetSocketOrError, setCurrentStats, setActiveRoom(setInnerAppState, setRoom)))
  const localAddToQueue = addToQueue(socket, setActiveSearch, localSetAppState, user)
  const localRaidToQueue = raidToQueue(socket, setOwnedRaid, localSetAppState, user)

  return (
    <div>
      <Header user={user} setAppState={setAppState} />
      <StateComponent currentStats={currentStats} socketReady={ready} user={user} addRaidToQueue={localRaidToQueue} addToQueue={localAddToQueue} activeSearch={activeSearch} setUser={setUserPermanent(setInnerUser)} setAppState={localSetAppState} />
      {socket && ready && <small>Connected to raid matchmaker!</small>}
      {socketError && <div>Connection error! {JSON.stringify(socketError)}</div>}
      <div>Autoraid wooloo 0.001</div>
    </div>
  )
}

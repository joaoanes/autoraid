import PropTypes from "prop-types";
import React, { useState, useEffect } from "react"

import { getUser, setUser } from "../lib/setUser"
import Matchmaking from "../components/Matchmaking"
import RaidPicker from "../components/RaidPicker"

import Home from "../components/Home"
import Login from "../components/Login"
import Header from "../components/Header"
import Room from "../components/Room"
import Faq from "../components/Faqs"
import { socketForQueues, addUserToQueue, addRaidToQueue } from "../lib/ws"
import { setNotification as setNotificationAPI, hasPermission, setupPWAInstall, confirmPWAInstall } from "../lib/notifications"
import RaidCreator from "../components/RaidCreator"
import { getRaidList } from "../lib/pokemonList"

const { REACT_APP_CYNDAQUIL_VERSION = "uhh", REACT_APP_WOOLOO_VERSION = "UHHH" } = process.env 

export const stateMapping = {
  init: Home,
  login: Login,
  home: Home,
  raidPicker: RaidPicker,
  raidCreator: RaidCreator,
  matchmaking: Matchmaking,
  room: Room,
  faq: Faq,
}

const setUserPermanent = (stateChanger) => (user) => {
  stateChanger(user)
  setUser(user)
}

const messageHandler = (setCurrentStats, setActiveRoom) => (message) => {
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
  if (["init", "login", "faq"].indexOf(newAppState) === -1) {
    if (!socket) { requireSocket() }
  }
}

const addToQueue = (socket, setActiveSearch, setAppState, me) => (mon) => {
  addUserToQueue(socket, mon.boss_name, me)
  setActiveSearch(mon)
  setAppState("matchmaking")
}

const raidToQueue = (socket, setOwnedRaid, setAppState, me) => (mon, maxInvites, location) => {
  addRaidToQueue(socket, mon.boss_name, location, maxInvites, me)
  setOwnedRaid(mon)
  setAppState("matchmaking")
}

const stop = () => {
  window.location.reload()
}

const Background = ({ matchmaking }) => (
  <div style={styles.backgroundContainer}>
    <img style={{ ...styles.backgroundLogo, ...(matchmaking ? styles.matchmaking : {}) }} src="/logo512.png" />
    <div style={styles.backgroundStars} />
  </div>
)

Background.propTypes = {
  matchmaking: PropTypes.any.isRequired
}

const installPWA = (prompt, setAccepted) => {
  confirmPWAInstall(prompt, setAccepted)
}

export const WoolooWithState = () => {

  const [user, setInnerUser] = useState(getUser())
  const [socketOrError, setSocketOrError] = useState({})
  const [appState, setInnerAppState] = useState("init")
  const [activeSearch, setActiveSearch] = useState(null)
  const [ownedRaid, setOwnedRaid] = useState(null)

  const [currentStats, setCurrentStats] = useState(null)
  const [activeRoom, setRoom] = useState(null)

  const [activeRaids, setActiveRaids] = useState(null)

  const [prompt, setPrompt] = useState(false)
  const [acceptedInstall, setAccepted] = useState(false)

  useEffect(() => {
    getRaidList().then(setActiveRaids)
  }, [])

  useEffect(() => setupPWAInstall(setPrompt), [])

  return (
    <Autoraid 
      {...{
        user,
        socketOrError,
        appState,
        activeSearch,
        ownedRaid,
        currentStats,
        activeRoom,
        activeRaids,
        prompt,
        acceptedInstall,
        setPrompt,
        setAccepted,
        setActiveSearch,
        setOwnedRaid,
        setCurrentStats,
        setRoom,
        setInnerAppState,
        setInnerUser,
        setSocketOrError,
        setNotification: setNotificationAPI
      }} 
    />
  )
}

// Shit, I accidentally built a stateful router.
export const Autoraid = (props) => {
  const {
    user,
    socketOrError = {},
    appState,
    activeSearch,
    ownedRaid,
    currentStats,
    activeRoom,
    activeRaids,
    setActiveSearch,
    setOwnedRaid,
    setCurrentStats,
    setRoom,
    prompt,
    acceptedInstall,
    setPrompt,
    setAccepted,
    setNotification,
    setInnerAppState,
    setInnerUser,
    setSocketOrError,
  } = props

  
  const { socket, error: socketError, ready } = socketOrError

  console.log("Update", appState, user, socketOrError)

  const StateComponent = stateMapping[appState]
  // next time just declare const functions in-body jfc

  const localSetSocketOrError = (socket) => ready ? () => (null) : setSocketOrError(socket)
  const localSetAppState = setAppState(setInnerAppState, requireSocket(localSetSocketOrError, setCurrentStats, setActiveRoom(setInnerAppState, setRoom)))
  const localAddToQueue = addToQueue(socket, setActiveSearch, localSetAppState, user)
  const localRaidToQueue = raidToQueue(socket, setOwnedRaid, localSetAppState, user)
  const localOnInstall = () => installPWA(prompt, setAccepted)
  
  useEffect(() => {
    if (activeRoom) {
      setNotification("Raid ready!", `Add FC ${activeRoom.raid.leader.fc}`, "wooloo-raidready")
    }
  }, [activeRoom])

  useEffect(() => {
    if (activeSearch && currentStats && !activeRoom) {
      const stats = currentStats[activeSearch.boss_name]
      setNotification("Searching for raid", `Raids: ${stats.rooms}, People: ${stats.queued}`, "wooloo-raidmatch", false)
    }
  }, [activeSearch, currentStats])

  return (
    <div style={styles.app}>
      <div style={styles.appContainer}>
        <div style={styles.headerContainer}>
          <Header user={user} setAppState={setAppState} />
        </div>
        <div style={styles.contentContainer}>
          <StateComponent onInstall={localOnInstall} prompt={prompt} acceptedInstall={acceptedInstall} setPrompt={setPrompt} setAccepted={setAccepted} activeRaids={activeRaids} stop={stop} ownedRaid={ownedRaid} currentStats={currentStats} socketReady={ready} user={user} addRaidToQueue={localRaidToQueue} addToQueue={localAddToQueue} activeSearch={activeSearch} setUser={setUserPermanent(setInnerUser)} setAppState={localSetAppState} />
        </div>
        <div style={styles.footerContainer}>
          <footer style={styles.footer}>
            <small>{`Autoraid 2020 (wooloo v.${REACT_APP_WOOLOO_VERSION} cyndaquil v.${REACT_APP_CYNDAQUIL_VERSION})`}</small>
            <small>built with &lt;3 by <a style={styles.link} href="https://www.github.com/joaoanes">@joaoanes</a></small>
            {socket && <div style={{ ...styles.socket, ...(ready ? { opacity: 1 } : { animation: "fade infinite 0.5s alternate backwards" }), ...(socketError ? styles.error : {}) }}><img src="/connected.svg" /></div>}
          </footer>
        </div>
        <Background matchmaking={activeSearch || ownedRaid} />
      </div>
    </div>
  )
}

// npx react-proptypes-generate src/containers/Autoraid.js Autoraid
Autoraid.propTypes = {
  activeRaids: PropTypes.any.isRequired,
  activeRoom: PropTypes.shape({
    raid: PropTypes.shape({
      leader: PropTypes.shape({
        fc: PropTypes.any
      })
    })
  }).isRequired,
  activeSearch: PropTypes.shape({
    boss_name: PropTypes.any
  }).isRequired,
  appState: PropTypes.any.isRequired,
  currentStats: PropTypes.any.isRequired,
  ownedRaid: PropTypes.any.isRequired,
  setActiveRaids: PropTypes.func.isRequired,
  setActiveSearch: PropTypes.func.isRequired,
  setCurrentStats: PropTypes.func.isRequired,
  setInnerAppState: PropTypes.func.isRequired,
  setInnerUser: PropTypes.func.isRequired,
  setOwnedRaid: PropTypes.func.isRequired,
  setRoom: PropTypes.func.isRequired,
  setSocketOrError: PropTypes.func.isRequired,
  socketOrError: PropTypes.object.isRequired,
  user: PropTypes.any.isRequired
}

const styles = {
  // background

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
  app: {
    display: "flex",
    flexDirection: "column",
    height: "100%",
  },
  // component
  backgroundContainer: {
    position: "absolute",
    top: 0,
    bottom: 0,
    left: 0,
    right: 0,
    background: "linear-gradient(230deg, #15234B 0%, #0A1733 100%)",
    zIndex: -200,
  },
  headerContainer: {
  },
  contentContainer: {
    flex: 1,
    justifyContent: "center",
    display: "flex",
  },
  footerContainer: {

    flexBasis: 50,
  },
  appContainer: {
    display: "flex",
    flexDirection: "column",
    alignSelf: "center",
    maxWidth: 920,
    flexGrow: 1,
  },
  footer: {
    display: "flex",
    flexDirection: "column",
    margin: 5,
  },
  link: {
    color: "orange",
  },
  socket: {
    width: 40,
    fill: "white",
    position: "absolute",
    right: 5,
    opacity: 0.2,
    bottom: 0,
  },
  error: {
    backgroundColor: "red",
    opacity: 0.8,
  },
}

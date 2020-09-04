const API_WEBSOCKET = "wss://ws.raid.network/ws"
let global_sockets = {}
let global_intervals = {}

const getSocket = (address) => (messageHandler, initHandler, closeHandler) => {
  if (global_sockets[address]) {
    return global_sockets[address]
  }

  const socket = new WebSocket(`${API_WEBSOCKET}/${address}`, [])

  socket.addEventListener("message", (event) => {
    messageHandler(JSON.parse(event.data.toString()))
  })

  socket.addEventListener(
    "open",
    initHandler || (
      () => (
        1 / 0 // that'll make you pay attention
      )
    ),
  )

  socket.addEventListener(
    "close",
    closeHandler || (
      () => (
        1 / 0 // that'll make you pay attention
      )
    ),
  )

  global_sockets[address] = socket
  global_intervals[address] = setInterval(heartbeat(address), 1000)

  return socket
}

const heartbeat = (address) => () => {
  global_sockets[address].send(JSON.stringify({action: "boop", me: {}, data: {}}))
}

export const addUserToQueue = (socket, bossName, user) => {
  socket.send(
    JSON.stringify({
      action: "join",
      me: user,
      data: {

        queue: bossName,
      },
    },
    ))
}

export const addRaidToQueue = (socket, bossName, location, maxInvites, user) => {
  socket.send(
    JSON.stringify({
      action: "create",
      me: user,
      data: {
        boss_name: bossName,
        location_name: location || "Anonymous",
        max_invites: Number.parseInt(maxInvites, 0) || 5,
      },
    }),
  )

}

export const socketForQueues = getSocket("queues")

export const socketForRoom = (room) => getSocket(`${room}`)

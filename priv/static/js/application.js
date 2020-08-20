let setup = () => {
    class myWebsocketHandler {
      setupSocket() {
        this.socket = new WebSocket("ws://bro:wat@localhost:4000/ws/queues", [], {headers: {"AUTH": "ELLO"}})
  
        this.socket.addEventListener("message", (event) => {
          const pTag = document.createElement("p")
          pTag.innerHTML = event.data.toString()
  
          document.getElementById("main").append(pTag)
        })
  
        this.socket.addEventListener("close", () => {
          this.setupSocket()
        })
      }

      user() {
        return {
          fc: document.getElementById("fc").value,
          name: document.getElementById("name").value,
          level: document.getElementById("level").value,
        }
      }
  
      join(event) {
        event.preventDefault()
          
        this.socket.send(
          JSON.stringify({
            action: "join",
            me: this.user(),
            data: {
                
                queue: "MISSINGNO"
            },
          })
        )
      }

      create(event) {
        event.preventDefault()
          
        this.socket.send(
          JSON.stringify({
            action: "create",
            me: this.user(),
            data: {
                boss_name: "MISSINGNO",
                location_name: "Cinnabar Islande", 
                max_invites: 4
            },
          })
        )
      }
    }
  
    const websocketClass = new myWebsocketHandler()
    websocketClass.setupSocket()
    
    document.getElementById("queue_button")
      .addEventListener("click", (event) => websocketClass.join(event))

      document.getElementById("create_button")
      .addEventListener("click", (event) => websocketClass.create(event))
  }

  document.addEventListener('DOMContentLoaded', (event) => {
    setup()
  })
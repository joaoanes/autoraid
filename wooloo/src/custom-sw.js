self.addEventListener("message", function(event) {
  console.log("Handling message event:", event)
  const { type, responsePort, data } = event

  switch (type) {
    case "notification": handleNotification(responsePort, data)
      break

    default: "hh"
  }

})

const handleNotification = (port, data) => {

}

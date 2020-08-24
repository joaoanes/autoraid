export const setNotification = (message, body, tag, renotify = true) => {
  hasPermission()
    .then(() => navigator.serviceWorker.ready)
    .then(
      (reg) => {
        console.log("Sending notification", message, body)
        reg.showNotification(
          message,
          {
            body: body,
            renotify,
            silent: true,
            requireInteraction: true,
            icon: "/logo192.png",
            badge: "/logo192.png",
            tag: tag || "autoraid-wooloo",
          },
        )
      },
    )
    .catch((e) => console.error(e))
}

export const hasPermission = () => new Promise((res, rej) => {
  Notification.requestPermission((result) => {
    if (result === "granted") {
      return res(true)
    }
    return rej(false)
  })
})

export const setupPWAInstall = (setPrompt) => {
  let deferredPrompt

  window.addEventListener("beforeinstallprompt", (e) => {
    deferredPrompt = e
    setPrompt(deferredPrompt)
  })
}

export const confirmPWAInstall = (prompt, setPrompt) => {
  prompt.prompt()
  prompt.userChoice.then((choiceResult) => {
    if (choiceResult.outcome === "accepted") {
      setPrompt("accepted")
    }
  })
}

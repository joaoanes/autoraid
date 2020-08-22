export const setNotification = (message, body, tag) => (
  hasPermission()
    .then(() => navigator.serviceWorker.ready)
    .then(
      (reg) => reg.showNotification(
        message,
        {
          body: body,
          renotify: true,
          tag: tag || "autoraid-wooloo",
        },
      ),
    )
    .catch((e) => console.error(e))
)

export const hasPermission = () => new Promise((res, rej) => {
  Notification.requestPermission(function(result) {
    if (result === "granted") {
      return res(true)
    }
    return rej(false)
  })
})

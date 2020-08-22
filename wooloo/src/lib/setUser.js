export const getUser = () => {
  const item = window.localStorage.getItem("autoraid-user")
  return item ? JSON.parse(item) : null
}

export const setUser = (user) => {
  window.localStorage.setItem("autoraid-user", JSON.stringify(user))
}

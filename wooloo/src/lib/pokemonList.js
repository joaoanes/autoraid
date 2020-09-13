let listSingleton = null

export const getRaidList = async () => {
  if (listSingleton) return listSingleton

  const res = await fetch("/boss_registry_w.json").then((res) => res.json())

  listSingleton = res

  return res
}

export const getIcon = ({ dex_number, form, tier }) => {
  if (form === "Alola") {
    return `https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${dex_number}-alola.png`
  }

  if (form !== "Alola" && form !== "Normal") {
    return `https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${dex_number}-mega-${form.toLowerCase()}.png`
  }

  if (form !== "Alola" && form === "Normal" && tier === "mega") {
    return `https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${dex_number}-mega.png`
  }


  return `https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${dex_number}.png`
}

import React, { useState, useEffect } from "react"
import { getRaidList } from "../lib/pokemonList"
import PokemonList from "../components/ui/PokemonList"

export const PokemonListLoader = (props) => {


  if (activeRaids) {
    return <PokemonList {...props} pokemonList={activeRaids} />
  }

return (<div>Loading!</div>)
}

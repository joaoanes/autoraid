import React from "react"

import PokemonList from "../components/ui/PokemonList.js"

export default {
  title: "Wooloo/PokemonList",
  component: PokemonList,
}

const Template = (args) => <div style={{ backgroundColor: "black" }}>
  <PokemonList {...args} />
</div>

export const Empty = Template.bind({})
Empty.args = {
  pokemonList: [],
}

export const WithTestData = Template.bind({})
WithTestData.args = {
  pokemonList: null,
}

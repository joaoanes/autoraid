import React from 'react';

import PokemonList from '../components/ui/PokemonList';

export default {
  title: 'Components/PokemonList',
  component: PokemonList,
}

const Template = (args) => <div style={{backgroundColor: "red"}}><PokemonList {...args} /></div>

const dummyValues = {
  pokemonList: {
    "1": [
      {
        "dex_number": 501,
        "name": "Oshawott",
        "form": "Normal",
        "tier": 1,
        "possible_shiny": false,
        "boss_name": "Oshawott"
      },
    ],
    "2": [
      {
        "dex_number": 1,
        "name": "Bulbasaur",
        "form": "Normal",
        "tier": 1,
        "possible_shiny": false,
        "boss_name": "Bulbasaur"
      },
    ]
  }
}

export const Nothing = Template.bind({});
Nothing.args = {
  ...dummyValues,
};

export const Selected = Template.bind({});
Selected.args = {
  ...dummyValues,
  selected:{boss_name: "Oshawott"},
};

import React from 'react';

import Matchmaking from '../components/Matchmaking';

export default {
  title: 'Components/Matchmaking',
  component: Matchmaking,
  argTypes: {
    stop: {action: "stopped!"},
  }
}

const Template = (args) => <div style={{backgroundColor: 'red'}}><Matchmaking {...args} /></div>

const testPokemon = {
  "dex_number": 501,
  "name": "Oshawott",
  "form": "Normal",
  "tier": 1,
  "possible_shiny": false,
  "boss_name": "Oshawott"
}

export const WithSearch = Template.bind({});
WithSearch.args = {
  activeSearch: testPokemon
};

export const WithSearchAndStats = Template.bind({});
WithSearchAndStats.args = {
  activeSearch: testPokemon,
  currentStats: {[testPokemon.boss_name]: {queued: 0, rooms: "F"}}
}

export const WithRaid = Template.bind({});
WithRaid.args = {
  ownedRaid: testPokemon
};

export const WithRaidAndStats = Template.bind({});
WithRaidAndStats.args = {
  ownedRaid: testPokemon,
  currentStats: {[testPokemon.boss_name]: {queued: 0, rooms: "F"}}
};

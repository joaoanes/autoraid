import React from 'react';

import { Autoraid, stateMapping } from '../../src/containers/Autoraid';

export default {
  title: 'Wooloo/App',
  component: Autoraid,
  argTypes: {
    user: {},
    appState: {
      control: {
        type: 'inline-radio',
        options: Object.keys(stateMapping),
      },
    },
    setNotification: {action: "notification!"},
    setOwnedRaid: {action: "notification!"},
    setActiveSearch: {action: "notification!"},
    setRoom: {action: "notification!"},
    setInnerAppState: {action: "appstate"}
    }
};

const Template = (args) => <Autoraid {...args} />;

const testPokemon = {
  "dex_number": 501,
  "name": "Oshawott",
  "form": "Normal",
  "tier": 1,
  "possible_shiny": false,
  "boss_name": "Oshawott"
}

const dummyValues = {
  setActiveSearch: () => (null),
  setOwnedRaid: () => (null),
  setCurrentStats: () => (null),
  setRoom: () => (null),
  setActiveRaids: () => (null),
  setInnerUser: () => (null),
  setSocketOrError: () => (null),
  activeRaids: {
    "1": [
      testPokemon,
    ]
  },
  
  user: {name: "hello!"}
}

export const LoggedOut = Template.bind({});
LoggedOut.args = {
  ...dummyValues,
  appState: "init",
  user: null
};

export const LoggedIn = Template.bind({});
LoggedIn.args = {
  ...dummyValues,
  appState: "home",
};

export const WithReadySocket = Template.bind({});
WithReadySocket.args = {
  ...dummyValues,
  appState: "home",
  socketOrError: {socket: true, error: null, ready: true},
};

export const WithFailingSocket = Template.bind({});
WithFailingSocket.args = {
  ...dummyValues,
  appState: "home",
  socketOrError: {socket: true, error: true, ready: false},
};

export const WithConnectingSocket = Template.bind({});
WithConnectingSocket.args = {
  ...dummyValues,
  appState: "home",
  socketOrError: {socket: true, error: null, ready: false},
};

export const MatchmakingRaid = Template.bind({});
MatchmakingRaid.args = {
  ...dummyValues,
  appState: "matchmaking",
  ownedRaid: testPokemon,
};

export const MatchmakingSearch = Template.bind({});
MatchmakingSearch.args = {
  ...dummyValues,
  appState: "matchmaking",
  activeSearch: testPokemon,
};

export const Freestyle = Template.bind({});
Freestyle.args = {
  ...dummyValues,
  appState: "home",
  ownedRaid: testPokemon,
  activeSearch: testPokemon,
};
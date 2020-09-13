import React from 'react';

import { Login } from '../components/Login';

export default {
  title: 'Components/Login',
  component: Login,
  argTypes: {
    user: {},
    setUser: {action: "set user"},
    setName: {action: "name"},
    setLevel: {action: "level"},
    setAppState:{action: "app state change!"}
  }
}

const Template = (args) => <div style={{backgroundColor: 'red'}}><Login {...args} /></div>

const dummyValues = {
  setUser: () => null,
  activeRaids: {
    "1": [
      {
        "dex_number": 501,
        "name": "Oshawott",
        "form": "Normal",
        "tier": 1,
        "possible_shiny": false,
        "boss_name": "Oshawott"
      },
    ]
  }
}

export const Unfilled = Template.bind({});
Unfilled.args = {
  ...dummyValues,

};

export const MidFilled = Template.bind({});
MidFilled.args = {
  ...dummyValues,
  name: "hello!",
  level: 40,
};

export const Filled = Template.bind({});
Filled.args = {
  ...dummyValues,
  name: "hello!",
  fc: "111111111111",
  level: 40,
};

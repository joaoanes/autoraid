import React from 'react';

import Home from '../components/Home';

export default {
  title: 'Components/Home',
  component: Home,
  argTypes: {
    user: {},
    onInstall: {action: "want install!"},
    setAppState:{action: "app state change!"}
  }
}

const Template = (args) => <div style={{backgroundColor: 'red'}}><Home {...args} /></div>

const dummyValues = {
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

export const LoggedOut = Template.bind({});
LoggedOut.args = {
  ...dummyValues,

};

export const LoggedIn = Template.bind({});
LoggedIn.args = {
  ...dummyValues,
  user: {name: "hello!"}
};


export const Prompted = Template.bind({});
Prompted.args = {
  ...dummyValues,
  prompt: true,
  acceptedInstall: false,
  user: {name: "hello!"}
};

export const PromptedAndAccepted = Template.bind({});
PromptedAndAccepted.args = {
  ...dummyValues,
  prompt: true,
  acceptedInstall: true,
};


export const PromptedWithoutUser = Template.bind({});
PromptedWithoutUser.args = {
  ...dummyValues,
  prompt: true,
  acceptedInstall: false,
};


import React from 'react';

import RaidPicker from '../components/RaidPicker';

export default {
  title: 'Components/Raidpicker',
  component: RaidPicker,
  argTypes: { 
    addToQueue: { action: 'add to queue' } 
  },
};

const Template = (args) => <div style={{backgroundColor: 'red'}}><RaidPicker {...args} /></div>

const dummyValues = {
  user: {name: "Test"},
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

export const Unselected = Template.bind({});
Unselected.args = {
  ...dummyValues,
};


export const Selected = Template.bind({});
Selected.args = {
  ...dummyValues,
  initialSelection: {boss_name: "Oshawott"}
};
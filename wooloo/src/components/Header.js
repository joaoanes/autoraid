import React, { useState, useEffect } from "react"

const getGreeting = () => {
  const greetings = [
    "Very glad to see you back!",
    "Is that a raid over there?",
    "Shiny deino when",
    "Now without Pokemon Home integration!",
    "As seen on TV!",
    "Here's hoping it's a shiny this time!",
    "A max revive for your raiding experience!",
    "Imagine raid passes hitting for 25% damage",
    "Have you met our lord Helix?",
    "My uncle's uncle works at nintendo",
    "Are the niantic servers on fire again?",
    "Game Freekin'",
    "Ditto community day when",
    "When will Gible return to rotation",
    "Thank you for using me <3",
    "You just earned your daily login bonus! jk",
    "Locally sourced, farm-to-table",
    "Jessie still looks weird in-game",
    "Always frontload your shinies.",
    "Boy, how many are of these?",
    "Pokemon candies are Soylent Green",
    "Now with maxed out effort values!",
    "15/15/15! 15/15/15! 15/15/15!",
    "Wooloo is the website's codename",
    "Cyndaquil is the server's codename",
    "Made entirely with love",
    "Best of luck!",
  ]

  return greetings[Math.trunc(Math.random() * greetings.length)]
}

const Header = ({ user }) => {
  const [greeting, setGreeting] = useState("Hello!")
  useEffect(() => setGreeting(getGreeting()), [])
  return (
    <header style={styles.header}>
      <img style={styles.logoName} src="/logoname.svg" />
      <span style={styles.tagline}>{user ? greeting : "One-click raids for Pokemon Go!"}</span>
    </header>
  )
}

export default Header

const styles = {
  header: {
    margin: 20,
    borderBottom: "2px solid white",
    display: "flex",
    flexDirection: "column",
  },
  logoName: {
    maxWidth: "80%",
  },
  tagline: {
    marginTop: 5,
    marginBottom: 15,
    fontSize: 20,
  },
}

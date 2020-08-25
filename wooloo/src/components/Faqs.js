import React, { useState } from "react"

const Faqs = ({ }) => (
  <div style={styles.container}>
    <div style={styles.qna}>

      <div style={styles.q}>What is this?</div>
      <div style={styles.a}>Welcome to the raid network! A raid matchmaker designed to be fast, one-click and very notification-heavy (I don't know about you, but my pokemon go restarts if I switch apps too much).</div>

      <div style={styles.q}>How does it work?</div>
      <div style={styles.a}>Dead simple. Select if you want to join or create raid, pick the pokemon you want, and open pokemon go. An Android or iOS notification will keep you informed, and as soon as you're matched, the notification displays the friend code of your host.</div>

      <div style={styles.q}>Why build this? Aren't there other apps?</div>
      <div style={styles.a}>The other apps either require a lot of switching between the game and the app, or require you to constantly swipe to refresh raid lists. Or ads. The Pokemon Go community deserves better.</div>

      <div style={styles.q}>Do you save my data?</div>
      <div style={styles.a}>No data is ever stored besides the absolute minimum. I can't afford to store user data, databases are expensive :P</div>

      <div style={styles.q}>Who runs this?</div>
      <div style={styles.a}>An asshole with too much free time in Portugal. Level 39 (since 2016!), <span style={styles.instinct}>Team Instinct</span>. Check my github profile at the footer.</div>

      <div style={styles.q}>Wow can I donate?</div>
      <div style={styles.a}>Yeah. Here's <a href="https://help.unicef.org/donate-unicef">UNICEF</a>. Here's <a href="https://supporters.eff.org/donate">the EFF</a>. Here's <a href={"https://donate.doctorswithoutborders.org/"}>Doctors Without Borders</a>. I'm well enough - just spread the word about this site.</div>

      <div style={styles.q}>Something is broken!</div>
      <div style={styles.a}>Please let me know ASAP - <a href={"mailto://broken@raid.network"}>click here to send me an email.</a></div>

      <div style={styles.q}>I have suggestions!</div>
      <div style={styles.a}>Please let me know "ASAP" - <a href={"mailto://broken@raid.network"}>click here to send me an email.</a></div>

      <div style={styles.q}>What did you use to build this?</div>
      <div style={styles.a}>Elixir for the server backend, React for what you're looking at right now. The code should be open sourced soon.</div>

      <div style={styles.q}>What are you working on next?</div>
      <div style={styles.a}>Raid chats. Shouldn't be too hard</div>
    </div>

  </div>
)

const styles = {
  qna: {
    height: "80vh",
    width: "80%",
    overflow: "scroll",
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    textAlign: "center",
  },
  q: {
    fontSize: 20,
    fontWeight: 700,
    marginBottom: 20,
  },
  a: {
    fontSize: 14,
    marginBottom: 50,
  },
  buttonContainer: {
    display: "flex",
    marginTop: "auto",
    marginBottom: "auto",
    width: "100%",
    justifyContent: "center",
  },
  inputContainer: {
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    textAlign: "center",
  },
  container: {
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    marginLeft: "auto",
    marginRight: "auto",
    overflowY: "scroll",
  },
  tauros: {
    minHeight: 96,
  },
  input: {
    border: "unset",
    backgroundColor: "unset",
    color: "white",
    borderBottom: "1px solid white",
    margin: 20,
    width: "100%",
    fontSize: 16,
  },
}

export default Faqs

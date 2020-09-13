import React, { useState, useEffect } from "react"
import IconButton from "./ui/IconButton"
import Button from "./ui/Button"

const routeToNextState = (setAppState, user) => (desired_state) => user ? setAppState(desired_state) : (desired_state === "faq" ? setAppState("faq") : setAppState("login"))

const Home = ({ setAppState, user, prompt, acceptedInstall, onInstall }) => {
  const router = routeToNextState(setAppState, user)

  return (
    <div style={styles.homeContainer}>
      <div style={styles.greeting}>
        {user ? `Hello ${user.name}!` : "Welcome to the raid network!"}
      </div>
      {
        user && (
          <div style={styles.logout} onClick={() => router("login")}>(Not you? Click here to log out)</div>
        )
      }
      <div style={styles.cta}>
        {"What do you want to do?"}
      </div>

      <div style={styles.buttons}>
        <IconButton superStyles={{ width: 130, height: 160 }} icon="/pass.png" onClick={() => router("raidPicker")}>I want to join a raid!</IconButton>
        <IconButton superStyles={{ width: 130, height: 160 }} icon="/raid.png" onClick={() => router("raidCreator")}>I want trainers to join my raid!</IconButton>
      </div>

      {user && <div style={styles.activity}>(Less than 100 users on queue)</div>}

      {!user && <div style={styles.faq}>
        <Button onClick={() => router("faq")} selected={true} superStyles={{ border: "unset" }}>What is this? (FAQ)</Button>
      </div>}
      <div style={styles.prompt}>
        {prompt && user && !acceptedInstall && <Button selected={true} onClick={onInstall}>
          <div>
            <div>Install to applications</div>
            <small style={{ fontWeight: 500 }}>(optional, but encouraged)</small>
          </div>
        </Button>}
        {prompt && acceptedInstall && <div>{"Thank you! <3"}</div>}
      </div>
    </div >
  )
}

const styles = {
  activity: {
    marginTop: 20,
    marginBottom: "auto",
  },
  faq: {
    marginBottom: 100,
  },
  logout: {
    fontSize: 14,
    fontStyle: "italic",
    pointer: "cursor",
  },
  buttons: {
    display: "flex",
    justifyContent: "space-around",
    marginTop: 40,
  },
  cta: {
    marginTop: 20,
    fontSize: 30,
  },
  homeContainer: {
    alignItems: "center",
    display: "flex",
    flexDirection: "column",
  },
  prompt: {
    display: "flex",
    flexDirection: "column",
    width: "100%",
  },
  greeting: {
    marginTop: 20,
    fontSize: 25,
    textAlign: "center",
  },
}

export default Home

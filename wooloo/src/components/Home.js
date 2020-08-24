import React from "react"
import IconButton from "./ui/IconButton"
import Button from "./ui/Button"

const routeToNextState = (setAppState, user) => (desired_state) => user ? setAppState(desired_state) : setAppState("login")

const Home = ({ setAppState, user }) => {
  const router = routeToNextState(setAppState, user)
  return (
    <div style={styles.homeContainer}>
      <div>
        {user ? `Hello ${user.name}!` : "Using it is easy! Click one of the two buttons below:"}
      </div>

      {
        user && (
          <Button selected={true} onClick={() => router("login")}>Not you? Logout</Button>

        )
      }

      <br></br>

      <div style={styles.buttons}>

        <IconButton onClick={() => router("raidPicker")}>I want to join a raid!</IconButton>
        <IconButton onClick={() => router("raidCreator")}>I want trainers to join my raid!</IconButton>
      </div>
    </div >
  )
}

const styles = {
  buttons: {
    display: "flex",
    width: 400,
    justifyContent: "space-around",
    marginTop: 130,
  },
  homeContainer: {
    alignItems: "center",
    justifyContent: "center",
    display: "flex",
    flexDirection: "column",
  },
}

export default Home

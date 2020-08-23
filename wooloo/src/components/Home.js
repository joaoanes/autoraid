import React from "react"

const routeToNextState = (setAppState, user) => (desired_state) => user ? setAppState(desired_state) : setAppState("login")

const Home = ({ setAppState, user }) => {
  const router = routeToNextState(setAppState, user)
  return (
    <div>
      <div>
        {user ? `Hello ${user.name}!` : "Using it is easy!"}
      </div>

      {
        user && (
          <div>
            <button onClick={() => router("login")}>Logout</button>
          </div>
        )
      }

      <br></br>

      <div>

        <button onClick={() => router("raidPicker")}>I want to raid!</button>
        <button onClick={() => router("raidCreator")}>I want to create a raid!</button>
      </div>
    </div>
  )
}

export default Home

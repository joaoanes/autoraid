import React from "react"
import Button from "./ui/Button"

const Matchmaking = ({ _stats, _started_at, activeSearch, ownedRaid, currentStats, stop }) => {
  const { bossName, dexEntry } = activeSearch ? activeSearch : ownedRaid
  const stats = (currentStats || { [bossName]: { queued: "??", rooms: "??" } })[bossName]

  return (
    <div style={styles.container}>
      <div style={styles.tagLine}>We're finding you some trainers!</div>
      <div style={styles.header}>
        <span>{(`Finding ${ownedRaid ? "users" : "raids"} for ${bossName}`)}</span>
        <img style={styles.bossImg} src={`https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${dexEntry}.png`} />
      </div>

      <div style={styles.stats}>
        <div style={styles.statsHeader}>Queue status</div>
        <div style={styles.statsContent}>
          <div style={styles.statsContentHeader}>
            <div style={styles.statsNumber}>{stats.queued}</div>
            <div style={styles.statsTagline}>{"Trainers looking for raids"}</div>
          </div>
          <div style={styles.statsContentHeader}>
            <div style={styles.statsNumber}>{stats.rooms}</div>
            <div style={styles.statsTagline}>{"Raids looking for trainers"}</div>
          </div>
        </div>
      </div>

      <div style={styles.instructionsHeader}>You can open the game now!</div>
      <div style={styles.instructions}>{
        ownedRaid ? "You will be matched into a room and people will add you. Accept and invite them."
          : "A notification will tell you when the raid is ready, and will show the FC you need to add to your friends list. They will invite you in."
      }</div>
      <Button selected={true} onClick={() => stop()}>Stop matchmaking</Button>
    </div>
  )
}

const styles = {
  stats: {
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    width: 300,
  },
  statsNumber: {
    fontSize: 40,
    margin: 20,
  },
  statsContentHeader: {
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    textAlign: "center",
  },
  statsHeader: {
    width: "100%",
    paddingBottom: 20,
    borderBottom: "1px solid white",
    textAlign: "center",
  },
  statsContent: {
    display: "flex",
  },
  instructionsHeader: {
    marginTop: 20,
    fontSize: 20,
  },
  header: {
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
  },
  bossImg: {
    width: 96,
    height: 96,
  },
  tagLine: {
    fontSize: 20,
    fontWeight: 700,
  },
  instructions: {
    marginTop: 5,
    fontSize: 13,
    textAlign: "center",
    width: "60%",
    fontWeight: 400,
  },

  container: {
    alignItems: "center",
    justifyContent: "space-around",
    display: "flex",
    flexDirection: "column",
  },
}

export default Matchmaking

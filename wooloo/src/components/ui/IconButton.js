import React from "react"
import { merge } from "lodash"

const IconButton = ({ icon, children, onClick, selected }) => {
  const steel = { ...styles.buttonContainer, ...(selected ? styles._selected : {}) }

  console.log(children, steel)
  return (
    <button className="toggleable" style={steel} onClick={onClick ? onClick : () => null}>
      {icon ? <img src={icon} style={styles.icon}></img> : null}
      <div style={styles.bodyContainer}>{children}</div>
    </button>
  )
}

const styles = {
  buttonContainer: {
    width: 100,
    height: 120,
    border: "1px solid white",
    borderRadius: 10,
    cursor: "pointer",
    backgroundColor: "unset",
    color: "white",
    display: "flex",
    flexDirection: "column",
    alignItems: "center",
    fontFamily: "Lato",
  },
  icon: {
    width: 80,
    height: 80,
    left: "auto",
    right: "auto",
    position: "relative",
  },

  bodyContainer: {
    fontSize: 13,
    padding: 10,
    textAlign: "center",
  },
  _selected: { // selected as key makes things go haywire
    backgroundColor: "rgba(255, 255, 255, 0.2)",
  },
}

export default IconButton

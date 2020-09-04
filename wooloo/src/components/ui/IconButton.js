import React from "react"
import { merge } from "lodash"

const IconButton = ({ icon, children, onClick, selected, superStyles }) => {
  const steel = { ...styles.buttonContainer, ...(selected ? styles._selected : {}), ...(superStyles) }

  return (
    <button className="toggleable" style={steel} onClick={onClick ? onClick : () => null}>
      {icon ? <img src={icon} style={styles.icon}></img> : null}
      {
        children && <div style={styles.bodyHolder}>
          <div style={styles.bodyContainer}>{children}</div>
        </div>
      }
    </button>
  )
}

const styles = {
  bodyHolder: {
    position: "absolute",
    bottom: 0,
    height: 45,
    backgroundColor: "rgba(0,0,0,0.4)",
    width: "100%",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    fontWeight: 700,
  },
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
    justifyContent: "space-around",
    overflow: "hidden",
    position: "relative",
  },
  icon: {
    maxWidth: "120%",
    left: "auto",
    right: "auto",
    top: -20,
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

import React from "react"

const Button = ({ selected, children, onClick, superStyles }) =>

  <button style={{ ...styles.selectButton, ...(selected ? {} : styles.buttonUnavailable), ...(superStyles) }}
    onClick={() => onClick ? onClick() : () => (null)}
  >
    {children}
  </button >

const styles = {
  selectButton: {
    backgroundColor: "unset",
    padding: 20,
    fontSize: 18,
    fontWeight: 700,

    border: "2px solid white",
    borderRadius: 20,
    color: "white",
  },
  buttonUnavailable: {
    border: "2px solid grey",
    color: "grey",
  },
}

export default Button

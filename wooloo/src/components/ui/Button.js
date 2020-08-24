import React from "react"

const Button = ({ selected, children, onClick }) =>

  <button style={{ ...styles.selectButton, ...(selected ? {} : styles.buttonUnavailable) }}
    onClick={() => onClick ? onClick() : () => (null)}
  >
    {children}
  </button >

const styles = {
  selectButton: {
    backgroundColor: "unset",
    padding: 20,
    marginTop: 20,
    fontSize: 18,
    fontWeight: 700,
    width: "80%",
    border: "1px solid white",
    borderRadius: 20,
    color: "white",
  },
  buttonUnavailable: {
    border: "1px solid grey",
    color: "grey",
  },
}

export default Button

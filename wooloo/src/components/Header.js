import React from "react"

const Header = ({ user }) => (
  <header style={styles.header}>
    <img style={styles.logoName} src="/logoname.svg" />
    <span style={styles.tagline}>One-click raids for Pokemon Go!</span>
  </header>
)

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

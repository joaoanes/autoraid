import React from "react"
import PokemonList from "./PokemonList"
import Button from "./Button"

export const PokemonPicker = ({ select, pokemonList, buttonText, selected, setSelected }) => (<>
  <div style={styles.list}>
    <PokemonList pokemonList={pokemonList} selected={selected} setSelected={setSelected} />
  </div>

  <div style={styles.separator} />
  <div style={styles.buttonContainer}>
    <Button selected={selected !== null} onClick={() => select(selected)} >
      {buttonText}
    </Button>
  </div>

</>
)

export default PokemonPicker

const styles = {
  buttonContainer: {
    marginTop: "auto",
    marginBotton: "auto",
    flex: 1,
    display: "flex",
    width: "100%",
    justifyContent: "center",
    alignItems: "center",
  },
  list: {
    height: "55vh",
    overflowY: "scroll",
    overflowX: "hidden",
  },
  separator: {
    border: "1px solid white",
    width: "100%",
  },
}

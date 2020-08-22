export const getValueFromEvent = (setter) => (event) => { event.preventDefault(); return setter(event.target.value) }

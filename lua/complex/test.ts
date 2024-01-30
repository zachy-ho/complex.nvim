function fn() {
  let foo = 0
  let bar = 0
  // if (true || false && true && false && true && false) {}
  // if (true && false || true || false || true || false) {}
  // if (true || true && true && false || true || false) {}
  if (true || !!foo && !(bar || (undefined && 2)) || null) {}
  true && !false
  const huh = true && 1
}

const arrowFn = () => {
  try {

  } catch (e) {
    try {

    } catch (e) {}
  } finally {}
}

const someVar = {
  1: 2
}

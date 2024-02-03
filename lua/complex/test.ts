function fn() {
}

const arrowFn = () => {
  if (true || false && true) { // +
    if (true) {}
  }
  const hmm = true && fn() || fn()
}

const someVar = {
  1: 2
}

function fn() {
}

const arrowFn = () => {
  let animal: 'dog' | 'cat'
  switch (animal) {
    case 'dog':
      true && (function() {})() || false
      while (true) {}
      const foo = ''
      break;
    case 'cat':
      const bar = ''
      break;
    default:
      const baz = ''
      break;
  }
}

const someVar = {
  1: 2
}

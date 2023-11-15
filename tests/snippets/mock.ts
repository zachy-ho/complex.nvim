function fn1() {
  console.log('fn1');
}

function fn2() {
  function innerFn() {
    console.log('innerFn');
  }
}

const arrowFn = () => {
  console.log('arrowFn');
};

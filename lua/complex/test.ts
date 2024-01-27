function fn() {
  console.log("fn");
  if (true) {
    console.log()
    if (false) {
    }
  } else if (true) {
    if (true) {}
    else if (true) {
      if (true) {}
    }
    else {}
  } else {
    if (true) {  }
    else if(true) {
      if (true) {}
    }
    else {}
  }
}

const arrowFn = () => {
  console.log("arrow fn");
  for (let i = 0; i < 2; i++) {

  }

  while (false) {
  }

  let v = 3;
  do {
    console.log('in a do while')
    continue;
    break;
  }
  while (v > 0) 
}

const someVar = {
  1: 2
}

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
  try {

  } catch (e) {
    try {

    } catch (e) {}
  } finally {}
}

const someVar = {
  1: 2
}

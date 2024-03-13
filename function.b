func add(int a, int b) {
  return a + b;
}

func mult(int a, int b) {
  return a * b;
}

func main() {
  int a;
  int b;
  int c;
  int d;

  a := 100;
  b := 50;

  c := add(a,b);

  write(c);

  int e;

  e := a + b;

  d := mult(c, e);
  write(d);
}
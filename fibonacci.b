func fibonacci(int k) {

  if (k <=  1) {
    return 1;
  }

  return fibonacci(k-1) + fibonacci(k-2);

}

func main() {
  int n;

  int fib_n;
  read(n);
  fib_n := fibonacci(n);
  write(fib_n);

}
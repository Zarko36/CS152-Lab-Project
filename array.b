func main() {
  int a[20];
  int b;
  int c;

  b := 3;
  c := 5;
  a[0] := b + c;
  write(a[0]);


  a[1] := 100;
  write(a[1]);

  a[2] := 200;
  write(a[2]);

  int d;

  d := a[1] + c;



  a[3] := a[0] * d;

  write(a[3]);

}
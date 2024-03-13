func main() {
   int n;
   int array[1000];
   int i;
   int j;
   int x;
   int sqrt_n;

   read(n);
   x := n;

   while(x>n/x) {
      x := (x+n/2)/2;
   }

   sqrt_n := x;

   i := 2;

   while(i<=sqrt_n) {
      if (a[i] == 0) {
         j := i + 1;
         while(j <= n) {
            a[j] := 1;
            j := j+1;
         }

      }
      i := i + 1;
   }

   i := 2;

   while(i<=n) {
      if (a[i] == 0) {
         write(i);
      }

      i := i + 1;
   }
}
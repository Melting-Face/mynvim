#include <stdio.h>

int main(void) {
  int x = 1;
  int y = x + 1; /* BREAK */
  printf("%d\n", y);
  return 0;
}

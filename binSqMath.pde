static float quadRoot (int input) {
  if(input > 0) return pow(input, .25f);
  return 0;
}

static int getBestFit (int input) {
  return ceil(quadRoot(input));
}
    
static int getNumCells (int input) {
  return (int) pow(4, input);
}
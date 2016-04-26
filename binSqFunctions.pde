Map<Cell, List<Dot>> getDotsInBins (List<Dot> inDots, Grid inGrid) {
  // Reset Bins
  boolean[] binned = new boolean[inDots.size()];
  // Output
  Map<Cell, List<Dot>> output = new HashMap<Cell, List<Dot>>();
  // Count Dots in Bin
  for (Cell c : this.bins.getCells()) {
    List<Dot> dotsInBin = new ArrayList<Dot>();
    for (int i = 0; i < inDots.size (); i++) {
      if (!binned[i]) {
        Dot d = inDots.get(i);
        if (c.contains(d)) {
          dotsInBin.add(d);
          binned[i] = true;
        }
      }
    }
    output.put(c, dotsInBin);
  }
  return output;
}
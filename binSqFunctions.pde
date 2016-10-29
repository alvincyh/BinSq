Map<Cell,Grid> getNestedBins (Grid inGrid) {
  // Output
  Map<Cell,Grid> output = new LinkedHashMap<Cell,Grid>();
  // Create a grid of (nested) bins within each bin
  for(Cell c : inGrid.getCells()){
    int bestFit = getBestFit(c.count);
    int nRecur  = c.level + bestFit;
    if(nRecur > uniPartitionLimit){
      bestFit = uniPartitionLimit - c.level;
      nRecur  = c.level + bestFit;
    }
    int nCells  = getNumCells(bestFit);
    int nIndex  = nCells * c.id;
    Grid temp = Uniform.partition(gridDim, gridDim, gridDim, gridDim, nRecur);
    List<Cell> subset = new ArrayList<Cell>();
    for (int i = nIndex; i < (nIndex + nCells); i++) {
      Cell nc = temp.getCells().get(i);
      subset.add(nc);
    }
    output.put(c, new Grid(c.x, c.y, c.width, c.height, subset));
  }
  return output;
}


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


Map<Cell,Map<Cell,List<Integer>>> getDotsInNestedBins (Map<Cell,Grid> inGrids, Map<Cell,List<Dot>> inDots) {
  // Output
  Map<Cell,Map<Cell,List<Integer>>> output = new HashMap();

  for(Cell c : inGrids.keySet()){
    List<Cell> nestedbinsInBin = (ArrayList) inGrids.get(c).getCells();
    List<Dot> dotsInBin = (ArrayList) inDots.get(c);
    // Distance matrix
    float[] distMat = new float[nestedbinsInBin.size()];
    for (Dot dot : dotsInBin) {
      // Get distance to nested bins
      for (int m=0; m<distMat.length; m++) distMat[m] = 9999;
      for (int m=0; m<nestedbinsInBin.size(); m++) {
        Cell nestedBin = (Cell) nestedbinsInBin.get(m);
        distMat[m] = new PVector(nestedBin.x, nestedBin.y).dist(dot);
      }
      // Select nearest nested bin
      if (min(distMat) == 9999) break;
      int index = arrayMinIndex(distMat);
      Cell nestedBin = (Cell) nestedbinsInBin.get(index);
      // Add dot value to nested bin
      if (output.containsKey(c)) {
        Map<Cell,List<Integer>> valueSets = (HashMap) output.get(c);
        if(valueSets.containsKey(nestedBin)){
          List<Integer> valueSet = (ArrayList) valueSets.get(nestedBin);
          valueSet.add(dot.v);
        } else {
          List<Integer> valueSet = new ArrayList();
          valueSet.add(dot.v);
          valueSets.put(nestedBin, valueSet);
        }
      } else {
        Map<Cell,List<Integer>> valueSets = new HashMap();
        List<Integer> valueSet = new ArrayList();
        valueSet.add(dot.v);
        valueSets.put(nestedBin, valueSet);
        output.put(c, valueSets);
      }
    }
  }
  return output;
}


Map<Cell,Map<Integer,Integer>> getVisibleHistogram (Map<Cell,Map<Cell,List<Integer>>> inDots) {
  // Output
  Map<Cell,Map<Integer,Integer>> output = new HashMap();

  for(Cell bin : inDots.keySet()){
    Map<Integer,Integer> visible_histogram = new HashMap();
    for(Cell nestedbin : inDots.get(bin).keySet()){
      List<Integer> values_in_nestedbin = inDots.get(bin).get(nestedbin);
      // Add visible dot value to visible histogram
      int visible_value = (Integer) values_in_nestedbin.get(values_in_nestedbin.size() - 1);
      if(visible_histogram.containsKey(visible_value)){
        int frequency = (Integer) visible_histogram.get(visible_value);
        visible_histogram.put(visible_value, frequency + 1);
      } else {
        visible_histogram.put(visible_value, 1);
      }
    }
    output.put(bin, visible_histogram);
  }
  return output;
}


Map<Cell,Map<Integer,Integer>> getActualHistogram (Map<Cell,Map<Cell,List<Integer>>> inDots) {
  // Output
  Map<Cell,Map<Integer,Integer>> output = new HashMap();

  for(Cell bin : inDots.keySet()){
    Map<Integer,Integer> actual_histogram  = new HashMap();
    for(Cell nestedbin : inDots.get(bin).keySet()){
      List<Integer> values_in_nestedbin = inDots.get(bin).get(nestedbin);
      // Add all dot values to actual histogram
      for(Integer value : values_in_nestedbin){
        if(actual_histogram.containsKey(value)){
          int frequency = (Integer) actual_histogram.get(value);
          actual_histogram.put(value, frequency + 1);
        } else {
          actual_histogram.put(value, 1);
        }
      }
    }
    output.put(bin, actual_histogram);
  }
  return output;
}
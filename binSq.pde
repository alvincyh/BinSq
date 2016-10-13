import java.util.*;


// gridded map
int dotSz   = 2;
int maxDots = 20;
int gridDim = 256;
int varPartitionLimit = 4;
int uniPartitionLimit = 7;
Grid bins;
Map<Cell,Grid> nestedbins;

// dots
List<Dot> dots;

// histograms
Map<Cell,Map<Cell,List<Integer>>> values;
Map<Cell,Map<Integer,Integer>> visible;
Map<Cell,Map<Integer,Integer>> actual;
Map<Cell,Integer> equalize;

// track events
boolean isEqualise = true;
boolean isGrid	   = false;
boolean isGeo	   = false;


void settings() {
    size(512,512);
    pixelDensity(displayDensity());
}

void setup(){

    rectMode(CENTER);
    noFill();
    noLoop();

    // load dots
    Table loadDots = loadTable(sketchPath("data/hasselt.csv"), "header");
    loadDots.sort("colour");

    // parse dots
    dots = new ArrayList();
    for (TableRow row : loadDots.rows()) {
      float x = row.getFloat("x");
      float y = row.getFloat("y");
      int col = row.getInt("colour");
      dots.add(new Dot(x, y, col));
    }

	// initalise histograms
	values   = new HashMap(); // Dot values in each nested bin
	visible  = new HashMap(); // Visible histogram of each bin
	actual   = new HashMap(); // Actual histogram of each bin
	equalize = new HashMap(); // Final product	

	// create a variable grid  
	// with QuadTree paritioning
	bins = QuadTree.partition(
		new ArrayList<PVector>(dots),
	    new PVector(gridDim, gridDim), 
	    gridDim, gridDim, varPartitionLimit, maxDots
	);
	println("1. Variable grid created.");

	// create a uniform grid  
	// by paritioning evenly
	nestedbins = new LinkedHashMap<Cell,Grid>();
	for(Cell c : bins.getCells()){
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
		nestedbins.put(c, new Grid(c.x, c.y, c.width, c.height, subset));
	}
	println("2. Uniform grid created.");

	// bin dots to variable grid
	Map<Cell,List<Dot>> dotsInBins = getDotsInBins(dots, bins);
	println("3. Bin to variable grid ok.");

	// bin dots to uniform grid (nested binning)
	for(Cell c : nestedbins.keySet()){
		List<Cell> nestedbinsInBin = (ArrayList) nestedbins.get(c).getCells();
		List<Dot> dotsInBin = (ArrayList) dotsInBins.get(c);
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
			if (this.values.containsKey(c)) {
				Map<Cell,List<Integer>> valueSets = (HashMap) this.values.get(c);
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
				this.values.put(c, valueSets);
			}
		}
	}
	println("4. Bin to uniform grid ok.");

	// compute relative histograms
	for(Cell bin : values.keySet()){
		Map<Integer,Integer> visible_histogram = new HashMap();
		Map<Integer,Integer> actual_histogram  = new HashMap();
		for(Cell nestedbin : values.get(bin).keySet()){
			List<Integer> values_in_nestedbin = values.get(bin).get(nestedbin);
			// Add visible dot value to visible histogram
			int visible_value = (Integer) values_in_nestedbin.get(values_in_nestedbin.size() - 1);
			if(visible_histogram.containsKey(visible_value)){
				int frequency = (Integer) visible_histogram.get(visible_value);
				visible_histogram.put(visible_value, frequency + 1);
			} else {
				visible_histogram.put(visible_value, 1);
			}
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
		visible.put(bin, visible_histogram);
		actual.put(bin, actual_histogram);
	}
	println("5. Compute relative histogram ok.");



  // Histogram equalization
  for (Cell bin : values.keySet()) {

    Grid nestedbins_in_bin                  = (Grid) nestedbins.get(bin);
    Map<Cell, List<Integer>> values_in_bin  = (HashMap) values.get(bin);
    Map<Integer, Integer> act_histogram     = (HashMap) actual.get(bin);
    Map<Integer, Integer> rel_histogram     = new HashMap();

    int limit      = values_in_bin.size();         // visible dots
    int toPlot     = getSum(act_histogram);        // total dots
    int plotSz     = nestedbins_in_bin.getSize();  // number nested bins
    float scaleBy  = 1.0;

      // 1a. There are more dots than avaliable
      //     nested bins and some dots are hidden.
      //     The solution is then to occupy all
      //     avaliable nested bins. Histogram is
      //     thus scaled relative to the number of
      //     nested bins within the bin.
      if (toPlot > limit && toPlot > plotSz) {
        int decrease = toPlot;
        while (decrease > limit || scaleBy <= 0) {
          decrease = toPlot;
          scaleBy -= 0.01;
          decrease *= scaleBy;
        }
        if (scaleBy > 0) {
          for (Integer value : act_histogram.keySet ()) {
            int base_frequency  = (Integer) act_histogram.get(value);
            int scale_freqeuncy = (Integer) floor(base_frequency * scaleBy);
            if (scale_freqeuncy < 1) scale_freqeuncy = 1;
            rel_histogram.put(value, scale_freqeuncy);
          }
        }
      }
      // 1b. There are less dots than nested bins.
      //     This allows for a the dots to be
      //     displayed without overlaps. Thus the
      //     solution is to scale the histogram
      //     relative to the visible dots.
      else {
        // 1b1. Remove outliers (where value frequency = 1)
        Map<Integer,Integer> temp = new HashMap();
        for (Integer value : act_histogram.keySet()) {
          int frequency  = (Integer) act_histogram.get(value);
          if (frequency == 1) {
            temp.put(value, frequency);
          } else {
            rel_histogram.put(value, frequency);
          }
        }
        // 1b2. Nested bin contains more than one value
        if(rel_histogram.size() > 0){
          // 1b2a. Sort ascending order
          rel_histogram = sortByValue(rel_histogram, false);
          // 1b2b. Find scalar
          List<Integer> values_in_rel_histogram  = new ArrayList(rel_histogram.keySet());
          int lowest_value                       = (Integer) values_in_rel_histogram.get(0);
          int lowest_frequency                   = (Integer) rel_histogram.get(lowest_value);
          // 1b2c. Modify histogram
          for (Integer value : rel_histogram.keySet()) {
            int frequency  = (Integer) rel_histogram.get(value);            
            rel_histogram.put(value, ceil(frequency / lowest_frequency));
          }
        }
        // 1b3. Restore outliers
        Iterator it = temp.entrySet().iterator();
        while (it.hasNext ()) {
          Map.Entry pair = (Map.Entry) it.next();
          int value      = (Integer) pair.getKey();
          int frequency  = (Integer) pair.getValue();
          rel_histogram.put(value, frequency);
        }        
        // 1b4. Scale histogram to visible dots
        rel_histogram = sortByValue(rel_histogram, false);
        scaleBy = getBestMatch(getSum(rel_histogram), limit);
        for (Integer value : rel_histogram.keySet()) {
          int frequency  = (Integer) rel_histogram.get(value);
          rel_histogram.put(value, (int) (frequency * scaleBy));
        }

      }

      // 2a. Ignore single value nested bins
      for(Integer value : rel_histogram.keySet()){
        int frequency = (Integer) rel_histogram.get(value);
        for(Cell nestedbin : values_in_bin.keySet()){
          if (frequency > 0) {
            if(!equalize.containsKey(nestedbin)){
              List<Integer> values_in_nestedbin = (ArrayList) values_in_bin.get(nestedbin);
              Set<Integer> value_summary = new HashSet(values_in_nestedbin);
              if(value_summary.size() == 1){
                if(value_summary.contains(value)){
                  equalize.put(nestedbin, value);
                  frequency--;
                }
              }
            }
          } else {
            break;
          }
        }
        rel_histogram.put(value, frequency);
      }
      // 2b. Resolve disputed nested bins
      for(Integer value : rel_histogram.keySet()){
        int frequency = (Integer) rel_histogram.get(value);
        for(Cell nestedbin : values_in_bin.keySet()){
          if (frequency > 0) {
            if(!equalize.containsKey(nestedbin)){
              List<Integer> values_in_nestedbin = (ArrayList) values_in_bin.get(nestedbin);
              Set<Integer> value_summary = new HashSet(values_in_nestedbin);
              if(value_summary.size() > 1){
                if(value_summary.contains(value)){
                  equalize.put(nestedbin, value);
                  frequency--;
                }
              }
            }
          } else {
            break;
          }
        }
        rel_histogram.put(value, frequency);
      }
      // 2c1. Extract empty nested bins
      Set<Cell> empty_nested_bins = new HashSet();
      for(Cell nestedbin : nestedbins_in_bin.getCells()){
        if(!values_in_bin.containsKey(nestedbin)){
          empty_nested_bins.add(nestedbin);
        }
      }
      // 2c2. Relocate remaining dots to empty nested bins
      for(Integer value : rel_histogram.keySet()){
        int frequency = (Integer) rel_histogram.get(value);

        int num_dots_with_value = 0;

        if(frequency > 0){
          for(Cell nestedbin : values_in_bin.keySet()){
            List<Integer> values_in_nestedbin = (ArrayList) values_in_bin.get(nestedbin);
            // 2d1. Summarize values
            Map<Integer,Integer> value_summary = new HashMap();
            for(Integer value_in_nestedbin : values_in_nestedbin){
              if(value_summary.containsKey(value_in_nestedbin)){
                int frequency_of_value = (Integer) value_summary.get(value_in_nestedbin);
                value_summary.put(value_in_nestedbin, frequency_of_value + 1);
              } else {
                value_summary.put(value_in_nestedbin, 1);
              }
            }
            // 2d2. 
            if(value_summary.containsKey(value)){
              int frequency_of_value = (Integer) value_summary.get(value);
              if(frequency_of_value > 1){
                num_dots_with_value++;
                int number_of_dots_to_displace = frequency_of_value - 1;
                for(int i=0; i<number_of_dots_to_displace; i++){
                  if(frequency > 0){
                    float[] distMat = new float[empty_nested_bins.size()];
                    List<Cell> ordered_empty_nested_bins = new ArrayList(empty_nested_bins);
                    for (int j=0; j<ordered_empty_nested_bins.size(); j++) {
                      Cell other_nestedbin = (Cell) ordered_empty_nested_bins.get(j);
                      distMat[j] = new PVector(nestedbin.x, nestedbin.y).dist(new PVector(other_nestedbin.x, other_nestedbin.y));
                    }
                    // Select nearest nested bin
                    if (min(distMat) == 9999){
                      println("No Room");
                      break;
                    }
                    int index = arrayMinIndex(distMat);
                    Cell nearest_nestedbin = (Cell) ordered_empty_nested_bins.get(index);
                    equalize.put(nearest_nestedbin, value);
                    empty_nested_bins.remove(nearest_nestedbin);
                    frequency--;
                  }
                }
              }
            }
          }
        }
        rel_histogram.put(value, frequency);
      }
  }
  println("6. Dot prioritization ok.");


}


void draw(){

	background(255);


	if(isGrid){
		strokeWeight(0.5);
		stroke(0,25);
		for(Cell bin : nestedbins.keySet()){
			List<Cell> nestedbinsInBin = (ArrayList) nestedbins.get(bin).getCells();
			for(Cell nestedBin : nestedbinsInBin){
				rect(nestedBin.x, nestedBin.y, nestedBin.width, nestedBin.height);
			}
		}
		stroke(0);
		for(Cell c : bins.getCells()){
			rect(c.x, c.y, c.width, c.height);
		}
	}


	if(isGeo){
	    strokeWeight(dotSz);
	    for(Dot d : dots){
	      stroke(d.v);
	      point(d.x, d.y);
	    }
		println("Rendering Geographic View");
	} else {
	    strokeWeight(dotSz);
	    if(isEqualise){
			for(Cell nestedbin : equalize.keySet()){
				int value = (Integer) equalize.get(nestedbin);
				stroke(value);
				point(nestedbin.x, nestedbin.y);
			}
			println("Rendering Equalised Gridded Map");
	    } else {
			for(Cell bin : values.keySet()){
				for(Cell nestedbin : values.get(bin).keySet()){
					List<Integer> values_in_nestedbin = values.get(bin).get(nestedbin);
					int v = (Integer) values_in_nestedbin.get(values_in_nestedbin.size() - 1);
					stroke(v);
					point(nestedbin.x, nestedbin.y);
				}
			}
			println("Rendering Overlapping Gridded Map");
	    }
	}

	noLoop();

}
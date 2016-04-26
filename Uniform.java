// This java class file will be part of a
// larger "com.dataurbanist.geotools" package

import processing.core.*;

import java.util.*;

@SuppressWarnings("unchecked")
public class Uniform {
	
	public static Grid partition (PVector inVec, float inWidth, float inHeight, int inRecursions) {
		return Uniform.partition(inVec.x, inVec.y, inWidth, inHeight, inRecursions);
	}		
	
	public static Grid partition (float inX, float inY, float inWidth, float inHeight, int inRecursions) {
		List<Cell> cells	= new ArrayList();
		float x				= inX;
		float y				= inY;		
		float w 			= inWidth;
		float h				= inHeight;
		int r				= inRecursions;
		float[][] hilbert	= Grid.hilbert(x, y, w, h, r, 0, 1, 2, 3);
		float cw 			= w/PApplet.sqrt(hilbert.length);
		float ch 			= h/PApplet.sqrt(hilbert.length);		
		for (int id = 0; id < hilbert.length; id++) {
			cells.add(new Cell(hilbert[id][0], hilbert[id][1], cw*2, ch*2, r, id));
		}
		return new Grid(x, y, w, h, cells);
	}
	
}
// This java class file will be part of a
// larger "com.dataurbanist.geotools" package

import processing.core.*;
import java.util.*;

@SuppressWarnings("unchecked")
public class Grid {
	
	// Contains cells
	public List<Cell> cells;
	
	// Geometry
	public float x;
	public float y;
	public float width;
	public float height;
	
	public Grid (float inX, float inY, float inWidth, float inHeight, List<Cell> inCells) {
		this.x		= inX;
		this.y 		= inY;
		this.width 	= inWidth;
		this.height = inHeight;
		this.cells	= inCells;
	}
	
	public void setCentre(int inX, int inY){
		this.x = inX;
		this.y = inY;		
	}
	
	public void setCentre(float inX, float inY){
		this.x = (int) inX;
		this.y = (int) inY;		
	}
	
	public void setCentre(PVector inPVector){
		this.x = (int) inPVector.x;
		this.y = (int) inPVector.y;
	}
	
	public static float[][] hilbert (float inX, float inY, float inWidth, float inHeight, int inNumIterations, int inA, int inB, int inC, int inD) {
		float[] centre = {inX, inY};
		return Grid.hilbert(centre, inWidth, inHeight, inNumIterations, inA, inB, inC,inD);
	}
	
	public static float[][] hilbert (float[] inCentre, float inWidth, float inHeight, int inNumIterations, int inA, int inB, int inC, int inD) {
		float w = inWidth/2;
		float h = inHeight/2;
		float seed[][] = new float[4][2];
		seed[inA][0] = inCentre[0] - w;
		seed[inA][1] = inCentre[1] - h;
		seed[inB][0] = inCentre[0] + w;
		seed[inB][1] = inCentre[1] - h;
		seed[inC][0] = inCentre[0] + w;
		seed[inC][1] = inCentre[1] + h;
		seed[inD][0] = inCentre[0] - w;
		seed[inD][1] = inCentre[1] + h;	
		if (--inNumIterations >= 0) {
			float extend[][] = new float[0][2];
			extend = (float[][]) PApplet.concat(extend, Grid.hilbert (seed[0], w, h, inNumIterations, inA, inD, inC, inB));
			extend = (float[][]) PApplet.concat(extend, Grid.hilbert (seed[1], w, h, inNumIterations, inA, inB, inC, inD));
			extend = (float[][]) PApplet.concat(extend, Grid.hilbert (seed[2], w, h, inNumIterations, inA, inB, inC, inD));
			extend = (float[][]) PApplet.concat(extend, Grid.hilbert (seed[3], w, h, inNumIterations, inC, inB, inA, inD));
			return extend;
		}
		return seed;
	}
	
	public List<Cell> getCells () {
		return this.cells;
	}
	
	public Cell getCell (int inIndex) {
		return this.cells.get(inIndex);
	}
	
	public int getSize () {
		return this.cells.size();
	}

}
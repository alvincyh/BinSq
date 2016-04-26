// This java class file will be part of a
// larger "com.dataurbanist.geotools" package

import processing.core.PVector;

@SuppressWarnings("unchecked")
public class Cell {
	
	// Geometry
	public float x;
	public float y;
	public float width;
	public float height;
	
	// Subdivision
	public int id;
	public int level;
	public int count;
	
	public Cell (PVector inCentre, float inWidth, float inHeight, int inLevel, int inId) {
		this.setCentre(inCentre);
		this.width 	= inWidth;
		this.height = inHeight;
		this.level	= inLevel;
		this.id 	= inId;
	}
	
	public Cell (float inX, float inY, float inWidth, float inHeight, int inLevel, int inId) {
		this.setCentre(inX, inY);
		this.width 	= inWidth;
		this.height = inHeight;
		this.level	= inLevel;
		this.id 	= inId;
	}
	
	public void setCentre (float inX, float inY) {
		this.x = (int) inX;
		this.y = (int) inY;		
	}
	
	public void setCentre (PVector inPVector) {
		this.x = (int) inPVector.x;
		this.y = (int) inPVector.y;
	}
	
	public PVector getCentre () {
		return new PVector (this.x, this.y);
	}
	
	public boolean contains (PVector inPVector) {
		return this.contains(inPVector.x, inPVector.y);
	}
	
	public boolean contains (float inX, float inY) {
		float w = this.width  / 2;
		float h = this.height / 2;
		if (inX >= (this.x - w) && 
			inX <= (this.x + w) && 
			inY >= (this.y - h) && 
			inY <= (this.y + h)) {
			return true;
		}
		return false;
	}
	
}
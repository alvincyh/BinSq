// This java class file will be part of a
// larger "com.dataurbanist.geotools" package

import processing.core.*;
import java.util.*;

@SuppressWarnings("unchecked")
public class QuadTree {
    
    public static Grid partition (List<PVector> inPoints, PVector inVec, float inWidth, float inHeight, int inMaxRecursions, int inThreshold) {
        return QuadTree.partition(inPoints, inVec.x, inVec.y, inWidth, inHeight, inMaxRecursions, inThreshold);
    }
    
    
    public static Grid partition (List<PVector> inPoints, float inX, float inY, float inWidth, float inHeight, int inMaxRecursions, int inThreshold) {
        List<Cell> cells    = new ArrayList();
        float x             = inX;
        float y             = inY;      
        float w             = inWidth;
        float h             = inHeight;
        int r               = inMaxRecursions;
        int t               = inThreshold;
        int level           = 0;
        float[][] hilbert   = Grid.hilbert(x, y, w, h, level, 0, 1, 2, 3);
        for (int id = 0; id < hilbert.length; id++) {
            cells.add(new Cell(hilbert[id][0], hilbert[id][1], w, h, level, id));
        }
        cells = QuadTree.subdivide(inPoints, cells, x, y, w, h, r, t);
        return new Grid(x, y, w, h, cells);
    }

    
    private static List<Cell> subdivide (List<PVector> inPoints, List<Cell> inCells, float inX, float inY, float inWidth, float inHeight, int inMaxRecursions, int inThreshold) {
        List<Cell> output   = inCells;
        int recursions      = 0;
        int prevNumCells    = 1;
        int currNumCells    = output.size();
        Set<Cell> killList  = new HashSet();
        Set<Cell> stopList  = new HashSet();
        while (prevNumCells != currNumCells) {
            if (recursions >= inMaxRecursions) break;
            prevNumCells = output.size();
            output = QuadTree.advance(inPoints, output, inX, inY, inWidth, inHeight, stopList, killList, inThreshold);
            currNumCells = output.size();
            recursions++;
        }
        return output;
    }
    
    
    private static List<Cell> populateCells (List<PVector> inPoints, List<Cell> inCells, Set<Cell> inStopRef) {
        List<Cell> output = inCells;
        // Reset bins
        boolean[] binned = new boolean[inPoints.size()];
        // Count the number of points in each cell
        for (Cell c : output) {
            if (!inStopRef.contains(c)) {
                for (int i = 0; i < inPoints.size(); i++) {
                    PVector pt = inPoints.get(i);
                    if (!binned[i]) {
                        boolean isWithin = c.contains(pt);
                        if (isWithin) {
                            c.count++;
                            binned[i] = true;
                        }
                    }
                }
            }
        }
        return output;
    }
    
    
    private static List<Cell> advance (List<PVector> inPoints, List<Cell> inCells, float inX, float inY, float inWidth, float inHeight, Set<Cell> inStopRef, Set<Cell> inKillRef, int inThreshold) {
        List<Cell> output = inCells;
        output = QuadTree.populateCells(inPoints, output, inStopRef);
        for (Cell c : output) {
            if (!inStopRef.contains(c)) {
                if (c.count > inThreshold) {
                    inKillRef.add(c);
                } else {
                    inStopRef.add(c);
                }
            }
        }
        for (int i = 0; i < output.size(); i++) {
            Cell c = output.get(i);
            if (inKillRef.contains(c)) {
                float w  = c.width/2;
                float h  = c.height/2;
                if(w < 1 || h < 1){
                    inStopRef.add(c);
                } else {
                    int level           = c.level + 1;
                    int nIndex          = 4 * c.id;             
                    int count           = 0;
                    float[][] hilbert   = Grid.hilbert(inX, inY, inWidth, inHeight, level, 0, 1, 2, 3);
                    for (int id = nIndex; id < (nIndex + 4); id++) {
                        output.add(i+count, new Cell(hilbert[id][0], hilbert[id][1], w, h, level, id));
                        count++;
                    }
                    output.remove(c);
                }
            }
        }
        inKillRef.clear();
        output = QuadTree.populateCells(inPoints, output, inStopRef);
        return output;
    }
    
}
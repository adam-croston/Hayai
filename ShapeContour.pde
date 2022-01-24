//----------------------------------------------------------------------------
// This reperesents a polygonal image shape to use to stencil object outlines.
//
// TODO: Higher level class that can be vector or bitmap and even has file
//       watchers so that users can use whatever bitmap editor they choose.
// TODO: Matching bitmap shape class.
// TODO: Support for multipart shapes.
// TODO: Make the imgQuad not be part of this class.
//----------------------------------------------------------------------------
static final float TEN_DEGS_IN_RADS = 10.0f * (TWO_PI / 360.0f);
class ShapeBounds{
  PVector min;
  PVector max;
};
final float edgeSelectionDistance = 10.0f;
class ShapeContour{
  //--------------------------------------------------------------------------
  // CREATION/SAVE/LOAD
  
  ShapeContour(PVector initialVertPos){
    vertices = new ArrayList<ShapeVert>();
    vertices.add(new ShapeVert(initialVertPos, true));  
    
    isSelected = true;
    isClosed = false;
    
    // Set up the warp quad and default image.
    setWarpQuad("grid.png");
  }
  ShapeContour(ShapeContour otherShapeContour){
    vertices = new ArrayList<ShapeVert>();   
    int numVerts = otherShapeContour.vertices.size();
    for(int i = 0; i< numVerts; ++i){
      PVector pos = otherShapeContour.vertices.get(i).getPos();
      vertices.add(new ShapeVert(pos, false));  
    }
    
    isSelected=otherShapeContour.isSelected;
    isClosed=otherShapeContour.isClosed;
    
    imgQuad = new WarpQuad(otherShapeContour.imgQuad);
  }
  ShapeContour(ArrayList<String> loadInfo){
    // Load up all the verts.
    int numVerts = int(loadInfo.remove(0));
    vertices = new ArrayList<ShapeVert>();
    for(int i = 0; i< numVerts; ++i){
      ShapeVert tempVert  = new ShapeVert(loadInfo);
      vertices.add(tempVert);
    }
    
    // Make sure it is not selected.
    isSelected = false;
    isClosed = true;
    
    // Load the warp quad and image.
    imgQuad = new WarpQuad(loadInfo);
  }
  void save(ArrayList<String> saveInfo){
    // Save all the verts.
    int numVerts = vertices.size();
    saveInfo.add(str(numVerts));
    for(int i = 0; i< numVerts; ++i){
      vertices.get(i).save(saveInfo);
    }
    
    // We don't care if it is selected or not.
    // We don't care if it is closed or not.
    
    // Save the warp quad and image.
    imgQuad.save(saveInfo);
  }
  
  //--------------------------------------------------------------------------
  // SELECTION
  
  // Check if a position is located within a polygon.
  // Uses polygon based hit detectio with the "ray tecing" algorithm.
  boolean canSelect(PVector pointerPos){
       int nPoints=vertices.size();
       int j=-9999;
       int i=-9999;
       
       // Check if the pointer is located close enough to a vert.
       for(i=0;i<(nPoints);i++){
         if(vertices.get(i).canSelectVert(pointerPos)){
           return true;
         }
       }
       
       // Check if the pointer is located close enough to an edge.
       for(i=0;i<(nPoints);i++){
         // Skip testing an edge from the last vert back to first if
         // there are only 1 or 2 verts.
         if((nPoints<= 2) && (i == (nPoints - 1))){
           continue;
         }
         
         // Get the distance to the edge to the point.
         PVector posA = vertices.get(i).getPos();
         PVector posB = vertices.get((i + 1) % nPoints).getPos();
         PVector pa = PVector.sub(pointerPos, posA);
         PVector ba = PVector.sub(posB, posA);
         
         //float h = clamp(dot(pa,ba)/dot(ba,ba), 0.0f, 1.0f);
         float h = constrain((pa.x*ba.x + pa.y*ba.y)/(ba.x*ba.x + ba.y*ba.y), 0.0f, 1.0f);
         PVector hba = PVector.mult(ba, h);
         PVector delta = PVector.sub(pa, hba);
         delta.z = 0.0f;
         float distance = delta.mag();
         if(distance< edgeSelectionDistance){
           return true;
         }
       }
      
      // Determine if the point is in the polygon.
      // This method uses the ray tracing algorithm.
      // Original code from post at:
      // http://stackoverflow.com/questions/11716268/point-in-polygon-algorithm
      boolean locatedInPolygon=false;
      for(i=0;i<(nPoints);i++){
          //repeat loop for all sets of points
          if(i==(nPoints-1)){
              //if i is the last vertex, let j be the first vertex
              j= 0;
          }else{
              //for all-else, let j=(i+1)th vertex
              j=i+1;
          }
  
          float vertY_i= (float)vertices.get(i).getPos().y;
          float vertX_i= (float)vertices.get(i).getPos().x;
          float vertY_j= (float)vertices.get(j).getPos().y;
          float vertX_j= (float)vertices.get(j).getPos().x;
          float testX  = (float)pointerPos.x;
          float testY  = (float)pointerPos.y;
  
          // following statement checks if testPoint.Y is below Y-coord of i-th vertex
          boolean belowLowY=vertY_i>testY;
          // following statement checks if testPoint.Y is below Y-coord of i+1-th vertex
          boolean belowHighY=vertY_j>testY;
  
          // following statement is true if testPoint.Y satisfies either (only
          // one is possible) 
          // -->(i).Y< testPoint.Y< (i+1).Y        OR  
          // -->(i).Y > testPoint.Y > (i+1).Y
          //
          // (Note)
          // Both of the conditions indicate that a point is located within the edges of
          // the Y-th coordinate of the (i)-th and the (i+1)- th vertices of the polygon.
          // If neither of the above conditions is satisfied, then it is assured that a
          // semi-infinite horizontal line draw to the right from the testpoint will NOT
          // cross the line that connects vertices i and i+1 of the polygon.
          boolean withinYsEdges= belowLowY != belowHighY;
  
          if(withinYsEdges){
              // this is the slope of the line that connects vertices i and i+1 of
              // the polygon
              float slopeOfLine   = (vertX_j-vertX_i)/ (vertY_j-vertY_i);
  
              // this looks up the x-coord of a point lying on the above line, given
              // its y-coord
              float pointOnLine   = (slopeOfLine* (testY - vertY_i))+vertX_i;
  
              //checks to see if x-coord of testPoint is smaller than the point on the
              // line with the same y-coord
              boolean isLeftToLine= testX< pointOnLine;
  
              if(isLeftToLine){
                  // This statement changes true to false (and vice-versa).
                  locatedInPolygon= !locatedInPolygon;
              }//end if (isLeftToLine).
          }//end if (withinYsEdges.
      }
      return locatedInPolygon;
  }
  // Pixel based hit detection! slower, but much more compact code.
  /*
  boolean canSelect(PVector pointerPos){
    PGraphics tempGraphics = createGraphics(800, 800, JAVA2D);
    tempGraphics.beginDraw();
    tempGraphics.background(0);
      tempGraphics.fill(255);
      tempGraphics.noStroke();
      tempGraphics.beginShape();
        for(int i = 0; i< vertices.size(); ++i){
          tempGraphics.vertex(vertices.get(i).getPos().x, vertices.get(i).getPos().y);
        }
      tempGraphics.endShape(CLOSE);
      boolean hit =(tempGraphics.get((int)pointerPos.x, (int)pointerPos.y) == color(255));
    tempGraphics.endDraw();
    return hit;
  }
  */
  void setIsSelected(boolean selected){
    isSelected = selected;
    if(isSelected){
    }else{
      turnOffVertexSelection();
      if(!isClosed){
        isClosed = true;
      }
    }
  }
  boolean getIsSelected(){
    return isSelected;    
  }
  
  //--------------------------------------------------------------------------
  // ADJUSTMENT
  
  void updatePos(PVector delta){
    for(int i = 0; i< vertices.size(); ++i){
      if(vertices.get(i) != null){
        vertices.get(i).adjustPos(delta);
      }
    }
    imgQuad.updatePos(delta);
  }
  
  // TODO : This should become more sphisticated and find the actual centroid instead
  // of just the average of the points which even for a circle can become wighted to one
  // side.
  PVector getCentroid(){
    int count = 0;
    PVector sum = new PVector(0.0f, 0.0f);
    
    for(int i = 0; i< vertices.size(); ++i){
      if(vertices.get(i) != null){
        sum = PVector.add(sum, vertices.get(i).getPos()); 
        ++count;
      }
    }
    
    if(count > 0){
      return PVector.div(sum, (float)count);
    }else{
      return new PVector(0.0f, 0.0f, 0.0f);
    }
  }
  void flipX(){
    PVector center  = getCentroid();
    for(int i = 0; i< vertices.size(); ++i){
      if(vertices.get(i) != null){
        PVector pos = vertices.get(i).getPos();
        pos = PVector.sub(pos, center);
        pos.x = pos.x * -1.0;
        pos = PVector.add(pos, center);
        vertices.get(i).setPos(pos);
      }
    }
    imgQuad.flipX(center); 
  }
  void flipY(){
    PVector center  = getCentroid();
    for(int i = 0; i< vertices.size(); ++i){
      if(vertices.get(i) != null){
        PVector pos = vertices.get(i).getPos();
        pos = PVector.sub(pos, center);
        pos.y = pos.y * -1.0;
        pos = PVector.add(pos, center);
        vertices.get(i).setPos(pos);
      }
    }
    imgQuad.flipY(center); 
  }
  void rotCCW(){
    float rotRads = TEN_DEGS_IN_RADS;
    PVector center  = getCentroid();
    for(int i = 0; i< vertices.size(); ++i){
      if(vertices.get(i) != null){
        PVector pos = vertices.get(i).getPos();
        pos = PVector.sub(pos, center);
        rotate2D(pos, rotRads);
        pos = PVector.add(pos, center);
        vertices.get(i).setPos(pos);
      }
    }
    imgQuad.rotCCW(center, rotRads);
  }
  void rotCW(){
    float rotRads = -TEN_DEGS_IN_RADS;
    PVector center  = getCentroid();
    for(int i = 0; i< vertices.size(); ++i){
      if(vertices.get(i) != null){
        PVector pos = vertices.get(i).getPos();
        pos = PVector.sub(pos, center);
        rotate2D(pos, rotRads);
        pos = PVector.add(pos, center);
        vertices.get(i).setPos(pos);
      }
    }
    imgQuad.rotCW(center, rotRads);
  }
  
  int getSelectedVertIndex(){
    for(int i = 0; i< vertices.size(); ++i){
      if(vertices.get(i).getIsSelectedVert()){
        return i;
      }
    }
    return -1;
  }
  int getFirstSelectableVertIndex(PVector pointerLoc){
    for(int i = 0; i< vertices.size(); ++i){
      if(vertices.get(i).canSelectVert(pointerLoc)){
        return i;        
      }
    }
    return -1;
  }
  void selectVertByIndex(int vertIndex){
    turnOffVertexSelection();
    if((vertIndex >= 0) && (vertIndex< vertices.size())){
      vertices.get(vertIndex).setIsSelectedVert(true);
      setIsSelected(true);
    }
  }
  void turnOffVertexSelection(){
    for(int i = 0; i< vertices.size(); ++i){
      vertices.get(i).setIsSelectedVert(false);
    }
  }
  void updateVertexPosition(int vertIndex, PVector delta){
    if((vertIndex< 0) || (vertIndex > vertices.size())){return;}
    
    vertices.get(vertIndex).adjustPos(delta); 
  }
  void removeVertex(int remove){
    if(remove< 0){
       if(vertices.size() > 0){
        remove = 0;
       }else{
         return;
       }
    }
    vertices.remove(remove);
    
    if(vertices.size()<= 0){
      theScene.shapes.remove(this);
      return;
    }
    
    int newSelectedVert = constrain(remove - 1, 0, vertices.size());
    vertices.get(newSelectedVert).setIsSelectedVert(true);
  }
  
 
  void setWarpQuad(String fileName){
    if(imgQuad != null){
      imgQuad.setImgFile(fileName);
    }else{      
      // Make a new warp quad.
      PVector vA = new PVector(0.0f,  0.0f,    0.0f);
      PVector vB = new PVector(width, 0.0f,    0.0f); 
      PVector vC = new PVector(width, height,  0.0f);
      PVector vD = new PVector(0.0f,  height,  0.0f);   
      float perspectiveX = 1.0f;
      float perspectiveY = 1.0f;
      imgQuad = new WarpQuad(fileName, vA, vB, vC, vD, perspectiveX, perspectiveY);  
    }
  }
  
  ShapeBounds getBounds(){
    PVector  min = new PVector(100000.0f, 100000.0f, 100000.0f);
    PVector  max = new PVector(-100000.0f, -100000.0f, -100000.0f);
    for(int i = 0; i< vertices.size(); ++i){
      PVector vertPos = vertices.get(i).getPos();
      min.x =(min.x< vertPos.x)?min.x:vertPos.x;
      min.y =(min.y< vertPos.y)?min.y:vertPos.y;
      max.x =(max.x > vertPos.x)?max.x:vertPos.x;
      max.y =(max.y > vertPos.y)?max.y:vertPos.y;
    }

    ShapeBounds bounds = new ShapeBounds();
    bounds.min = min;
    bounds.max = max;
    return bounds;
  }
  
  void quickFitWarp(){
     PVector vA;
     PVector vB;
     PVector vC;
     PVector vD;
       
     if(vertices.size() == 4){
       // Special case for quick fit...  The shape is already a quad...
       // The warp quads start in the lower left and go anti clockwise...
       // TODO: We don't know how the use drew the quad, so try to find the best
       // ordering of the verts!
       // TODO: for now just use whatever order the user used!
       // Determine what 
       vA = vertices.get(3).getPos();
       vB = vertices.get(2).getPos();
       vC = vertices.get(1).getPos();
       vD = vertices.get(0).getPos();
     }else{
       ShapeBounds bounds = getBounds();
       
       vA = new PVector(bounds.min.x, bounds.min.y, 0.0f);
       vB = new PVector(bounds.max.x, bounds.min.y, 0.0f);
       vC = new PVector(bounds.max.x, bounds.max.y, 0.0f);
       vD = new PVector(bounds.min.x, bounds.max.y, 0.0f);
     }
     
     // DEBUG @adam.croston : Avoid wierd shader bug for prefectly rectangular warp verts.
     vA.add(PVector.random2D().mult(0.01f));
     vB.add(PVector.random2D().mult(0.01f));
     vC.add(PVector.random2D().mult(0.01f));
     vD.add(PVector.random2D().mult(0.01f));
     // END DEBUG
       
     imgQuad.setVerts(vA, vB, vC, vD);
  }
  void flipWarpX(){  
    PVector center  = getCentroid();    
    imgQuad.flipX(center); 
  }
  void flipWarpY(){    
    PVector center  = getCentroid();     
    imgQuad.flipY(center); 
  }
  void rotWarpCCW(){
    float rotRads = TEN_DEGS_IN_RADS;
    PVector center  = getCentroid();   
    imgQuad.rotCCW(center, rotRads);
  }
  void rotWarpCW(){
    float rotRads = -TEN_DEGS_IN_RADS;
    PVector center  = getCentroid();  
    imgQuad.rotCW(center, rotRads);
  }   
  void updateWarpPos(PVector delta){
     imgQuad.updatePos(delta);
  }
  
  //--------------------------------------------------------------------------
  // DISPLAY  
  
  void displayWarpQuad(){
    imgQuad.display(); 
  }
  void displayShape(boolean showVerts, boolean showEdges, boolean showFills, boolean beingEdited){
    if(showFills){
      pushStyle();
        imgQuad.applyShaderForWarp();
        textureMode(NORMAL);
        beginShape();
        noStroke();
        fill(255);
        texture(imgQuad.getImage());
        for(int i = 0; i< vertices.size(); ++i){
          float x = vertices.get(i).getPos().x;
          float y = vertices.get(i).getPos().y;
          vertex(x, y, 0, x/width, y/height);
        }
        if(isSelected && beingEdited){
          endShape();
        }else{
          endShape(CLOSE);
        }
        resetShader();
      popStyle();
    }

    if(showEdges){
      final float maxSize = max(width, height); 
      float radius  = 0.001f * maxSize;
    
      pushStyle();         
        // Deal with wierd bug...
        if(vertices.size() == 2){
          float x1 = vertices.get(0).getPos().x;
          float y1 = vertices.get(0).getPos().y;
          float x2 = vertices.get(1).getPos().x;
          float y2 = vertices.get(1).getPos().y;
          
          // Draw the selection base.
          if(isSelected){
            stroke(255,0,0,255);
            strokeWeight(2.0f * radius);
            noFill();        
            line(x1, y1, x2, y2);
          }
          stroke(128);
          strokeWeight(radius);
          noFill();        
          line(x1, y1, x2, y2);          
        }else{
            if(isSelected){
              translate(0, 0);
              beginShape();
                stroke(255,0,0,255);
                strokeWeight(2.0f * radius);
                noFill();
                for(int i = 0; i< vertices.size(); ++i){
                  float x = vertices.get(i).getPos().x;
                  float y = vertices.get(i).getPos().y;
                  vertex(x, y);
                }
              if(isSelected && beingEdited){
                endShape();
              }else{
                endShape(CLOSE);
              }
            }
            
            translate(0, 0);
            beginShape();
              stroke(128);
              strokeWeight(radius);
              noFill();
              for(int i = 0; i< vertices.size(); ++i){
                float x = vertices.get(i).getPos().x;
                float y = vertices.get(i).getPos().y;
                vertex(x, y);
              }
            if(isSelected && beingEdited){
              endShape();
            }else{
              endShape(CLOSE);
            }
        }
      popStyle();      
    }
        
    if(showVerts){
      pushStyle();
        for(int i = 0; i< vertices.size(); ++i){
          vertices.get(i).display();
        }
      popStyle();  
    }
  }

  ArrayList<ShapeVert> vertices;
  boolean isSelected;
  boolean isClosed;
  WarpQuad imgQuad;
}

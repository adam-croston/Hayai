//----------------------------------------------------------------------------
// This reperesents a single vertex of a polygonal shape.
//----------------------------------------------------------------------------

final float vertSelectionDistance = 10.0f;

class ShapeVert{
  //--------------------------------------------------------------------------
  // CREATION/SAVE/LOAD
  
  ShapeVert(PVector position, boolean selected){
    pos = position;
    isSelected = selected;    
  }
  ShapeVert(ShapeVert otherShapeVert)
  {
    PVector otherShapeVertPos = otherShapeVert.getPos();
    pos = new PVector(otherShapeVertPos.x, otherShapeVertPos.y, otherShapeVertPos.z);
    isSelected = otherShapeVert.isSelected;
  }
  ShapeVert(ArrayList<String> loadInfo){
    // Load the vert position (only load the 2D portion)..
    pos = new PVector(float(loadInfo.remove(0)), float(loadInfo.remove(0)), 0.0f);
    
    // Make sure it is not selected.
    isSelected = false;
  }
  void save(ArrayList<String> saveInfo){
    // Save the vert position (only save the 2D portion).
    saveInfo.add(str(pos.x));
    saveInfo.add(str(pos.y));
    
    // We don't care if it is selected or not.
  }
  
  //--------------------------------------------------------------------------
  // SELECTION
  
  boolean canSelectVert(PVector pointerPos){
    float distance = dist(pointerPos.x, pointerPos.y, pos.x, pos.y);
    return (distance< vertSelectionDistance);
  }
  void setIsSelectedVert(boolean selected){
    isSelected = selected;    
  }
  boolean getIsSelectedVert(){
    return isSelected;    
  }
  
  //--------------------------------------------------------------------------
  // ADJUSTMENT
  
  PVector getPos(){
   return pos; 
  }
  void setPos(PVector val){
   pos = val; 
  }  
  void adjustPos(PVector delta){
    pos = PVector.add(pos, delta); 
  }

  //--------------------------------------------------------------------------
  // DISPLAY
  
  void display(){
    final float maxSize = max(width, height); 
    float radius  = 0.005f * maxSize;
    pushStyle();
      if(isSelected){
        fill(255, 0, 0, 102);// Dark red.
        noStroke();
        ellipse(pos.x, pos.y, radius, radius);
      }
      noStroke();
      fill(255);
      ellipse(pos.x, pos.y, radius * 0.5f, radius * 0.5f);
    popStyle();
  }
  
  PVector pos;
  boolean isSelected;
}

//----------------------------------------------------------------------------
// Raw actions so that scene actions are seperated from the user actions
// that invoke them.
// This allows us to undo/redo and make recordings.
// These should only be things that change the state of the scene.
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
// Active Shape control.
//----------------------------------------------------------------------------
void action_deselectAllShapes(){
  theScene.deselectAllShapes();
}
void action_activateShapeByIndex(int i){
  theScene.deselectAllShapes();
  if((i >= 0) && (i< theScene.shapes.size())){
    theScene.shapes.get(i).setIsSelected(true);
  }
}
void action_selectedShapeNext(){
  boolean selectedShapeIsSet = (theScene.getFirstSelectedShape() >= 0);
  if(!selectedShapeIsSet){
    if(theScene.shapes.size() > 0){
      theScene.shapes.get(0).setIsSelected(true);
    }
  }else{
    int currentSelectedShapeIndex = theScene.getFirstSelectedShape();
    int tempShapeIndex = currentSelectedShapeIndex + 1;
    if(tempShapeIndex >= theScene.shapes.size()){tempShapeIndex = 0;}
    theScene.oldSelectedShape = currentSelectedShapeIndex;
    theScene.deselectAllShapes();
    theScene.shapes.get(tempShapeIndex).setIsSelected(true);
  }
}
void action_selectedShapePrev(){
  boolean selectedShapeIsSet = (theScene.getFirstSelectedShape() >= 0);
  if(!selectedShapeIsSet){
    if(theScene.shapes.size() > 0){
      theScene.shapes.get(theScene.shapes.size() - 1).setIsSelected(true);
    }
  }else{
    int currentSelectedShapeIndex = theScene.getFirstSelectedShape();
    int tempShapeIndex = currentSelectedShapeIndex - 1;
    if(tempShapeIndex< 0){tempShapeIndex = theScene.shapes.size() - 1;}
    theScene.oldSelectedShape = currentSelectedShapeIndex;
    theScene.deselectAllShapes();
    theScene.shapes.get(tempShapeIndex).setIsSelected(true);
  }
}    
void action_activatePreviousSelectShape(){
  // Make sure something is selected by default if possible.
  if(  (theScene.getFirstSelectedShape()< 0) &&
       (theScene.oldSelectedShape >= 0) &&
       (theScene.oldSelectedShape< theScene.shapes.size())){
    theScene.shapes.get(theScene.oldSelectedShape).setIsSelected(true);
  }
}

//----------------------------------------------------------------------------
// Shape add/remove.
//----------------------------------------------------------------------------
void action_addShape(PVector loc){
  theScene.shapes.add(new ShapeContour(loc));
}
void action_removeShape(int shapeIndex){
  if((shapeIndex< 0) || (shapeIndex >= theScene.shapes.size())){ return; }

  theScene.shapes.remove(shapeIndex);
}
void action_copyShape(int shapeIndex){
  if((shapeIndex< 0) || (shapeIndex >= theScene.shapes.size())){ return; }
  ShapeContour theShape = theScene.shapes.get(shapeIndex);
  
  copiedShapeInfo = new ArrayList<String>();
  theShape.save(copiedShapeInfo);
}
void action_cutShape(int shapeIndex){
  if((shapeIndex< 0) || (shapeIndex >= theScene.shapes.size())){ return; }
  ShapeContour theShape = theScene.shapes.get(shapeIndex);
  
  copiedShapeInfo = new ArrayList<String>();
  theShape.save(copiedShapeInfo);
  theScene.shapes.remove(shapeIndex);
}
void action_pasteShape(boolean atNewPos, PVector newPos){
  if(copiedShapeInfo != null){
    theScene.deselectAllShapes();
    // Note the trick immediately below works since in Java strings are immutable.
    ArrayList<String> comsumableShapeInfo = new ArrayList<String>(copiedShapeInfo);
    ShapeContour newPolygon = new ShapeContour(comsumableShapeInfo);
    theScene.shapes.add(newPolygon);
    if(atNewPos){
      final PVector centroid = newPolygon.getCentroid();
      final PVector posDelta = PVector.sub(newPos, centroid);
      newPolygon.updatePos(posDelta);
    }
    theScene.shapes.get(theScene.shapes.size() - 1).setIsSelected(true);
  }
}

//----------------------------------------------------------------------------
// Shape modifiers.
//----------------------------------------------------------------------------
void action_shapeMove(int shapeIndex, PVector nudgeDelta){
  if((shapeIndex< 0) || (shapeIndex >= theScene.shapes.size())){ return; }
  ShapeContour theShape = theScene.shapes.get(shapeIndex);
  
  theShape.updatePos(nudgeDelta);
}
void action_shapeLayerRaise(int shapeIndex){
  if((shapeIndex< 0) || (shapeIndex >= theScene.shapes.size())){ return; }
  ShapeContour theShape = theScene.shapes.get(shapeIndex);
  
  if(shapeIndex< (theScene.shapes.size()-1)){
    ShapeContour tempShape = theScene.shapes.get(shapeIndex + 1);
    theScene.shapes.set(shapeIndex + 1, theShape);
    theScene.shapes.set(shapeIndex, tempShape);
  }
}
void action_shapeLayerLower(int shapeIndex){
  if((shapeIndex< 0) || (shapeIndex >= theScene.shapes.size())){ return; }
  ShapeContour theShape = theScene.shapes.get(shapeIndex);
  
  if(shapeIndex > 0){
    ShapeContour tempShape = theScene.shapes.get(shapeIndex - 1);
    theScene.shapes.set(shapeIndex - 1, theShape);
    theScene.shapes.set(shapeIndex, tempShape);
  }
}
void action_flipX(int shapeIndex){
  if((shapeIndex< 0) || (shapeIndex >= theScene.shapes.size())){ return; }
  ShapeContour theShape = theScene.shapes.get(shapeIndex);
  
  theShape.flipX();
}
void action_flipY(int shapeIndex){
  if((shapeIndex< 0) || (shapeIndex >= theScene.shapes.size())){ return; }
  ShapeContour theShape = theScene.shapes.get(shapeIndex);
  
  theShape.flipY();
}
void action_rotCCW(int shapeIndex){
  if((shapeIndex< 0) || (shapeIndex >= theScene.shapes.size())){ return; }
  ShapeContour theShape = theScene.shapes.get(shapeIndex);
  
  theShape.rotCCW();
}
void action_rotCW(int shapeIndex){
  if((shapeIndex< 0) || (shapeIndex >= theScene.shapes.size())){ return; }
  ShapeContour theShape = theScene.shapes.get(shapeIndex);
  
  theShape.rotCW();
}

//----------------------------------------------------------------------------
// Active vert selection.
//----------------------------------------------------------------------------
void action_selectVert(int shapeIndex, int vertIndex){
  if((shapeIndex< 0) || (shapeIndex >= theScene.shapes.size())){ return; }
  ShapeContour theShape = theScene.shapes.get(shapeIndex);
    
  theShape.selectVertByIndex(vertIndex); 
}
void action_deselectAllVerts(){
  for(int i = 0; i< theScene.shapes.size(); ++i){
    theScene.shapes.get(i).turnOffVertexSelection();
  }
}
void action_selectVertNext(int shapeIndex){
  if((shapeIndex< 0) || (shapeIndex >= theScene.shapes.size())){ return; }
  ShapeContour theShape = theScene.shapes.get(shapeIndex);
  
  boolean selectedVertIsSet = (theShape.getSelectedVertIndex() >= 0);
  if(selectedVertIsSet){
    int tempVertex = theShape.getSelectedVertIndex() + 1;
    if(tempVertex >= theShape.vertices.size()){tempVertex = 0;}
    theShape.turnOffVertexSelection();
    theShape.vertices.get(tempVertex).setIsSelectedVert(true);
  }
}

void action_selectVertPrev(int shapeIndex){
  if((shapeIndex< 0) || (shapeIndex >= theScene.shapes.size())){ return; }
  ShapeContour theShape = theScene.shapes.get(shapeIndex);
  
  boolean selectedVertIsSet = (theShape.getSelectedVertIndex() >= 0);
  if(selectedVertIsSet){
    int tempVertex = theShape.getSelectedVertIndex() - 1;
    if(tempVertex< 0){tempVertex = theShape.vertices.size() - 1;}
    theShape.turnOffVertexSelection();
    theShape.vertices.get(tempVertex).setIsSelectedVert(true);
  }
}

//----------------------------------------------------------------------------
// Vert add/remove & modifiers.
//----------------------------------------------------------------------------
void action_addVert(int shapeIndex, PVector loc){
  if((shapeIndex< 0) || (shapeIndex >= theScene.shapes.size())){ return; }
  ShapeContour theShape = theScene.shapes.get(shapeIndex);
  
  theShape.turnOffVertexSelection();
  theShape.vertices.add(new ShapeVert(loc, true));
  //constrain(getSelectedVertIndex() + 1, 0, vertices.size()), 
}
void action_removeVert(int shapeIndex, int vertIndex){
  if((shapeIndex< 0) || (shapeIndex >= theScene.shapes.size())){ return; }
  ShapeContour theShape = theScene.shapes.get(shapeIndex);
  
  theShape.removeVertex(vertIndex);
}
void action_updateVertLoc(int shapeIndex, int vertIndex, PVector locDelta){
  if((shapeIndex< 0) || (shapeIndex >= theScene.shapes.size())){ return; }
  ShapeContour theShape = theScene.shapes.get(shapeIndex);
  
  theShape.updateVertexPosition(vertIndex, locDelta);
}

//----------------------------------------------------------------------------
// Warp modifiers.
//----------------------------------------------------------------------------
void action_setWarpImage(int shapeIndex, String fileAbsolutePath){
  if((shapeIndex< 0) || (shapeIndex >= theScene.shapes.size())){ return; }
  ShapeContour theShape = theScene.shapes.get(shapeIndex);
  
   RequestGarbageCleanup();
   theShape.setWarpQuad(fileAbsolutePath);
}
void action_setWarpVertLoc(int shapeIndex, int warpVertIndex, PVector loc){
  if((shapeIndex< 0) || (shapeIndex >= theScene.shapes.size())){ return; }
  ShapeContour theShape = theScene.shapes.get(shapeIndex);
  
  theShape.imgQuad.setVertLoc(warpVertIndex, loc);
}
void action_doQuickFitWarp(int shapeIndex){
  if((shapeIndex< 0) || (shapeIndex >= theScene.shapes.size())){ return; }
  ShapeContour theShape = theScene.shapes.get(shapeIndex);
  
  theShape.quickFitWarp();
}
void action_warpMove(int shapeIndex, PVector nudgeDelta){
  if((shapeIndex< 0) || (shapeIndex >= theScene.shapes.size())){ return; }
  ShapeContour theShape = theScene.shapes.get(shapeIndex);
  
  theShape.updateWarpPos(nudgeDelta);
}
void action_flipWarpX(int shapeIndex){
  if((shapeIndex< 0) || (shapeIndex >= theScene.shapes.size())){ return; }
  ShapeContour theShape = theScene.shapes.get(shapeIndex);
  
  theShape.flipWarpX();
}
void action_flipWarpY(int shapeIndex){
  if((shapeIndex< 0) || (shapeIndex >= theScene.shapes.size())){ return; }
  ShapeContour theShape = theScene.shapes.get(shapeIndex);
  
  theShape.flipWarpY();
}
void action_rotWarpCCW(int shapeIndex){
  if((shapeIndex< 0) || (shapeIndex >= theScene.shapes.size())){ return; }
  ShapeContour theShape = theScene.shapes.get(shapeIndex);
  
  theShape.rotWarpCCW();
}
void action_rotWarpCW(int shapeIndex){
  if((shapeIndex< 0) || (shapeIndex >= theScene.shapes.size())){ return; }
  ShapeContour theShape = theScene.shapes.get(shapeIndex);
  
  theShape.rotWarpCW();
}
void action_adjustWarpPerspectiveX(int shapeIndex, float delta){
  if((shapeIndex< 0) || (shapeIndex >= theScene.shapes.size())){ return; }
  ShapeContour theShape = theScene.shapes.get(shapeIndex);
  
  theShape.imgQuad.adjustPerspectiveX(delta);
}
void action_adjustWarpPerspectiveY(int shapeIndex, float delta){
  if((shapeIndex< 0) || (shapeIndex >= theScene.shapes.size())){ return; }
  ShapeContour theShape = theScene.shapes.get(shapeIndex);
  
  theShape.imgQuad.adjustPerspectiveY(delta);
}

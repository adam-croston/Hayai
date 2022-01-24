boolean userInput_updateGui(boolean pointerDown, PVector pointerLoc){
  if(!guiEditor.showGui){return false;}
  
  // Make sure the some buttons are gray if not approriate.
  boolean editImageButtonsActive = (theScene.getFirstSelectedShape()>=0);
  guiEditor.setImgButtn.setIsActive(editImageButtonsActive);
  guiEditor.fitWarpButtn.setIsActive(editImageButtonsActive);
  
  boolean movementButtonsActive = (theScene.getFirstSelectedShape()>=0) &&
                                  ((mainMode == MOVE_SHAPE) || (mainMode == EDIT_WARP));
  guiEditor.flpXButtn.setIsActive(movementButtonsActive);
  guiEditor.flpYButtn.setIsActive(movementButtonsActive);
  guiEditor.rotCCWButtn.setIsActive(movementButtonsActive);
  guiEditor.rotCWButtn.setIsActive(movementButtonsActive);
  guiEditor.layerUpButtn.setIsActive(movementButtonsActive);
  guiEditor.layerDnButtn.setIsActive(movementButtonsActive);  
  
  boolean maskTogglerActive = (theScene.getFirstSelectedShape()>=0) && (mainMode == EDIT_WARP);
  guiEditor.maskToggler.setIsActive(maskTogglerActive);
  
  // Update the mode togggler.
  int oldWhichOne = guiEditor.mainModeToggler.whichOne;
  if(guiEditor.mainModeToggler.update(pointerDown, pointerLoc)){
    
    if(guiEditor.mainModeToggler.whichOne == 0){
      mainMode = MAKE_SHAPE;
      if(guiEditor.mainModeToggler.whichOne != oldWhichOne){
        theScene.deselectAllShapes();
      }
    }
    else if(guiEditor.mainModeToggler.whichOne == 1){
      mainMode = MOVE_SHAPE;
      if(guiEditor.mainModeToggler.whichOne != oldWhichOne){
        // Make sure something is selected by default if possible.
        action_activatePreviousSelectShape();
      }
    }
    else if(guiEditor.mainModeToggler.whichOne == 2){
      mainMode = MOVE_VERT;
      if(guiEditor.mainModeToggler.whichOne != oldWhichOne){
        // Make sure something is selected by default if possible.
        action_activatePreviousSelectShape();
      }
    }
    else if(guiEditor.mainModeToggler.whichOne == 3){
      mainMode = EDIT_WARP;
      if(guiEditor.mainModeToggler.whichOne != oldWhichOne){
        // Make sure something is selected by default if possible.
        action_activatePreviousSelectShape();
      }
    }

    return true;    
  }
  
  // Update the save button.
  if(guiEditor.saveButtn.update(pointerDown, pointerLoc)){
    boolean openFile = guiEditor.saveButtn.pressed;
    if(openFile){
      //println("SAVE INVOKED");
      selectOutput("Select data file to save:", "saveFileSelected");
    }
    guiEditor.saveButtn.pressed = false;
    return true;
  }
 
  // Update the load button.
  if(guiEditor.loadButtn.update(pointerDown, pointerLoc)){
    boolean openFile = guiEditor.loadButtn.pressed;
    if(openFile){
      //println("LOAD INVOKED");
      selectInput("Select data file to load:", "loadFileSelected");
    }
    guiEditor.loadButtn.pressed = false;
    return true;
  }
  
  // Update the options buttons.
  if(guiEditor.blipToggler.update(pointerDown, pointerLoc)){return true;}
  if(guiEditor.gridToggler.update(pointerDown, pointerLoc)){return true;}
  if(guiEditor.vertToggler.update(pointerDown, pointerLoc)){return true;}
  if(guiEditor.edgeToggler.update(pointerDown, pointerLoc)){return true;}
  if(guiEditor.fillToggler.update(pointerDown, pointerLoc)){return true;}
  if(guiEditor.maskToggler.update(pointerDown, pointerLoc)){return true;}
  
  // Update the warp bounds button.
  if(guiEditor.fitWarpButtn.update(pointerDown, pointerLoc)){
    boolean doQuickFitWarp = guiEditor.fitWarpButtn.pressed;
    if(doQuickFitWarp){
      if(theScene.getFirstSelectedShape() >= 0){
        theScene.shapes.get(theScene.getFirstSelectedShape()).quickFitWarp();
      }
    }
    guiEditor.fitWarpButtn.pressed = false;
    return true;
  }
  
  
  if(guiEditor.flpXButtn.update(pointerDown, pointerLoc)){
    boolean doFlpWarpX = guiEditor.flpXButtn.pressed;
    if(doFlpWarpX){
      if(theScene.getFirstSelectedShape() >= 0){
        if(mainMode == MOVE_SHAPE){
          theScene.shapes.get(theScene.getFirstSelectedShape()).flipX();
        }
        if(mainMode == EDIT_WARP){
          theScene.shapes.get(theScene.getFirstSelectedShape()).flipWarpX();
        }
      }
    }
    guiEditor.flpXButtn.pressed = false;
    return true;
  }
  if(guiEditor.flpYButtn.update(pointerDown, pointerLoc)){
    boolean doFlpWarpY = guiEditor.flpYButtn.pressed;
    if(doFlpWarpY){
      if(theScene.getFirstSelectedShape() >= 0){
        if(mainMode == MOVE_SHAPE){
          theScene.shapes.get(theScene.getFirstSelectedShape()).flipY();
        }
        if(mainMode == EDIT_WARP){
          theScene.shapes.get(theScene.getFirstSelectedShape()).flipWarpY();
        }
      }
    }
    guiEditor.flpYButtn.pressed = false;
    return true;
  }
  if(guiEditor.rotCCWButtn.update(pointerDown, pointerLoc)){
    boolean doRotWarpCCW = guiEditor.rotCCWButtn.pressed;
    if(doRotWarpCCW){
      if(theScene.getFirstSelectedShape() >= 0){
        if(mainMode == MOVE_SHAPE){
          theScene.shapes.get(theScene.getFirstSelectedShape()).rotCCW();
        }
        if(mainMode == EDIT_WARP){
          theScene.shapes.get(theScene.getFirstSelectedShape()).rotWarpCCW();
        }
      }
    }
    guiEditor.rotCCWButtn.pressed = false;
    return true;
  }
  if(guiEditor.rotCWButtn.update(pointerDown, pointerLoc)){
    boolean doRotWarpCW = guiEditor.rotCWButtn.pressed;
    if(doRotWarpCW){
      if(theScene.getFirstSelectedShape() >= 0){
        if(mainMode == MOVE_SHAPE){
          theScene.shapes.get(theScene.getFirstSelectedShape()).rotCW();
        }
        if(mainMode == EDIT_WARP){
          theScene.shapes.get(theScene.getFirstSelectedShape()).rotWarpCW();
        }
      }
    }
    guiEditor.rotCWButtn.pressed = false;
    return true;
  }
  if(guiEditor.layerUpButtn.update(pointerDown, pointerLoc)){
    boolean doMvUp = guiEditor.layerUpButtn.pressed;
    if(doMvUp){
      if(theScene.getFirstSelectedShape() >= 0){
        int shapeIndex = theScene.getFirstSelectedShape();
        if(shapeIndex< (theScene.shapes.size()-1)){
          ShapeContour tempShape = theScene.shapes.get(shapeIndex + 1);
          theScene.shapes.set(shapeIndex + 1, theScene.shapes.get(shapeIndex));
          theScene.shapes.set(shapeIndex, tempShape);
        }        
      }
    }
    guiEditor.layerUpButtn.pressed = false;
    return true;
  }
  if(guiEditor.layerDnButtn.update(pointerDown, pointerLoc)){
    boolean doMvDn = guiEditor.layerDnButtn.pressed;
    if(doMvDn){
      if(theScene.getFirstSelectedShape() >= 0){
        int shapeIndex = theScene.getFirstSelectedShape();
        if(shapeIndex > 0){
          ShapeContour tempShape = theScene.shapes.get(shapeIndex - 1);
          theScene.shapes.set(shapeIndex - 1, theScene.shapes.get(shapeIndex));
          theScene.shapes.set(shapeIndex, tempShape);
        }
      }
    }
    guiEditor.layerUpButtn.pressed = false;
    return true;
  }
  
  // Update the set image button.
  if(guiEditor.setImgButtn.update(pointerDown, pointerLoc)){
    if(theScene.getFirstSelectedShape() >= 0){
      boolean openFile = guiEditor.setImgButtn.pressed;
      if(openFile){
        selectInput("Select a image or animation file to use:", "imgFileSelected");
      }
    }
    guiEditor.setImgButtn.pressed = false;
    return true;
  }
  
  return false;
}

//----------------------------------------------------------------------------
// Mouse input.
//----------------------------------------------------------------------------
void userInput_mousePressed(){
  final PVector pointerLoc = new PVector(mouseX, mouseY);
  final boolean pointerDown = mousePressed;
  guiEditor.pointerPressLoc = pointerLoc;
  
  boolean guiHandled = userInput_updateGui(pointerDown, pointerLoc);
  if(guiHandled){return;}

  if(mainMode == MAKE_SHAPE){
    if(theScene.getFirstSelectedShape()< 0){
      theScene.shapes.add(new ShapeContour(pointerLoc));
    }else{
      int selectedShapeNum = theScene.getFirstSelectedShape();
      ShapeContour selectedShape = theScene.shapes.get(selectedShapeNum);
      PVector firstVertPos = selectedShape.vertices.get(0).getPos();
      boolean closeEnoughToFirstVertToClose =
        (dist(pointerLoc.x, pointerLoc.y, firstVertPos.x, firstVertPos.y)< 10);
      if(closeEnoughToFirstVertToClose){
        theScene.deselectAllShapes();
      }else{
        selectedShape.turnOffVertexSelection();
        selectedShape.vertices.add(new ShapeVert(pointerLoc, true));
        //constrain(getSelectedVertIndex() + 1, 0, vertices.size()), 
      }
    }
  }else if(mainMode == MOVE_SHAPE){
    theScene.deselectAllShapes();
    for(int i = theScene.shapes.size() - 1; i >= 0; --i){
      if(theScene.shapes.get(i).canSelect(pointerLoc)){
        theScene.shapes.get(i).setIsSelected(true);
        break;
      }
    }
  }else if(mainMode == MOVE_VERT){
    theScene.deselectAllVerts();     
    if(theScene.getFirstSelectedShape() >= 0){
      int selectedShapeNum = theScene.getFirstSelectedShape();
      ShapeContour selectedShape = theScene.shapes.get(selectedShapeNum);
      final int vertIndex = selectedShape.getFirstSelectableVertIndex(pointerLoc);
      if(vertIndex >= 0){
        selectedShape.selectVertByIndex(vertIndex);      
      }
    }else{
      for(int i = 0; i< theScene.shapes.size(); ++i){
        final int vertIndex = theScene.shapes.get(i).getFirstSelectableVertIndex(pointerLoc);
        if(vertIndex >= 0){
          theScene.shapes.get(i).selectVertByIndex(vertIndex);      
          break;
        }
      }
    }
  }else if(mainMode == EDIT_WARP){
    if(theScene.getFirstSelectedShape() >= 0){
      if(mouseButton == LEFT){
        int selectedShapeNum = theScene.getFirstSelectedShape();
        ShapeContour selectedShape = theScene.shapes.get(selectedShapeNum);
        final int warpVertIndex = selectedShape.imgQuad.getFirstSelectableVertIndex(pointerLoc);
        if(warpVertIndex >= 0){
          selectedShape.imgQuad.setVertLoc(warpVertIndex, pointerLoc);
        }
      }
    }
  }
}

void userInput_mouseDragged(){
  if(theScene.getFirstSelectedShape()< 0){return;}
  final PVector pointerLoc = new PVector(mouseX, mouseY);
  PVector pointerDelta = PVector.sub(pointerLoc, guiEditor.pointerPressLoc);
  
  int selectedShapeNum = theScene.getFirstSelectedShape();
  ShapeContour selectedShape = theScene.shapes.get(selectedShapeNum);
  
  if(mainMode == MOVE_SHAPE){
    selectedShape.updatePos(pointerDelta);
  }else if(mainMode == MOVE_VERT){
    final int vertIndex = selectedShape.getSelectedVertIndex();
    if(vertIndex >= 0){
      selectedShape.updateVertexPosition(vertIndex, pointerDelta);
    }
  }else if(mainMode == EDIT_WARP){
    if(mouseButton == LEFT){
      final int warpVertIndex = selectedShape.imgQuad.getFirstSelectableVertIndex(pointerLoc);
      if(warpVertIndex >= 0){
        selectedShape.imgQuad.setVertLoc(warpVertIndex, pointerLoc);
      }
    }
  }
  
  guiEditor.pointerPressLoc = pointerLoc;
}

void userInput_mouseReleased(){
  final PVector pointerLoc = new PVector(mouseX, mouseY);
  final boolean pointerDown = mousePressed;

  boolean guiHandled = userInput_updateGui(pointerDown, pointerLoc);
  if(guiHandled){return;}
}

void userInput_mouseClicked(){
  if(mouseButton == LEFT){
  }else if(mouseButton == RIGHT){
  }else if(mouseButton == CENTER){
    perspectiveAxis = !perspectiveAxis;
  }
}

void userInput_mouseWheel(MouseEvent event){
  if(mainMode != EDIT_WARP){return;}
  if(theScene.getFirstSelectedShape()< 0){return;}
  
  float e = event.getCount();
  if(e == 0){return;}
  
  int selectedShapeNum = theScene.getFirstSelectedShape();
  ShapeContour selectedShape = theScene.shapes.get(selectedShapeNum);
  
  if(perspectiveAxis){
    selectedShape.imgQuad.adjustPerspectiveX(0.01f * e);
  }else{
    selectedShape.imgQuad.adjustPerspectiveY(0.01f * e);
  }
}

//----------------------------------------------------------------------------
// Keyboard input.
//----------------------------------------------------------------------------
//void userInput_keyReleased(KeyEvent e){
void userInput_keyReleased(){
  // We don't need to respond if the mod keys changed.
  if(modShiftJustChanged){
    return;
  }
  if(modControlJustChanged){
    return;
  }
  if(modAltJustChanged){
    return;
  }
  
  boolean shiftDown = modShiftIsPressed;
  boolean controlDown = modControlIsPressed;
  //boolean altDown = modAltIsPressed;// Unused.
  int releasedKeyCode = mostRecentPressedKeyboardButtonEvent;
  char releasedKeyChar = mostRecentTypedCharEvent;
  
  if(releasedKeyChar == '?' || releasedKeyChar == ' '){
    guiEditor.showGui = !guiEditor.showGui;
  }
  if(releasedKeyChar == '1'){
    mainMode = MAKE_SHAPE;
    guiEditor.mainModeToggler.whichOne = 0;
  }
  if(releasedKeyChar == '2'){
    mainMode = MOVE_SHAPE;
    guiEditor.mainModeToggler.whichOne = 1;   
  }
  if(releasedKeyChar == '3'){
    mainMode = MOVE_VERT;
    guiEditor.mainModeToggler.whichOne = 2;
  }
  if(releasedKeyChar == '4'){
    mainMode = EDIT_WARP;
    guiEditor.mainModeToggler.whichOne = 3;
  }

  // Reload shader.
  if((releasedKeyChar == 'r')){
    // Make sure the shaders are loaded.
    WarpShader.loadShaderEffect();  
  }
  
  // Close shape.
  if(releasedKeyChar == ENTER){
    theScene.deselectAllShapes();
  }
  
  // Delete the selected shape or vert.
  if((releasedKeyChar == BACKSPACE ||
      releasedKeyChar == DELETE) ){
    // || (controlDown & (releasedKeyChar == 'x')){
    if(mainMode == MOVE_SHAPE){
      if(theScene.getFirstSelectedShape() >= 0){
        theScene.shapes.remove(theScene.getFirstSelectedShape());
      }
    }else if((mainMode == MAKE_SHAPE) ||(mainMode == MOVE_VERT)){
      if(theScene.getFirstSelectedShape() >= 0){
        int selectedShapeNum = theScene.getFirstSelectedShape();
        ShapeContour selectedShape = theScene.shapes.get(selectedShapeNum);
        int currVert = selectedShape.getSelectedVertIndex();
        if(currVert >= 0){
          selectedShape.removeVertex(currVert);
        }
      }
    }
  }
  
  // Cut, Copy, and Paste Shapes.
  if(controlDown && (releasedKeyCode == 'c'-32)){// Copy
    if(theScene.getFirstSelectedShape() >= 0){
      copiedShapeInfo = new ArrayList<String>();
      theScene.shapes.get(theScene.getFirstSelectedShape()).save(copiedShapeInfo);
    }  
  }
  if(controlDown && (releasedKeyCode == 'x'-32)){ // Cut
    if(theScene.getFirstSelectedShape() >= 0){
      copiedShapeInfo = new ArrayList<String>();
      theScene.shapes.get(theScene.getFirstSelectedShape()).save(copiedShapeInfo);
      theScene.shapes.remove(theScene.getFirstSelectedShape());
    }
  }
  if(controlDown && (releasedKeyCode == 'v'-32)){// Paste
    if(copiedShapeInfo != null){
      theScene.deselectAllShapes();
      // The trick iimediately below works since in Java strings are immutable.
      ArrayList<String> comsumableShapeInfo = new ArrayList<String>(copiedShapeInfo);
      ShapeContour newPolygon = new ShapeContour(comsumableShapeInfo);
      theScene.shapes.add(newPolygon);
      if(shiftDown){// Move it under the cursor?
        final PVector centroid = newPolygon.getCentroid();
        final PVector pointerLoc = new PVector(mouseX, mouseY);
        final PVector pointerDelta = PVector.sub(pointerLoc, centroid);
        newPolygon.updatePos(pointerDelta);
      }
      theScene.shapes.get(theScene.shapes.size() - 1).setIsSelected(true);
    }
  }
  
  // Change layer positon of shapes.
  if(mainMode == MOVE_SHAPE){
    if(releasedKeyChar == 'i'){//KeyEvent.VK_PAGE_UP){
      if(theScene.getFirstSelectedShape() >= 0){
        int shapeIndex = theScene.getFirstSelectedShape();
        if(shapeIndex< (theScene.shapes.size()-1)){
          ShapeContour tempShape = theScene.shapes.get(shapeIndex + 1);
          theScene.shapes.set(shapeIndex + 1, theScene.shapes.get(shapeIndex));
          theScene.shapes.set(shapeIndex, tempShape);
        }
      }    
    }
    if(releasedKeyChar == 'k'){//KeyEvent.VK_PAGE_DOWN){
      if(theScene.getFirstSelectedShape() >= 0){
        int shapeIndex = theScene.getFirstSelectedShape();
        if(shapeIndex > 0){
          ShapeContour tempShape = theScene.shapes.get(shapeIndex - 1);
          theScene.shapes.set(shapeIndex - 1, theScene.shapes.get(shapeIndex));
          theScene.shapes.set(shapeIndex, tempShape);
        }
      }
    }
  }
  
  // Cycle forward? (for shapes or verts)
  if(!shiftDown & (releasedKeyChar == TAB)){
    if(mainMode != MOVE_VERT){
      action_selectedShapeNext();
    }else{
      action_selectVertNext(theScene.getFirstSelectedShape());
    }
  }
  
  // Cycle backward? (for shapes or verts)
  if(shiftDown & (releasedKeyChar == TAB)){
    if(mainMode != MOVE_VERT){
      action_selectedShapePrev();
    }else{
      action_selectVertPrev(theScene.getFirstSelectedShape());
    }
  }
  
  // Make sure down states get updated.
  final PVector pointerLoc = new PVector(mouseX, mouseY);
  final boolean pointerDown = false;
  userInput_updateGui(pointerDown, pointerLoc);  
}

//void userInput_keyPressed(KeyEvent e){
void userInput_keyPressed(){
  boolean shiftDown = modShiftIsPressed;
  //boolean controlDown = modControlIsPressed;// Unused.
  //boolean altDown = modAltIsPressed;// Unused.
  int pressedKeyCode = mostRecentPressedKeyboardButtonEvent;
  char pressedKeyChar = mostRecentTypedCharEvent;
  
  /*
  // Draw a cicle to indicate control is down.
  if(controlDown){
    final float rateMsF = 500.0f;
    float portion = (millis()%(int(rateMsF)))/rateMsF;
    final float maxSize = max(width, height); 
    float radius  = 0.1f * maxSize * portion;
    stroke(255 * (1.0f - portion));
    noFill();
    ellipse(0, 0, radius, radius);
  }
  */ 
  
  // Nudge a shape of a vert?
  if (pressedKeyChar == CODED){
    if(  (pressedKeyCode == LEFT) ||
         (pressedKeyCode == RIGHT) ||
         (pressedKeyCode == UP) ||
         (pressedKeyCode == DOWN)){ 
      //println(  "NUDGE releasedKeyCode="+pressedKeyCode+
      //          " \tkey="+int(pressedKeyChar)+
      //          " \ttype="+pressedKeyChar+
      //          "\tshift="+(shiftDown?"true":"false")); 
      if(theScene.getFirstSelectedShape()< 0){return;}
      
      int selectedShapeNum = theScene.getFirstSelectedShape();
      ShapeContour selectedShape = theScene.shapes.get(selectedShapeNum);
      
      final float moveAmount = shiftDown?10.0f:1.0f;
      final float leftNudge = ((pressedKeyCode == LEFT)?0.0f:moveAmount);
      final float rightNudge = ((pressedKeyCode == RIGHT)?0.0f:moveAmount);
      final float upNudge = ((pressedKeyCode == UP)?0.0f:moveAmount);
      final float downNudge = ((pressedKeyCode == DOWN)?0.0f:moveAmount);
      final PVector nudgeDelta = new PVector( (0.0f + leftNudge - rightNudge),
                                              (0.0f + upNudge - downNudge));
    
      if(mainMode == MOVE_SHAPE){
        selectedShape.updatePos(nudgeDelta);
      }else if(mainMode == MOVE_VERT){
        final int vertIndex = selectedShape.getSelectedVertIndex();
        if(vertIndex >= 0){
          selectedShape.updateVertexPosition(vertIndex, nudgeDelta);
        }
      }else if(mainMode == EDIT_WARP){
        selectedShape.updateWarpPos(nudgeDelta);
      }
    }
  }
}


//----------------------------------------------------------------------------
// Handle OS dialog interaction callbacks.
//----------------------------------------------------------------------------
// Called automatically by the call to selectOutput above.
void saveFileSelected(File selection){
  if (selection == null){
    //println("Window was closed or the user hit cancel.");
  }else{
    //println("User selected save " + selection.getAbsolutePath());
    theScene.save(selection.getAbsolutePath());
  }
  
  // Make sure down states get updated.
  final PVector pointerLoc = new PVector(mouseX, mouseY);
  final boolean pointerDown = false;
  userInput_updateGui(pointerDown, pointerLoc);    
}

// Called automatically by the call to selectInput above.
void loadFileSelected(File selection){
  if(selection == null){
    //println("Window was closed or the user hit cancel.");
  }else{
    //println("User selected load " + selection.getAbsolutePath());
    theScene = new Scene(selection.getAbsolutePath());
  }
  
  // Make sure down states get updated.
  final PVector pointerLoc = new PVector(mouseX, mouseY);
  final boolean pointerDown = false;
  userInput_updateGui(pointerDown, pointerLoc);  
}

// Called automatically by the call to selectInput above.
void imgFileSelected(File selection){
  if(selection == null){
    //println("Window was closed or the user hit cancel.");
  }else{
    //println("User selected img " + selection.getAbsolutePath());
    if(theScene.getFirstSelectedShape() >= 0){
      cursor(WAIT);
      RequestGarbageCleanup();
      int selectedShapeNum = theScene.getFirstSelectedShape();
      ShapeContour selectedShape = theScene.shapes.get(selectedShapeNum);
      selectedShape.setWarpQuad(selection.getAbsolutePath());
    }
  }
  
  // Make sure down states get updated.
  final PVector pointerLoc = new PVector(mouseX, mouseY);
  final boolean pointerDown = false;
  userInput_updateGui(pointerDown, pointerLoc);  
}

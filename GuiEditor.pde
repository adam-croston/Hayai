final int GuiElementSafeZone = 30;

class GuiEditor{
  //--------------------------------------------------------------------------
  // CREATION/SAVE/LOAD
  GuiEditor(){
      buttonMinSpace = width/200.0f;
  
      font = createFont("Arial", 11);
      textFont(font);
      pointerPressLoc = new PVector(0.0f, 0.0f);
    
      // Make the gui elelments.
      allElements = new ArrayList<GuiElement>();
      
      // Top row of elements... 
      
      // Main mode togger.
      ArrayList<String> multiToggleOptions = new ArrayList<String>();
      multiToggleOptions.add("MAKE_SHAPE");
      multiToggleOptions.add("MOVE_SHAPE");  
      multiToggleOptions.add("MOVE_VERT");
      multiToggleOptions.add("EDIT_WARP");
      mainModeToggler = new GuiMultiToggle(new PVector(width * 3 / 12, GuiElementSafeZone), multiToggleOptions, 0);
      allElements.add(mainModeToggler);
      
      // Shape and warp adjust buttons.
      setImgButtn = new GuiButton(new PVector(width * 10 / 24, GuiElementSafeZone), "SET IMAGE", false);
      allElements.add(setImgButtn);
      fitWarpButtn = new GuiButton(new PVector(setImgButtn.getRightEdge() + buttonMinSpace * 2.0f, GuiElementSafeZone), "FIT WARP", false);
      allElements.add(fitWarpButtn);
      flpXButtn = new GuiButton(new PVector(fitWarpButtn.getRightEdge() + buttonMinSpace, GuiElementSafeZone), "fX", false);
      allElements.add(flpXButtn);
      flpYButtn = new GuiButton(new PVector(flpXButtn.getRightEdge() + buttonMinSpace, GuiElementSafeZone), "fY", false);
      allElements.add(flpYButtn);
      rotCCWButtn = new GuiButton(new PVector(flpYButtn.getRightEdge() + buttonMinSpace, GuiElementSafeZone), "rR", false);
      allElements.add(rotCCWButtn);
      rotCWButtn = new GuiButton(new PVector(rotCCWButtn.getRightEdge() + buttonMinSpace, GuiElementSafeZone), "rL", false);
      allElements.add(rotCWButtn);
      layerUpButtn = new GuiButton(new PVector(rotCWButtn.getRightEdge() + buttonMinSpace, GuiElementSafeZone), "Up", false);
      allElements.add(layerUpButtn);
      layerDnButtn = new GuiButton(new PVector(layerUpButtn.getRightEdge() + buttonMinSpace, GuiElementSafeZone), "Dn", false);
      allElements.add(layerDnButtn);

      // Scene Save/Load.
      saveButtn = new GuiButton(new PVector(width * 5 / 6, GuiElementSafeZone), "SAVE SCENE", true);
      allElements.add(saveButtn);
      loadButtn = new GuiButton(new PVector(saveButtn.getRightEdge() + buttonMinSpace, GuiElementSafeZone), "LOAD SCENE", true);
      allElements.add(loadButtn);
      
      // Bottom row of elements...
      blipToggler = new GuiABToggle(new PVector(width * 1 / 7, height - GuiElementSafeZone), "BLIP", "NO BLIP", false, true);   
      allElements.add(blipToggler);
      gridToggler = new GuiABToggle(new PVector(width * 2 / 7, height - GuiElementSafeZone), "GRID", "NO GRID", false, true);
      allElements.add(gridToggler);
      vertToggler = new GuiABToggle(new PVector(width * 3 / 7, height - GuiElementSafeZone), "VERT", "NO VERT", true, true);
      allElements.add(vertToggler);
      edgeToggler = new GuiABToggle(new PVector(width * 4 / 7, height - GuiElementSafeZone), "EDGE", "NO EDGE", true, true);   
      allElements.add(edgeToggler);
      fillToggler = new GuiABToggle(new PVector(width * 5 / 7, height - GuiElementSafeZone), "FILL", "NO FILL", true, true);
      allElements.add(fillToggler);
      maskToggler = new GuiABToggle(new PVector(width * 6 / 7, height - GuiElementSafeZone), "MASK", "NO MASK", true, false);   
      allElements.add(maskToggler);
  }
  
  //--------------------------------------------------------------------------
  // DISPLAY
  void displayPreScene(){
    // Draw the grid?
    if(showGui && gridToggler.whichOne){
      drawGrid();
    }
  }  
  void displayPostScene(){
    if(!showGui){
      noCursor();
      return;
    }
    
    // Mouse coord display.
    /*
    {
      pushStyle();
        fill(255);
        textAlign(LEFT, CENTER);
        float xPos = layerDnButtn.getRightEdge() + buttonMinSpace;
        if(  theScene.getFirstSelectedShape() >= 0 &&
            theScene.shapes.get(theScene.getFirstSelectedShape()).getSelectedVertIndex() >= 0){
            int selectedShapeNum = theScene.getFirstSelectedShape();
            ShapeContour selectedShape = theScene.shapes.get(selectedShapeNum);
          PVector tempLoc = selectedShape.vertices.get(selectedShape.getSelectedVertIndex()).getPos();
          text(  "Selected Vertex: " + constrain((int) tempLoc.x, 0, width) + ", " +
                 constrain((int) tempLoc.y, 0, height) +
                 "\nMouse: " + constrain(mouseX, 0, width) + ", " +
                 constrain(mouseY, 0, height), xPos, GuiElementSafeZone);
        }else{
          text("Mouse: " + constrain(mouseX, 0, width) + ", " +
                constrain(mouseY, 0, height), xPos, GuiElementSafeZone);
        }
      popStyle();
    }
    */
    
    // Memory status display.
    {
      // From http://stackoverflow.com/questions/29716330/java-library-for-tracking-java-heap-size
      // and  http://stackoverflow.com/questions/3571203/
      //  what-is-the-exact-meaning-of-runtime-getruntime-totalmemory-and-freememory
      final int mb = 1024*1024;
      
      // Maximum heap size:
      long hMaxSize = Runtime.getRuntime().maxMemory();
      
      // Current heap size (it can grow until the allowed maximum is reached):
      long hCurrentSize = Runtime.getRuntime().totalMemory();
    
      // How much of the current heap size is ready for new objects:
      long hReadySize = Runtime.getRuntime().freeMemory();
      
      // How much of the current heap is being used by active objects.
      long hUsedMem = hCurrentSize - hReadySize;
      
      // How much of the maximum heap is actually being used by active objects.
      long hFreeMem = hMaxSize - hUsedMem;
      
      float freeMemPct = 100.0f * ((float)hFreeMem / (float)(hMaxSize));
      
      pushStyle();    
        fill(255);
        textAlign(LEFT, CENTER);
        float xPos = layerDnButtn.getRightEdge() + buttonMinSpace;
        text("FreeMem%: " + freeMemPct , xPos, GuiElementSafeZone);
      popStyle();
    }  
    
    // Gui elemets drawn last so over everythings else.
    for(int i = 0; i< allElements.size(); ++i){
      allElements.get(i).display();
    }
    /*
    mainModeToggler.display();
    saveButtn.display();
    loadButtn.display();
    blipToggler.display(); 
    gridToggler.display();
    vertToggler.display();
    edgeToggler.display();
    fillToggler.display();
    maskToggler.display();
    fitWarpButtn.display();
    flpXButtn.display();
    flpYButtn.display();
    rotCCWButtn.display();
    rotCWButtn.display();
    layerUpButtn.display();
    layerDnButtn.display();
    setImgButtn.display();
    */
    
    // Draw the blip?
    if(blipToggler.whichOne){
      final float rateMsF = 500.0f;
      float portion = (millis()%(int(rateMsF)))/rateMsF;
      final float maxSize = max(width, height); 
      float radius  = 0.1f * maxSize * portion;
      stroke(255 * (1.0f - portion));
      strokeWeight(10);  // Beastly
      noFill();
      ellipse(mouseX, mouseY, radius, radius);
      strokeWeight(1);
    } 

    // Set the 2d mouse cursor type.
    if(mainMode == MAKE_SHAPE){
      cursor(CROSS);     
    }else if(mainMode == MOVE_SHAPE){
      cursor(MOVE);
    }else if(mainMode == MOVE_VERT){
      cursor(HAND);
    }else if(mainMode == EDIT_WARP){
      cursor(ARROW);
    }
  }
  void drawGrid(){
    pushStyle();
      stroke(255, 51);
      int off = 0;
      int spacing = 10;
      for(int i = 0; i<= max(width, height); i += spacing){
        line(i, 0, i, height);
        line(0, i, width +(i == max(width, height) ? 1 : 0), i);
      }
     popStyle();
  }  
    
  PFont font;
  PVector pointerPressLoc;
  boolean showGui = true;
  float buttonMinSpace;
  
  // Convenient array of all the elements (makes iterating over all of
  // them easier).
  ArrayList<GuiElement> allElements;

  // Named individual elements.
  GuiMultiToggle mainModeToggler;
  GuiButton saveButtn;
  GuiButton loadButtn;
  GuiABToggle blipToggler;
  GuiABToggle gridToggler;
  GuiABToggle vertToggler;
  GuiABToggle edgeToggler;
  GuiABToggle fillToggler;
  GuiABToggle maskToggler;
  GuiButton fitWarpButtn;
  GuiButton flpXButtn;
  GuiButton flpYButtn;
  GuiButton rotCCWButtn;
  GuiButton rotCWButtn;
  GuiButton layerUpButtn;
  GuiButton layerDnButtn;
  GuiButton setImgButtn;
};

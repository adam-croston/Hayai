class Scene{
  //--------------------------------------------------------------------------
  // CREATION/SAVE/LOAD
  Scene(){
    // Make the shapes list.
    shapes = new ArrayList<ShapeContour>();
    
    // Make sure the shaders are loaded.
    WarpShader.loadShaderEffect();
  }
  Scene(String fileName){
    // Load the file into an array list of strings.
    String stringsArray[] = loadStrings(fileName);
    ArrayList<String> loadInfo = new ArrayList<String>(Arrays.asList(stringsArray));
   
    // Make the shapes list.
    shapes = new ArrayList<ShapeContour>();
    
    // Load up all the shapes.
    int numShapes = int(loadInfo.remove(0));
    for(int i = 0; i< numShapes; ++i){
      ShapeContour tempShape = new ShapeContour(loadInfo);
      shapes.add(tempShape);
    }
  }
  void save(String fileName){
    // Describe the scene as an array list of strings.
    ArrayList<String> saveInfo = new ArrayList<String>();
    
    // Save all the shapes.
    int numShapes = shapes.size();
    saveInfo.add(str(numShapes));
    for(int i = 0; i< numShapes; ++i){
      shapes.get(i).save(saveInfo);       
    }
    
    // Save the array list of strings as a file.
    String data[] = new String[saveInfo.size()];
    data = (String [])saveInfo.toArray(data);
    //String[] data = saveInfo.toArray(new String[saveInfo.size()]);
    saveStrings(fileName, data);
  }
  
  //--------------------------------------------------------------------------
  // SELECTION
  int getFirstSelectedShape(){
    for(int i = 0; i< shapes.size(); ++i){
      if(shapes.get(i).getIsSelected()){
        return i;
      }
    }
    return -1;
  }
  
  void deselectAllShapes(){
    // Potentially update what the old active shape was.
    if(theScene.getFirstSelectedShape() >= 0){
      theScene.oldSelectedShape = theScene.getFirstSelectedShape();
    }else{
      if(  (theScene.oldSelectedShape >= 0) &&
           (theScene.oldSelectedShape< shapes.size())){
        // Keep it around.
      }else{
         theScene.oldSelectedShape = -1;
      }
    }
    
    for(int i = 0; i< shapes.size(); ++i){
      shapes.get(i).setIsSelected(false);
    }
  }
  void deselectAllVerts(){
    for(int i = 0; i< shapes.size(); ++i){
      shapes.get(i).turnOffVertexSelection();
    }
  }
  
  //--------------------------------------------------------------------------
  // DISPLAY
  void display(){
    // Show all the shapes.
    if(  (mainMode == MAKE_SHAPE) ||
         (mainMode == MOVE_SHAPE) ||
         (mainMode == MOVE_VERT) ||
         ((mainMode == EDIT_WARP) && (guiEditor.maskToggler.whichOne))){
      for(int i = 0; i< theScene.shapes.size(); ++i){
        if(!guiEditor.showGui){
          theScene.shapes.get(i).displayShape(false, false, true, (mainMode == MAKE_SHAPE));
        }else{
          theScene.shapes.get(i).displayShape(  guiEditor.vertToggler.whichOne,
                                                guiEditor.edgeToggler.whichOne,
                                                guiEditor.fillToggler.whichOne,
                                                (mainMode == MAKE_SHAPE));
        }
      } 
    }else if((mainMode == EDIT_WARP) && (!guiEditor.maskToggler.whichOne)){
      if(guiEditor.showGui){
        if(theScene.getFirstSelectedShape() >= 0){
          theScene.shapes.get(theScene.getFirstSelectedShape()).displayWarpQuad();
        }
      }else{
        for(int i = 0; i< theScene.shapes.size(); ++i){
          theScene.shapes.get(i).displayShape(false, false, true, (mainMode == MAKE_SHAPE));
        }
      }
    }
    
    // Draw the line from the last active vert to the cursor.
    if(  (mainMode == MAKE_SHAPE) &&
         (theScene.getFirstSelectedShape() >= 0) &&
         (theScene.shapes.get(theScene.getFirstSelectedShape()).getSelectedVertIndex() >= 0)){
      pushStyle();
        int selectedShapeNum = theScene.getFirstSelectedShape();
        ShapeContour selectedShape = theScene.shapes.get(selectedShapeNum);
        int selectedVertNum = selectedShape.getSelectedVertIndex();
        ShapeVert selectedVert = selectedShape.vertices.get(selectedVertNum);
        PVector currVertPos = selectedVert.getPos();
        float x1 = currVertPos.x;
        float y1 = currVertPos.y;
        float x2 = mouseX;
        float y2 = mouseY;
        stroke(255,255,0,255);
        strokeWeight(1);
        noFill();     
        line(x1, y1, x2, y2);        
      popStyle();   
    }
  }
  
  
    
  ArrayList<ShapeContour> shapes;
  int oldSelectedShape = -1;
};

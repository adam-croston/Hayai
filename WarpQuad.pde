//----------------------------------------------------------------------------
// This reperesents the image and the presepective "keystone" correction to
// apply to the image.
//
// TODO: Sliders for perspective warping amounts.
// TODO: Prevent quad from ever being degenerate.
// TODO: Make span acrsoss image plane.
// TODO: Support for texture translation, rotation, and tiling within the
//       warp.
// TODO: Nicer edge display and make it play better with shape display.
//----------------------------------------------------------------------------

final float maxDistVertGrabDist = 200.0f;

class WarpQuad{  
  //--------------------------------------------------------------------------
  // CREATION/SAVE/LOAD
  
  WarpQuad(  String fileName,
             PVector vA, PVector vB, PVector vC, PVector vD,
             float perspectiveX, float perspectiveY){
    setImgFile(fileName);
    setVerts(vA, vB, vC, vD);
    setPerspective(perspectiveX, perspectiveY);
  }
  WarpQuad(WarpQuad otherWarpQuad){
    imgSrc = otherWarpQuad.imgSrc;
    vertA = new PVector(otherWarpQuad.vertA.x, otherWarpQuad.vertA.y, otherWarpQuad.vertA.z);
    vertB = new PVector(otherWarpQuad.vertB.x, otherWarpQuad.vertB.y, otherWarpQuad.vertB.z);
    vertC = new PVector(otherWarpQuad.vertC.x, otherWarpQuad.vertC.y, otherWarpQuad.vertC.z);
    vertD = new PVector(otherWarpQuad.vertD.x, otherWarpQuad.vertD.y, otherWarpQuad.vertD.z);
    pX = otherWarpQuad.pX;
    pY = otherWarpQuad.pY;
  }
  WarpQuad(ArrayList<String> loadInfo){
    // Determine what the image file was.
    imgSrc = new ImageSource(loadInfo);
    
    // Load up all the verts (only load the 2D portion)..
    PVector vA = new PVector(float(loadInfo.remove(0)), float(loadInfo.remove(0)), 0.0f);
    PVector vB = new PVector(float(loadInfo.remove(0)), float(loadInfo.remove(0)), 0.0f);
    PVector vC = new PVector(float(loadInfo.remove(0)), float(loadInfo.remove(0)), 0.0f);
    PVector vD = new PVector(float(loadInfo.remove(0)), float(loadInfo.remove(0)), 0.0f);
    setVerts(vA, vB, vC, vD);
    
    // Load up the perspective warp info.
    setPerspective(float(loadInfo.remove(0)), float(loadInfo.remove(0)));
  }
  void save(ArrayList<String> saveInfo){
    // Save what the image file was.
    imgSrc.save(saveInfo);
    
    // Save all the verts (only save the 2D portion).
    saveInfo.add(str(vertA.x)); saveInfo.add(str(vertA.y));
    saveInfo.add(str(vertB.x)); saveInfo.add(str(vertB.y));
    saveInfo.add(str(vertC.x)); saveInfo.add(str(vertC.y));
    saveInfo.add(str(vertD.x)); saveInfo.add(str(vertD.y));
    
    // Save the perspective warp info.
    saveInfo.add(str(getPerspectiveX()));
    saveInfo.add(str(getPerspectiveY()));
  }
    
  //--------------------------------------------------------------------------
  // SELECTION
  
  // Algorithm from:
  // https://books.google.com/books?id=WGpL6Sk9qNAC&pg=PA60&lpg=PA60&
  //dq=detect+degenerate+quad&source=bl&ots=Pn0PpL2giP&sig=FAytJKe_xx4E9pfEJOZByVaCqhw&hl=en&sa=X&
  //ved=0CB4Q6AEwAGoVChMIgeze1O6FxgIVii2ICh0wZQCf#v=onepage&q=detect%20degenerate%20quad&f=false
  boolean isQuadConvex(PVector vA, PVector vB, PVector vC, PVector vD){
    // Set up some deltas to make the math easier.
    PVector bd = PVector.sub(vD, vB);
    PVector ba = PVector.sub(vA, vB);
    PVector bc = PVector.sub(vC, vB);
    
    // Quad is nonconvex if Dot(Cross(ba, ba), Cross(bd, bc)) >= 0.
    PVector bda = bd.cross(ba);
    PVector bdc = bd.cross(bc);
    if(PVector.dot(bda, bdc) >= 0.0f){return false;}
    
    // Quad is now convex iff Dot(Cross(ac, ad), Cross(ac, ab))< 0.
    PVector ac = PVector.sub(vC, vA);
    PVector ad = PVector.sub(vD, vA);
    PVector ab = PVector.sub(vB, vA);
    PVector acd = ac.cross(ad);
    PVector acb = ac.cross(ab);
    return (PVector.dot(acd, acb)< 0.0f);
  }
  int getFirstSelectableVertIndex(PVector pointerLoc){
    // Determine which vert the cursor is closest to.
    int closestVertNum = -1;// SentinelValue
    float closestVertDist = 10000.0f;// SentinelValue
    if(PVector.dist(vertA, pointerLoc)<= closestVertDist){
      closestVertDist = PVector.dist(vertA, pointerLoc); closestVertNum = 0;
    }
    if(PVector.dist(vertB, pointerLoc)<= closestVertDist){
      closestVertDist = PVector.dist(vertB, pointerLoc); closestVertNum = 1;
    }
    if(PVector.dist(vertC, pointerLoc)<= closestVertDist){
      closestVertDist = PVector.dist(vertC, pointerLoc); closestVertNum = 2;
    }
    if(PVector.dist(vertD, pointerLoc)<= closestVertDist){
      closestVertDist = PVector.dist(vertD, pointerLoc); closestVertNum = 3;
    }

    // If we couldn't determine which vert was closest or we're too far away
    // then don't update any verts.
    if((closestVertNum< 0) || (closestVertDist >= maxDistVertGrabDist)){
      return -1;
    }else{
      return closestVertNum;
    }
  }

  //--------------------------------------------------------------------------
  // ADJUSTMENT
  
  void setImgFile(String fileName){
    imgSrc = new ImageSource(fileName);
  }
  void setImageSource(ImageSource imageSrc){
    imgSrc = imageSrc;
  }
  PImage getImage(){
    return imgSrc.getImage();
  }
    
  void setVerts(PVector vA, PVector vB, PVector vC, PVector vD){
    vertA = new PVector(vA.x, vA.y, 0.0f);
    vertB = new PVector(vB.x, vB.y, 0.0f);
    vertC = new PVector(vC.x, vC.y, 0.0f);
    vertD = new PVector(vD.x, vD.y, 0.0f);
  }
  PVector getVertA(){return vertA;}
  PVector getVertB(){return vertB;}
  PVector getVertC(){return vertC;}
  PVector getVertD(){return vertD;}
  boolean setVertLoc(int vertIndex, PVector loc){
    // If it doesn't mess up the quad (make it non-convex) then update the
    // closest warp vert position.
    if(vertIndex == 0){
      if(!isQuadConvex(loc, vertB, vertC, vertD)){ return false; }
      else{
        vertA.x = loc.x; vertA.y = loc.y;
        return true;
      }
    }else if(vertIndex == 1){
      if(!isQuadConvex(vertA, loc, vertC, vertD)){ return false; }
      else{
        vertB.x = loc.x; vertB.y = loc.y;
        return true;
      }
    }else if(vertIndex == 2){
      if(!isQuadConvex(vertA, vertB, loc, vertD)){ return false; }
      else{
        vertC.x = loc.x; vertC.y = loc.y;
        return true;
      }
    }else if(vertIndex == 3){
      if(!isQuadConvex(vertA, vertB, vertC, loc)){ return false; }
      else{
        vertD.x = loc.x; vertD.y = loc.y;
        return true;
      }
    }else{
      // Shouldn't ever get here, but for safety keep this line.
      return false;
    }
  }
  void updatePos(PVector delta){
    vertA = PVector.add(vertA, delta); 
    vertB = PVector.add(vertB, delta); 
    vertC = PVector.add(vertC, delta); 
    vertD = PVector.add(vertD, delta); 
  }
  void flipX(PVector center){
    PVector verts[] = new PVector[4];
    verts[0] = getVertA();
    verts[1] = getVertB();
    verts[2] = getVertC();
    verts[3] = getVertD();
    for(int i = 0; i< 4; ++i){
      verts[i] = PVector.sub(verts[i], center);
      verts[i].x = verts[i].x * -1.0;
      verts[i] = PVector.add(verts[i], center);
    }
    setVerts(verts[0], verts[1], verts[2], verts[3]);
    /*
     PVector vA = getVertB();
     PVector vB = getVertA();
     PVector vC = getVertD();
     PVector vD = getVertC();
       
     setVerts(vA, vB, vC, vD); 
     */
  }
  void flipY(PVector center){
    PVector verts[] = new PVector[4];
    verts[0] = getVertA();
    verts[1] = getVertB();
    verts[2] = getVertC();
    verts[3] = getVertD();
    for(int i = 0; i< 4; ++i){
      verts[i] = PVector.sub(verts[i], center);
      verts[i].y = verts[i].y * -1.0;
      verts[i] = PVector.add(verts[i], center);
    }
    setVerts(verts[0], verts[1], verts[2], verts[3]);
    /*
     PVector vA = getVertD();
     PVector vB = getVertC();
     PVector vC = getVertB();
     PVector vD = getVertA();
       
     setVerts(vA, vB, vC, vD);
    */
  }
  void rotCCW(PVector center, float rotRads){
    PVector verts[] = new PVector[4];
    verts[0] = getVertA();
    verts[1] = getVertB();
    verts[2] = getVertC();
    verts[3] = getVertD();
    for(int i = 0; i< 4; ++i){
      verts[i] = PVector.sub(verts[i], center);
      rotate2D(verts[i], rotRads);
      verts[i] = PVector.add(verts[i], center);
    }
    setVerts(verts[0], verts[1], verts[2], verts[3]);
    /*
     PVector vA = getVertD();
     PVector vB = getVertA();
     PVector vC = getVertB();
     PVector vD = getVertC();
     
     setVerts(vA, vB, vC, vD);
     */
  }
  void rotCW(PVector center, float rotRads){
    PVector verts[] = new PVector[4];
    verts[0] = getVertA();
    verts[1] = getVertB();
    verts[2] = getVertC();
    verts[3] = getVertD();
    for(int i = 0; i< 4; ++i){
      verts[i] = PVector.sub(verts[i], center);
      rotate2D(verts[i], rotRads);
      verts[i] = PVector.add(verts[i], center);
    }
    setVerts(verts[0], verts[1], verts[2], verts[3]);
    /*
    PVector vA = getVertB();
     PVector vB = getVertC();
     PVector vC = getVertD();
     PVector vD = getVertA();
       
     setVerts(vA, vB, vC, vD); 
     */
  }

  void setPerspective(float x, float y){
    pX = max(x, 0.01f);
    pY = max(y, 0.01f);
  }
  float getPerspectiveX(){
    return pX;
  }
  float getPerspectiveY(){
    return pY;
  }  
  void adjustPerspectiveX(float delta){
    pX = max(pX + delta, 0.01f);
  }
  void adjustPerspectiveY(float delta){
    pY = max(pY + delta, 0.01f);
  }
    
  //--------------------------------------------------------------------------
  // DISPLAY
  
  void applyShaderForWarp(){
    WarpShader.applyShaderEffect(float(width), float(height), vertA, vertB, vertC, vertD, pX, pY);
  }
  
  void display(){
    pushStyle();
      applyShaderForWarp();
      textureMode(NORMAL);
      beginShape();
      noStroke();
      fill(0);    
      texture(imgSrc.getImage());
      vertex(0.0f,  0.0f,    0.0f, 0.0f, 0.0f);
      vertex(width, 0.0f,    0.0f, 1.0f, 0.0f);
      vertex(width, height,  0.0f, 1.0f, 1.0f);
      vertex(0.0f,  height,  0.0f, 0.0f, 1.0f);
      endShape(CLOSE);
      resetShader();
    popStyle();
    
    if(true){//showVerts){
      PVector verts[] = new PVector[4];
      verts[0] = getVertB();
      verts[1] = getVertC();
      verts[2] = getVertD();
      verts[3] = getVertA();
      
    final float maxSize = max(width, height); 
    float radius  = 0.01f * maxSize;

      pushStyle();
        for(int i = 0; i< 4; ++i){
          if(false){//isSelected){
            fill(255, 0, 0, 102);// Dark red.
            noStroke();
            ellipse(verts[i].x, verts[i].y, radius, radius);
          }
          noStroke();
          fill(255);
          ellipse(verts[i].x, verts[i].y, radius * 0.5f, radius * 0.5f);
        }
      popStyle();  
    }
  }
  
  ImageSource imgSrc;
  PVector vertA;
  PVector vertB;
  PVector vertC;
  PVector vertD;
  float pX;
  float pY;
};

//----------------------------------------------------------------------------
// These are the gui elements that can be presented to the user.
//
// TODO: Better code re-use
// TODO: Less code in the main loop.
// TODO: Sliders (for perspective warping amounts).
// TODO: Make the MultiToggle able to turn on/off options.
//----------------------------------------------------------------------------

final int edgePadding = 6;
final int selectedValue = 255;
final int unselectedValue = 160;
final int grayedValue = 60;


//----------------------------------------------------------------------------
// This represents a generic gui element.
//----------------------------------------------------------------------------
class GuiElement{
  GuiElement(PVector pos, float rectWidth, float rectHeight, boolean active){
    loc = pos;
    hitRectWidth = rectWidth;
    hitRectHeight = rectHeight;
    isActive = active;
    
    down = false;
    downPrev = false;
    pressed = false;  
  }
  
  boolean update(boolean pointerDown, PVector pointerLoc){ 
    downPrev = down;
    down = false;
    if(pointerDown &&
        pointerLoc.x > loc.x - hitRectWidth / 2 &&
        pointerLoc.x< loc.x + hitRectWidth / 2 &&
        pointerLoc.y > loc.y - hitRectHeight / 2 &&
        pointerLoc.y< loc.y + hitRectHeight / 2){
      down = true;
    }else{
      return false;
    }
    
    pressed = false;
    if(!isActive){
      return down; 
    }
    if(down && !downPrev){
      pressed = true;
    }

    return true;
  } 
  void display(){
;
  }
  void setIsActive(boolean active){
    isActive = active;
    if(!isActive){
     down = false;
     downPrev = false;
     pressed = false;
    }
  }
  
  float getRightEdge(){
    return (loc.x + hitRectWidth);
  }
  
  PVector loc;
  float hitRectWidth;
  float hitRectHeight;
  boolean isActive;
  boolean down;
  boolean downPrev;
  boolean pressed; 
};


//----------------------------------------------------------------------------
// This represents an onscreen button.
//----------------------------------------------------------------------------
class GuiButton extends GuiElement{
  
  GuiButton(PVector pos, String text, boolean active){
    super(pos, edgePadding + textWidth(text) + edgePadding, 10 + textAscent(), active);
    label = text; 
  }
  
  @Override
  void display(){
    pushStyle();
      float leftEdge = loc.x - hitRectWidth / 2;
      float topEdge = loc.y - hitRectHeight / 2;
      if(isActive){stroke(selectedValue);}
      else{stroke(grayedValue);}
      fill(0);      
      rect(leftEdge, topEdge, hitRectWidth, hitRectHeight);
      textAlign(CENTER, CENTER);

      if(!isActive){
        fill(grayedValue);
      }else{
        if(pressed){
          fill(selectedValue);
        }else{
            fill(unselectedValue);
        }
      }
      text(label, leftEdge + edgePadding + textWidth(label)/2, loc.y - 1);
    popStyle();
  }
  
  String label; 
}

//----------------------------------------------------------------------------
// This represents an onscreen toggle.
//----------------------------------------------------------------------------
class GuiABToggle extends GuiElement{
 
  GuiABToggle(PVector pos, String text0, String text1, boolean isFirstSelected, boolean active){
    super(pos, 0, 0, active);
    
    first = text0;
    second = text1;
    hitRectWidth = edgePadding + textWidth(first) + 2*edgePadding + textWidth(second) + edgePadding;
    hitRectHeight = 10 + textAscent();
    whichOne = isFirstSelected;    
  }
  
  @Override
  boolean update(boolean pointerDown, PVector pointerLoc){
    if(!super.update(pointerDown, pointerLoc)){
      return false;
    }
   
    if(pressed){
      float leftEdge = loc.x - hitRectWidth / 2;
      float rightEdge = leftEdge + edgePadding + textWidth(first) + edgePadding;
      whichOne =(pointerLoc.x< rightEdge);
    }
    
    return true;
  }
  
  @Override
  void display(){
    pushStyle();
      float leftEdge = loc.x - hitRectWidth / 2;
      float topEdge = loc.y - hitRectHeight / 2;
      if(isActive){stroke(selectedValue);}
      else{stroke(grayedValue);}
      fill(0);      
      rect(leftEdge, topEdge, hitRectWidth, hitRectHeight);
      textAlign(CENTER, CENTER);
      
      // First label.
      if(!isActive){
        fill(grayedValue);
      }else{
        if(whichOne){
          fill(selectedValue);
        }else{
            fill(unselectedValue);
        }
      }
      text(first, leftEdge + edgePadding + textWidth(first)/2, loc.y - 1);
      
      // Divider line.
      line(leftEdge + edgePadding + textWidth(first) + edgePadding + 2, loc.y - hitRectHeight / 2,
            leftEdge + edgePadding + textWidth(first) + edgePadding - 2, loc.y + hitRectHeight / 2);

       // Second label.
      if(!isActive){
        fill(grayedValue);
      }else{
        if(!whichOne){
          fill(selectedValue);
        }else{
            fill(unselectedValue);
        }
      }
      text(second,
        leftEdge + edgePadding + textWidth(first) + 2*edgePadding + textWidth(second)/2,
        loc.y - 1);
    popStyle();
  }
  
  String first;
  String second;
  boolean whichOne;  
}

//----------------------------------------------------------------------------
// This represents an onscreen radio button set.
//----------------------------------------------------------------------------
class GuiMultiToggle extends GuiElement{
  //--------------------------------------------------------------------------
  // CREATION
  
  GuiMultiToggle(PVector pos, ArrayList<String> texts, int itemSelected){
    super(pos, 0, 0, true);
    strings = new ArrayList<String>();
    for(int i = 0; i< texts.size(); ++i){
      strings.add(new String(texts.get(i)));
    }
    hitRectWidth = 0;
    for(int i = 0; i< strings.size(); ++i){
      hitRectWidth += textWidth(strings.get(i));
      hitRectWidth +=(2 * edgePadding);
    }
    hitRectHeight = 10 + textAscent();
    
    whichOne =  itemSelected;    
  }
  
  @Override
  boolean update(boolean pointerDown, PVector pointerLoc){
    if(!super.update(pointerDown, pointerLoc)){
      return false;
    }
    
    if(pressed){
      float leftEdge = loc.x - hitRectWidth / 2;
      float rightEdge = leftEdge;
      whichOne = 0;
      for(int i = 0; i< strings.size(); ++i){
        rightEdge += textWidth(strings.get(i));
        rightEdge += 2*edgePadding;  
        if(pointerLoc.x< rightEdge){
          whichOne = i;
          break;
        }
      }
    }
    
    return true;
  }
  
  @Override
  void display(){
    pushStyle();
      float leftEdge = loc.x - hitRectWidth / 2;
      float topEdge = loc.y - hitRectHeight / 2;
      stroke(selectedValue);
      //strokeWeight(0.5);
      fill(0);      
      rect(leftEdge, topEdge, hitRectWidth, hitRectHeight);
      textAlign(CENTER, CENTER);
      
      float rightEdge = leftEdge;
      for(int i = 0; i< strings.size(); ++i){
        if(i == whichOne){
          fill(selectedValue);
        }else{
          fill(unselectedValue);
        }
      
        rightEdge += textWidth(strings.get(i));
        rightEdge += 2*edgePadding;  
        
        text(strings.get(i), ((leftEdge + rightEdge)/2), loc.y - 1);
        
        if(strings.size() > 1 &&(i<(strings.size() - 1))){
          line(rightEdge + 2, loc.y - hitRectHeight / 2,
                rightEdge - 2, loc.y + hitRectHeight / 2);
        }
        
        // Update for next item.
        leftEdge = rightEdge;
      }
    popStyle();
  }
  
  ArrayList<String> strings;
  int whichOne;  
}

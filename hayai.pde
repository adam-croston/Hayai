//----------------------------------------------------------------------------
// This is the main program file for the app.
//
// Hayai is a rapid set up time projection mapping tool. It is meant for small
// scale projection mapping installations where load in time is critical.
//
// This is a massive tweak of http://www.openprocessing.org/sketch/60524
// Which itself was a tweak of http://www.openprocessing.org/sketch/60365
//
// TODO: LOTS!!!!!
//
//    Put up on github
//    Clean up code!
//
//    Cursor brightness and animation control.
//
//    Shapes
//      Create Square, Cricle, Freehand.
//      Support for pixel shapes instead of vector shapes!!
//      Support for file watchers on shapes and images!
//      Support for live edit of shapes and images from other programs.
//
//    Grid with colors, not black and white.
//    Multi-projector support?
//    Save/Load file extensions!
//
//    Supprt for shift-click, control-click, etc.
//
//    Multi-select of verts and shapes!
//      That way nudging or deleting or image edit affects all of them.
//    Merge shapes?
//    Rotate shape (mouse wheel or control arrows).
//
//    Split edge (causing shape to open   or potentially become two shapes).
//    Add vert along edge.
//    Continue shape from either end point.
//      i.e. if select first vert (or last) and then go to draw tool will continue from there. 
//    Bezier curves?
//
//    Proper image control: translate, rotate, scale.
//      Set tiling mode for image:
//        regular, h-mirror, v-mirror, hv-mirror
//        regular, h-offset per row, v-offset pre row.
//
//    Need offst and playback speed for images.
//    Need playback mode, loop, ping pong, etc.
//
//----------------------------------------------------------------------------
import java.awt.Toolkit;
import java.awt.event.KeyEvent;
import java.awt.datatransfer.StringSelection; 
import java.util.*; 

// Main app modes.
final int MAKE_SHAPE = 0;
final int MOVE_VERT = 1;
final int MOVE_SHAPE = 2;
final int EDIT_WARP = 3;

static PApplet g_theApp;

GuiEditor guiEditor;
Scene theScene;

int mainMode;
boolean perspectiveAxis = true;

ArrayList<String> copiedShapeInfo;


//----------------------------------------------------------------------------
// Do any app set up.
//----------------------------------------------------------------------------
// Old way of invoking fullscreen (See "Setup()" below.).
//boolean sketchFullScreen(){
//  return true;
//  //return false;
//}
//https://processing.org/discourse/beta/num_1185318989.html
//http://forum.processing.org/one/topic/using-a-secondary-display.html
// http://www.superduper.org/processing/fullscreen_api/
//https://github.com/processing/processing/wiki/Window-Size-and-Full-Screen
/*
public void init() {
  frame.removeNotify();
  frame.setUndecorated(true); // works.
  frame.addNotify();
  frame.setAlwaysOnTop(false); 

  // call PApplet.init() to take care of business
  super.init();
} 
// The in setup)(){
// size(1024,768, OPENGL); // set to the size of the second display
// frame.setLocation(1440,0); // set to the position of the second display
// }
*/
void setup(){
  
  // Stored for convenience so it doesn't have to be passed way down
  // to some poorlydesgined helper functions.
  g_theApp = this;
  
  fullScreen(P3D);// New way of invoking fullscreen (See "sketchFullScreen()" above.).
  //size(int(displayWidth/1.5f), int(displayHeight/1.5f), P3D); 
  //size(displayWidth, displayHeight, P3D);
  //size(1920, 1080, P3D);
 
 //set at second screen  
 //frame.setLocation(1280,0);
 
  ellipseMode(CENTER);
  smooth();
  textureMode(NORMAL);

  // Make all the editor widgets.
  guiEditor = new GuiEditor();
  
  // Make the actual work doc.
  theScene = new Scene();
}

//----------------------------------------------------------------------------
// Handle memory management.
//----------------------------------------------------------------------------
void RequestGarbageCleanup(){
   System.gc();
   System.runFinalization();
}

//----------------------------------------------------------------------------
// Handle doc frame updates
//----------------------------------------------------------------------------
void draw(){
  background(0);
  
  guiEditor.displayPreScene();
  theScene.display();
  guiEditor.displayPostScene();
}

//----------------------------------------------------------------------------
// Handle user input.
//----------------------------------------------------------------------------
void mousePressed(){
  println("mousePressed");
  userInput_mousePressed();
}
void mouseDragged(){
  println("mouseDragged");
  userInput_mouseDragged();
}
void mouseReleased(){
  println("mouseReleased");
  userInput_mouseReleased();
}
void mouseClicked(){
  println("mouseClicked");
  userInput_mouseClicked();
}
void mouseWheel(MouseEvent event){
  println("mouseWheel");
  userInput_mouseWheel(event);
}

//----------------------------------------------------------------------------
// Handle keyboard input.
//
// Unfortunately Processing's default handling of keyboard events is incredibly
// limited.
// In previous version or Processing (pre 3) easy access to the applets
// java.awt.event.KeyEvent was allowed, but this in no longer the case.
//
// All this code is to overcome those limitations.
//
// Explanation of the processing global variables key vs keyCode
//
// key holds the most recent typed character.
// Thus when doing key combos this returns the inteded key.
// I.e. If you are holding down the <control> and then press the <j> key this
// will hold the ascii code for the backspace character, but so will
// pressing the <backspace> by itself.
//
// keyCode hold the most recent pressed keyboard button.
// Thus even when doing key combos this returns the last pressed keyboard key.
// I.e. If you are holding down the <control> and then press the <j> key this
// will hold the ascii code for the <J> (always uppercase) character, but so 
// will pressing the <j> by itself.
//
/*
void keyReleased(KeyEvent e){
  println("keyReleased");
  //userInput_keyReleased(e); 
}
void keyPressed(KeyEvent e){
  println("keyPressed");
  //userInput_keyPressed(e); 
}
*/
char mostRecentTypedCharEvent = 0;
int mostRecentPressedKeyboardButtonEvent = 0;

// Special keys state handling.
boolean modShiftJustChanged = false;
boolean modShiftIsPressed = false;
boolean modControlJustChanged = false;
boolean modControlIsPressed = false;
boolean modAltJustChanged = false;
boolean modAltIsPressed = false;

boolean dirLeftJustChanged = false;
boolean dirLeftIsPressed = false;
boolean dirRightJustChanged = false;
boolean dirRightIsPressed = false;
boolean dirUpJustChanged = false;
boolean dirUpIsPressed = false;
boolean dirDownJustChanged = false;
boolean dirDownIsPressed = false;

boolean docPageUpJustChanged = false;
boolean docPageUpPressed = false;
boolean docPageDnJustChanged = false;
boolean docPageDnPressed = false;
boolean docHomeJustChanged = false;
boolean docHomePressed = false;
boolean docEndJustChanged = false;
boolean docEndPressed = false;

void UpdateSpecialKeysState(boolean pressedVal, int currKeyCode){
  modShiftJustChanged = false;
  modControlJustChanged = false;
  modAltJustChanged = false;
  dirLeftJustChanged = false;
  dirRightJustChanged = false;
  dirUpJustChanged = false;
  dirDownJustChanged = false;
  docPageUpJustChanged = false;
  docPageDnJustChanged = false;
  docHomeJustChanged = false;
  docEndJustChanged = false;

  if (currKeyCode == SHIFT){
    modShiftIsPressed = pressedVal; modShiftJustChanged = true;  
  }else if (currKeyCode == CONTROL){
    modControlIsPressed = pressedVal; modControlJustChanged = true;
  }else if (currKeyCode == ALT){
    modAltIsPressed = pressedVal; modAltJustChanged = true;
  }else if (currKeyCode == UP) {
    dirUpIsPressed = pressedVal; dirUpJustChanged = true;
  }else if (currKeyCode == DOWN) {
    dirDownIsPressed = pressedVal; dirDownJustChanged = true;
  }else if(currKeyCode == LEFT){
    dirLeftIsPressed = pressedVal; dirLeftJustChanged = true;
  }else if(currKeyCode == RIGHT){
    dirRightIsPressed = pressedVal; dirRightJustChanged = true;
  }else if(currKeyCode == KeyEvent.VK_PAGE_UP){
    docPageUpPressed = pressedVal; docPageUpJustChanged = true;
  }else if(currKeyCode == KeyEvent.VK_PAGE_DOWN){
    docPageDnPressed = pressedVal; docPageDnJustChanged = true;
  }else if(currKeyCode == KeyEvent.VK_HOME){
    docHomePressed = pressedVal; docHomeJustChanged = true;
  }else if(currKeyCode == KeyEvent.VK_END){
    docEndPressed = pressedVal; docEndJustChanged = true;
  }
}
void keyPressed() {
  mostRecentTypedCharEvent = key;
  mostRecentPressedKeyboardButtonEvent = keyCode;
  boolean pressedVal = true;
  UpdateSpecialKeysState(pressedVal, mostRecentPressedKeyboardButtonEvent);
  userInput_keyPressed(); 
}
void keyReleased() {
  mostRecentTypedCharEvent = key;
  mostRecentPressedKeyboardButtonEvent = keyCode;
  boolean pressedVal = false;
  UpdateSpecialKeysState(pressedVal, mostRecentPressedKeyboardButtonEvent);
  userInput_keyReleased();
}

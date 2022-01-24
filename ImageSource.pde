//----------------------------------------------------------------------------
// This reperesents a possibly animating image.
// Several file types are supported: gif, jpg, tga, png, mov, mp4.
//
// TODO: avi support.
// TODO: Playback control- play, pause, speed, step, loop/ping-pong.
//----------------------------------------------------------------------------

import processing.video.*;
import gifAnimation.*;

// Necessary to suport movie playback.
void movieEvent(Movie m){
  m.read();
}

class ImageSource{
  //--------------------------------------------------------------------------
  // CREATION/SAVE/LOAD

  ImageSource(String fileName){
    setImageSource(fileName);
  }
  ImageSource(ArrayList<String> loadInfo){     
    // Determine what the image file was.
    String fileName = loadInfo.remove(0);
    setImageSource(fileName);
  }
  void save(ArrayList<String> saveInfo){
    saveInfo.add(fileSource);
  }    

  //--------------------------------------------------------------------------
  // DISPLAY
  
  void update(){
    //gifFrameNum =((gifFrameNum + 1) % gifFrames.length);
  }
  
  PImage getImage(){
    if(type == 0){
      return simpleImage;
    }else if(type == 1){
      return mov;
    }else if(type == 2){
      return gifAnimation;
    }else{
      return new PImage(1,1);
    }
  }
  
  //--------------------------------------------------------------------------
  // ADJUSTMENT
  void setImageSource(String fileName){
    fileSource = fileName;
    String fileNameLower = fileName.toLowerCase();

    if(  fileNameLower.endsWith("png") ||
         fileNameLower.endsWith("tga") ||
         fileNameLower.endsWith("jpg")){
      type = 0;
      simpleImage = loadImage(fileName);
    }else if(fileNameLower.endsWith("mov") || fileNameLower.endsWith("mp4")){
      type = 1;
      mov = new Movie(g_theApp, fileName);// Supports .mp4 and .mov
      mov.loop();
      mov.volume(0);
    }else if(fileNameLower.endsWith("gif")){
      type = 2;
      //gifFrames = Gif.getPImages(g_theApp, fileName);
      //gifFrameNum = 0;
      gifAnimation = new Gif(g_theApp, fileName);
      gifAnimation.play();
    }else{
      type = -1;// Unsupported file type.
    }
  }
  
  String getImgSource(){
    return fileSource;
  }
  
  // What was the original file path?
  String fileSource;
  
  // Which file source type is this?
  int type = -1;
  PImage simpleImage;// Support for single frame .gif, .jpg, .tga, and .png images
  //PImage[] gifFrames;
  //int gifFrameNum;
  Gif gifAnimation;// Has playback services and understands delay in gif file.
  Movie mov;// Quicktime files "mov" & "mp4"    
};

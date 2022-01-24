//----------------------------------------------------------------------------
// This reperesents the method of rendering a warped image within a shape.
//----------------------------------------------------------------------------

static class WarpShader{  
  
  // Load the vertex and fragment shaders.
  static void loadShaderEffect(){
    warpShaderEffect = g_theApp.loadShader("../shaders/warp_frag.glsl", "../shaders/warp_vert.glsl");
  }
  
  // Prepare rendering so it uses the vertex and fragment shaders and set the
  // approriate uniforms (passes data to them).
  static void applyShaderEffect(  float resX, float resY,
                                  PVector vA, PVector vB, PVector vC, PVector vD,
                                  float perspectiveX, float perspectiveY){
    //float timeS = millis() / 1000.0f;
    //warpShader.set("timeS", timeS);
    //warpShader.set("mouseScreenPos0To1", float(mouseX)/resX, float(mouseY)/resY);
    warpShaderEffect.set("screenRes", resX, resY);
    warpShaderEffect.set("warpVertAScreenPos0To1", vA.x/resX, vA.y/resY);
    warpShaderEffect.set("warpVertBScreenPos0To1", vB.x/resX, vB.y/resY);
    warpShaderEffect.set("warpVertCScreenPos0To1", vC.x/resX, vC.y/resY);
    warpShaderEffect.set("warpVertDScreenPos0To1", vD.x/resX, vD.y/resY);
    warpShaderEffect.set("warpPerspXY", 1.0f / perspectiveX, 1.0f / perspectiveY);
    g_theApp.shader(warpShaderEffect);  
  }
  
  static PShader warpShaderEffect;
}

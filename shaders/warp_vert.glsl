#define PROCESSING_TEXTURE_SHADER

//uniform float timeS;
//uniform vec2 mouseScreenPos0To1;
uniform vec2 screenRes;
uniform vec2 warpVertAScreenPos0To1;
uniform vec2 warpVertBScreenPos0To1;
uniform vec2 warpVertCScreenPos0To1;
uniform vec2 warpVertDScreenPos0To1;
uniform vec2 warpPerspXY;

uniform mat4 transform;
uniform mat4 texMatrix;

attribute vec4 vertex;
attribute vec4 color;
attribute vec2 texCoord;

varying vec4 vertColor;
varying vec4 vertTexCoord;

void main() {
  gl_Position = transform * vertex;
    
  vertColor = color;
  vertTexCoord = texMatrix * vec4(texCoord, 1.0, 1.0);
}

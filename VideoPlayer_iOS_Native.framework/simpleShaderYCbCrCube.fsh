precision mediump float;
uniform sampler2D yourTextureY;
uniform sampler2D yourTextureCbCr;
uniform int cubeIndex;
varying vec2 texCoord;
uniform mat3 colorConversionMatrix;

void main(void) {
    mediump vec3 yuv;
    lowp vec3 rgb;
    
    vec2 texCoordCube = texCoord;
    
    texCoordCube.x = texCoordCube.x;
    texCoordCube.y = (texCoordCube.y + float(cubeIndex)) / 6.0;
    
    // Subtract constants to map the video range start at 0
    yuv.x = texture2D(yourTextureY, texCoordCube).r - (16.0/255.0);
    yuv.yz = texture2D(yourTextureCbCr, texCoordCube).rg - vec2(0.5, 0.5);
    
    rgb = colorConversionMatrix * yuv;
    
    gl_FragColor = vec4(rgb,1.0);
}
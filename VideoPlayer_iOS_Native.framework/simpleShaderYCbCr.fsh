precision mediump float;
uniform sampler2D yourTextureY;
uniform sampler2D yourTextureCbCr;
uniform int isStereo;
uniform int eyeIndex;
varying vec2 texCoord;
uniform mat3 colorConversionMatrix;

void main(void) {
    mediump vec3 yuv;
    lowp vec3 rgb;
    
    vec2 coord = texCoord;
    if (isStereo == 1) {
        coord = texCoord / vec2(1.0, 2.0);
        if (eyeIndex == 1) {
            coord += vec2(0.0, 0.5);
        }
    }
    // Subtract constants to map the video range start at 0
    yuv.x = texture2D(yourTextureY, coord).r - (16.0/255.0);
    yuv.yz = texture2D(yourTextureCbCr, coord).ra - vec2(0.5, 0.5);
    
    rgb = colorConversionMatrix * yuv;
    
    gl_FragColor = vec4(rgb,1.0);
}

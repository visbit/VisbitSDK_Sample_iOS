precision mediump float;
uniform sampler2D yourTexture;
uniform float u_viewDegree;
varying vec2 texCoord;
#define M_PI 3.1415926

void main(void) {
    
    float v = M_PI*(texCoord.y - 0.5); // map from [0 1] to [-pi/2 pi/2]
    vec4 color = texture2D(yourTexture, texCoord);
    if (abs(v) < u_viewDegree) {
        gl_FragColor = color;
    } else {
        float alpha =  10.0 * (u_viewDegree - abs(v)) + 1.0;
        gl_FragColor = alpha * color;
    }
}
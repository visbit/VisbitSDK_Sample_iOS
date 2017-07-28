precision mediump float;
uniform sampler2D yourTexture;
varying vec2 texCoord;

void main(void) {
    gl_FragColor = texture2D(yourTexture, texCoord);
}
precision mediump float;
uniform sampler2D yourTexture;
uniform sampler2D yourTextureDownSample;

// skybox
uniform float alpha0;
uniform float alpha1;
uniform float alpha2;
uniform float alpha3;
uniform float alpha4;
uniform float alpha5;

varying vec2 texCoord;

void main(void) {
    
    float x = (texCoord.x - 0.125);
    if (x < 0.0) {
        x = x + 1.0;
    }
    
    float y = texCoord.y;
    float alpha = 0.0;
    if (y < 0.25) {
        alpha = alpha4; //top
    } else if (y > 0.75) {
        alpha = alpha5; //bot
    } else if (x < 0.25) {
        alpha = alpha0;
    } else if (x > 0.25 && x < 0.5) {
        alpha = alpha1;
    } else if (x > 0.5 && x < 0.75) {
        alpha = alpha2;
    } else {
        alpha = alpha3;
    }
    
    gl_FragColor = alpha * texture2D(yourTexture, texCoord) + (1.0-alpha) * texture2D(yourTextureDownSample, texCoord);

//    gl_FragColor = texture2D(yourTexture, texCoord) + vec4(alpha, 0.0, 0.0, 0.0);
}
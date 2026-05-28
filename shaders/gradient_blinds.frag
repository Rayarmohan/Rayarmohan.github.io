uniform vec3  iResolution;
uniform vec2  iMouse;
uniform float iTime;

uniform float uAngle;
uniform float uNoise;
uniform float uBlindCount;
uniform float uSpotlightRadius;
uniform float uSpotlightSoftness;
uniform float uSpotlightOpacity;
uniform float uMirror;
uniform float uDistort;
uniform float uShineFlip;
uniform vec3  uColor0;
uniform vec3  uColor1;
uniform vec3  uColor2;
uniform vec3  uColor3;
uniform vec3  uColor4;
uniform vec3  uColor5;
uniform vec3  uColor6;
uniform vec3  uColor7;
uniform float uColorCount;

out vec4 fragColor;

float rand(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

vec2 rotate2D(vec2 p, float a){
    float c = cos(a);
    float s = sin(a);
    return mat2(c, -s, s, c) * p;
}

vec3 getGradientColor(float t){
    float tt = clamp(t, 0.0, 1.0);
    float count = uColorCount;
    if (count < 2.0) count = 2.0;
    float scaled = tt * (count - 1.0);
    float seg = floor(scaled);
    float f = fract(scaled);

    if (seg < 1.0) return mix(uColor0, uColor1, f);
    if (seg < 2.0 && count > 2.0) return mix(uColor1, uColor2, f);
    if (seg < 3.0 && count > 3.0) return mix(uColor2, uColor3, f);
    if (seg < 4.0 && count > 4.0) return mix(uColor3, uColor4, f);
    if (seg < 5.0 && count > 5.0) return mix(uColor4, uColor5, f);
    if (seg < 6.0 && count > 6.0) return mix(uColor5, uColor6, f);
    if (seg < 7.0 && count > 7.0) return mix(uColor6, uColor7, f);
    if (count > 7.0) return uColor7;
    if (count > 6.0) return uColor6;
    if (count > 5.0) return uColor5;
    if (count > 4.0) return uColor4;
    if (count > 3.0) return uColor3;
    if (count > 2.0) return uColor2;
    return uColor1;
}

void main() {
    // Replaced FlutterFragCoord() with gl_FragCoord for broad web environment compatibility
    vec2 fragCoord = gl_FragCoord.xy; 
    vec2 uv0 = fragCoord.xy / iResolution.xy;

    float aspect = iResolution.x / iResolution.y;
    vec2 p = uv0 * 2.0 - 1.0;
    p.x *= aspect;
    vec2 pr = rotate2D(p, uAngle);
    pr.x /= aspect;
    vec2 uv = pr * 0.5 + 0.5;

    vec2 uvMod = uv;
    if (uDistort > 0.0) {
        float a = uvMod.y * 6.0;
        float b = uvMod.x * 6.0;
        float w = 0.01 * uDistort;
        uvMod.x += sin(a) * w;
        uvMod.y += cos(b) * w;
    }
    float t = uvMod.x;
    if (uMirror > 0.5) {
        t = 1.0 - abs(1.0 - 2.0 * fract(t));
    }
    vec3 base = getGradientColor(t);

    vec2 offset = vec2(iMouse.x / iResolution.x, iMouse.y / iResolution.y);
    float d = length(uv0 - offset);
    float r = max(uSpotlightRadius, 1e-4);
    float dn = d / r;
    float spot = (1.0 - 2.0 * pow(dn, uSpotlightSoftness)) * uSpotlightOpacity;
    vec3 cir = vec3(spot);
    
    float stripe = fract(uvMod.x * max(uBlindCount, 1.0));
    if (uShineFlip > 0.5) stripe = 1.0 - stripe;
    vec3 ran = vec3(stripe);

    vec3 col = cir + base - ran;
    col += (rand(fragCoord.xy + iTime) - 0.5) * uNoise;

    fragColor = vec4(col, 1.0);
}
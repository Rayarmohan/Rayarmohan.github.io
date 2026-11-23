
#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform vec2 uMouse;

uniform float uTime;
uniform float uDpr;

uniform vec3 uBgColor;
uniform vec3 uDotColor;
uniform vec3 uGlowColor;

out vec4 fragColor;

void main() {

    // Fragment coordinates in physical pixels.
    vec2 fragCoord = FlutterFragCoord().xy;

    // Convert logical resolution to physical pixels.
    vec2 res = max(
        uResolution * uDpr,
        vec2(1.0)
    );

    // Convert logical mouse position to physical pixels.
    vec2 mousePos = uMouse * uDpr;

    float minDim = max(
        min(res.x, res.y),
        1.0
    );

    // Normalized centered coordinates.
    vec2 p = (fragCoord - 0.5 * res) / minDim;

    vec2 m = (mousePos - 0.5 * res) / minDim;

    // Exact cursor position.
    vec2 toCursor = p - m;

    float dist = length(toCursor);

    // Cursor influence.
    float spot = exp(-dist * 3.5);

    float tightSpot = exp(-dist * 8.0);

    // Ripple animation.
    float ripple =
        sin(dist * 35.0 - uTime * 3.0)
        * exp(-dist * 5.0)
        * 0.006;

    // Idle animation.
    float idleWave =
        sin(p.x * 4.0 + uTime * 0.4)
        * cos(p.y * 4.0 - uTime * 0.3)
        * 0.001;

    // Physical dot distortion.
    vec2 direction = normalize(
        toCursor + vec2(0.00001)
    );

    float distortion =
        exp(-dist * 4.0) * 0.018;

    vec2 warpedP =
        p
        - direction * distortion
        + vec2(ripple + idleWave);

    // Grid configuration.
    float cellSize = 0.042;

    vec2 gridUV = warpedP / cellSize;

    vec2 cellCenter = fract(gridUV) - 0.5;

    float dDot = length(cellCenter);

    // Dot radius.
    float radius = mix(
        0.085,
        0.145,
        spot
    );

    float dotMask = 1.0 - smoothstep(
        radius * 0.55,
        radius,
        dDot
    );

    // Dot opacity.
    float baseDotAlpha = 0.14;

    float activeDotAlpha = spot * 0.65;

    vec3 dots =
        uDotColor
        * dotMask
        * (baseDotAlpha + activeDotAlpha)

        + uGlowColor
        * dotMask
        * tightSpot
        * 0.45;

    // Cursor glow.
    vec3 aura = uGlowColor * (
        spot * 0.11
        + tightSpot * 0.09
    );

    // Vignette.
    float vig = 1.0 - smoothstep(
        0.45,
        1.35,
        length(p)
    );

    // Final color.
    vec3 col =
        uBgColor * (0.85 + 0.15 * vig)
        + aura
        + dots;

    fragColor = vec4(
        clamp(col, 0.0, 1.0),
        1.0
    );
}

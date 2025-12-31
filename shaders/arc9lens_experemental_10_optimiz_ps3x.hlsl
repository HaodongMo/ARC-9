// -- Configuration --
sampler sScene : register(s0);

// c0: Vignette Circle 1
// x: Center X (px), y: Center Y (px), z: Radius (px), w: Smooth Start Radius (px)
float4 vVig1 : register(c0);

// c1: Vignette Circle 2
// x: Center X (px), y: Center Y (px), z: Radius (px), w: Smooth Start Radius (px)
float4 vVig2 : register(c1);

// c2: CA & Offsets
// xy: Red Offset Vector (UV space), z: Lateral CA Base Strength, w: Lateral CA Angle Strength
float4 vCAParams : register(c2);

// c3: Scene Params
// x: Lens K (Base), y: Unused, z: Res X, w: Res Y
float4 vSceneParams : register(c3);

// -- Helper Functions --

// Optimized Vignette: Uses pre-calculated centers and radii from registers
float GetVignetteFactor(float2 coords_px, float4 vig1, float4 vig2)
{
    float d1 = length(coords_px - vig1.xy);
    float d2 = length(coords_px - vig2.xy);

    // smoothstep(min, max, x)
    float mask1 = 1.0 - smoothstep(vig1.w, vig1.z, d1);
    float mask2 = 1.0 - smoothstep(vig2.w, vig2.z, d2);

    return mask1 * mask2;
}

float2 lens_distort(float2 uv, float k1, float k2, float2 center) {
    float2 d = uv - center;
    float r2 = dot(d, d);
    float r4 = r2 * r2;
    float f = 1.0 + k1 * r2 + k2 * r4;
    return center + d * f;
}

// -- Main Pixel Shader --
float4 main( float2 texCoord : TEXCOORD0 ) : COLOR
{
    float2 uv = texCoord;
    float2 res = vSceneParams.zw;
    float2 frag_p = uv * res;

    // 1. Calculate Primary Vignette (Used for distortion weighting)
    float vig_factor = GetVignetteFactor(frag_p, vVig1, vVig2);

    // 2. Calculate Dynamic Distortion
    // Original logic: factor = 3.0 - pow(abs(vig_factor), 1.25) * 1.75;
    // Optimization: vig_factor is always 0..1, so abs() is removed.
    float factor = 3.0 - pow(vig_factor, 1.25) * 1.75;
    
    float base_k = vSceneParams.x;
    float dynamic_k1 = base_k * factor * 1.2;
    float dynamic_k2 = base_k * factor * 0.3;

    // Center for distortion is fixed at 0.5 (from original 'ret_uv')
    float2 d_uv = lens_distort(uv, dynamic_k1, dynamic_k2, float2(0.5, 0.5));

    // 3. Background Sampling with Lateral CA
    float2 center_uv = float2(0.5, 0.5);
    float2 diff_uv = uv - center_uv;
    float r_dist = length(diff_uv);
    float2 radial_dir = normalize(diff_uv);

    // Use pre-calculated CA strength components
    // Original: base + angle (where angle included 't' which is now pre-calced in w)
    float ca_amount = vCAParams.z * pow(abs(r_dist), 1.5) + vCAParams.w * r_dist;

    float3 col;
    // Manual unroll of CA sampling
    col.r = tex2D(sScene, d_uv + radial_dir * ca_amount * 2.5).r;
    col.g = tex2D(sScene, d_uv + radial_dir * ca_amount * 0.5).g;
    col.b = tex2D(sScene, d_uv - radial_dir * ca_amount * 1.8).b;

    // 4. Directional CA on Vignette Edges
    // We utilize the exact ratios from the original shader to derive Green/Blue from Red
    // Red   = 2.0 * scale
    // Green = 0.5 * scale (Red * 0.25)
    // Blue  = -1.5 * scale (Red * -0.75)
    
    float2 off_r = vCAParams.xy;
    float2 off_g = off_r * 0.25;
    float2 off_b = off_r * -0.75;

    // Apply vignette to channels separately (mimics the "Directional CA" look)
    col.r *= GetVignetteFactor(frag_p + (off_r * res), vVig1, vVig2);
    col.g *= GetVignetteFactor(frag_p + (off_g * res), vVig1, vVig2);
    col.b *= GetVignetteFactor(frag_p + (off_b * res), vVig1, vVig2);

    // 5. Final Tint
    col *= pow(vig_factor, 1.2);

    return float4(col, 1.0);
}
// -- Configuration --
sampler sScene : register(s0);

// -- Constants --
// c0: x:EYE_DIST, y:LENS_K, z:CA_STR, w:BLUR_STR
float4 vLensParams : register(c0);
// c1: Screen Resolution
float4 vResolution : register(c1);
// c2: x:FORGIVENESS, y:OFFSET, z:RAD1, w:RAD2
float4 vVigParams : register(c2);
// c3: x:MouseX, y:MouseY, z:STATIC_SIZE, w:STATIC_FADE
float4 vCenterParams : register(c3);

// -- Base Values --
#define DEF_EYE_DIST 0.1
#define DEF_LENS_K -0.525
#define DEF_CA_STR 0.5        // Increased base CA for visibility
#define DEF_BLUR_STR 0.15
#define DEF_VIG_FORGIVENESS 0.75
#define DEF_OFFSET_FRAC 0.75
#define DEF_RAD1_FRAC 0.8
#define DEF_RAD2_FRAC 0.5

#define MAX_DIST_FRAC 0.15
#define FORG_COMPENSATION 0.1
#define MOUSE_THRESHOLD_PX 1.0

// -- Helper Functions --

float CalculateVignette(float2 uv, float2 res, float2 center_point, float4 vig_params, float4 center_params, float eye_dist)
{
    float VIGNETTE_FORGIVENESS_FRAC = DEF_VIG_FORGIVENESS + vig_params.x;
    float OFFSET_FRAC = DEF_OFFSET_FRAC + vig_params.y;
    float RAD1_FRAC = (DEF_RAD1_FRAC - eye_dist) + vig_params.z; 
    float RAD2_FRAC = DEF_RAD2_FRAC + vig_params.w;

    float2 center_p = 0.5 * res;
    float2 safe_center = (length(center_point) <= 0.001) ? float2(0.5, 0.5) : center_point;
    float2 mo_p = safe_center * res;
    
    float2 dir_p = mo_p - center_p;
    float dir_len_p = length(dir_p);
    
    // Normalize direction
    if (dir_len_p < MOUSE_THRESHOLD_PX) {
        dir_p = float2(0.0, 0.0);
    } else {
        dir_p = dir_p / dir_len_p;
    }

    // Calculate the two shifting vignette circles (The "Lens" effect)
    float max_dist_p = MAX_DIST_FRAC * length(res) * VIGNETTE_FORGIVENESS_FRAC;
    float t = clamp(dir_len_p / max_dist_p, 0.0, 1.0);
    float offset_p = OFFSET_FRAC * min(res.x, res.y) * t;

    float2 c1_p = center_p + dir_p * offset_p * 1.75;
    float2 c2_p = center_p - dir_p * offset_p * t * t;

    float rad1_p = RAD1_FRAC * min(res.x, res.y);
    float rad2_p = RAD2_FRAC * min(res.x, res.y);

    float2 frag_p = uv * res;
    float d1_p = length(frag_p - c1_p);
    float d2_p = length(frag_p - c2_p);

    float mask1 = 1.0 - smoothstep((0.55 - eye_dist) * rad1_p, rad1_p, d1_p);
    float mask2 = 1.0 - smoothstep(0.8 * rad2_p, rad2_p, d2_p);

    // REMOVED: Static mask logic. Only returning the dynamic vignette.
    return min(mask1, mask2);
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
    float2 res = vResolution.xy;
    if(res.x < 1.0) res = float2(1920.0, 1080.0);
    
    // Parameter Setup
    float EYE_DISTANCE = DEF_EYE_DIST + vLensParams.x;
    float LENS_DIST_K = DEF_LENS_K + vLensParams.y;
    
    // BOOSTED: Chromatic Aberration Strength
    float LATERAL_CA_STRENGTH = (0.025 + EYE_DISTANCE/15.0); 
    float CA_STRENGTH = (DEF_CA_STR + vLensParams.z) * 2.5; // Multiplied for more impact
    float BLUR_STRENGTH = DEF_BLUR_STR + vLensParams.w;
    
    float VIGNETTE_FORGIVENESS_FRAC = DEF_VIG_FORGIVENESS + vVigParams.x;
    float2 mo = (length(vCenterParams.xy) < 0.01) ? float2(0.5, 0.5) : vCenterParams.xy;

    float2 center_p = 0.5 * res;
    float2 mo_p = mo * res;
    float2 dir_p = mo_p - center_p;
    float dir_len_p = length(dir_p);
    float max_dist_p = MAX_DIST_FRAC * length(res) * VIGNETTE_FORGIVENESS_FRAC;
    float t = clamp(dir_len_p / max_dist_p, 0.0, 1.0);
    
    float2 ret_uv = float2(0.5, 0.5);
    float2 norm_dir = (length(mo - 0.5) > 0.0) ? normalize(mo - 0.5) : float2(0.0, 0.0);

    float vig_factor = CalculateVignette(uv, res, mo, vVigParams, vCenterParams, EYE_DISTANCE);
    float forg_scale = (1.0 / VIGNETTE_FORGIVENESS_FRAC * VIGNETTE_FORGIVENESS_FRAC) * FORG_COMPENSATION;

    // Distortion
    float factor = 3.0 - pow(vig_factor, 1.25);
    float dynamic_k1 = LENS_DIST_K * factor * 1.2;
    float dynamic_k2 = LENS_DIST_K * factor * 0.3;
    float2 d_uv = lens_distort(uv, dynamic_k1, dynamic_k2, ret_uv);

    // 1. Background Sampling & Lateral CA (BOOSTED)
    float2 radial_dir = normalize(uv - ret_uv);
    float r = length(uv - ret_uv);
    float base_ca = LATERAL_CA_STRENGTH * pow(r, 1.5) * 0.5; // Increased multiplier
    float angle_ca = LATERAL_CA_STRENGTH * r * 0.8 * t;
    float ca_amount = base_ca + angle_ca;

    float3 col;
    col.r = tex2D(sScene, d_uv + radial_dir * ca_amount * 2.5).r;
    col.g = tex2D(sScene, d_uv + radial_dir * ca_amount * 0.5).g;
    col.b = tex2D(sScene, d_uv - radial_dir * ca_amount * 1.8).b;

    // 2. Directional CA on Vignette Edges (BOOSTED)
    float ca_t = t * 0.5 + smoothstep(0.02, 0.2, t) * 1.0;
    float ca_scale = CA_STRENGTH * forg_scale * ca_t * 1.5;
    
    float2 off_r = norm_dir * ca_scale * 2.0;
    float2 off_g = norm_dir * ca_scale * 0.5;
    float2 off_b = -norm_dir * ca_scale * 1.5;

    col.r *= CalculateVignette(uv + off_r, res, mo, vVigParams, vCenterParams, EYE_DISTANCE);
    col.g *= CalculateVignette(uv + off_g, res, mo, vVigParams, vCenterParams, EYE_DISTANCE);
    col.b *= CalculateVignette(uv + off_b, res, mo, vVigParams, vCenterParams, EYE_DISTANCE);

    // Final result
    col *= pow(vig_factor, 1.2);
    return float4(col, 1.0);
}
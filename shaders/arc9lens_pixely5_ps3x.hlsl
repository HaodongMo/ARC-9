// --- Textures ---
sampler sScene : register(s0);
sampler sOverlay : register(s1);

// --- Constants ---
// C0.x = Vertical Grid Resolution (e.g., 100.0 blocks vertically)
// C0.y = Global opacity multiplier for the overlay (0.0 to 1.0)
// C0.z = Aspect Ratio (Screen Width / Screen Height, e.g., 1.7777 for 16:9)
float4 C0 : register(c0);

struct PS_INPUT {
    float2 UV : TEXCOORD0;
};

float4 main(PS_INPUT input) : COLOR0 {
    // 1. Setup 2D Grid Resolution
    // Multiply the vertical resolution by the aspect ratio to get the horizontal resolution.
    // Example for 16:9: float2(100.0 * 1.7777, 100.0) = float2(177.77, 100.0)
    float2 gridRes = float2(C0.x * C0.z, C0.x); 
    
    // Prevent division by zero errors on both axes
    gridRes = max(gridRes, float2(1.0, 1.0));

    // 2. Calculate Pixelated UVs
    // The math is identical, but now it operates independently on the X and Y axes 
    // using our new float2 gridRes.
    float2 blockUV = (floor(input.UV * gridRes) + 0.5) / gridRes;
    
    float4 sceneColor = tex2D(sScene, blockUV);

    // 3. Calculate Local Macro-Pixel UVs
    // This perfectly tiles your overlay texture inside the newly squared-off blocks.
    float2 localUV = frac(input.UV * gridRes);
    
    float4 overlayColor = tex2D(sOverlay, localUV);

    // 4. Blend the Scene and the Overlay
    float overlayAlpha = overlayColor.a * C0.y; 
    
    float4 finalColor;
    finalColor.rgb = lerp(sceneColor.rgb, overlayColor.rgb, overlayAlpha);
    finalColor.a = sceneColor.a;

    return finalColor;
}
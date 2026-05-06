sampler ImageBuffer : register(s0);
sampler MaskTexture : register(s1);

float2 C0               : register(c0);

struct PS_INPUT
{
    float2 pPos        : VPOS;
    float4 vTexCoord   : TEXCOORD0;
};

float4 main(PS_INPUT i) : COLOR
{
    float2 uv = i.vTexCoord.xy;
    
    float4 originalColor = tex2Dlod(ImageBuffer, float4(uv, 0.0, 0.0));
    float mask = tex2Dlod(MaskTexture, float4(uv, 0.0, 0.0)).r;
    
    float depth = originalColor.a;
    float t = saturate(depth / max(C0.y, 0.00001));
    float focus = 1.0 - t * t;
    
    focus = focus * (1.0 - mask);
    
    float3 greenOverlay = float3(0.0, 1.0, 0.0);
    float3 debugRGB = lerp(originalColor.rgb, greenOverlay, focus);
    
    return float4(debugRGB, 1.0);
}
Shader "EggParty/EnhancedHeadShader_Corrected"
{
    Properties
    {
        // Main Textures
        [MainTexture] _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _MaskTex("Mask Texture (R:Rim Area)", 2D) = "gray" {}
        _GalaxyTex("Galaxy Texture (R:PerlinNoise, G:DotPattern)", 2D) = "black" {}
        _GalaxyTex2("Galaxy Texture Two (Black)", 2D) = "black" {}
        _NoiseTex("Function Texture", 2D) = "white" {}
        
        // Material Properties
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        
        // Soft Body Deformation
        _SoftBodyCenter("Soft Body Center Position", Vector) = (0,0,0)
        _SoftBodyX("Soft Body Positive X", Vector) = (1,0,0)
        _SoftBodyY("Soft Body Positive Y", Vector) = (0,1,0)
        _SoftBodyZ("Soft Body Positive Z", Vector) = (0,0,1)
        _SoftBodyNX("Soft Body Negative X", Vector) = (-1,0,0)
        _SoftBodyNY("Soft Body Negative Y", Vector) = (0,-1,0)
        _SoftBodyNZ("Soft Body Negative Z", Vector) = (0,0,-1)
        
        // Spark Effects
        _SparkParameters("Spark (Intensity, Scale, Offset, SampleOffset)", Vector) = (1,1,0.05,0.03)
        _SparkSpeed("Spark Speed", Float) = 0.5
        _SparkColor("Spark Color", Color) = (1.0,1.0,1.0,1.0)
        _SparkColor2("Spark Color 2", Color) = (1.0,1.0,1.0,1.0)
        _SparkColor3("Spark Color 3", Color) = (1.0,1.0,1.0,1.0)
        _BottomSparkSpeed("Bottom Spark Speed", Range(0.0,1.0)) = 0.5
        _TopSparkSpeed("Top Spark Speed", Range(0.0,1.0)) = 0.5
        _SparkColorExponent("Spark Color Exponent", Float) = 5
        _SparkTiling("Spark Tiling", Range(0.5,1.0)) = 0.6
        _BlurAmount("Blur Amount", Float) = 0.015
        _CenterIntensity("Center Intensity", Float) = 2.5
        
        // Rim Lighting
        _RimOffset("Rim Offset", Float) = 0.5
        _RimColor("Rim Color", Color) = (1.0,1.0,1.0,1.0)
        _RimStrength("Rim Strength", Float) = 5
        _RimBlurAmount("Rim Blur Amount", Float) = 0.05
        _RimSmoothness("Rim Smoothness", Range(0.01, 0.5)) = 0.1
        
        // Galaxy Effects
        _GalaxyParallaxOffset("Galaxy Parallax Offset", Float) = 100.0
        _GalaxyScale("Galaxy Scale", Float) = 1.0
        _NoiseStrength("Noise Strength", Float) = 0.1
        _StarsIntensity("Stars Intensity", Float) = 2.0
        _GalaxyFlowSpeed("Galaxy Flow Speed", Vector) = (0.1, 0.1, 0, 0)
        _PerlinDistortion("Perlin Distortion", Float) = 0.05
        
        // Stars Color and Glow
        [HDR] _StarsColor("Stars Color (HDR)", Color) = (1.0, 1.0, 1.0, 1.0)
        _StarsGlowIntensity("Stars Glow Intensity", Float) = 3.0
        _StarsPulseSpeed("Stars Pulse Speed", Float) = 1.0
        _StarsTwinkleAmount("Stars Twinkle Amount", Float) = 0.2
        
        // Bright Stars Enhancement
        _BrightStarsIntensity("Bright Stars Intensity", Float) = 5.0
        _BrightStarsThreshold("Bright Stars Threshold", Range(0.0, 1.0)) = 0.7
        _BrightStarsGlow("Bright Stars Glow", Float) = 10.0
        _FunctionTexBrightness("Function Texture Brightness", Float) = 2.0
    }
    
    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
        }
        
        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }
            
            Cull Back
            Blend One Zero
            ZTest LEqual
            ZWrite On

            HLSLPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment
            #pragma target 3.0

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            // Textures and Samplers
            TEXTURE2D(_MainTex);            SAMPLER(sampler_MainTex);
            TEXTURE2D(_MaskTex);            SAMPLER(sampler_MaskTex);
            TEXTURE2D(_GalaxyTex);          SAMPLER(sampler_GalaxyTex);
            TEXTURE2D(_GalaxyTex2);         SAMPLER(sampler_GalaxyTex2);
            TEXTURE2D(_NoiseTex);           SAMPLER(sampler_NoiseTex);

            // Constant Buffer
            CBUFFER_START(UnityPerMaterial)
                // Texture Transforms
                float4 _MainTex_ST;
                
                // Soft Body Parameters
                float3 _SoftBodyCenter;
                float3 _SoftBodyX;
                float3 _SoftBodyY;
                float3 _SoftBodyZ;
                float3 _SoftBodyNX;
                float3 _SoftBodyNY;
                float3 _SoftBodyNZ;
                
                // Spark Parameters
                float4 _SparkParameters;
                float _SparkSpeed;
                float4 _SparkColor;
                float4 _SparkColor2;
                float4 _SparkColor3;
                float _BottomSparkSpeed;
                float _TopSparkSpeed;
                float _SparkColorExponent;
                float _SparkTiling;
                float _BlurAmount;
                float _CenterIntensity;
                
                // Rim Lighting Parameters
                float _RimOffset;
                float4 _RimColor;
                float _RimStrength;
                float _RimBlurAmount;
                float _RimSmoothness;
                
                // Galaxy Parameters
                float _GalaxyParallaxOffset;
                float _GalaxyScale;
                float _NoiseStrength;
                float _StarsIntensity;
                float4 _GalaxyFlowSpeed;
                float _PerlinDistortion;
                
                // Stars Color and Glow Parameters
                float4 _StarsColor;
                float _StarsGlowIntensity;
                float _StarsPulseSpeed;
                float _StarsTwinkleAmount;
                
                // Bright Stars Enhancement Parameters
                float _BrightStarsIntensity;
                float _BrightStarsThreshold;
                float _BrightStarsGlow;
                float _FunctionTexBrightness;
            CBUFFER_END

            // Vertex Input
            struct VertexInput
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 texcoord : TEXCOORD0;
            };

            // Vertex Output / Fragment Input
            struct VertexOutput
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float2 uv : TEXCOORD2;
                float3 tangentWS : TEXCOORD3;
                float3 bitangentWS : TEXCOORD4;
                float3 viewDirWS : TEXCOORD5;
            };

            // Soft Body Deformation Function
            float3 ApplySoftBodyDeformation(float3 worldPosition)
            {
                // Calculate direction from center
                float3 centerDirection = normalize(worldPosition - _SoftBodyCenter);
                
                // Soft body deformation constant
                const float deformationConstant = 0.63492101;
                
                // Calculate positive deformation weights
                float3 positiveWeights = clamp(centerDirection * deformationConstant, 0.0, 1.0) * 
                                        float3(_SoftBodyX.x, _SoftBodyY.y, _SoftBodyZ.z);
                
                // Calculate negative deformation weights  
                float3 negativeWeights = clamp(centerDirection * (-deformationConstant), 0.0, 1.0) *
                                        float3(_SoftBodyNX.x, _SoftBodyNY.y, _SoftBodyNZ.z);
                
                // Apply deformation
                return worldPosition + (positiveWeights + negativeWeights);
            }

            // Galaxy Parallax UV Calculation with Perlin Noise Distortion
            float2 CalculateGalaxyUV(float2 baseUV, float3 worldNormal, float3 viewDir, float3 tangent, float3 bitangent)
            {
                // Create TBN matrix and its transpose
                float3x3 worldToTangent = float3x3(tangent, bitangent, worldNormal);
                
                // Transform view direction to tangent space
                float3 viewDirTS = normalize(mul(worldToTangent, viewDir));
                float3 normalTS = normalize(mul(worldToTangent, worldNormal));
                
                // Calculate reflection vector in tangent space
                float3 reflectDirTS = reflect(-viewDirTS, normalTS);
                
                // Apply parallax offset
                float parallaxScale = _GalaxyParallaxOffset / max(abs(reflectDirTS.z), 0.1);
                float2 parallaxOffset = reflectDirTS.xy * parallaxScale * (1.0 / 512.0);
                
                // Apply Perlin noise distortion from GalaxyTex R channel
                float2 noiseUV = baseUV + _Time.y * _GalaxyFlowSpeed.xy;
                float4 galaxySample = SAMPLE_TEXTURE2D(_GalaxyTex, sampler_GalaxyTex, noiseUV);
                float perlinNoise = galaxySample.r; // R channel is Perlin noise
                
                // Use Perlin noise to create distortion
                float2 perlinOffset = (perlinNoise - 0.5) * 2.0 * _PerlinDistortion;
                
                return baseUV + parallaxOffset + perlinOffset;
            }

            // Enhanced Bright Stars Effect with Function Texture Enhancement
            float3 CalculateBrightStarsEffect(float dotPattern, float2 uv, float3 viewDirTS)
            {
                // Sample FunctionTexture for bright stars enhancement
                float4 functionTex = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, uv);
                
                // Extract bright parts from FunctionTexture (using multiple channels for variety)
                float brightNoiseR = functionTex.r;
                float brightNoiseG = functionTex.g;
                float brightNoiseB = functionTex.b;
                
                // Combine bright parts with enhanced brightness
                float combinedBrightness = (brightNoiseR + brightNoiseG + brightNoiseB) / 3.0;
                combinedBrightness = pow(combinedBrightness, 0.5) * _FunctionTexBrightness; // Enhance bright areas
                
                // Apply color to stars with enhanced brightness
                float3 coloredStars = dotPattern * _StarsColor.rgb;
                
                // Add glow effect with enhanced intensity for bright stars
                float glow = dotPattern * _StarsGlowIntensity;
                
                // Add pulsing animation
                float pulse = (sin(_Time.y * _StarsPulseSpeed) + 1.0) * 0.5;
                float pulseEffect = 1.0 + pulse * 0.5;
                
                // Add twinkling effect using noise
                float2 twinkleUV = uv + _Time.y * 0.1;
                float twinkleNoise = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, twinkleUV).r;
                float twinkle = 1.0 + (twinkleNoise - 0.5) * _StarsTwinkleAmount;
                
                // Create bright stars effect - only the brightest parts
                float brightStarsMask = smoothstep(_BrightStarsThreshold, 1.0, combinedBrightness);
                float3 brightStars = brightStarsMask * _StarsColor.rgb * _BrightStarsIntensity;
                
                // Add glowing halo around bright stars
                float brightStarsGlow = smoothstep(_BrightStarsThreshold - 0.2, _BrightStarsThreshold, combinedBrightness);
                brightStars += brightStarsGlow * _StarsColor.rgb * _BrightStarsGlow;
                
                // Combine all effects
                float3 finalStars = coloredStars * glow * pulseEffect * twinkle + brightStars;
                
                // Add view-dependent sparkle for bright stars
                float viewSparkle = 1.0 + dot(normalize(viewDirTS), float3(0, 0, 1)) * 0.5;
                finalStars *= viewSparkle;
                
                return finalStars;
            }

            // Galaxy Effect using Perlin Noise (R) and Dot Pattern (G)
            float3 CalculateGalaxyEffect(float2 baseUV, float2 distortedUV, float3 viewDirTS)
            {
                // Sample GalaxyTex with distorted UV
                float4 galaxySample = SAMPLE_TEXTURE2D(_GalaxyTex, sampler_GalaxyTex, distortedUV);
                
                // Extract channels
                float perlinNoise = galaxySample.r; // R channel: Perlin noise for volume/depth
                float dotPattern = galaxySample.g;  // G channel: Dot pattern for stars
                
                // Sample GalaxyTex2 (which is all black, so this will return black)
                float4 galaxy2Sample = SAMPLE_TEXTURE2D(_GalaxyTex2, sampler_GalaxyTex2, baseUV);
                
                // Use Perlin noise to create volume and depth illusion
                float depthEffect = perlinNoise * _NoiseStrength;
                
                // Calculate enhanced stars with color, glow and bright stars
                float3 starsEffect = CalculateBrightStarsEffect(dotPattern, baseUV, viewDirTS);
                
                // Combine effects
                // Perlin noise creates the "body" of the galaxy with depth
                // Stars effect adds the colorful, glowing stars with bright highlights
                float3 galaxyColor = depthEffect + starsEffect;
                
                return galaxyColor;
            }

            // Enhanced Spark Effect with Bright Highlights
            float3 CalculateSparkEffects(float2 uv, float3 viewDirTS, float3 albedo, float3 galaxyEffect)
            {
                // Base spark UV with scaling
                float2 sparkBaseUV = uv * _SparkParameters.y * 3.0;
                
                // View-dependent offset
                float2 viewOffset = viewDirTS.xy * _SparkParameters.z;
                float2 animatedUV = sparkBaseUV + viewOffset + (_Time.y * _SparkSpeed);
                
                // Spark sampling offsets
                float2 sparkOffset = float2(_SparkParameters.w, _SparkParameters.w);
                
                // Main spark samples from NoiseTex
                float4 sparkSample1 = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, animatedUV + sparkOffset);
                float4 sparkSample2 = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, animatedUV - sparkOffset);
                float4 sparkSample3 = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, animatedUV);
                
                // Secondary spark samples (higher frequency)
                float2 detailedSparkUV = sparkBaseUV * 1.4;
                float pulse = (_Time.w + 1.0) * 0.5;
                float2 pulseUV = detailedSparkUV + (pulse * _BottomSparkSpeed);
                
                float4 detailedSpark1 = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, detailedSparkUV + sparkOffset);
                float4 detailedSpark2 = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, detailedSparkUV - sparkOffset * 2.0);
                float4 detailedSpark3 = SAMPLE_TEXTURE2D(_NoiseTex, sampler_NoiseTex, pulseUV);
                
                // Enhance bright parts of spark samples
                float brightSpark1 = smoothstep(0.7, 1.0, sparkSample1.g) * _BrightStarsIntensity;
                float brightSpark2 = smoothstep(0.7, 1.0, sparkSample2.g) * _BrightStarsIntensity;
                float brightSpark3 = smoothstep(0.7, 1.0, sparkSample3.g) * _BrightStarsIntensity;
                
                // Combine spark effects with enhanced bright sparks
                float blurG = (sparkSample1.g + sparkSample2.g + sparkSample3.g) / 3.0;
                float centerSpark = sparkSample1.g * _CenterIntensity + blurG;
                
                // Add bright spark highlights
                float brightSparks = (brightSpark1 + brightSpark2 + brightSpark3) * _SparkColor.rgb;
                
                // Final spark composition with bright highlights
                float3 sparks = (1.0 - detailedSpark3.r) * albedo * 2.0 * galaxyEffect
                              + detailedSpark3.g * pow(_SparkColor.rgb, _SparkColorExponent)
                              + sparkSample3.g * _SparkColor2.rgb * galaxyEffect
                              + sparkSample1.g * _SparkColor3.rgb * centerSpark * galaxyEffect
                              + brightSparks;
                
                return sparks;
            }

            // Rim Lighting Calculation using MaskTex R channel
            float3 CalculateRimLighting(float2 uv, float3 normal, float3 viewDir, float maskR)
            {
                // Calculate rim factor
                float NdotV = 1.0 - saturate(dot(normal, viewDir));
                
                // Anti-aliasing for smooth rim
                float rimDDX = abs(ddx(NdotV));
                float rimDDY = abs(ddy(NdotV));
                float rimWidth = rimDDX + rimDDY;
                float smoothRange = _RimSmoothness + rimWidth * 1.5;
                
                float rim = smoothstep(_RimOffset - smoothRange, _RimOffset + smoothRange, NdotV);
                
                // Use MaskTex R channel for rim area control
                float rimIntensity = pow(rim * maskR, _RimStrength);
                
                return rimIntensity * _RimColor.rgb;
            }

            // Vertex Shader
            VertexOutput Vertex(VertexInput input)
            {
                VertexOutput output;
                
                // Transform position to world space
                float3 worldPosition = TransformObjectToWorld(input.positionOS);
                
                // Apply soft body deformation
                worldPosition = ApplySoftBodyDeformation(worldPosition);
                
                // Transform to clip space
                output.positionCS = TransformWorldToHClip(worldPosition);
                output.positionWS = worldPosition;
                
                // Transform normals and tangents
                output.normalWS = normalize(TransformObjectToWorldNormal(input.normalOS));
                output.tangentWS = normalize(TransformObjectToWorldDir(input.tangentOS.xyz));
                output.bitangentWS = normalize(cross(output.normalWS, output.tangentWS) * input.tangentOS.w);
                
                // Calculate view direction
                output.viewDirWS = GetWorldSpaceNormalizeViewDir(worldPosition);
                
                // Pass UV coordinates
                output.uv = TRANSFORM_TEX(input.texcoord, _MainTex);
                
                return output;
            }

            // Fragment Shader
            half4 Fragment(VertexOutput input) : SV_Target
            {
                // Normalize vectors
                float3 normalWS = normalize(input.normalWS);
                float3 tangentWS = normalize(input.tangentWS);
                float3 bitangentWS = normalize(input.bitangentWS);
                float3 viewDirWS = normalize(input.viewDirWS);
                
                // Create TBN matrix
                float3x3 worldToTangent = float3x3(tangentWS, bitangentWS, normalWS);
                float3 viewDirTS = normalize(mul(worldToTangent, viewDirWS));
                
                // Sample main textures
                half4 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
                half4 mask = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, input.uv);
                
                // Calculate galaxy UV with parallax and Perlin distortion
                float2 galaxyUV = CalculateGalaxyUV(input.uv, normalWS, viewDirWS, tangentWS, bitangentWS);
                
                // Calculate enhanced galaxy effect with bright, glowing stars
                float3 galaxyEffect = CalculateGalaxyEffect(input.uv, galaxyUV, viewDirTS);
                
                // Calculate other effects
                float3 sparkEffects = CalculateSparkEffects(input.uv, viewDirTS, albedo.rgb, galaxyEffect);
                float3 rimLighting = CalculateRimLighting(input.uv, normalWS, viewDirWS, mask.r); // Use mask R channel
                
                // Combine all effects
                float3 finalColor = albedo.rgb + sparkEffects + rimLighting + galaxyEffect;
                
                return half4(finalColor, albedo.a);
            }
            ENDHLSL
        }
    }
    
    FallBack "Universal Render Pipeline/Lit"
}
Shader "EggParty/OriginFS_URP"
{
    Properties
    {
        // Base Maps
        _AlbedoTex("Albedo (RGB)", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "bump" {}
        _DetailNormalMap("Detail Normal Map", 2D) = "gray" {}
        _MaskTex("Mask Texture (R:Metallic, G:Aniso, B:Roughness, A:Detail)", 2D) = "white" {}
        _MatCap("MatCap", 2D) = "gray" {}
        _ReflectionProbe("Reflection Probe", Cube) = "" {}

        // Normal Parameters
        _DetailNormalUVTiling("Detail Normal UV Tiling", Float) = 1.0
        _DetailNormalIntensity("Detail Normal Intensity", Float) = 1.0

        // Anisotropic Parameters
        _AnisoNormalEnable("Aniso Normal Enable", Range(0.0, 1.0)) = 0.5
        _AnisoPow("Aniso Power", Range(0.0, 3.0)) = 1.0
        _AnisoColor("Aniso Color", Color) = (1.0, 1.0, 1.0, 1.0)

        // Fresnel Parameters
        _FresnelScale("Fresnel Scale", Range(0.0, 1.0)) = 0.5
        _FresnelPow("Fresnel Power", Range(0.5, 5.0)) = 2.5
        _FRScale("FR Scale", Range(0.0, 1.0)) = 0.5
        _FRPow("FR Power", Range(0.5, 5.0)) = 2.5

        // Metalness & Roughness
        _BaseMetalness("Base Metalness", Float) = 1.0
        _MetalnessMaskEnable("Metalness Mask Enable", Range(0.0, 1.0)) = 0.5
        _changeBY("Change BY", Range(0.0, 1.0)) = 0.5

        // Colors
        _BaseColor("Base Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _MentalColor("Metal Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _RimColor("Rim Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _FrenelColor("Frenel Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _AnisoMentalColor("Aniso Metal Color", Color) = (1.0, 1.0, 1.0, 1.0)

        // Intensity
        _Intensity("Intensity (R, M, B, W)", Vector) = (1.0, 1.0, 1.0, 1.0)
        _TintValue("Tint Value", Range(0.0, 2.0)) = 1.0

        // Rim & Fresnel
        _FA("FA", Float) = 0.0
        _FB("FB", Float) = 1.0
        _FrenelEmiStr("Frenel Emission Strength", Float) = 1.0
        _FrenelMaskEnable("Frenel Mask Enable", Range(0.0, 1.0)) = 0.5

        // Subsurface Scattering
        _SSColorA("SS Color A", Color) = (1.0, 1.0, 1.0, 1.0)
        _SSColorIntensityA("SS Color Intensity A", Float) = 1.0
        _SSColor("SS Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _SSColorIntensity("SS Color Intensity", Float) = 1.0

        // Emission
        _BaseEmissiveKey("Base Emissive Key", Float) = 0.0
        _EmissiveValue("Emissive Value", Float) = 1.0
        _UseDefaultEmis("Use Default Emissive", Float) = 1.0
        _EmissiveBreathPercent("Emissive Breath Percent", Float) = 0.5
        _EmissiveBreathSpd("Emissive Breath Speed", Float) = 1.0
        _EmissiveBreathEnable("Emissive Breath Enable", Range(0.0, 1.0)) = 0.0

        // Time
        _TimeValue("Time Value", Float) = 1.0

        // Alpha
        _AlphaMtl("Alpha Material", Float) = 1.0
        _AlphaBlend("Alpha Blend", Float) = 0.0
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "Lit"
        }
        LOD 300

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            Blend One Zero
            ZWrite On
            Cull Back

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            // ========== Textures & Samplers ==========
            TEXTURE2D(_AlbedoTex);
            SAMPLER(sampler_AlbedoTex);
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);
            TEXTURE2D(_DetailNormalMap);
            SAMPLER(sampler_DetailNormalMap);
            TEXTURE2D(_MaskTex);
            SAMPLER(sampler_MaskTex);
            TEXTURE2D(_MatCap);
            SAMPLER(sampler_MatCap);
            TEXTURECUBE(_ReflectionProbe);
            SAMPLER(sampler_ReflectionProbe);

            // ========== Constant Buffer ==========
            CBUFFER_START(UnityPerMaterial)
                half4 _AlbedoTex_ST;
                float _DetailNormalUVTiling;
                float _DetailNormalIntensity;
                float _AnisoNormalEnable;
                float _AnisoPow;
                float _FresnelScale;
                float _FresnelPow;
                float _FRScale;
                float _FRPow;
                float _BaseMetalness;
                float _MetalnessMaskEnable;
                float _changeBY;
                float _TintValue;
                float4 _BaseColor;
                float4 _MentalColor;
                float4 _RimColor;
                float4 _FrenelColor;
                float4 _AnisoColor;
                float4 _AnisoMentalColor;
                float4 _Intensity;
                float _FA;
                float _FB;
                float _FrenelEmiStr;
                float _FrenelMaskEnable;
                float4 _SSColorA;
                float _SSColorIntensityA;
                float4 _SSColor;
                float _SSColorIntensity;
                float _BaseEmissiveKey;
                float _EmissiveValue;
                float _UseDefaultEmis;
                float _EmissiveBreathPercent;
                float _EmissiveBreathSpd;
                float _EmissiveBreathEnable;
                float _TimeValue;
                float _AlphaMtl;
                float _AlphaBlend;
            CBUFFER_END

            // ========== Vertex Input ==========
            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 tangentWS : TEXCOORD2;
                float3 bitangentWS : TEXCOORD3;
                float2 uv : TEXCOORD4;
            };

            // ========== Vertex Shader ==========
            Varyings vert(Attributes input)
            {
                Varyings output;
                float3 positionWS = TransformObjectToWorld(input.positionOS);
                output.positionCS = TransformWorldToHClip(positionWS);
                output.positionWS = positionWS;
                output.normalWS = normalize(TransformObjectToWorldNormal(input.normalOS));
                output.tangentWS = normalize(TransformObjectToWorldDir(input.tangentOS.xyz));
                output.bitangentWS = cross(output.normalWS, output.tangentWS) * input.tangentOS.w;
                output.uv = TRANSFORM_TEX(input.uv, _AlbedoTex);
                return output;
            }

            // ========== Helper Functions ==========
            float3 BlendNormals(float3 normal1, float3 normal2, float intensity)
            {
                float3 blended = normalize(float3(
                    normal1.xy + normal2.xy * intensity,
                    normal1.z * normal2.z
                ));
                return blended;
            }

            // ========== Fragment Shader ==========
            half4 frag(Varyings input) : SV_Target
            {
                float2 uv = input.uv;
                float3 positionWS = input.positionWS;
                float3 normalWS = input.normalWS;
                float3 tangentWS = input.tangentWS;
                float3 bitangentWS = input.bitangentWS;

                // Build TBN matrix
                float3x3 TBN = float3x3(tangentWS, bitangentWS, normalWS);
                float3x3 TBN_I = transpose(TBN);

                // ========== Step 1: Sample Textures ==========
                half4 albedo = SAMPLE_TEXTURE2D(_AlbedoTex, sampler_AlbedoTex, uv);
                half4 normalMap = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, uv);
                half4 mask = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, uv);
                half4 matcapSample = SAMPLE_TEXTURE2D(_MatCap, sampler_MatCap, uv);

                // ========== Step 2: Unpack Normals ==========
                float3 normalTS = normalize(normalMap.xyz * 2.0 - 1.0);

                // Sample detail normal with multiple UV modes
                float2 detailNormuv1 = frac(uv * 4.0) * _DetailNormalUVTiling * 0.25;
                float2 detailNormuv2 = uv * _DetailNormalUVTiling;
                float mixUV = clamp((ceil(uv.y - 0.25) + ceil(0.25 - uv.x)), 0.0, 1.0);
                float2 finalDetailNormalUV = lerp(detailNormuv1, detailNormuv2, mixUV);
                half4 detailNormalMap = SAMPLE_TEXTURE2D(_DetailNormalMap, sampler_DetailNormalMap, finalDetailNormalUV);
                float3 detailNormalTS = normalize(detailNormalMap.xyz * 2.0 - 1.0);
                float detailNormalAlpha = detailNormalMap.w;

                // ========== Step 3: Blend Normals ==========
                float3 blendedNormalTS = BlendNormals(normalTS, detailNormalTS, _DetailNormalIntensity);
                float3 normalMixed = normalize(mul(blendedNormalTS, TBN));

                // ========== Step 4: Direction Calculations ==========
                float3 viewDir = normalize(_WorldSpaceCameraPos - positionWS);
                Light mainLight = GetMainLight();
                float3 lightDir = normalize(mainLight.direction);

                // ========== Step 5: MatCap Projection ==========
                float3 normalVS = TransformWorldToViewDir(normalMixed);
                float2 matcapUV = normalVS.xy * 0.5 + 0.5;
                matcapUV.y = 1.0 - matcapUV.y;
                half4 matcapLinear = pow(max(0, SAMPLE_TEXTURE2D(_MatCap, sampler_MatCap, matcapUV)), 2.2);

                // ========== Step 6: Color Space Conversion ==========
                half4 basecolorLinear = pow(max(0, albedo), 2.2);
                float MetalnessMask = mask.x;
                float RoughnessMask = mask.z;
                float AnisoMask = mask.y;

                // ========== Step 7: Anisotropic Specular ==========
                float3 binorMixed = cross(normalMixed, tangentWS);
                float3 VerticalWS = normalize(mul(TBN, float3(0.0, 1.0, 0.0)));
                float3 AnisoMix = lerp(VerticalWS, binorMixed, _AnisoNormalEnable);

                float anisoLightDot = dot(AnisoMix, lightDir);
                float anisoRoughness = ((lerp(120.0, 60.0, _AnisoNormalEnable) * _AnisoPow) * 1.4427) + 1.4427;
                float anisoSpecular = pow(max(0.0, anisoLightDot), anisoRoughness);
                float3 anisoFinal = anisoSpecular * mainLight.color * detailNormalAlpha * _AnisoColor.rgb * AnisoMask;

                // ========== Step 8: Fresnel & Metalness ==========
                float vDotn = dot(viewDir, normalMixed);
                float fresnelBase = vDotn - _FresnelScale;
                float fresnelFactor = clamp(pow(max(0, fresnelBase), _FresnelPow) * 2.0, 0.0, 1.0);
                float fresnelMask = 1.0 - fresnelFactor;

                // MatCap应该作为环境反射，而不是直接叠加
                half4 MatCapFinal = matcapLinear * lerp(RoughnessMask, MetalnessMask, _MetalnessMaskEnable);

                // ========== Step 9: Basic Lighting ==========
                float NdotL = max(0, dot(normalMixed, lightDir));
                float3 diffuse = basecolorLinear.rgb * NdotL * mainLight.color * _Intensity.x;

                // ========== Step 10: Rim Light ==========
                float rimFactor = clamp(pow(max(0, 1.0 - vDotn), _FB), 0.0, 1.0);
                float3 rimLight = _RimColor.rgb * rimFactor * _Intensity.w * 0.5;  // 减弱Rim强度

                // ========== Step 11: Subsurface Scattering ==========
                float3 ssColor = lerp(_SSColorA.rgb, _SSColor.rgb, clamp(sin(_TimeValue * _TimeValue) + 0.5, 0.0, 1.0));
                float3 ssLight = ssColor * (lerp(_SSColorIntensityA, _SSColorIntensity, 0.5)) * RoughnessMask * 0.3;  // 减弱SS强度

                // ========== Step 12: Emission ==========
                float breathFactor = lerp(1.0, (1.0 + (_EmissiveBreathPercent * ((2.0 * abs(frac(_TimeValue) - 0.5)) - 1.0))), _EmissiveBreathEnable);
                float3 emission = (basecolorLinear.rgb * _EmissiveValue * _UseDefaultEmis) * breathFactor * 0.5;  // 减弱发光强度

                // ========== Step 13: Final Composition ==========
                // 基础颜色
                float3 finalColor = basecolorLinear.rgb * _BaseColor.rgb * _TintValue;
                
                // 添加漫反射
                finalColor = lerp(finalColor, diffuse, 0.8);
                
                // 添加各向异性高光（已经很亮了，需要控制）
                finalColor += anisoFinal * 0.5;
                
                // 添加MatCap作为环境反射（仅在金属/粗糙区域）
                finalColor += MatCapFinal.rgb * _MentalColor.rgb * fresnelMask * 0.3;
                
                // 添加Rim光
                finalColor += rimLight * 0.3;
                
                // 添加子表面散射
                finalColor += ssLight * 0.2;
                
                // 添加发光
                finalColor += emission * 0.3;

                // ========== Step 14: Reflection Probe ==========
                float3 reflectDir = reflect(-viewDir, normalMixed);
                float3 reflectionProbe = SAMPLE_TEXTURECUBE(_ReflectionProbe, sampler_ReflectionProbe, reflectDir).rgb;
                finalColor += reflectionProbe * fresnelMask * 0.2;  // 大幅减弱反射探针

                // ========== Alpha ==========
                float alpha = clamp(albedo.a * _AlphaMtl, 0.0, 1.0);

                return half4(finalColor, alpha);
            }
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull Back

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Varyings vert(Attributes input)
            {
                Varyings output;
                float3 positionWS = TransformObjectToWorld(input.positionOS);
                output.positionCS = TransformWorldToHClip(positionWS);
                output.uv = input.uv;
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                return 0;
            }
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags { "LightMode" = "DepthOnly" }

            ZWrite On
            ColorMask R
            Cull Back

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float3 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
            };

            Varyings vert(Attributes input)
            {
                Varyings output;
                float3 positionWS = TransformObjectToWorld(input.positionOS);
                output.positionCS = TransformWorldToHClip(positionWS);
                return output;
            }

            half4 frag(Varyings input) : SV_Target
            {
                return 0;
            }
            ENDHLSL
        }
    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}

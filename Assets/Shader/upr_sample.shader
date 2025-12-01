Shader "EggParty/SimplePBR_URP"
{
    Properties
    {
        _BaseMap("Base Color", 2D) = "white" {}
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _NormalMap("Normal Map", 2D) = "bump" {}
        _NormalScale("Normal Scale", Float) = 1.0
        _MaskMap("Mask Map (R:Roughness, B:Metallic)", 2D) = "white" {}
        _Roughness("Roughness", Range(0, 1)) = 0.5
        _Metallic("Metallic", Range(0, 1)) = 0.0
    }
    
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
        }
        
        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            // URP 必需的包含文件
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            
            // 属性
            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);
            TEXTURE2D(_NormalMap);
            SAMPLER(sampler_NormalMap);
            TEXTURE2D(_MaskMap);
            SAMPLER(sampler_MaskMap);
            
            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                float4 _BaseColor;
                float _NormalScale;
                float _Roughness;
                float _Metallic;
            CBUFFER_END
            
            // 顶点着色器输入
            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 uv : TEXCOORD0;
            };
            
            // 顶点着色器输出
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 tangentWS : TEXCOORD2;
                float3 bitangentWS : TEXCOORD3;
                float3 positionWS : TEXCOORD4;
            };
            
            // 顶点着色器
            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                
                // 位置变换
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                output.positionWS = TransformObjectToWorld(input.positionOS.xyz);
                
                // 法线和切线变换
                output.normalWS = TransformObjectToWorldNormal(input.normalOS);
                output.tangentWS = TransformObjectToWorldDir(input.tangentOS.xyz);
                output.bitangentWS = cross(output.normalWS, output.tangentWS) * input.tangentOS.w;
                
                // UV
                output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
                
                return output;
            }
            
            // 片段着色器
            float4 frag(Varyings input) : SV_Target
            {
                // ============ 纹理采样 ============
                float4 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv) * _BaseColor;
                float3 normalTS = UnpackNormal(SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, input.uv));
                normalTS.xy *= _NormalScale;
                
                float4 maskMap = SAMPLE_TEXTURE2D(_MaskMap, sampler_MaskMap, input.uv);
                float roughness = maskMap.r * _Roughness;
                float metallic = maskMap.b * _Metallic;
                
                // ============ 法线处理 ============
                float3x3 tangentToWorld = float3x3(
                    input.tangentWS,
                    input.bitangentWS,
                    input.normalWS
                );
                float3 normalWS = mul(normalTS, tangentToWorld);
                normalWS = normalize(normalWS);
                
                // ============ 视线方向 ============
                float3 viewDir = normalize(_WorldSpaceCameraPos - input.positionWS);
                
                // ============ 主光源 ============
                float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
                Light mainLight = GetMainLight(shadowCoord);
                
                // ============ PBR 计算 ============
                float3 lightDir = normalize(mainLight.direction);
                float3 halfDir = normalize(lightDir + viewDir);
                
                // Fresnel (Schlick)
                float3 F0 = lerp(float3(0.04, 0.04, 0.04), baseColor.rgb, metallic);
                float cosTheta = max(dot(halfDir, viewDir), 0.0);
                float3 fresnel = F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
                
                // Distribution (GGX)
                float alpha = roughness * roughness;
                float alphaSq = alpha * alpha;
                float NdotH = max(dot(normalWS, halfDir), 0.0);
                float denominator = NdotH * NdotH * (alphaSq - 1.0) + 1.0;
                float distribution = alphaSq / (3.14159 * denominator * denominator);
                
                // Geometry (Schlick-GGX)
                float NdotL = max(dot(normalWS, lightDir), 0.0);
                float NdotV = max(dot(normalWS, viewDir), 0.0);
                float k = (roughness + 1.0) * (roughness + 1.0) / 8.0;
                float geometryL = NdotL / (NdotL * (1.0 - k) + k);
                float geometryV = NdotV / (NdotV * (1.0 - k) + k);
                float geometry = geometryL * geometryV;
                
                // Cook-Torrance BRDF
                float3 specular = (fresnel * distribution * geometry) / 
                                 max(4.0 * NdotL * NdotV, 0.001);
                
                // Diffuse
                float3 diffuse = baseColor.rgb * (1.0 - metallic) / 3.14159;
                
                // 最终光照
                float3 radiance = mainLight.color * mainLight.shadowAttenuation;
                float3 lighting = (diffuse + specular) * radiance * NdotL;
                
                // ============ 额外光源 ============
                uint pixelLightCount = GetAdditionalLightsCount();
                for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
                {
                    Light light = GetAdditionalLight(lightIndex, input.positionWS);
                    
                    float3 lightDirAdd = normalize(light.direction);
                    float3 halfDirAdd = normalize(lightDirAdd + viewDir);
                    float NdotLAdd = max(dot(normalWS, lightDirAdd), 0.0);
                    
                    // 简化计算（完整版本同上）
                    float3 specularAdd = specular;  // 简化
                    float3 diffuseAdd = diffuse;
                    
                    lighting += (diffuseAdd + specularAdd) * light.color * 
                               light.distanceAttenuation * light.shadowAttenuation * NdotLAdd;
                }
                
                // ============ 间接光照 ============
                float3 indirectLight = SampleSH(normalWS);
                lighting += baseColor.rgb * indirectLight;
                
                // ============ 最终输出 ============
                return float4(lighting, baseColor.a);
            }
            ENDHLSL
        }
        
        // 阴影投射 Pass
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
            
            ColorMask 0
            ZWrite On
            ZTest LEqual
            
            HLSLPROGRAM
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            // 定义必要的常量缓冲区
            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
            CBUFFER_END
            
            // 简单的阴影 Pass 实现
            struct Attributes
            {
                float4 positionOS : POSITION;
            };
            
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
            };
            
            Varyings ShadowPassVertex(Attributes input)
            {
                Varyings output = (Varyings)0;
                output.positionCS = TransformObjectToHClip(input.positionOS.xyz);
                return output;
            }
            
            float4 ShadowPassFragment(Varyings input) : SV_Target
            {
                return 0;
            }
            ENDHLSL
        }
    }
}
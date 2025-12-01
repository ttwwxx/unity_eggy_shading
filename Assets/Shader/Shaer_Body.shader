Shader "EggParty/Shaer_Body"
{
    Properties
    {
        _AlbedoTex ("Albedo (RGB)", 2D) = "white" {}
        _NormalMap("Normal Map",2D) = "bump"{}
        _DetailNormalMap("Detail Normal Map",2D) = "Gray"{}
        _MaskTex("Mask Texture", 2D) = "white"{}
        _MatCap("MatCap", 2D) = "Gray"{}
        //0 1 2 3 控制脸部表情切换
        _FaceUVOffset("Face UV Offset",float) = 0.0
        //0 1 2 3 控制脸部表情切换
        _CharOffset("Character Offset",float) = 0.25
        _DetailNormalUVTilling("Detail Normal UV Tilling",float) = 1.0
        _DetailNormalIntensity("Detail Normal Intensity",float) = 1.0
        _AnisoNormalEnable("Aniso Normal Enable", range(0.0,1.0)) = 0.5
        _AnisoPow("Aniso Pow",range(0.0, 3.0)) = 1.0
        _NormalScale("Main Normal Scale",range(0.0, 2.0)) = 1.0
        //frenel
        _FresnelPow("Fresnel Pow", range(0.5,5.0)) = 2.5
        _FresnelScale("Fresnel Scale",range(0.0,1.0)) = 0.5
        _MentalnessMaskEnable("Mentalness Mask Enable",range(0.0,1.0)) = 0.5
        _BaseMetalness("Base Metalness",float) = 1.0
        //金属度掩码启用
        _changeBY("Base Metalness",range(0.0,1.0)) = 0.5
        _TintValue("Tint Value",range(0.0,2.0)) = 1.0
        _BaseColor("Base Color", Color) = (1.0,1.0,1.0,1.0)
        _MentalColor("Mentalness Color", Color) = (1.0,1.0,1.0,1.0)
        _Intensity("R&M Intensity",Vector) = (1.0,1.0,1.0,1.0)
        _AnisoColor("Aniso Color",Color) = (1.0,1.0,1.0,1.0)
    }
    SubShader
    {
        Tags { 
            "RenderPipeline" = "UniversalPipeline"
            "RenderType"="Opaque" 
            "Queue" = "Geometry"
            }
        Pass
        {
           Cull Back
           Blend One Zero
           ZTest LEqual
           ZWrite On

           HLSLPROGRAM
           #pragma vertex vert
           #pragma fragment frag

           #pragma target 2.0

           
         #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
         #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
         #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

         struct a2v
         {
             float3 normalOS : NORMAL;
             float3 positionOS : POSITION;
             float4 tangentOS : TANGENT;
             float2 uv : TEXCOORD0;
             
         };

         struct v2f
         {
             float4 positionCS : SV_POSITION;
             float3 positionWS : TEXCOORD0;
             float3 normalWS : TEXCOORD1;
             float3 tangentWS : TEXCOORD2;
             float3 bitangent : TEXCOORD3;
             float2 uv : TEXCOORD4;

         
         };

         //纹理采样器
         TEXTURE2D(_AlbedoTex);
         SAMPLER(sampler_AlbedoTex);
         TEXTURE2D(_NormalMap);
         SAMPLER(sampler_NormalMap);
         TEXTURE2D(_MaskTex);
         SAMPLER(sampler_MaskTex);
         TEXTURE2D(_MatCap);
         SAMPLER(sampler_MatCap);
         TEXTURE2D(_DetailNormalMap);
         SAMPLER(sampler_DetailNormalMap);

         //常量buffer
         CBUFFER_START(UnityPerMaterial)
            half4 _AlbedoTex_ST;
            float _FaceUVOffset;
            float _CharOffset;
            float _DetailNormalUVTilling;
            float _DetailNormalIntensity;
            float _AnisoNormalEnable;
            float _AnisoPow;
            float _FresnelPow;
            float _FresnelScale;
            float _MentalnessMaskEnable;
            float _BaseMetalness;
            float _changeBY;
            float _TintValue;
            float4 _Intensity;
            float4 _BaseColor;
            float4 _MentalColor;
            float4 _AnisoColor;
            float _NormalScale;

         CBUFFER_END

         v2f vert(a2v i)
         {
             v2f o;
             float3 positionWS = TransformObjectToWorld(i.positionOS);
             float4 positionCS = TransformWorldToHClip(positionWS);
             float3 normalWS = normalize(TransformObjectToWorldNormal(i.normalOS));
             float3 tangentWS = normalize(TransformObjectToWorldDir(i.tangentOS));
             float3 binormalWS = cross(normalWS , tangentWS) * i.tangentOS.w;
             //face offset
             float offset = ((i.uv.y < 0.25 ) ? (_FaceUVOffset * _CharOffset ): 0.0) ; 
             i.uv.x += offset;

             o.positionWS = positionWS;
             o.positionCS = positionCS;
             o.normalWS = normalWS;
             o.tangentWS = tangentWS;
             o.bitangent = binormalWS;

             o.uv = TRANSFORM_TEX(i.uv,_AlbedoTex);

             return o;
         }
         
         half4 frag(v2f i) : SV_Target
         {
             
             float2 uv = i.uv;
             float4 positionCS = i.positionCS;
             float3 positionWS = i.positionWS;
             float3 tangentWS = i.tangentWS;
             float3 normalWS = i.normalWS;
             float3 binormalWS = i.bitangent;
             //构建btn矩阵：切线空间到世界空间
             float3x3 TBN = float3x3(tangentWS, binormalWS, normalWS);
             float3x3 TBN_I = transpose(TBN);
           
          
             //基础贴图采样
             half4 albedo = SAMPLE_TEXTURE2D(_AlbedoTex,sampler_AlbedoTex, uv);
             half4 normal = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, uv);
            // float3 normalTS = UnpackNormal(normal, _NormalScale);
             float3 normalTS = UnpackNormalScale(normal, _NormalScale);
             float3 finalNormalWS = mul(TBN, normalTS);
             half4 mask = SAMPLE_TEXTURE2D(_MaskTex,sampler_MaskTex, uv);
             half4 matcap = SAMPLE_TEXTURE2D(_MatCap,sampler_MatCap, uv);
             half4 basedetailnormal = SAMPLE_TEXTURE2D(_DetailNormalMap,sampler_DetailNormalMap,uv);
             //通用方向计算
             float3 cameraDir = _WorldSpaceCameraPos.xyz;
             float3 viewDir = cameraDir - positionWS;
             float3 viewDirTS = mul(TBN_I,viewDir );
             float3 norViewDir = normalize(viewDir);
             float3 norviewDirTS = normalize(viewDirTS);
             Light mainLight = GetMainLight();
             float3 sunDir = mainLight.direction;
             float3 lightDir = normalize((-sunDir) + viewDir);
             float vDotn = normalize(dot(norViewDir, finalNormalWS));
             float nDotl = normalize(dot(lightDir, finalNormalWS));
            
             //采样细节法线，支持多个UV模式
             float2 detailNormuv1 = frac(uv * 4.0) * _DetailNormalUVTilling * 0.25;
             float2 detailNormuv2 = uv  * _DetailNormalUVTilling;
             float mixUV = clamp((ceil(uv.y - 0.25) + ceil(0.25 - uv.x)) ,0.0, 1.0);
             float2 finalDetailNormalUV = lerp(detailNormuv1 , detailNormuv2 , mixUV);
             half4 detailnormal = SAMPLE_TEXTURE2D(_DetailNormalMap,sampler_DetailNormalMap, finalDetailNormalUV);
            //解码法线
             half4 finalDetaiNor = normalize(detailnormal * 2.0 - 1.0);
             float2 finalDetaiNor_xy = finalDetaiNor.xy;
             float finalDetaiNor_z = finalDetaiNor.z;
             float normal_z = normal.z;
             ////////////
             half4 test = SAMPLE_TEXTURE2D(_DetailNormalMap, sampler_DetailNormalMap,normal_z );
             ////////////
             //法线混合（主法线+细节法线）
               // 使用 Reoriented Normal Mapping 技术混合两个法线
               // 目的：在不失去细节的情况下混合法线
             float3 normalBlendA = float3(normal.xy * 0.5, normal_z + 1.0);
             float3 normalBlendB = float3((finalDetaiNor_xy * _DetailNormalIntensity * -1.0),finalDetaiNor_z);
             //float3 normalBlendB = float3((float3(finalDetaiNor_xy * _DetailNormalIntensity ,finalDetaiNor_z )).xy * (-1.0),finalDetaiNor_z);
             float3 normalWorldSpace = mul(TBN, normalize(normal.xyz * 2.0 - 1.0));
            // 法线混合：normalSample.w 是混合权重（掩码贴图的Alpha通道）
             float AdotB = dot(normalBlendA, normalBlendB);
             float3 mixA = normalBlendA * AdotB;
             float3 mixB = normalBlendB * (normal_z + 2.0);
             float3 mixABWorld = mul(TBN, normalize(mixA - mixB));
             float3 normalMixed = lerp(normalWorldSpace ,mixABWorld, normal.w);
             //各向异性:高光沿特定方向拓长
             float3 binorMixed = cross(normalMixed, tangentWS);
             float3 VerticalWS = normalize(mul(TBN, float3(0.0, 1.0, 0.0)));
             float3 AnisoMix = lerp(VerticalWS, binorMixed , _AnisoNormalEnable);
      
             float anisoLightDot = dot(AnisoMix, lightDir);
             float detailNormalAlpha = basedetailnormal.w;

             float3 tangentTS = cross(norviewDirTS, float3(0.0,1.0,0.0));
             float3 addmaskTS  = tangentTS + mask.y * norviewDirTS ;
             float3 cameraDirTS = mul(TBN_I, cameraDir);
             float anisoDot = dot(addmaskTS, cameraDirTS);
              anisoDot *= anisoDot;
              anisoDot = 1.0 - anisoDot;
             float anisoPow = saturate(pow(anisoDot, 80));
             // 各向异性粗糙度：掩码贴图掩控高光锐度
             // 各向同性时使用 120.0（锐），各向异性时使用 60.0（柔）
             //为什么乘以1.4427  1/ln(2) ✓ 将粗糙度从线性空间转换到对数空间✓ 使参数调整更均匀（人眼感知） ✓ 符合物理的微观法线分布✓ 提高 BRDF 计算精度
             float anisoRoughness = ((lerp(120.0, 60.0, _AnisoNormalEnable) * _AnisoPow) * 1.4427 ) +  1.4427;
             float anisoSpecular = pow(max(0.0,anisoLightDot ),anisoRoughness );
             float3 anisoFinal = anisoSpecular * mainLight.color * detailNormalAlpha * _AnisoColor * mask.y;
              // ============ 第五步：MatCap 投影（快速环境反射）============
             // MatCap 是一种低成本的环境反射技术，通过法线投影到 2D 纹理
            // 优点：性能好，效果强；缺点：不支持实时变化
             float3 normalVS = TransformWorldToViewDir(normalWS);
             // ✓ 只显示 MatCap 纹理的中心区域✓ 避免边缘失真✓ 使效果更自然
             float2 matcapUV = normalVS.xy * 0.5 + 0.5;
             float2 matcapUVflip = matcapUV;
             matcapUVflip.y= matcapUV.y *(-1.0);
             half4 matcapSample = SAMPLE_TEXTURE2D(_MatCap,sampler_MatCap, matcapUVflip);
               // ============ 第六步：颜色空间转换 ============
               // 从 sRGB 转换到线性空间（Gamma 校正）
               // 原因：纹理通常是 sRGB 空间，但 PBR 计算需要线性空间
             half4 basecolorLinear = pow(max(0, albedo),2.2);
             float MetalnessMask = mask.x;
             float RoughnessMask = mask.z;

               // ============ 第七步：菲涅尔反射 ============
                // 菲涅尔效应：从不同角度看表面，反射率不同
                // 应用：金属、水、等材质的边缘会更亮
             half4 MatCapLinear = pow(max(0, matcapSample), 2.2);
             half4 MatCapBlend = MatCapLinear * basecolorLinear;
             float rougnessOrMentalness = lerp(RoughnessMask, MetalnessMask, _MentalnessMaskEnable);
             half4 MatCapFinal = MatCapBlend * rougnessOrMentalness;
             float fresnelBase = vDotn - _FresnelScale;
             float fresnelPower = pow(fresnelBase, _FresnelPow);
             float fresnelRaw  = fresnelPower * 2.0;
             float fresnelFactor = clamp(fresnelRaw, 0.0, 1.0);
             float fresnelMask = 1.0 - fresnelFactor;
             half4 FresnelfinalColor = lerp(0.0, MatCapFinal,fresnelMask );
              // ============ 第八步：计算最终的基础颜色 ============
              float3 viewTangent = cross(normalize(norViewDir), float3(0.0,1.0,0.0));
              //切线与法线高度对齐时,就会出现各向异性高光
              float  biViewDot = dot(viewTangent, normalMixed);
              float3 pointToCamera = positionWS - cameraDir;
              float pointDistance = length(pointToCamera);
              float3 pointToCameraDir = pointToCamera / pointDistance;
              float3 normalFinal = normalize(normalMixed);
              //fresnelmix
              float3 fresnelBlend = lerp(basecolorLinear, (basecolorLinear * _BaseMetalness), FresnelfinalColor);
              float3 roughnessBlend = lerp(basecolorLinear,fresnelBlend, RoughnessMask );
              float3 anisoMentalEffect =lerp(1.0, lerp(1.0, 0.8, ((clamp((pow((clamp((biViewDot - 0.8), 0.0,1.0)), 0.2)), 0.0,1.0)) * 2.0)), _changeBY);
              float3 RougAnisoMix = roughnessBlend * anisoMentalEffect;
              float3 finalBaseColor = RougAnisoMix * _BaseColor * _TintValue;
              
              half4 final = lerp(albedo,mask.y * anisoPow * RoughnessMask  * albedo ,mask.y * anisoPow * RoughnessMask);
             half4 final2 = (half4(finalBaseColor, 1.0) + MatCapFinal * RoughnessMask * _MentalColor + MatCapFinal) * nDotl;
             return final2 ;
         }
         ENDHLSL


         }

      
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError" 
}

Shader "EggParty/Shaer_head"
{
    Properties
    {
        //texture
        _DiffuseTex ("Base Color", 2D) = "white" {}
        _MaskTex("Mask Texture",2D) = "gray"{}
        _GalaxyTex("Galaxy Texture One", 2D) = "black"{}
        _GalaxyTex2("Galaxy Texture Two", 2D) = "black"{}
        _Tex0("Noise Texture", 2D) = "white"{}
        _MactCap("MactCap", 2D) = "gray"{}
        //spark - x：density y：offset z：tiliing w：sampling
        _SparkPara("Spark Parameter", Vector) = (1,1,1,1)
        _FrameTime("Frame Time", float) = 0.2
        _SparkSpeed("Spark Speed", float) = 0.5
        _BlurAmount("Blur Amount", float) = 0.015
        _CenterIntensity("Center Intensity", float) = 2.5
        //Galaxy
        _galaxyOffset("Galaxy Offset",float) = 100.0
        //x y密度 z对比度  w亮度
        _galaxyTexPara("Galaxy Texture Parameter",Vector) = (1.0,1.0,1.0,1.0)
        _galaxyNoiseMult("Galaxy Noise Multiple",float) = 1.0
        _galaxySpeedX("Galaxy Speed X", float) = 1.0
        _galaxySpeedY("Galaxy Speed Y", float) = 1.0
        _emisPara("Emission Parameter", Vector) = (1.0,1.0,1.0,1.0)
        _noiseColor01("Noise Color1", Color) = (1.0,1.0,1.0,1.0)
        _customMaskEmiCol("Mask Emission Color",float) = 0.5
        _galaxytex2Pow("Galaxy2 Pow", float) = 1.0
        _galaxytex2Mul("Galaxy2 Multiple",float) = 1.0
        _areaSwitch("Area Switch",float) = 1.0
        _maskEmisPow("Mask Emission Pow", float) = 1.0
        _maskEmisMul("Mask Emission Multiple", float) = 1.0
        //Rim
        //_FresnelPara：x:基础反射率;y:对比度，中心与边缘;z:边缘锐度控制;w：强度；
        _fresnelPara("Fresnel Parameter",Vector) = (0.1, 0.5, 2.0, 2.0) 
        //matcap  x y z w分别有一个作用
        _matcapPara("MactCap Parameter", Vector) = (1.0,1.0,1.0,1.0)
    
    
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


           

           //顶点着色器输入
           struct a2v
           {
               float3 positionOS : POSITION;
               float3 normalOS : NORMAL;
               float4 tangentOS : TANGENT;
               float2 uv : TEXCOORD0;
                 
           };
           //片元着色器输入
           struct v2f
           {
               float4 positionCS : SV_POSITION;//裁剪空间
               float3 positionWS : TEXCOORD0;
               float3 normalWS : TEXCOORD1;
               float2 uv : TEXCOORD2;
               float3 tangentWS : TEXCOORD3;
               float3 bitangent : TEXCOORD4;
               float3 normalOS : TEXCOORD5;
               float3 modelOringWS : TEXCOORD6;
           };


             //纹理采样器
            TEXTURE2D(_DiffuseTex);
            SAMPLER(sampler_DiffuseTex);
            TEXTURE2D(_MaskTex);
            SAMPLER(sampler_MaskTex);
            TEXTURE2D(_GalaxyTex);
            SAMPLER(sampler_GalaxyTex);
            TEXTURE2D(_GalaxyTex2);
            SAMPLER(sampler_GalaxyTex2);
            TEXTURE2D(_Tex0);
            SAMPLER(sampler_Tex0);
            TEXTURE2D(_MactCap);
            SAMPLER(sampler_MactCap);

           //常量buffer缓冲器，全局
           CBUFFER_START(UnityPerMaterial)
               float4 _DiffuseTex_ST;

               //Spark
               float4 _SparkPara;
               float _FrameTime;
               float _SparkSpeed;
               float _BlurAmount ;
               float _CenterIntensity;
               //Galaxy
               float _galaxyOffset;
               float4 _galaxyTexPara;
               float _galaxyNoiseMult;
               float _galaxySpeedX;
               float _galaxySpeedY;
               float4 _emisPara;
               float4 _noiseColor01;
               float _customMaskEmiCol;
               float _galaxytex2Pow;
               float _galaxytex2Mul;
               float _areaSwitch;
               float _maskEmisPow;
               float _maskEmisMul;
               //Rim
               float4 _fresnelPara;
               //Matcap
               float4 _matcapPara;

           CBUFFER_END


           //顶点着色器
           v2f vert(a2v i)
           {
               v2f o;
              //法线，切线，位置，副切线（法线）处理
               float3 _worldPos =  TransformObjectToWorld( i.positionOS);
               float4 _clipPos =  TransformWorldToHClip( _worldPos);
               float3 _normalWS = normalize(TransformObjectToWorldNormal(i.normalOS));
               float3 _tangentWS = normalize(TransformObjectToWorldDir(i.tangentOS.xyz));
               float3 _bitangent = cross(_normalWS, _tangentWS) * i.tangentOS.w;
              //赋值，输出
               o.positionWS = _worldPos;
               o.positionCS = _clipPos;
               o.normalWS = _normalWS;
               o.tangentWS = _tangentWS;
               o.bitangent = _bitangent;
               o.normalOS = i.normalOS;
               o.modelOringWS = TransformObjectToWorld(float3(0,0,0));
               o.uv = TRANSFORM_TEX(i.uv, _DiffuseTex);

               return o;
           }

            // 片元着色器
           half4 frag(v2f i) : SV_Target
           {
        
               //输入预准备
               float4 positionCS = i.positionCS;//裁剪空间
               float3 positionWS = i.positionWS;
               float3 positionVS = TransformWorldToView(positionWS);
               float3 normalWS = normalize(i.normalWS);
               float2 uv = i.uv;
               float3 tangentWS = normalize(i.tangentWS);
               float3 bitangent = normalize(i.bitangent);
               float3 normalOS = normalize(i.normalOS);
               float3 normalVS = TransformWorldToViewNormal(normalWS);
               float3 modelOringWS = i.modelOringWS;
                // 构建TBN矩阵（从切线空间到世界空间）
               float3x3 TBN = float3x3(tangentWS, bitangent, normalWS);
               float3x3 TBN_T = transpose(float3x3(tangentWS, bitangent, normalWS));
                 //方向计算
               float3 cameraDir = normalize(_WorldSpaceCameraPos.xyz);
               float3 viewDir = normalize(cameraDir - positionWS);
               float3 viewdirWS = mul(TBN, viewDir);
               float3 viewdirVS = normalize(-positionVS);
               float vDotn = dot(viewDir,i.normalWS);
               //贴图的基础采样,无uv偏移
               half4 baseMask = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, uv);
               half4 albedo = SAMPLE_TEXTURE2D(_DiffuseTex,sampler_DiffuseTex,uv);
               half4 baseGalaxy1 = SAMPLE_TEXTURE2D(_GalaxyTex,sampler_GalaxyTex,uv);
               half4 baseGalaxy2 = SAMPLE_TEXTURE2D(_GalaxyTex2,sampler_GalaxyTex2,uv);
               half4 baseTex0 = SAMPLE_TEXTURE2D(_Tex0,sampler_Tex0,uv);
               //第一层视差uv计算
               float2 tillingUV = (uv * _SparkPara.y) * 3.0;
               float2 viewOffset = viewdirWS.xy * _SparkPara.z;
               float2 timeOffset = _SparkSpeed * _Time.x;
               float2 finalstarUV = tillingUV + viewOffset + timeOffset; 
               float samplingPara = _SparkPara.w;
              
               //多重采样，减少锯齿
               half4 upSampling = SAMPLE_TEXTURE2D(_Tex0,sampler_Tex0,finalstarUV + samplingPara);
               half4 downSampling = SAMPLE_TEXTURE2D(_Tex0,sampler_Tex0,finalstarUV - samplingPara);
               half4 centerSampling = SAMPLE_TEXTURE2D(_Tex0,sampler_Tex0,finalstarUV);
                //第二层视差
               float2 tillingUV2 = tillingUV * 1.4;
               //第二次多重采样
               half4 upSampling2 = SAMPLE_TEXTURE2D(_Tex0,sampler_Tex0,tillingUV2 + samplingPara);
               half4 downSampling2 = SAMPLE_TEXTURE2D(_Tex0,sampler_Tex0,tillingUV2 - samplingPara * 2.0);
               half4 centerSampling2 = SAMPLE_TEXTURE2D(_Tex0,sampler_Tex0,tillingUV2);
               //Matcap
               float3 horizenVec = normalize(cross(viewdirVS,float3(0.0,1.0,0.0)));
               float norhorlen = dot(normalVS,horizenVec);
               float norverlen = dot(normalVS, cross(viewdirVS, horizenVec));
               float2 matcapUV = float2(norhorlen,norverlen) * 0.5 + float2(0.5, 0.5);
               half4 matcap = SAMPLE_TEXTURE2D(_MactCap,sampler_MactCap, matcapUV);
               //像素相对于模型原点的世界空间偏移
               float3 worldOffset = positionWS - modelOringWS;
               float2 maskbaseUV = (TransformWorldToView(worldOffset)).xy * _galaxyTexPara.y;
               half4 flowEffect = SAMPLE_TEXTURE2D(_Tex0,sampler_Tex0, (maskbaseUV + float2(_Time.x * 0.050000001, _Time.x * 0.050000001)));
              //galaxytex
               float2 galaxymulOffset = _galaxyNoiseMult * flowEffect.x;
               float2 galaxytimeOffset = float2(_galaxySpeedX,_galaxySpeedY) * _Time.x;
               float2 galaxyUV = maskbaseUV + galaxymulOffset + galaxytimeOffset;
               half4 galaxytex1 = SAMPLE_TEXTURE2D(_GalaxyTex,sampler_GalaxyTex, galaxyUV);
               half4 galaxytex2 = SAMPLE_TEXTURE2D(_GalaxyTex2,sampler_GalaxyTex2, galaxyUV);

                 //Gamma 压缩,2.2是标准伽马值,伽马到线性空间转换
               half4 gammaAlbedo = pow(max(float4(0.0,0.0,0.0,0.0) , albedo) , 2.2);
               half4 maskEmission = (pow(gammaAlbedo, _emisPara.x) * baseMask.y) * _emisPara.y;
               //viewDir反方向
               float3 inverseViewDir = positionWS - cameraDir;
               float leninverseViewDir = length(inverseViewDir);
               float3 normInverViewDir = inverseViewDir / leninverseViewDir;
               half4 galaxyColor = max(0.0,galaxytex1);
               half4 linearColor = pow(galaxyColor ,2.2);
               half4 adjustConstract = pow(linearColor ,_galaxyTexPara.z);
               half4 finalgalaxy1 = adjustConstract * _galaxyTexPara.w;
               half4 blendgalaxy1 = lerp(_noiseColor01, finalgalaxy1, 0.5);
               half4 blendAlbedo = lerp(maskEmission, blendgalaxy1,_customMaskEmiCol);
               half4 finalColor1 = blendAlbedo;
               //fresnel： Schlick近似  F(θ) = F₀ + (1 - F₀) * (1 - max(0, dot(N, V)))^p
               float fresnelStrenght = max(0.0, pow(min(1.0, _fresnelPara.x + (_fresnelPara.y * (1.0 - vDotn))),_fresnelPara.z));
              // (A 银河纹理) + (B菲涅尔边缘) + (C Matcap 高光) + (D遮罩自发光);
                //A银河纹理
              half4 linearColor2 = pow(max(galaxytex2, 0.0), 2.2);
              half4 galaxy2Strength = (pow(linearColor2, _galaxytex2Pow)) * _galaxytex2Mul;
              half4 mix1 = lerp(galaxy2Strength , finalgalaxy1 , baseMask.w * (1.0 + baseGalaxy2.w * 5.0));
              half4 mix2 = lerp(finalgalaxy1, mix1, _areaSwitch);
              half4 finalGalaxy = mix2;
                //B 菲涅尔边缘 = (基础颜色 * 菲涅尔强度) * 全局强度 * 噪声扰动
              half4 finalFresnel = ( finalColor1 * fresnelStrenght) * _fresnelPara.w * clamp((baseTex0.z + 0.1), 0.0, 1.0);
                //C Matcap
              half4 pow1 = pow(pow(max(matcap, 0.0), 2.2),_matcapPara.y * _matcapPara.x );
                  //matcap.w是一张边缘mask
              half4 pow2 = pow(matcap.w, _matcapPara.w) * _matcapPara.z;
              half4 finalMatcap = pow1 + pow2;
                 //D 遮罩自发光
              half4 maskEmis = ((blendAlbedo * pow(baseMask.x, _maskEmisPow)) * 7.0) * _maskEmisMul;
              
              half4 final1 = finalGalaxy + finalFresnel + finalMatcap + maskEmis;
              float basefresnel = (1.0 - vDotn) * (1.0 - vDotn);
               return final1;
           }
           ENDHLSL
        }
    
    }
     FallBack "Hidden/Universal Render Pipeline/FallbackError" 
}
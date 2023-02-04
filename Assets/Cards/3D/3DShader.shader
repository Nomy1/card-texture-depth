Shader "Example/3D"
{
    Properties
    { 
        // textures
        [NoScaleOffset] _BorderMap("Border Map", 2D) = "white" {}
        [NoScaleOffset] _AlphaMap("Alpha Map", 2D) = "white" {}
        _BackgroundMap("Background Map", 2D) = "white" {}
        [MainTexture] _MidgroundMap("Midground Map", 2D) = "white" {}
        _TitleMap("Title Map", 2D) = "white" {}
        // distance
        _BackgroundDistance("Background Distance", Range(0.0, 1.0)) = 0.0
        _MidgroundDistance("Midground Distance", Range(0.0, 1.0)) = 0.0
        _TitleDistance("Title Distance", Range(-0.5, 0.0)) = 0.0
    }

    SubShader
    {
        PackageRequirements
        {
            "com.unity.render-pipelines.universal": "14.0.0"  
        }
        
        Tags 
        { 
            "RenderType" = "Transparent" 
            "Queue" = "Transparent"
            "RenderPipeline" = "UniversalRenderPipeline" 
        }

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"            

            // Card border texture
            TEXTURE2D(_BorderMap);
            SAMPLER(sampler_BorderMap);

            // Background texture
            TEXTURE2D(_BackgroundMap);
            SAMPLER(sampler_BackgroundMap);

            // Midground texture
            TEXTURE2D(_MidgroundMap);
            SAMPLER(sampler_MidgroundMap);

            // Title texture
            TEXTURE2D(_TitleMap);
            SAMPLER(sampler_TitleMap);

            // Alpha cutoff texture
            TEXTURE2D_HALF(_AlphaMap);
            SAMPLER(sampler_AlphaMap);

            
            CBUFFER_START(UnityPerMaterial)
            // pack textures in buffer for TRANSFORM_TEX macro to work
            float4 _BorderMap_ST;
            float4 _BackgroundMap_ST;
            float4 _MidgroundMap_ST;
            float4 _AlphaMap_ST;
            float4 _TitleMap_ST;
            // pack material properties
            float _BackgroundDistance;
            float _MidgroundDistance;
            float _TitleDistance;
            CBUFFER_END

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float2 titleuv : TEXCOORD1;
                float3 positionWS : TEXCOORD2;
                float3 viewDir : TEXCOORD3;
                float h : DEPTH0;
                float v : DEPTH1;
            };            
            
            v2f vert(appdata input)
            {
                v2f output;

                output.vertex = TransformObjectToHClip(input.vertex);
                output.positionWS = TransformObjectToWorld(input.vertex);
                output.normal = TransformObjectToWorldNormal(input.normal);
                output.viewDir = normalize(GetWorldSpaceViewDir(output.positionWS));
                
                const float3 cameraRight = mul((float3x3)unity_CameraToWorld, float3(1,0,0));
                const float3 cameraUp = mul((float3x3)unity_CameraToWorld, float3(0,1,0));

                float horizontal = dot(output.normal, cameraRight);
                float vertical = dot(output.normal, cameraUp);

                output.h = horizontal;
                output.v = vertical;
                output.uv = TRANSFORM_TEX(input.uv, _BackgroundMap);
                output.titleuv = TRANSFORM_TEX(input.uv, _TitleMap);

                return output;
            }
        
            half4 frag(v2f input) : SV_Target
            {
                float2 titleOffsetUv = float2(input.h * _TitleDistance, input.v * _TitleDistance);
                float4 titleCol = SAMPLE_TEXTURE2D(_TitleMap, sampler_TitleMap, input.titleuv + titleOffsetUv);
                float4 alphaCol = SAMPLE_TEXTURE2D(_AlphaMap, sampler_AlphaMap, input.uv);
                float4 borderCol = SAMPLE_TEXTURE2D(_BorderMap, sampler_BorderMap, input.uv);
                float2 backgroundOffsetUV = float2(input.h * _BackgroundDistance, input.v * _BackgroundDistance);
                float4 bgCol = SAMPLE_TEXTURE2D(_BackgroundMap, sampler_BackgroundMap, input.uv + backgroundOffsetUV);
                float2 midgroundOffsetUV = float2(input.h * _MidgroundDistance, input.v * _MidgroundDistance);
                float4 midCol = SAMPLE_TEXTURE2D(_MidgroundMap, sampler_MidgroundMap, input.uv + midgroundOffsetUV);

                half1 borderAlpha = step(0.5, borderCol.a);
                half1 bgAlpha = step(0.5, alphaCol.r);
                half1 midAlpha = step(0.5, midCol.a);
                    
                half4 col = titleCol.a ?
                    titleCol :
                    (borderAlpha ?
                        borderCol :
                        bgAlpha ?
                            half4(0,0,0,0) : !midAlpha ?
                                bgCol : midCol);


                /*
                // if-else
                //
                float4 col = borderCol;
                
                if(titleCol.a > 0.1)
                {
                    col = titleCol;
                }
                else if(alphaCol.a < 0.8)
                {
                    if(midCol.a > 0.5)
                    {
                        col = midCol;
                    }
                    else
                    {
                         col = bgCol;
                    }
                } else
                {
                    if(borderCol.a > 0.9)
                    {
                        col = borderCol;
                    }
                    else
                    {
                        discard;
                    }
                }
                */
                

                //float dotVal = dot(input.viewDir, input.normal);
                
                return col;
            }
            ENDHLSL
        }
    }
}
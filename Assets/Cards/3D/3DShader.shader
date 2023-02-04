// This shader fills the mesh shape with a color predefined in the code.
Shader "Example/3D"
{
    // The properties block of the Unity shader. In this example this block is empty
    // because the output color is predefined in the fragment shader code.
    Properties
    { 
        // Base card texture
        _BorderMap("Border Map", 2D) = "white" {}
        _AlphaMap("Alpha Map", 2D) = "white" {}
        _BackgroundMap("Background Map", 2D) = "white" {}
        _MidgroundMap("Midground Map", 2D) = "white" {}
        //_ForegroundMap("Foreground Map", 2D) = "white" {}
    }

    // The SubShader block containing the Shader code. 
    SubShader
    {
        // SubShader Tags define when and under which conditions a SubShader block or
        // a pass is executed.
        Tags 
        { 
            "RenderType" = "Transparent" 
            "Queue" = "Transparent"
            "RenderPipeline" = "UniversalRenderPipeline" 
        }

        Pass
        {
            // Blend SrcAlpha OneMinusSrcAlpha
            
            
            
            // The HLSL code block. Unity SRP uses the HLSL language.
            HLSLPROGRAM
            // This line defines the name of the vertex shader. 
            #pragma vertex vert
            // This line defines the name of the fragment shader. 
            #pragma fragment frag

            // The Core.hlsl file contains definitions of frequently used HLSL
            // macros and functions, and also contains #include references to other
            // HLSL files (for example, Common.hlsl, SpaceTransforms.hlsl, etc.).
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"            

            TEXTURE2D(_BorderMap);
            TEXTURE2D(_BackgroundMap);
            TEXTURE2D(_MidgroundMap);
            TEXTURE2D(_AlphaMap);
            //TEXTURE2D(_ForegroundMap);
            SAMPLER(sampler_BackgroundMap);
            SAMPLER(sampler_BorderMap);
            SAMPLER(sampler_MidgroundMap);
            SAMPLER(sampler_AlphaMap);
            
            CBUFFER_START(UnityPerMaterial)
            float4 _BorderMap_ST;
            float4 _BackgroundMap_ST;
            float4 _MidgroundMap_ST;
            float4 _AlphaMap_ST;
            //float4 _ForegroundMap_ST;
            CBUFFER_END

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float2 bgUV : TEXCOORD0;
                float2 midUV : TEXCOORD1;
                float2 borderUV : TEXCOORD2;
                float3 positionWS : TEXCOORD3;
                float3 viewDir : TEXCOORD4;
            };            
            
            v2f vert(appdata IN)
            {
                v2f OUT;

                VertexNormalInputs normInputs = GetVertexNormalInputs(IN.normal);
                OUT.normal = normInputs.normalWS;
                VertexPositionInputs posInputs = GetVertexPositionInputs(IN.vertex);
                OUT.vertex = posInputs.positionCS;
                OUT.positionWS = posInputs.positionWS;

                half3 viewDir = GetWorldSpaceNormalizeViewDir(OUT.positionWS);

                float3 cameraRight = mul((float3x3)unity_CameraToWorld, float3(1,0,0));
                float3 cameraUp = mul((float3x3)unity_CameraToWorld, float3(0,1,0));
                
                OUT.viewDir = normalize(GetWorldSpaceViewDir(OUT.positionWS));
                float horizontal = dot(OUT.normal, cameraRight);
                float vertical = dot(OUT.normal, cameraUp);
                
                OUT.bgUV = TRANSFORM_TEX(IN.uv + float2(horizontal, vertical), _BackgroundMap);
                OUT.midUV = TRANSFORM_TEX(IN.uv + float2(horizontal * 0.5, vertical * 0.5), _MidgroundMap);
                OUT.borderUV = TRANSFORM_TEX(IN.uv, _BorderMap);
                
                
                
                return OUT;
            }
        
            float4 frag(v2f IN) : SV_Target
            {
                float4 bgCol = SAMPLE_TEXTURE2D(_BackgroundMap, sampler_BackgroundMap, IN.bgUV);
                float4 midCol = SAMPLE_TEXTURE2D(_MidgroundMap, sampler_MidgroundMap, IN.midUV);
                float4 borderCol = SAMPLE_TEXTURE2D(_BorderMap, sampler_BorderMap, IN.borderUV);
                float4 alphaCol = SAMPLE_TEXTURE2D(_AlphaMap, sampler_AlphaMap, IN.borderUV);

                float cardCol = bgCol + alphaCol;
                
                half3 viewDir = GetWorldSpaceNormalizeViewDir(IN.positionWS);

                float4 col = borderCol;
                
                if(alphaCol.a < 0.8)
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

                

                float dotVal = dot(IN.viewDir, IN.normal);
                
                return col;
            }
            ENDHLSL
        }
    }
}
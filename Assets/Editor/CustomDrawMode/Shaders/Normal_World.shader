
Shader "Hidden/CustomDrawMod_Normal_World"
{
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" }

        Pass
        {
            ZWrite On
            CGPROGRAM

            #pragma target 3.0

            // -------------------------------------

            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local _ _ALPHATEST_ON _ALPHABLEND_ON _ALPHAPREMULTIPLY_ON
            #pragma shader_feature _EMISSION
            #pragma shader_feature_local _METALLICGLOSSMAP
            #pragma shader_feature_local _DETAIL_MULX2
            #pragma shader_feature_local _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature_local _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature_local _GLOSSYREFLECTIONS_OFF
            #pragma shader_feature_local _PARALLAXMAP

            #pragma multi_compile_fwdbase
            #pragma multi_compile_instancing

            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            #include "UnityStandardInput.cginc"
            #include "lib.cginc"

            float4 frag(v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

                float4 uv = GetUV(i);

                half alpha = Alpha(uv.xy);
                #if defined(_ALPHATEST_ON)
                    clip(alpha - _Cutoff);
                #endif

                float3 n = float3(0, 0, 1);

                #ifdef _NORMALMAP
                    n = NormalInTangentSpace(uv);
                #endif

                half3 worldNormal;
                worldNormal.x = dot(i.tspace0, n);
                worldNormal.y = dot(i.tspace1, n);
                worldNormal.z = dot(i.tspace2, n);

                worldNormal = worldNormal * 0.5 + 0.5;
                worldNormal = IsGammaSpace() ? worldNormal : pow(worldNormal, 2.2);
                worldNormal = normalize(worldNormal);

                return float4(worldNormal, 1);
            }
            ENDCG
        }
    }
}
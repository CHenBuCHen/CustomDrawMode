Shader "Hidden/CustomDrawMode_Roughness"
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
            #pragma shader_feature_local _SPECGLOSSMAP

            #pragma multi_compile_fwdbase
            #pragma multi_compile_instancing

            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            #include "UnityStandardInput.cginc"
            #include "lib.cginc"

            half4 frag(v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

                float4 uv = GetUV(i);

                half alpha = Alpha(uv.xy);
                #if defined(_ALPHATEST_ON)
                    clip(alpha - _Cutoff);
                #endif

                half r = 0;
                #ifdef _SPECGLOSSMAP
                    r = 1 - SpecularGloss(uv).a;
                #else
                    r = 1 - MetallicGloss(uv).g;
                #endif
                r = IsGammaSpace() ? r : pow(r, 2.2);

                return half4(r, r, r, 1);
            }
            ENDCG
        }
    }
}
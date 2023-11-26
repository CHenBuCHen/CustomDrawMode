struct v2f
{
    float4 vertex : SV_POSITION;
    float4 texcoord0 : TEXCOORD0;
    float4 texcoord1 : TEXCOORD1;
    float4 color : COLOR;
    float3 tangent : NORMAL;
    float3 worldPos : TEXCOORD2;
    half3 tspace0 : TEXCOORD3; // tangent.x, bitangent.x, normal.x
    half3 tspace1 : TEXCOORD4; // tangent.y, bitangent.y, normal.y
    half3 tspace2 : TEXCOORD5; // tangent.z, bitangent.z, normal.z
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

v2f vert(appdata_full v)
{
    v2f o;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
    UNITY_TRANSFER_INSTANCE_ID(v, o);

    o.vertex = UnityObjectToClipPos(v.vertex);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
    o.color = v.color;
    o.texcoord0 = v.texcoord;
    o.texcoord1 = v.texcoord1;
    o.tangent = v.tangent;
    half3 wNormal = UnityObjectToWorldNormal(v.normal);
    half3 wTangent = UnityObjectToWorldDir(v.tangent.xyz);
    // compute bitangent from cross product of normal and tangent
    half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
    half3 wBitangent = cross(wNormal, wTangent) * tangentSign;
    // output the tangent space matrix
    o.tspace0 = half3(wTangent.x, wBitangent.x, wNormal.x);
    o.tspace1 = half3(wTangent.y, wBitangent.y, wNormal.y);
    o.tspace2 = half3(wTangent.z, wBitangent.z, wNormal.z);
    return o;
}

float4 GetUV(v2f i)
{
    float4 texcoord;
    texcoord.xy = TRANSFORM_TEX(i.texcoord0, _MainTex); // Always source from uv0
    texcoord.zw = TRANSFORM_TEX(((_UVSec == 0) ? i.texcoord0 : i.texcoord1), _DetailAlbedoMap);
    return texcoord;
}

float3 HSVToRGB(float3 c)
{
    float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * lerp(K.xxx, saturate(p - K.xxx), c.y);
}

float3 RGBToHSV(float3 c)
{
    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
    float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

half _Smoothness;

half2 MetallicGloss_URP(float2 uv)
{
    half2 mg;

    #ifdef _METALLICSPECGLOSSMAP
        #ifdef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            mg.r = tex2D(_MetallicGlossMap, uv).r;
            mg.g = tex2D(_MainTex, uv).a;
        #else
            mg = tex2D(_MetallicGlossMap, uv).ra;
        #endif
        mg.g *= _Smoothness;
    #else
        mg.r = _Metallic;
        #ifdef _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            mg.g = tex2D(_MainTex, uv).a * _Smoothness;
        #else
            mg.g = _Smoothness;
        #endif
    #endif
    return mg;
}
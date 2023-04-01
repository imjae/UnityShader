Shader "Custom/NewSurfaceShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _Red ("Red", Range(0, 1)) = 0
        _Green ("Green", Range(0, 1)) = 0
        _Blue ("Blue", Range(0, 1)) = 0
        _BrightDark ("Brightness $ Darkness", Range(-2, 2)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;

        float _Red;
        float _Green;
        float _Blue;
        float _BrightDark;

        struct Input
        {
            float2 uv_MainTex;
        };

        fixed4 _Color;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo= fixed3(_Red, _Green, _Blue) + _BrightDark;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}

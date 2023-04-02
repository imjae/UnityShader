Shader "Custom/tex"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };
        
        fixed4 _Color;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            // 간단한 그레이 스케일은 각 rgb값의 평균
            float3 easyGrayScale = (c.r + c.g + c.b) / 3;
            // RGB to YIQ 변환 매트릭스 방식으로 그레이스케일 값 구하는 공식
            float3 grayScale = c.r * 0.2989 + c.g * 0.5870 + c.b * 0.1140;
            o.Albedo = grayScale;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}

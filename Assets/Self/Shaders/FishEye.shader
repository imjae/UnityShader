Shader "self/fisheye" 
{
    Properties 
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Strength ("Strength", Range(0, 1)) = 0.5
    }

    SubShader 
    {
        // Opaque geometry 이후에 렌더링
        Tags { "Queue" = "Transparent" }

        // 화면 뒤의 오브젝트를 _BackgroundTexture에 저장
        GrabPass 
        {
            "_BackgroundTexture"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 grabPos : TEXCOORD1;
                float4 pos : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Strength;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.grabPos = ComputeGrabScreenPos(o.pos);
                o.uv = v.uv;
                return o;
            }

            sampler2D _BackgroundTexture;

            half4 frag(v2f i) : SV_Target
            {

                float2 center = float2(0.5, 0.5);
                float2 offset = i.uv - center;
                float distance = length(offset);
                float2 distortedUV = center + offset * (1 + _Strength * distance);

                half4 bgcolor = tex2D(_MainTex, distortedUV);
                return bgcolor;
            }
            ENDCG
        }
    }
}
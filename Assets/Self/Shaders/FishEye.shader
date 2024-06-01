Shader "self/fisheye" 
{
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

            struct v2f
            {
                float4 grabPos : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.grabPos = ComputeGrabScreenPos(o.pos);
                return o;
            }

            sampler2D _BackgroundTexture;

            half4 frag(v2f i) : SV_Target
            {
                half4 bgcolor = tex2D(_BackgroundTexture, i.grabPos);
                return 1 - bgcolor; // 색상 반전
            }
            ENDCG
        }
    }
}
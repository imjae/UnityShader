Shader "Self/TVGlitchShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _HorizontalWaveLength ("HorizontalWaveLength", float) = 0
        _HorizontalWaveSpeed ("HorizontalWaveSpeed", float) = 0

        _NoiseScale ("NoiseScale", float) = 0

    }
    SubShader
    {
        Tags { "RenderType"="Transparent " }
        LOD 100

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
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float _HorizontalWaveLength;
            float _HorizontalWaveSpeed;
            float _NoiseScale;

            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 Remap_float4(float4 In, float2 InMinMax, float2 OutMinMax) 
            {
                float4 Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                return Out;
            }

            // Gradient Noise를 생성하는 함수
            float2 unity_gradientNoise_dir(float2 p)
            {
                p = p % 289;
                float x = (34 * p.x + 1) * p.x % 289 + p.y;
                x = (34 * x + 1) * x % 289;
                x = frac(x / 41) * 2 - 1;
                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
            }

            float unity_gradientNoise(float2 p)
            {
                float2 ip = floor(p);
                float2 fp = frac(p);
                float d00 = dot(unity_gradientNoise_dir(ip), fp);
                float d01 = dot(unity_gradientNoise_dir(ip + float2(0, 1)), fp - float2(0, 1));
                float d10 = dot(unity_gradientNoise_dir(ip + float2(1, 0)), fp - float2(1, 0));
                float d11 = dot(unity_gradientNoise_dir(ip + float2(1, 1)), fp - float2(1, 1));
                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                return lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x);
            }

            void GradientNoise(float2 UV, float Scale, out float Out)
            {
                Out = unity_gradientNoise(UV * Scale) + 0.5;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;



                float y = i.uv.y;
                float ty = y + _Time.y * _HorizontalWaveSpeed;
                float4 sineValue = sin(ty * _HorizontalWaveLength);

                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                col = col * Remap_float4(sineValue, float2(-1,1), float2(0.5, 1));

                return col;
            }

            ENDCG
        }
    }
}

Shader "Self/TVGlitchShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _HorizontalGlitchLength ("Horizontal WaveLength", Float) = 0
        _HorizontalGlitchSpeed ("Horizontal WaveSpeed", Float) = 1
        _MinHorizontalGlitch ("Minimum Horizontal Glitch", Float) = 1
        _MaxHorizontalGlitch ("Maximum Horizontal Glitch", Float) = 1
        _WaveNoiseScale ("Noise Scale", Float) = 0
        _WaveNoiseSpeed ("Noise Speed", Float) = 0
        _MinWaveNoise ("Minimum Noise Arrange", Float) = -1
        _MaxWaveNoise ("Maximum Noise Arrange", Float) = 1
        _BlinkNoiseSpeed ("Blink Noise Speed", Float) = 40
        _BlinkNoiseScale ("Blink Noise Scale", Float) = 10
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
            float _HorizontalGlitchLength;
            float _HorizontalGlitchSpeed;
            float _WaveNoiseScale;
            float _WaveNoiseSpeed;
            float _MinWaveNoise;
            float _MaxWaveNoise;

            float _BlinkNoiseSpeed;
            float _BlinkNoiseScale;

            float4 _MainTex_ST;

            float4 remap_float4(float4 In, float2 InMinMax, float2 OutMinMax) 
            {
                float4 Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                return Out;
            }

            float remap_float(float value, float2 InMinMax, float2 OutMinMax)
            {
                // Normalize the input value to the range [0, 1]
                float t = saturate((value - InMinMax.x) / (InMinMax.y - InMinMax.x));
                
                // Remap the normalized value to the output range
                return lerp(OutMinMax.x, OutMinMax.y, t);
            }

            // Gradient Noise를 생성하는 함수
            float2 gradientNoise_dir(float2 p)
            {
                p = p % 289;
                float x = (34 * p.x + 1) * p.x % 289 + p.y;
                x = (34 * x + 1) * x % 289;
                x = frac(x / 41) * 2 - 1;
                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
            }

            float gradientNoise(float2 p)
            {
                float2 ip = floor(p);
                float2 fp = frac(p);
                float d00 = dot(gradientNoise_dir(ip), fp);
                float d01 = dot(gradientNoise_dir(ip + float2(0, 1)), fp - float2(0, 1));
                float d10 = dot(gradientNoise_dir(ip + float2(1, 0)), fp - float2(1, 0));
                float d11 = dot(gradientNoise_dir(ip + float2(1, 1)), fp - float2(1, 1));
                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                return lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x);
            }

            void gradientNoise(float2 UV, float Scale, out float Out)
            {
                Out = gradientNoise(UV * Scale) + 0.5;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float blinkNoise;
                gradientNoise(_Time.y * _BlinkNoiseSpeed, _BlinkNoiseScale, blinkNoise);

                float waveNoise;
                gradientNoise(i.uv.g + _Time.y * _WaveNoiseSpeed, _WaveNoiseScale, waveNoise);
                float remapGradientNoise = remap_float(waveNoise, float2(0,1), float2(_MinWaveNoise, _MaxWaveNoise));

                float2 realUV = i.uv + remapGradientNoise * blinkNoise * blinkNoise * blinkNoise * blinkNoise;

                // sample the texture
                fixed4 col = tex2D(_MainTex, realUV);

                float horizontalGlitch2Time = i.uv.g + _Time.y * _HorizontalGlitchSpeed;
                float4 horizontalGlitchValue = sin(horizontalGlitch2Time * _HorizontalGlitchLength);
                col = col * remap_float4(horizontalGlitchValue, float2(-1,1), float2(0.5, 1));

                return col;
            }

            ENDCG
        }
    }
}

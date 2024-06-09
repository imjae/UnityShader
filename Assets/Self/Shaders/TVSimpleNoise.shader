Shader "Self/TVSimpleNoise"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        [MaterialPropertyDrawer(typeof(ShaderProperties))]
        _HorizontalGlitchLength ("Horizontal WaveLength", Float) = 0
        _HorizontalGlitchSpeed ("Horizontal WaveSpeed", Float) = 1
        _MinHorizontalGlitch ("Minimum Horizontal Glitch", Float) = 1
        _MaxHorizontalGlitch ("Maximum Horizontal Glitch", Float) = 1

        _PosterizeStepX ("PosterizeStep X", Range(1, 300)) = 100
        _PosterizeStepY ("PosterizeStep Y", Range(1, 300)) = 100

        _SimpleNoiseScale ("Simple Noise Scale", float) = 100
        _SimpleNoiseSpeed ("Simple Noise Speed", float) = 100

        _RemapSimpleNoiseMin ("Remap Simple Noise Min", Range(0, 1)) = 0
        _RemapSimpleNoiseMax ("Remap Simple Noise Max", Range(0, 1)) = 0

        _DistortionStrength ("Distortion Strength", Range(0, 1)) = 0.5

        _WaveNoiseScale ("Noise Scale", Float) = 0
        _WaveNoiseSpeed ("Noise Speed", Float) = 0
        _MinWaveNoise ("Minimum Noise Arrange", Float) = -1
        _MaxWaveNoise ("Maximum Noise Arrange", Float) = 1

        _BlinkNoiseSpeed ("Blink Noise Speed", float) = 0
        _BlinkNoiseScale ("Blink Noise Scale", float) = 0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        GrabPass
        {
            "_GrabTex"
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
                float4 grabUV : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                o.grabUV = ComputeGrabScreenPos(o.vertex);
                return o;
            }

            inline float unity_noise_randomValue (float2 uv)
            {
                return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
            }

            inline float unity_noise_interpolate (float a, float b, float t)
            {
                return (1.0-t)*a + (t*b);
            }

            inline float unity_valueNoise (float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                f = f * f * (3.0 - 2.0 * f);

                uv = abs(frac(uv) - 0.5);
                float2 c0 = i + float2(0.0, 0.0);
                float2 c1 = i + float2(1.0, 0.0);
                float2 c2 = i + float2(0.0, 1.0);
                float2 c3 = i + float2(1.0, 1.0);
                float r0 = unity_noise_randomValue(c0);
                float r1 = unity_noise_randomValue(c1);
                float r2 = unity_noise_randomValue(c2);
                float r3 = unity_noise_randomValue(c3);

                float bottomOfGrid = unity_noise_interpolate(r0, r1, f.x);
                float topOfGrid = unity_noise_interpolate(r2, r3, f.x);
                float t = unity_noise_interpolate(bottomOfGrid, topOfGrid, f.y);
                return t;
            }

            void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
            {
                float t = 0.0;

                float freq = pow(2.0, float(0));
                float amp = pow(0.5, float(3-0));
                t += unity_valueNoise(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

                freq = pow(2.0, float(1));
                amp = pow(0.5, float(3-1));
                t += unity_valueNoise(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

                freq = pow(2.0, float(2));
                amp = pow(0.5, float(3-2));
                t += unity_valueNoise(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

                Out = t;
            }

            void Unity_Posterize_float4(float4 In, float4 Steps, out float4 Out)
            {
                Out = floor(In / (1 / Steps)) * (1 / Steps);
            }

            void Unity_Remap_float4(float4 In, float2 InMinMax, float2 OutMinMax, out float4 Out)
            {
                Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
            }

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

            void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
            {
                Out = unity_gradientNoise(UV * Scale) + 0.5;
            }

            void DistoredGrabUV(float4 grabUV, float DistortionStrength, out float2 OutDistoredUV)
            {
                float2 center = float2(0.5, 0.5);
                float2 offset = grabUV.xy - center;
                float distance = length(offset);
                
                OutDistoredUV = center + offset * (1 + DistortionStrength * distance);
            }

            sampler2D _MainTex;
            sampler2D _GrabTex;

            float _HorizontalGlitchLength;
            float _HorizontalGlitchSpeed;
            float _MinHorizontalGlitch;
            float _MaxHorizontalGlitch;

            float _PosterizeStepX;
            float _PosterizeStepY;

            float _SimpleNoiseScale;
            float _SimpleNoiseSpeed;

            float _RemapSimpleNoiseMin;
            float _RemapSimpleNoiseMax;

            float _DistortionStrength;

            float _WaveNoiseScale;
            float _WaveNoiseSpeed;
            float _MinWaveNoise;
            float _MaxWaveNoise;

            float _BlinkNoiseSpeed;
            float _BlinkNoiseScale;

            fixed4 frag (v2f i) : SV_Target
            {
                float4 posterizeValue;
                Unity_Posterize_float4(i.grabUV, float4(_PosterizeStepX,_PosterizeStepY,0,0), posterizeValue);

                float simpleNoiseValue;
                Unity_SimpleNoise_float(posterizeValue.xy, _SimpleNoiseScale, simpleNoiseValue);

                float noiseValue = frac(simpleNoiseValue * _Time.y * _SimpleNoiseSpeed);

                float4 remapNoiseValue;
                Unity_Remap_float4(noiseValue, float2(0, 1), float2(_RemapSimpleNoiseMin, _RemapSimpleNoiseMax), remapNoiseValue);

                float2 distoredUV;
                DistoredGrabUV(i.grabUV, _DistortionStrength, distoredUV);

                float waveNoise;
                Unity_GradientNoise_float(i.grabUV.g + _Time.y * _WaveNoiseSpeed, _WaveNoiseScale, waveNoise);

                float4 remapWaveNoise;
                Unity_Remap_float4(waveNoise, float2(0,1), float2(_MinWaveNoise, _MaxWaveNoise), remapWaveNoise);

                float blinkNoise;
                Unity_GradientNoise_float(_Time.y * _BlinkNoiseSpeed, _BlinkNoiseScale, blinkNoise);

                float2 resultUV = distoredUV;// + remapWaveNoise.x + blinkNoise * blinkNoise  * blinkNoise * blinkNoise;

                fixed4 color = tex2D(_GrabTex, resultUV);// * noiseValue;
                
                float horizontalGlitch2Time = resultUV.g + _Time.y * _HorizontalGlitchSpeed;
                float4 horizontalGlitchValue = sin(horizontalGlitch2Time * _HorizontalGlitchLength);

                float4 horizontalGlitchColor;
                Unity_Remap_float4(horizontalGlitchValue, float2(-1, 1), float2(_MinHorizontalGlitch, _MaxHorizontalGlitch), horizontalGlitchColor);
                return color * remapNoiseValue.x * horizontalGlitchColor ;
            }
            ENDCG
        }
    }
}

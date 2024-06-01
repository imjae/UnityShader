Shader "Self/FishEye"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _DistortionAmount ("Distortion Amount", Range(0, 1)) = 0.5
    }

    SubShader
    {
        // Draw after all opaque geometry
        Tags { "Queue" = "Transparent" }

        // Render the object with the texture generated above, and invert the colors
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

            v2f vert(appdata_base v) {
                v2f o;
                // use UnityObjectToClipPos from UnityCG.cginc to calculate 
                // the clip-space of the vertex
                o.pos = UnityObjectToClipPos(v.vertex);

                // use ComputeGrabScreenPos function from UnityCG.cginc
                // to get the correct texture coordinate
                o.grabPos = ComputeGrabScreenPos(o.pos);
                return o;
            }


            half4 frag(v2f i) : SV_Target
            {
                half4 bgcolor = tex2D(_MainTex, i.grabPos);
                return 1 - bgcolor;
            }
            ENDCG
        }

    }
}
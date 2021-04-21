Shader "Custom/DiffuseEmptyLevel"{
    SubShader{
        pass{
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            struct a2v{
                float4 pos:POSITION;
                float3 normal:normal;
            };
            struct v2f{
                float4 pos:sv_position;
                float3 color:color;
            };
            v2f vert(a2v i){ 
                v2f o;
                o.pos = UnityObjectToClipPos(i.pos);
                o.color = float3(1,1,1);
                return o;
            }
            float4 frag(v2f o):sv_target{
                return float4(o.color,1);
            }
            ENDCG
        }
    }
}
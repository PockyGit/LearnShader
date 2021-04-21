// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/DiffusePxielLevel"{
    properties{
        _Diffuse("Diffuse Color",Color)=(1,1,1,1)
    }
    SubShader{
        pass{
            Tags{"LightMode"="ForwardBase"}

            CGPROGRAM
            #include "Lighting.cginc"
            #pragma vertex vert
            #pragma fragment frag
            float4 _Diffuse;

            struct a2v{
                float4 vertex:POSITION;
                float3 normal:normal;//模型空间下的坐标
            };   
            struct v2f{
                float4 pos :sv_position;
                fixed3 normal:color;
            };       

            v2f vert(a2v input){
                v2f output;
                output.pos = UnityObjectToClipPos(input.vertex);
                output.normal = input.normal;
                return output;
            }
            float4 frag(v2f input):sv_target{
                float3 normalWorld = normalize(mul(input.normal,(float3x3)unity_WorldToObject));
                float3 lightWorld = normalize(_WorldSpaceLightPos0.rgb);
                float3 ambientColor = UNITY_LIGHTMODEL_AMBIENT;
                
                //漫反射 = 光线颜色和强度* 漫反射系数 * 法线dot入射光线
                float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(normalWorld,lightWorld));
                float3 colorRes = diffuse + ambientColor;

                return float4(colorRes,1.0);
            }

            ENDCG
        }
    }

    fallback "diffuse"
}
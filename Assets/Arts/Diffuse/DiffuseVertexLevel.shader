// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/DiffuseVertexLevel"{
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

            struct Application2VertexShader{
                float4 vertex:POSITION;
                float3 normal:normal;//模型空间下的坐标
            };   
            struct VertexShader2Fragment{
                float4 pos :sv_position;
                fixed3 color:color;
            };       

            VertexShader2Fragment vert(Application2VertexShader a2v){
                VertexShader2Fragment v2f;
                v2f.pos = UnityObjectToClipPos(a2v.vertex);
                fixed3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.rgb;
                
                //矩阵乘在后面，等于逆矩阵：也就是模型空间到世界坐标
                fixed3 normalWorld = normalize(mul(a2v.normal,(float3x3)unity_WorldToObject));
                //世界坐标系中的光源方向
                fixed3 lightWorld = normalize(_WorldSpaceLightPos0.rgb);
                
                //计算漫反射:入射光线的颜色和强度 * 材质的漫反射系数 * 表面法线和光源方向的点乘）
                //saturate:截取结果在[0-1]范围,防止负值
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(normalWorld,lightWorld));
                v2f.color = ambientColor + diffuse;
                
                return v2f;
            }
            float4 frag(VertexShader2Fragment v2f):sv_target{
                return float4(v2f.color,1.0);
            }

            ENDCG
        }
    }

    fallback "diffuse"
}
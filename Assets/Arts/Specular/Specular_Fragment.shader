Shader"Custom/Specular_Fragment"{
    Properties{
        _Diffuse("Diffuse Color",Color) = (1,1,1,1)
        _Specular("Specular Color",Color) = (1,1,1,1)
        _Gloss("_Gloss Value",Range(8,256)) = 20
    }
    SubShader{
        pass{
            Tags { "LightMode"="ForwardBase" }
            CGPROGRAM
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma vertex vert
            #pragma fragment frag
            struct a2v{
                float4 vertex:POSITION;
                float3 normal:NORMAL;
            };
            struct v2f{
                float4 pos :SV_POSITION;
                float4 worldPos :TEXCOORD0;
                float3 worldNormal:TEXCOORD1;
            };
            float3 _Diffuse;
            float3 _Specular;
            float _Gloss;
            
            v2f vert(a2v v){
                v2f o; 
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }
            float4 frag(v2f f):SV_TARGET{
                //DIFFUSE = _Diffuse.rgb * _Light.rgb * max(0,dot(worldNormal,worldLightDir));
                float3 worldNormal = normalize(UnityObjectToWorldNormal(f.worldNormal));
                float3 worldLightDir =UnityWorldSpaceLightDir(f.worldPos);
                float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));//* 0.5 + 0.5

                //specular
                float3 viewDir =normalize(UnityWorldSpaceViewDir(f.worldPos));
                float3 reflactDir = normalize(reflect(-worldLightDir,worldNormal));
                float3 specularRateOld = pow(max(0,dot(reflactDir,viewDir)),_Gloss);
                float3 specular = _LightColor0.rgb * _Specular.rgb * specularRateOld;
                float3 color = UNITY_LIGHTMODEL_AMBIENT.rgb + diffuse + specular;
                
                return float4(color,1.0);
            }
            ENDCG
        }
    }
}
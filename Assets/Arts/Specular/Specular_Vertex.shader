Shader"Custom/Specular_Vertex"{
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
                float3 color :Color;
            };
            float3 _Diffuse;
            float3 _Specular;
            float _Gloss;
            
            v2f vert(a2v v){
                //DIFFUSE = _Diffuse.rgb * _Light.rgb * max(0,dot(worldNormal,worldLightDir));
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
                float3 worldLightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                float3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                float3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));//* 0.5 + 0.5

                //specular
                float3 viewDir =normalize(UnityWorldSpaceViewDir(worldPos));
                float3 halfDir = normalize(worldLightDir + viewDir);
                float3 specularRate = pow(max(0,dot(worldNormal,halfDir)),_Gloss);

                float3 reflactDir = normalize(reflect(-worldLightDir,worldNormal));
                float3 specularRateOld = pow(max(0,dot(reflactDir,viewDir)),_Gloss);
                
                float3 specular = _LightColor0.rgb * _Specular.rgb * specularRateOld;

                v2f o; 
                o.pos = UnityObjectToClipPos(v.vertex);
                o.color= UNITY_LIGHTMODEL_AMBIENT.rgb + diffuse + specular;

                return o;
            }
            float4 frag(v2f f):SV_TARGET{
                return float4(f.color,1.0);
            }
            ENDCG
        }
    }
}
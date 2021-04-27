// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/Texture_Ramp"
{
    Properties{
        _Color("_Color",Color) = (1,1,1,1)
        _Ramp("_Ramp",2D) = "Whilte"{}
        _Specular("_Specular",Color) = (1,1,1,1)
        _Gloss("_Gloss",Range(8,256)) = 20
    }
    SubShader{
        pass{
            Tags{"LightMode" = "ForwardBase"}

            CGPROGRAM
            float4 _Color;
            sampler2D _Ramp;
            float4 _Ramp_ST;
            float4 _Specular;
            float _Gloss;
            
            #include"Lighting.cginc"
            #pragma vertex vert
            #pragma fragment frag
            struct a2v{
                float4 vertex :POSITION;
                float3 normal :NORMAL;
                float4 texcoord: TEXCOORD0;//uv坐标
            };
            struct v2f{
                float4 pos :SV_POSITION;
                float3 worldNormal:TEXCOORD0;
                float3 worldPos:TEXCOORD1;
                float2 uv:TEXCOORD2;
            };
            v2f vert(a2v i){
                v2f o;
                o.pos = UnityObjectToClipPos(i.vertex);
                o.worldNormal = UnityObjectToWorldNormal(i.normal);
                o.worldPos =mul(unity_ObjectToWorld,i.vertex);
                o.uv = TRANSFORM_TEX(i.texcoord,_Ramp);
                return o;
            }
            float4 frag(v2f i):SV_TARGET{
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb;
                
                fixed halfLambert = dot(worldNormal,worldLightDir) * 0.5 + 0.5;
                fixed lambert = dot(worldNormal,worldLightDir);
                fixed3 diffuseColor = tex2D(_Ramp,fixed2(lambert,lambert)).rgb * _Color.rgb;
                fixed3 diffuse = _LightColor0.rgb * diffuseColor;
                
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 halfDir = normalize(viewDir + worldLightDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal,halfDir)),_Gloss);

                return float4(ambient + diffuse + specular,1);
            }
            ENDCG
        }
    }

    Fallback "specular"
}
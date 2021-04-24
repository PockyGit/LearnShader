Shader"Custom/Texture_Single"{
    Properties{
        _MainColor("Main Color",Color) = (1,1,1,1)
        _MainTexture("_MainTexture Diffuse COlor",2D) = "whilte"{}
        _Specular("Specular Color",Color) = (1,1,1,1)
        _Gloss("_Gloss Value",Range(8,256)) = 20
    }
    SubShader{
        pass{
            Tags { "LightMode"="ForwardBase" }
            CGPROGRAM
            //for: TRANSFORM_TEX,UnityObjectToWorldNormal,UnityWorldSpaceViewDir,UnityWorldSpaceLightDir,
            #include "UnityCG.cginc"
            // for: _LightColor0.rgb
            #include "Lighting.cginc"
            #pragma vertex vert
            #pragma fragment frag
            struct a2v{
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float4 texcoord:TEXCOORD0;
            };
            struct v2f{
                float4 pos :SV_POSITION;
                float3 worldPos :TEXCOORD0;
                float3 worldNormal:TEXCOORD1;
                float2 uv:TEXCOORD2;
            };
            sampler2D _MainTexture;
            float4 _MainTexture_ST;//xy:scale,zw:offset
            float3 _Specular;
            float _Gloss;
            float4 _MainColor;
            
            v2f vert(a2v v){
                v2f o; 
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.uv = v.texcoord.xy * _MainTexture_ST.xy + _MainTexture_ST.zw;
                //o.uv = TRANSFORM_TEX(v.texcoord,_MainTexture);
                return o;
            }
            float4 frag(v2f f):SV_TARGET{
                //DIFFUSE = _Diffuse.rgb * _Light.rgb * max(0,dot(worldNormal,worldLightDir));
                float3 worldNormal = normalize(f.worldNormal);
                float3 worldLightDir = normalize(UnityWorldSpaceLightDir(f.worldPos));
                float3 albedo = tex2D(_MainTexture,f.uv).rgb * _MainColor.rgb;
                float3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal,worldLightDir));//* 0.5 + 0.5

                //specular
                float3 viewDir =normalize(UnityWorldSpaceViewDir(f.worldPos));
                float3 halfDir = normalize(viewDir + worldLightDir);
                float3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(worldNormal,halfDir)),_Gloss);
               
                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;
                
                return float4(ambient + diffuse + specular,1.0);
            }
            ENDCG
        }
    }
}
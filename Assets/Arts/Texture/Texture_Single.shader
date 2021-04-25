Shader "Texture_Normal"{
    Properties{
        _MainColor("Main Color",Color) = (1,1,1,1)
        _MainTex("Main Tex",2D) = "whilte" {}
        _SpeculerColor("_SpeculerColor",Color) = (1,1,1,1)
        _Gloss("_Gloss",Range(8,256)) = 20
    }
    SubShader{
        pass{
            CGPROGRAM
            #include"UnityCG.cginc"
            #include"Lighting.cginc"
            #pragma vertex vert
            #pragma fragment frag
            struct a2v{
                float4 vertex:POSITION;
                float3 normal:NORMAL;
                float4 uv:TEXCOORD0;
            };
            struct v2f{
                float4 pos:SV_POSITION;
                float4 uv:TEXCOORD0;
                float3 worldNormal:TEXCOORD1;
                float3 worldLightDir:TEXCOORD2;
                float3 worldPos:TEXCOORD3;
            };
            float4 _MainColor;
            sampler2D _MainTex;
            float4 _MainTex_ST;//xy:scale,zw:offset
            float4 _SpeculerColor;
            float _Gloss;

            v2f vert(a2v i){
                v2f o;
                o.pos = UnityObjectToClipPos(i.vertex);

                float3 worldPos = mul(unity_ObjectToWorld,i.vertex);
                o.worldPos = worldPos;
                o. worldLightDir = UnityWorldSpaceLightDir(worldPos);
                o. worldNormal = UnityObjectToWorldNormal(worldPos);
                o.uv.xy = i.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = i.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                return o;
            }
            float4 frag(v2f i):SV_TARGET{

                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * _MainColor.rgb;

                float3 albedo = tex2D(_MainTex,i.uv.xy).rgb * _MainColor.rgb;

                float3 diffuse = _LightColor0.rgb * albedo * saturate(dot(i.worldNormal,i.worldLightDir));

                float3 halfDir = normalize(i.worldLightDir + UnityWorldSpaceViewDir(i.worldPos));
                float3 speculer = _LightColor0.rgb * _SpeculerColor.rgb * pow(saturate(dot(i.worldNormal,halfDir)),_Gloss);

                return float4(ambient + diffuse + speculer,1);
            }
            ENDCG
        }
    }
}
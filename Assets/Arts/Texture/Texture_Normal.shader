Shader "Texture_Normal"{
    Properties{
        _MainColor("_MainColor",Color) = (1,1,1,1)
        _MainTex("_MainTex",2D) = "whilte" {}
        _BumpTex("_BumpTex",2D) = "whilte" {}
        _BumpTexIndenty("_BumpTexIndenty",Range(-1,1)) = 0
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
                float4 tangent:TANGENT;
                float4 uv:TEXCOORD0;
            };
            struct v2f{
                float4 pos:SV_POSITION;
                float4 uv:TEXCOORD0;
                float3 tangentLightDir:TEXCOORD1;
                float3 tangentViewDir:TEXCOORD2;
            };
            float4 _MainColor;
            sampler2D _MainTex;
            float4 _MainTex_ST;//xy:scale,zw:offset
            sampler2D _BumpTex;
            float4 _BumpTex_ST;
            float _BumpTexIndenty;
            float4 _SpeculerColor;
            float _Gloss;

            v2f vert(a2v i){
                v2f o;
                o.pos = UnityObjectToClipPos(i.vertex);

                o.uv.xy = i.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = i.uv.xy * _BumpTex_ST.xy + _BumpTex_ST.zw;

                //sub normal:y
                float3 subNormal = cross(normalize(i.normal),normalize(i.tangent.xyz) * i.tangent.w);
                //(built-in:TANGENT_SPACE_ROTATION) = rotationMirror
                float3x3 rotationMirror = float3x3(i.tangent.xyz,subNormal,i.normal);

                float3 worldPos = mul(unity_ObjectToWorld,i.vertex);
                o. tangentLightDir =mul(rotationMirror,UnityWorldSpaceLightDir(worldPos)).xyz;
                o. tangentViewDir = mul(rotationMirror,UnityWorldSpaceViewDir(worldPos)).xyz;
                
                return o;
            }
            float4 frag(v2f i):SV_TARGET{
                float3 tangentLightDir = normalize(i.tangentLightDir);
                float3 tangentViewDir = normalize(i.tangentViewDir);

                float4 normalTex = tex2D(_BumpTex,i.uv.xy);
                float3 tangentNormal;
                tangentNormal.xy = (normalTex.xy * 2 - 1) * _BumpTexIndenty;
                tangentNormal.z = sqrt(1 - saturate(dot(tangentNormal.xy,tangentNormal.xy)));

                float3 albedo = tex2D(_MainTex,i.uv).rgb * _MainColor.rgb;

                float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * albedo;

                float3 diffuse = _LightColor0.rgb * albedo * saturate(dot(tangentNormal,tangentLightDir));

                float3 halfDir = normalize(tangentLightDir + tangentViewDir);
                float3 speculer = _LightColor0.rgb * _SpeculerColor.rgb * pow(saturate(dot(tangentNormal,halfDir)),_Gloss);

                return float4(ambient + diffuse + speculer,1);
            }
            ENDCG
        }
    }
}
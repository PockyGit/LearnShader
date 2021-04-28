Shader "Custom/Alpha_Blend"{
    Properties{
        _MainTexture("_MainTexture",2D) = "whilte"{}
        _MainColor("_MainColor",Color) = (1,1,1,1)
        _AlphaRate("_AlphaRate",Range(0,1)) = 1
    }
    SubShader{
        //Tags{"Queue" = "AlphaTest"}
        Tags{"Queue" = "Transparent"}
        pass{
            ZWrite On
            ColorMask 0
        }
        pass{
            Tags{"LightMode" = "ForwardBase"}
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            
            CGPROGRAM
            #include"UnityCG.cginc"
            #include"Lighting.cginc"
            #pragma vertex vert
            #pragma fragment frag
            struct a2v{
                fixed4 vertex :POSITION;
                fixed normal :NORMAL;
                fixed4 uv:TEXCOORD0;
            };
            struct v2f{
                fixed4 pos:SV_POSITION;
                fixed4 worldPos:TEXCOORD0;
                fixed3 worldNormal:TEXCOORD1;
                fixed2 uv:TEXCOORD2;
            };
            sampler2D _MainTexture;
            fixed4 _MainTexture_ST;
            fixed4 _MainColor;
            fixed _AlphaRate;
            v2f vert(a2v i){
                v2f o ;
                o.pos = UnityObjectToClipPos(i.vertex);
                o.worldPos = mul(unity_ObjectToWorld,i.vertex);
                o.uv = TRANSFORM_TEX(i.uv,_MainTexture);
                o.worldNormal = UnityObjectToWorldNormal(i.vertex);
                return o;
            }
            fixed4 frag(v2f i):SV_TARGET{
                fixed4 pixelColor = tex2D(_MainTexture,i.uv);
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * _MainColor.rgb;
                fixed3 worldPos = normalize(i.worldPos);
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = UnityObjectToWorldDir(worldPos);
                
                fixed halfLambert = saturate(dot(worldNormal,worldLightDir)) * 0.5 +0.5;
                fixed3 albedo = pixelColor.rgb * _MainColor.rgb;
                fixed3 diffuse  =_LightColor0.rgb * albedo * halfLambert; 
                
                return fixed4(ambient + diffuse, pixelColor.a * _AlphaRate);
            }
            ENDCG

        }
        
    }
}
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/capter5"
{
	properties{
		_Color("Tint Color",Color)=(1,1,1,1)
	}
	SubShader
	{
		pass 
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag 
			#include"UnityCG.cginc"

			// float4 vert (float4 v:position):sv_position{
			// 	//return mul(UNITY_MATRIX_MVP,v);
			// 	return UnityObjectToClipPos(v);  
			// }		
			// fixed4 frag():sv_target
			// {
			//  	return fixed4(1,1,0,1);
			// }

			float4 _Color;

			//Application2VertexShader
			struct a2v
			{
				float4 vertex:position;
				float3 normal:normal;
				float4 texcoord:texcoord0;
			};

			//VertexShader2Fragment
			struct v2f
			{
				float4 pos:position;
				float3 color :color0;
			};
			//顶点着色器：计算顶点裁剪后的位置、顶点颜色
			v2f vert(a2v v)
			{    
				v2f f;
				f.pos = UnityObjectToClipPos(v.vertex);
				f.color = v.normal * 0.5 + fixed3(0.5,0.5,0.5);
				return f;
			}	
			//片元着色器：计算像素颜色
			fixed4 frag(v2f f):sv_target
			{
				float3 fcolor = f.color;
				float3 res = fcolor * _Color.rgb;
				
				//环境光 默认不叠加
				float3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.rgb;
				res *= ambientColor;

				return fixed4(res,1.0);
			}
			
			ENDCG
		}
	}
	fallback Off
}

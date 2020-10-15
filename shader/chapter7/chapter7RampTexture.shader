// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/chapter7RampTexture" {
	
	Properties
	{
		_Color("Color Tint",Color)=(1,1,1,1)
		
		_RampTex("Ramp Tex",2D) = "White"{}
		
		_Specular("Specular",Color) = (1,1,1,1)
		
		_Gloss("Gloss" , Range(8.0,256)) = 20
	}
	
	SubShader
	{
		Pass
		{
			Tags
			{
				"LightMode" = "ForwardBase"
			}
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include"Lighting.cginc"
			
			
			fixed4 _Color;
			sampler2D _RampTex;
			float4 _RampTex_ST;
			
			fixed4 _Specular;
			float _Gloss;
			
			
			struct a2v
			{
				float4 vertex :POSITION;
				float3 normal :NORMAL;
				float4 texcoord :TEXCOORD0;
			};
			
			struct v2f
			{
				float4 pos:SV_POSITION;
				fixed3 worldNormal :TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				float2 uv:TEXCOORD2;
				
			};
			
			
			v2f vert(a2v v)
			{
				v2f o;
				
				
				o.pos = UnityObjectToClipPos(v.vertex);
				
				o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);
				
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				
				o.uv = v.texcoord.xy *_RampTex_ST.xy + _RampTex_ST.zw;
				
				return o;
				
				
			}
			
			fixed4 frag(v2f o) :SV_Target
			{
				fixed3 worldNormal = normalize(o.worldNormal);
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - o.worldPos);
				fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				fixed halfLambert = 0.5 * dot(worldNormal,lightDir) +0.5;
				
				//因为——RampTex实际上是一个一维坐标，其纵轴上的颜色不变，因此我们使用halflambet来构建纹理坐标对渐变纹理进行采样
				fixed3 diffuseColor = tex2D(_RampTex,fixed2(halfLambert,halfLambert)).rgb * _Color.rgb;
				
				fixed3 diffuse = _LightColor0.rgb * diffuseColor ;
				
				fixed3 halfDir = normalize(viewDir + lightDir);
				
				fixed3 specular = _LightColor0.rgb * _Specular.rgb *pow(saturate(dot(halfDir,worldNormal)),_Gloss);
				
				
				return fixed4(ambient + diffuse + specular,1.0);
			}
			
			
			ENDCG
			
		}
	}

	FallBack "Specular"
}

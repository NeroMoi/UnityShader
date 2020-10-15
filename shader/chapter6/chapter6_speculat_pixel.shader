// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/chapter6_speculat_pixel" {
	
	Properties
	{
		_Diffuse("Diffuse",Color) = (1,1,1,1)
		
		_Specular("Specular",Color) = (1,1,1,1)
		
		_Gloss("Gloss",Range(8.0,256)) = 20
	
	}
	
	SubShader
	{
	
		Pass
		{
			Tags
			{
				"LightModel" = "ForwardBase"
			}
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include"Lighting.cginc"
			
			fixed4 _Specular;
			fixed4 _Diffuse;
			float _Gloss;
			
			struct a2v
			{
				float4 vertex :POSITION;
				float3 normal :NORMAL;
			};
			
			struct v2f
			{
				float4 pos: SV_POSITION;
				
				float3 worldNormal :TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};
			
			
			v2f vert(a2v v)
			{
				v2f o;
				
				o.pos = UnityObjectToClipPos(v.vertex);
					
				o.worldNormal = mul(v.normal,(float3x3)unity_WorldToObject);	
				
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				return o;
				
			}
			
			fixed4 frag(v2f o) :SV_Target
			{
				fixed3 worldNormal = normalize(o.worldNormal);
				
				
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - o.worldPos.xyz);
				
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				fixed3 diffuse = _LightColor0.rgb *_Diffuse.rgb * saturate(dot(worldNormal,worldLightDir));
				
				fixed3 reflectDir = normalize(reflect(-worldLightDir,worldNormal));
				
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - o.worldPos.xyz);
				
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(viewDir,reflectDir)),_Gloss);
				
				fixed3 color = ambient + diffuse + specular;
				
				return fixed4(color,1.0);
				
			}
			
			
			ENDCG
		
		}
	
	}
	
	
	FallBack "Specular"
}

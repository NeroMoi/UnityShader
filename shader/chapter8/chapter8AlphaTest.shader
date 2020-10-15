// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/chapter8AlphaTest" {
	
	Properties
	{
		_Color("Color Tint",Color)=(1,1,1,1)
		
		_MainTex("Main Tex",2D)="White"{}
		
		//深度测试的阈值
		_Cutoff("Alpha CutOff",Range(0,1)) = 0.5
		
	}
	
	SubShader
	{
	
		Tags
			{
				"Queue" = "AlphaTest" 
				//这个shader不会收到投影器的影响
				"IgnoreProjector" = "True"
				//把这个shader归入到提前定义的组，以指明该shander时一个使用了透明度测试的shader
				"RenderType" = "TransparentCutout"
			}
			
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
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _Cutoff;
			
			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal :NORMAL;
				float4 texcoord:TEXCOORD0;
			};
			
			struct v2f
			{
				float4 pos:SV_POSITION;
				float3 worldNormal :TEXCOORD0;
				float worldPos :TEXCOORD1;
				float uv:TEXCOORD2;
			};
			
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldNormal = mul(v.normal,unity_WorldToObject);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);
				o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				
				return o;
			}
			
			fixed4 frag(v2f o):SV_Target
			{
				fixed3 worldNormal = normalize(o.worldNormal);
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
			//	fixed3 worldViewDir = normalize(_WorldSpaceCameraPos.xyz - o.worldPos);
				
				fixed4 texColor = tex2D(_MainTex,o.uv);
				
				//AlphaTest
				clip (texColor.a - _Cutoff);
				
				fixed3 albedo = texColor.rgb * _Color.rgb;
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				
				fixed3 diffuse = _LightColor0.rgb * albedo *saturate(dot(worldNormal,worldLightDir));
				
				return fixed4(ambient + diffuse,1.0);
			}

			ENDCG
			
			
		}
	}

	FallBack "Transparent/Cutout/VertexLit"
}











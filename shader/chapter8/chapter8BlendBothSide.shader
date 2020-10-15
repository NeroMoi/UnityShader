// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/chapter8BlendBothSide" {
	
	//透明度测试的双向渲染
	Properties
	{
		_Color("Main Tint",Color) = (1,1,1,1)
		_MainTex("Main Tex",2D) = "White"{}
		_AlphaScale("Alpha Scale",Range(0,1)) =1
	}
	
	SubShader
	{
		Tags
		{
			"Queue" = "Transparent" 
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
		}
		
		Pass
		{
			Tags
			{
				"LightMode" = "ForwardBase"
			}
			
			//剔除正面
			Cull Front
			
				//关闭z写入
			ZWrite Off
			//将源颜色的混合因子设为srcAlpha ,目标颜色（已经存在与颜色缓冲的颜色）的混合因子设为one
			Blend SrcAlpha OneMinusSrcAlpha
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include"Lighting.cginc"
			
			
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed  _AlphaScale;
			
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
				
				fixed3 albedo = texColor.rgb * _Color.rgb;
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				
				fixed3 diffuse = _LightColor0.rgb * albedo *saturate(dot(worldNormal,worldLightDir));
				
				//设置该片元着色器返回值中的透明通道，它是纹理像素的透明通道和材质参数_ALPHASCALEd的成绩
				return fixed4(ambient + diffuse,texColor.a * _AlphaScale);
			}

			ENDCG
			
			
		}
		
		Pass
		{
			Tags
			{
				"LightMode" = "ForwardBase"
			}
			
			Cull Back
			
				//关闭z写入
			ZWrite Off
			//将源颜色的混合因子设为srcAlpha ,目标颜色（已经存在与颜色缓冲的颜色）的混合因子设为one
			Blend SrcAlpha OneMinusSrcAlpha
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include"Lighting.cginc"
			
			
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed  _AlphaScale;
			
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
				
				fixed3 albedo = texColor.rgb * _Color.rgb;
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				
				fixed3 diffuse = _LightColor0.rgb * albedo *saturate(dot(worldNormal,worldLightDir));
				
				//设置该片元着色器返回值中的透明通道，它是纹理像素的透明通道和材质参数_ALPHASCALEd的成绩
				return fixed4(ambient + diffuse,texColor.a * _AlphaScale);
			}

			ENDCG
			
		}
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	FallBack "Transparent/VertexLit"
}

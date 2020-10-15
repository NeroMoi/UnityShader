// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/chapter8AlphaBlendZWrite" {
	Properties
	{
		_Color("Color Tint",Color)=(1,1,1,1)
		
		_MainTex("Main Tex",2D)="White"{}
		
		//在透明纹理的基础上控制整体的透明度
		_AlphaScale("Alpha Scale",Range(0,1)) = 1
		
	}
	
	SubShader
	{
	
		Tags
			{
				//透明度混合
				"Queue" = "Transparent" 
				//这个shader不会收到投影器的影响
				"IgnoreProjector" = "True"
				//把这个shader归入到提前定义的组，以指明该shander时一个使用了透明度混合的shader
				"RenderType" = "Transparent"
			}
			
		//extra pass that renders to depth buffer only
		Pass
		{
			ZWrite On
			//用于设置颜色通道的写掩码write mask, 设为0时，意为着pass不写入任何颜色
			ColorMask 0	
		}
			
		Pass
		{
			Tags
			{
				"LightMode" = "ForwardBase"
			}
			
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
	FallBack "Diffuse"
}

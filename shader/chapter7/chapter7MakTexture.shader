// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/chapter7MakTexture" {
	
	Properties
	{
		_Color("Color Tint",Color) = (1,1,1,1)
		
		//主纹理
		_MainTex("MainTex",2D) = "White"{}
		//法线纹理
		_BumpMap("normal Map",2D) = "bump"{}
		
		_BumpScale("Bump Scale",Float) = 1.0
		
		//遮盖纹理，组像素的控制模型表面的高光强度
		//流程：通过采样得到遮盖纹理的纹素值，然后使用其中某个通道的值
		//例如texel.r来与之表面属性相乘，这样，当通道的值为0时，可以保证表面不受该属性的影响
		_SpecularMask("Specular Mask",2D) = "White"{}
		_SpecularScale("Specular scale",Float) = 1.0
		
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,256)) = 20
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
			
			//颜色纹理
			sampler2D _MainTex;
			float4 _MainTex_ST;
			//纹理使用共同的缩放与位移
			
			//法线纹理
			sampler2D _BumpMap;
		//	float4 _BumpMap_ST;
			float _BumpScale;
			
			//遮盖纹理
			sampler2D _SpecularMask;
			//float4 _SpeculatMask_ST;
			float _SpecularScale;
			
			//法线颜色，强度
			
			fixed4 _Specular;
			float _Gloss;
			
			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal:NORMAL;
				float4 tangent:TANGENT;
				float4 texcoord:TEXCOORD0;	
			};
			
			struct v2f
			{
				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD0;
				float3 lightDir:TEXCOORD1;
				float3 viewDir:TEXCOORD2;
			
			};
			
			//切线空间的运算
			
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				
				o.uv = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				
				fixed3 binormal = cross(normalize(v.normal),normalize(v.tangent.xyz))*v.tangent.w;
				
				float3x3 rotation = float3x3(v.tangent.xyz,binormal,v.normal);
				
				o.lightDir = mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;
				o.viewDir = mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;
				
				return o;
				
			}
			
			fixed4 frag(v2f o):SV_Target
			{
				fixed3 viewDir = normalize(o.viewDir);
				fixed3 lightDir = normalize(o.lightDir);
				
				fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap,o.uv));
				
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy,tangentNormal.xy)));
				
				fixed3 albedo = tex2D(_MainTex,o.uv).rgb * _Color.rgb;
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz *albedo;
				
				fixed3 diffuse = _LightColor0.rgb * albedo *saturate(dot(lightDir,tangentNormal));
				
				fixed3 halfDir = normalize(viewDir + lightDir);
				
				//使用纹素的r通道
				fixed specularMask = tex2D(_SpecularMask,o.uv).r * _SpecularScale;
				
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(halfDir,tangentNormal)),_Gloss) * specularMask;
			
				
				return fixed4(ambient + diffuse +specular,1.0);
			}
		
			
			
			ENDCG
		}
	}
	
	
	
	FallBack "specular"
}

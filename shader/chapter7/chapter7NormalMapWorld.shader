// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/chapter7NormalMapWorld" {
	
	Properties
	{
		_Color("Color Tint",Color) = (1,1,1,1)
		
		_MainTex("Main Tex",2D) = "White"{}
		
		_BumpMap("normal Map",2D) = "bump"{}
		
		_BumpScale("BumpScale",Float) = 1.0
		
		_Specular("Specualr",Color) = (1,1,1,1)
		
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
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			
			fixed4 _Specular;
			float _Gloss;
			
			struct a2v
			{
				fixed4 vertex :POSITION;
				fixed3 normal :NORMAL;
				fixed4 tangent :TANGENT;
				fixed4 texcoord :TEXCOORD0;
			};
			
			//使用的时世界空间，因此要存储切线空间到法线空间的矩阵
			struct v2f
			{
				fixed4 pos:SV_POSITION;
				float4 uv :TEXCOORD0;
				float4 TtoW0 : TEXCOORD1;
				float4 TtoW1 : TEXCOORD2;
				float4 TtoW2 : TEXCOORD3;
				
				//使用第四个分量存储世界空间下的顶点坐标
				
			};
			
			
			v2f vert(a2v v)
			{
				v2f o ;
				
				o.pos = UnityObjectToClipPos(v.vertex);
				
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				
				
				float3 worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
				//要去顶副切线的方向
				fixed3 worldBinormal = cross(worldNormal,worldTangent) * v.tangent.w;
				
				o.TtoW0 = float4(worldTangent.x,worldBinormal.x,worldNormal.x,worldPos.x);
				o.TtoW1 = float4(worldTangent.y,worldBinormal.y,worldNormal.y,worldPos.y);
				o.TtoW2 = float4(worldTangent.z,worldBinormal.z,worldNormal.z,worldPos.z);
				
				
				return o;
				
			}
			
			fixed4 frag(v2f o):SV_Target
			{
				float3 worldPos = float3(o.TtoW0.w,o.TtoW1.w,o.TtoW2.w);
				
				fixed3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 viewDir = normalize (_WorldSpaceCameraPos.xyz - worldPos);
				
				// get the normal in tangent space
				
				fixed3 bump = UnpackNormal(tex2D(_BumpMap,o.uv.zw));
				bump.xy *= _BumpScale;
				bump.z = sqrt(1.0 - saturate(dot(bump.xy,bump.xy)));
				
				//计算在切线空间的法线经过矩阵转换后的向量
				//bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));

				bump = normalize(half3(dot(o.TtoW0.xyz, bump), dot(o.TtoW1.xyz, bump), dot(o.TtoW2.xyz, bump)));
			
				
				//计算折射率
				fixed3 albedo = tex2D(_MainTex,o.uv).rgb*_Color.rgb;
				
				//计算环境光
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				
				//光源颜色*折射率* 法线与光源的余弦
				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(lightDir,bump));
				
				fixed3 halfDir = normalize(lightDir + viewDir);
				
				fixed3 specular = _LightColor0.rgb *_Specular.rgb *pow( saturate(dot(halfDir,bump)),_Gloss);
				
				
				return fixed4(diffuse + ambient + specular,1.0);
				
			}
			
			ENDCG
		}
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	FallBack "Specular"
}

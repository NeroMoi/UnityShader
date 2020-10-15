// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/chapter7NormalMapTangentSpace" {
	
	Properties
	{
		_Color("Color Tint",Color) = (1,1,1,1)
		_MainTex("Main Tex",2D) = "white"{}
		//法线纹理使用bump作为它的默认值，“bump”是UNITY内置的法线纹理
		//当没有提供任何法线纹理时，"bump"旧对应了模型自带的法线信息
		_BumpMap("Normal Map",2D) = "bump"{}
		//用于控制凹凸程度，等于0时意为着法线纹理不会对光照产生影响
		_BumpScale("Bump Scale",Float) = 1.0
		
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
			
			//表面纹理用来模拟漫反射
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			//法线纹理用来模拟凹凸
			
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _BumpScale;
			
			//高光反射
			fixed4 _Specular;
			float _Gloss;
			
			//需要得到顶点、法线、切线、材质
			struct a2v
			{
				float4 vertex:POSITION;
				float3 normal :NORMAL;
				
				float4 tangent :TANGENT;
				float4 texcoord :TEXCOORD0;
			};
			
			//需要得到顶点、存储纹理坐标的变量uv、视线方向、光照方向
			struct v2f
			{
				float4 pos: SV_POSITION;
				float4 uv: TEXCOORD0; //存储纹理映射坐标
				float3 lightDir :TEXCOORD1; 
				float3 viewDir :TEXCOORD2;
			};
			
			v2f vert(a2v v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				
				//纹理映射范围，与wrap的覆盖模式有关联
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				
				//计算副法线,W决定了选择哪一个方向
				
				float3 binormal = cross(normalize(v.normal),normalize(v.tangent.xyz)) * v.tangent.w;
				
				//创建个矩阵，用于向量从模型空间到切线空间
				float3x3 rotation = float3x3(v.tangent.xyz,binormal,v.normal);
				
			
				//把光源的方向从对象空间转换到切线空间
				o.lightDir = mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;
				
				//观察方向从对象空间到切线空间
				o.viewDir = mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;
				
				return o;
			}
			
			fixed4 frag(v2f o) : SV_Target
			{
			
			
				fixed3 tangentLightDir = normalize(o.lightDir);
				fixed3 tangentViewDir = normalize(o.viewDir);
				
				//已经求得的切线空间下的、光线、观察方向
				//现在求在像素中的纹理反隐射的法线矢量
				
				fixed4 packedNormal = tex2D(_BumpMap,o.uv.zw);
				
				fixed3 tangentNormal;
				
				tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1.0- saturate(dot(tangentNormal.xy,tangentNormal.xy)));
				
				
				
				//求漫反射的折射率 ->材质的颜色*物体的整体颜色
				
				fixed3 albedo = tex2D(_MainTex,o.uv).rgb * _Color.rgb;
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				
				//光源颜色*折射率* 法线与光源的余弦
				fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(tangentLightDir,tangentNormal));
				
				fixed3 halfDir = normalize(tangentViewDir + tangentLightDir);
				
				fixed3 specular = _LightColor0.rgb *_Specular.rgb *pow( saturate(dot(halfDir,tangentNormal)),_Gloss);
				
				
				return fixed4(diffuse + ambient + specular,1.0);
			}
			
			
			ENDCG
		}
	}


	FallBack "Specular"
}

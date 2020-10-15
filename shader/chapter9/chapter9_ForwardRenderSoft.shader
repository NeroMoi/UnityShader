// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'
// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/chapter9_ForwardRenderSoft" {
	
	Properties
	{
		_Diffuse("Diffuse",Color) = (1,1,1,1)
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss("Gloss",Range(8.0,256)) = 20 
	}
	
	SubShader {
	
		Tags { "RenderType"="Opaque" }
		
		Pass {
			// Pass for ambient light & first pixel light (directional light)
			Tags { "LightMode"="ForwardBase" }
		
			CGPROGRAM
			
			// Apparently need to add this declaration 
			//保证关照衰减等关照变量被正确赋值
			#pragma multi_compile_fwdbase	
			
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				//声明阴影映射纹理坐标变量
				
				// unityShadowCoord4 _ShadowCoord : TEXCOORD##idx1;
				//float4 _ShadowCoord : TEXCOORD##idx1;
				SHADOW_COORDS(2)
			};
			
			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				
				//计算并向片元着色器传递阴影坐标
				// a._ShadowCoord =  mul(_Object2World, v.vertex).xyz - _LightPositionRange.xyz;
				//不同的光源类型对应不同的矩阵
				TRANSFER_SHADOW(o);
				return o;
				
			}
			
			fixed4 frag(v2f i) : SV_Target {
			
				//fixed shadow = SHADOW_ATTENUATION(i);
				//使用宏计算光照衰减和阴影
				UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
				
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				
			 	fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));

			 	fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
			 	fixed3 halfDir = normalize(worldLightDir + viewDir);
			 	fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
				
				
				
				return fixed4(ambient + (diffuse + specular) * atten, 1.0);
			}
			
			ENDCG
		}
	
		Pass {
			// Pass for other pixel lights
			Tags { "LightMode"="ForwardAdd" }
			
			//叠加
			Blend One One
		
			CGPROGRAM
			
			// Apparently need to add this declaration
			#pragma multi_compile_fwdadd
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			
			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float3 worldNormal : TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				//声明一个用于阴影纹理采样的坐标变量，这个宏的参数是下一个可用的插值寄存器的索引
				
			};
			
			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				
				//用于在顶点着色器中计算上一步声明的纹理坐标
				
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
			
				
				 
				fixed3 worldNormal = normalize(i.worldNormal);
				#ifdef USING_DIRECTIONAL_LIGHT
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				#else
					fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz);
				#endif
				
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal, worldLightDir));
				
				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				fixed3 halfDir = normalize(worldLightDir + viewDir);
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
				
				#ifdef USING_DIRECTIONAL_LIGHT
					fixed atten = 1.0;
				#else
					#if defined (POINT)
				        float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1)).xyz;
				        //内部使用的关照衰减纹理作为查找表，在片元着色器中逐像素光照的计算衰减
				        fixed atten = tex2D(_LightTexture0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				    #elif defined (SPOT)
				    
				        float4 lightCoord = mul(unity_WorldToLight, float4(i.worldPos, 1));
				        //lightCoord.xy/lightCoord.w表示像素点在聚光灯空间的方位与聚光灯z轴的夹角（分x,y）
				        //这个值只有在[-0.5,-0.5]到[0.5,0.5]之间才有效
				        //纹理采样的uv坐标范围是【0，0】到【1，1】之间
				        //即在聚光灯角度范围之内的才有光照亮
				        //光的强度信息是存在纹理的w分量中的，所以取w分量来计算光强的衰减
				        
				        //先判断角度是否在采样的纹理范围内，在根据距离进行采样获得衰减值
				        fixed atten = (lightCoord.z > 0) 
				        * tex2D(_LightTexture0, lightCoord.xy / lightCoord.w + 0.5).w 
				        * tex2D(_LightTextureB0, dot(lightCoord, lightCoord).rr).UNITY_ATTEN_CHANNEL;
				    #else
				        fixed atten = 1.0;
				    #endif
				#endif

				return fixed4((diffuse + specular) * atten, 1.0);
			}
			
			ENDCG
		}
	}
	
	
	
	FallBack "Diffuse"
}

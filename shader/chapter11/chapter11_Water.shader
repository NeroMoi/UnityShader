// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/chapter11_Water" {

	Properties {
		_MainTex ("Main Tex", 2D) = "white" {}
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		//频幅A
		_Magnitude ("Distortion Magnitude", Float) = 1
		//频率f，单位时间内往复振动的次数 = 1/T = W/2PI，T表示完成一次振动所需的时间
 		_Frequency ("Distortion Frequency", Float) = 1
 		//波长的倒数 1/入
 		_InvWaveLength ("Distortion Inverse Wave Length", Float) = 10
 		//波速v = 入f，单位时间内波移动的距离
 		_Speed ("Speed", Float) = 0.5
	}
	SubShader {
		// Need to disable batching because of the vertex animation
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "DisableBatching"="True"}
		
		Pass {
			Tags { "LightMode"="ForwardBase" }
			
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off
			
			CGPROGRAM  
			#pragma vertex vert 
			#pragma fragment frag
			
			#include "UnityCG.cginc" 
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			float _Magnitude;
			float _Frequency;
			float _InvWaveLength;
			float _Speed;
			
			struct a2v {
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};
			
			v2f vert(a2v v) {
				v2f o;
				
				float4 offset;
				offset.yzw = float3(0.0, 0.0, 0.0);
				// x = Asin(wt +h) +z
				// x表示的是偏移的量 ，A表示振幅，wt +h表示相位，w表示伸长或缩短到原来的1/w倍，h表示初相
			//	offset.y = sin(_Frequency * _Time.y + v.vertex.x * _InvWaveLength +
			//	 v.vertex.y * _InvWaveLength + v.vertex.z * _InvWaveLength) * _Magnitude;
				 
				 offset.x = sin(_Frequency * _Time.y + v.vertex.x * _InvWaveLength +
				 v.vertex.y * _InvWaveLength + v.vertex.z * _InvWaveLength) * _Magnitude;
				 
				o.pos = UnityObjectToClipPos(v.vertex + offset);
				
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				//纹理动画
				o.uv +=  float2(0.0, _Time.y * _Speed);
				
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target {
				fixed4 c = tex2D(_MainTex, i.uv);
				c.rgb *= _Color.rgb;
				
				return c;
			} 
			
			ENDCG
		}
		
		
		Pass
		{
			Tags
			{
				"LightMode" = "ShadowCaster"
			}
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#pragma multi_compile_shadowcaster
			
			#include "UnityCG.cginc"
			
			float _Magnitude;
			float _Frequency;
			float _InvWaveLength;
			float _Speed;
			
			struct v2f
			{
				V2F_SHADOW_CASTER;
				
			};
			
			v2f vert(appdata_base v)
			{
				v2f o;
				
				float4 offset;
				
				offset.yzw = float3(0.0, 0.0, 0.0);
				offset.x = sin(_Frequency * _Time.y + v.vertex.x * _InvWaveLength + v.vertex.y * _InvWaveLength + v.vertex.z * _InvWaveLength) * _Magnitude;
				v.vertex = v.vertex + offset;
				
				
				v.vertex = v.vertex + offset;
				
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				
				return o;
				
				
			}
			
			fixed4 frag(v2f i):SV_Target
			{
				SHADOW_CASTER_FRAGMENT(i);
			}
				
			ENDCG

			
		}
	}
	FallBack "VertexLit"
	
}

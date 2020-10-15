// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/chapter11_ImageSequenceAnimation" {
	//在每个时刻播放的关键帧的位置
	Properties
	{
		_Color("Color Tint",Color) = (1,1,1,1)
		_MainTex("Image Sequence",2D) = "White"{}
		//水平方向包含的关键帧图像的个数
		_HorizontalAmount("Horizontal Amount",Float) = 8
		//竖直方向的....
		_VerticalAmount("Vertical Amount",Float) = 8
		//序列帧动画的播放速度
		_Speed("Speed",Range(1,100)) = 30
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
			
			Zwrite Off
			Blend SrcAlpha OneMinusSrcAlpha
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include"UnityCG.cginc"
			
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			float _HorizontalAmount;
			float _VerticalAmount;
			
			float _Speed;
			
			struct a2v
			{
				float4 vertex :POSITION;
				float2 texcoord:TEXCOORD0;
			};
			
			
			struct v2f
			{
				float4 pos:SV_POSITION;
				float2 uv:TEXCOORD0;
			};
			
			v2f vert (a2v v) 
			{  
				v2f o;  
				o.pos = UnityObjectToClipPos(v.vertex);  
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);  
				return o;
			}  
			
			fixed4 frag(v2f i):SV_Target
			{
				//向下取整
				float frame = floor(_Time.y * _Speed);  
				//判断水平方向上应该取哪一行的图像
				float row = floor(frame / _HorizontalAmount);
				//取那一列的图像
				float column = frame - row * _HorizontalAmount;
				
				//采样坐标隐射到单个图像上的纹理范围(1/8,1/8)
				// x/列的个数  ，y/行的个数
				half2 uv = float2(i.uv.x /_HorizontalAmount, i.uv.y / _VerticalAmount);
				//偏移到对应的图像上
				uv.x += column / _HorizontalAmount; //在第几列
				uv.y += 1 -(row+1) / _VerticalAmount;
		//		uv.y +=1-  row / _VerticalAmount; //在第几行
				//这里可行的原因是uv坐标会随着时间增大，模式是repeat,当uv坐标不再(0,0)，（1，1）范围内时就会重复
		//		uv.y -=	row / _VerticalAmount;	
				fixed4 c = tex2D(_MainTex, uv);
				c.rgb *= _Color;
				
				return c;
			}
			
			
			
			ENDCG
		}
		
	}
	FallBack "Transparent/VertexLit"
}
	



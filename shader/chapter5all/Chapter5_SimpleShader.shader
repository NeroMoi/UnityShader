// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Chapter5_SimpleShader" {
	
	Properties  //属性
	{
	//声明一个color类型的属性
		_Color("Color Tint",Color) = (1.0,1.0,1.0,1.0) 
		//颜色拾取器
	}
	SubShader // 一个显卡对应的subShader模式
	{
		Pass //一个渲染流程
		{
		//设置渲染状态和标签
			CGPROGRAM              // CG语言开始
			
			#pragma vertex vert   //包含了顶点着色器代码
			#pragma fragment  frag  //包含了片元着色器代码
			#include "UnityCG.cginc"
			
			fixed4 _Color;
			 //定义一个与属性 名称类型都相同的变量
			//使用一个结构体来定义顶点着色器的输入
			//语义的数据由Mesh Render 将他渲染的模型数据 在每帧调用draw Call的时候传递给 unity shader
			struct a2v //application to vertex
			{
				float4 vertex :POSITION; //模型空间的顶点坐标填充vertex
				float3 normal :NORMAL; //用模型空间的法线填充normal
				
				float4 texcoord :TEXCOORD0 ;//用模型空间的第一组纹理来填充
			};

			struct v2f //vertex to fragment
			{
				float4 pos : SV_POSITION;
				fixed3 color :COLOR0;
			};
			//逐顶点执行，返回的是该顶点在裁剪空间的位置
			//使用POSITION语义得到模型的顶点位置
			void vert(in a2v v,out v2f o)
			{
				
				//v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
			
				// v.normal 包含了顶点的法线方向，分量范围为[-1,1]
				//下面将其映射到[0,1]
				//存储到o.color中传递给片元着色器
				
				o.color = v.normal*0.5 + fixed3(0.5,0.5,0.5);
				//return o;
				
			}
			
				//把输出的颜色存储到一个渲染目标，这里输出到默认的帧缓冲
			fixed4 frag(v2f i): SV_Target
			{
				fixed3 c = i.color;
				c *= _Color.rgb;
				//使用color属性来控制输出颜色
			
				//	将插值后的颜色显示到屏幕上
				return fixed4(c,1.0);
			}
			
			ENDCG                 //CG语言结束
		
		}
	}
	FallBack "VertexLit"
}


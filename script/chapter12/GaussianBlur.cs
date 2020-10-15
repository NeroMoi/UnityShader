using UnityEngine;
using System.Collections;

public class GaussianBlur : PostEffectsBase {

	public Shader guassianBlurShader;
	public Material guassianBlurMaterial = null;


	public Material material
	{
			get{

			guassianBlurMaterial = CheckShaderAndCreateMaterial(guassianBlurShader,guassianBlurMaterial);

			return guassianBlurMaterial;
		}
	}

	//blur iterations -large number means more blur
	[Range(0,4)]
	public int iterations =3;

	//blur spread for each iteration -large vaule means more blur
	[Range(0.2f,3.0f)]
	public float blurSpread = 0.6f;

	//设置缓冲区缩小于原屏幕的尺寸
	[Range(1,8)]
	public int downSample = 2;

	void OnRenderImage(RenderTexture src,RenderTexture dest)
	{
			if (material != null) {


			int rtW = src.width/downSample;
			int rtH = src.height/downSample;

			//减少需要处理的像素个数
			RenderTexture buffer = RenderTexture.GetTemporary (rtW, rtH, 0);
			//滤波模式双线性
			buffer.filterMode = FilterMode.Bilinear;

			Graphics.Blit(src, buffer);

			//高斯模糊的次数
			for (int i = 0; i < iterations; i++) {
				material.SetFloat("_BlurSize", 1.0f + i * blurSpread);
				
				RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
				
				// Render the vertical pass
				Graphics.Blit(buffer, buffer1, material, 0);
				
				RenderTexture.ReleaseTemporary(buffer);
				buffer = buffer1;
				buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
				
				// Render the horizontal pass
				Graphics.Blit(buffer, buffer1, material, 1);
				
				RenderTexture.ReleaseTemporary(buffer);
				buffer = buffer1;

				RenderTexture.ReleaseTemporary(buffer1);

			}

			Graphics.Blit(buffer, dest);
			RenderTexture.ReleaseTemporary (buffer);

		} else {
			Graphics.Blit(src,dest);
		}
	}

































}

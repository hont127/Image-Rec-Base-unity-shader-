Shader "Hidden/RealtimeImageStatisticsShader"
{
	Properties
	{
	}
	SubShader
	{
		Blend One One

		tags
		{
			"Queue" = "Transparent"
			"RenderType" = "Transparent"
		}

		Pass
		{
			CGPROGRAM
			#pragma target 4.0
			#pragma vertex vert
			#pragma geometry geom
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct v2f
			{
				float4 color : COLOR;
				float4 vertex : SV_POSITION;
			};

			sampler2D _Image;
			float4 _LoopImageSize;
			float4 _SampleFilter;
			float4 _Rec_Color;
			float4 _GainValue;

			#define GAIN_VALUE _GainValue.x
			#define LOOP_IMAGE_SIZE_X _LoopImageSize.x
			#define LOOP_IMAGE_SIZE_Y _LoopImageSize.y
			#define GRID_SIZE_X _SampleFilter.x
			#define GRID_SIZE_Y _SampleFilter.y

			//像素判断的逻辑实现
			float4 Statistics_sample(sampler2D image, float4 rec_color, half4 uv, half2 image_size)
			{
				float4 result = 0;

				uint roll_width =(uv.x * image_size.x);
				uint roll_height = (uv.y * image_size.y);

				if (roll_width  % _SampleFilter.z  < _SampleFilter.w)return 0;
				if (roll_height  % _SampleFilter.z  < _SampleFilter.w)return 0;

				float4 image_col = tex2Dlod(image, uv);
				if (all(rec_color.rgb == image_col.rgb))
				{
					uint roll = (roll_width + roll_height) % 4;

					if (roll == 0)
						result = float4(GAIN_VALUE, 0, 0, 0);

					if (roll == 1)
						result = float4(0, GAIN_VALUE, 0, 0);

					if (roll == 2)
						result = float4(0, 0, GAIN_VALUE, 0);

					if (roll == 3)
						result = float4(0, 0, 0, GAIN_VALUE);
				}

				return result;
			}

			v2f vert(uint vid : SV_VertexID)
			{
				v2f o = (v2f)0;

				o.vertex = 0;

				half2 image_size = half2(GRID_SIZE_X * LOOP_IMAGE_SIZE_X, GRID_SIZE_Y * LOOP_IMAGE_SIZE_Y);

				half y = floor(vid / LOOP_IMAGE_SIZE_X);
				half x = (vid - y * LOOP_IMAGE_SIZE_X) / LOOP_IMAGE_SIZE_X;
				y = y / LOOP_IMAGE_SIZE_Y;
				//将vid转化为x,y坐标

				for (half rx = 0; rx < GRID_SIZE_X; rx++)
				{
					for (half ry = 0; ry < GRID_SIZE_Y; ry++)
					{
						half xx = x + rx;
						half yy = y + ry;

						float4 r = Statistics_sample(_Image, _Rec_Color, half4(xx, yy, 0, 0), image_size);

						o.color += r;
					}
				}
				//一个顶点处理多个像素

				return o;
			}

			[maxvertexcount(4)]
			void geom(point v2f vertElement[1], inout TriangleStream<v2f> triStream)
			{
				if (all(vertElement[0].color <= 0)) return;

				float size = 2;

				float4 v1 = vertElement[0].vertex + float4(-size, -size, 0, 0);
				float4 v2 = vertElement[0].vertex + float4(-size, size, 0, 0);
				float4 v3 = vertElement[0].vertex + float4(size, -size, 0, 0);
				float4 v4 = vertElement[0].vertex + float4(size, size, 0, 0);

				v2f r = (v2f)0;

				r.vertex = mul(UNITY_MATRIX_VP, v1);
				r.color = vertElement[0].color;
				triStream.Append(r);

				r.vertex = mul(UNITY_MATRIX_VP, v2);
				r.color = vertElement[0].color;
				triStream.Append(r);

				r.vertex = mul(UNITY_MATRIX_VP, v3);
				r.color = vertElement[0].color;
				triStream.Append(r);

				r.vertex = mul(UNITY_MATRIX_VP, v4);
				r.color = vertElement[0].color;
				triStream.Append(r);
			}

			fixed4 frag(v2f i) : SV_Target
			{
				return i.color;
			}
			ENDCG
		}
	}
}

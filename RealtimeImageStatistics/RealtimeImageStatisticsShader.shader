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

			float4 statistics_sample(sampler2D image, float4 rec_color, half4 uv, half2 image_size)
			{
				float4 result = 0;

				int roll_width = (uv.x * image_size.x);
				int roll_height = (uv.y * image_size.y);

				if (roll_width  % _SampleFilter.z < _SampleFilter.w)return 0;
				if (roll_height  % _SampleFilter.z < _SampleFilter.w)return 0;

				float4 image_col = tex2Dlod(image, uv);
				if (all(rec_color.rgb == image_col.rgb))
				{
					int roll = (uv.x*image_size.x + uv.y*image_size.y) % 4;

					if (roll == 0)
						result = float4(_GainValue.x, 0, 0, 0);

					if (roll == 1)
						result = float4(0, _GainValue.x, 0, 0);

					if (roll == 2)
						result = float4(0, 0, _GainValue.x, 0);

					if (roll == 3)
						result = float4(0, 0, 0, _GainValue.x);
				}

				return result;
			}

			v2f vert(uint vid : SV_VertexID)
			{
				v2f o = (v2f)0;

				o.vertex = 0;

				half2 image_size = half2(_SampleFilter.x * _LoopImageSize.x, _SampleFilter.y * _LoopImageSize.y);

				half y = floor(vid / _LoopImageSize.x);
				half x = (vid - y * _LoopImageSize.x) / _LoopImageSize.x;
				y = y / _LoopImageSize.y;

				for (half rx = 0; rx < _SampleFilter.x; rx++)
				{
					for (half ry = 0; ry < _SampleFilter.y; ry++)
					{
						half xx = x + rx;
						half yy = y + ry;

						float4 r = statistics_sample(_Image, _Rec_Color, half4(xx, yy, 0, 0), image_size);

						o.color += r;
					}
				}

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

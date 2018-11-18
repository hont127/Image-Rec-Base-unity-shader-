Shader "Hidden/FooShader"
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
			float4 _ImageSize;

			v2f vert(uint vid : SV_VertexID)
			{
				v2f o = (v2f)0;

				half y = floor(vid / _ImageSize.x);
				half x = (vid - y * _ImageSize.x) / _ImageSize.x;
				y = y / _ImageSize.y;

				o.vertex = 0;

				float4 image_col = tex2Dlod(_Image, half4(x,y,0,0));

				if (all(image_col.rgb == half3(0, 0, 1)))
				//if (all(image_col.rgb == half3(0, 1, 1)))    /*error*/
				{
					o.color = 1;
				}
				else
				{
					o.color = 0;
				}

				return o;
			}

			[maxvertexcount(4)]
			void geom(point v2f vertElement[1], inout TriangleStream<v2f> triStream)
			{
				if (vertElement[0].color.r <= 0) return;

				float size = 10;

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

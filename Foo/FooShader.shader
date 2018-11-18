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

			v2f vert(uint vid : SV_VertexID)
			{
				v2f o = (v2f)0;

				o.vertex = 0;

				int roll = vid % 4;

				if(roll == 0)
					o.color = float4(0.05, 0, 0, 0);

				if (roll == 1)
					o.color = float4(0, 0.05, 0, 0);

				if (roll == 2)
					o.color = float4(0, 0, 0.05, 0);

				if (roll == 3)
					o.color = float4(0, 0, 0, 0.05);

				return o;
			}

			[maxvertexcount(4)]
			void geom(point v2f vertElement[1], inout TriangleStream<v2f> triStream)
			{
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

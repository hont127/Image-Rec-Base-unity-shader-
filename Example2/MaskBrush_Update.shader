Shader "Hidden/MaskBrush_Update"
{
	Properties
	{
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 wPos : TEXCOORD1;
			};

			float4x4 _ObjectToWorldMatrix;
			float4 _BrushPoint;

			v2f vert(appdata v)
			{
				v2f o = (v2f)0;

				o.vertex = UnityObjectToClipPos(float4(v.uv.x-0.55, v.uv.y+0.5, 0, v.vertex.w));
				o.wPos = mul(_ObjectToWorldMatrix, v.vertex);
				o.uv = v.uv;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed d = distance(i.wPos, _BrushPoint);

				if (d < 0.5)
				{
					return 0.5-d;
				}
				else
				{
					return 0;
				}
			}
			ENDCG
		}
	}
}

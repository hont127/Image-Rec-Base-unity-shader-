using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace Hont
{
    public class Foo : MonoBehaviour
    {
        void Start()
        {
            var blueTex = new Texture2D(64, 64);
            for (int x = 0; x < blueTex.width; x++)
                for (int y = 0; y < blueTex.height; y++)
                    blueTex.SetPixel(x, y, Color.blue);
            blueTex.Apply();

            var mat = new Material(Shader.Find("Hidden/FooShader"));
            mat.SetTexture("_Image", blueTex);
            mat.SetVector("_ImageSize", new Vector4(blueTex.width, blueTex.height));
            mat.SetPass(0);
            var tempRT = RenderTexture.GetTemporary(16, 16, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.sRGB, 1);
            tempRT.filterMode = FilterMode.Point;
            tempRT.autoGenerateMips = false;
            tempRT.anisoLevel = 0;
            tempRT.wrapMode = TextureWrapMode.Clamp;
            var cacheRT = RenderTexture.active;
            RenderTexture.active = tempRT;
#if UNITY_2019_1_OR_NEWER
            Graphics.DrawProceduralNow(MeshTopology.Points, blueTex.width * blueTex.height, 1);
#else
            Graphics.DrawProcedural(MeshTopology.Points, blueTex.width * blueTex.height, 1);
#endif
            var tex2D = new Texture2D(16, 16, TextureFormat.ARGB32, false, false);
            tex2D.wrapMode = TextureWrapMode.Clamp;
            tex2D.anisoLevel = 0;
            tex2D.filterMode = FilterMode.Point;
            tex2D.ReadPixels(new Rect(0, 0, 16, 16), 0, 0);
            var firstPixel = tex2D.GetPixel(0, 0);
            Debug.Log("firstPixel: " + firstPixel);
            RenderTexture.active = cacheRT;
            RenderTexture.ReleaseTemporary(tempRT);
        }
    }
}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace Hont
{
    public class RealtimeImageStatistics
    {
        Material mMat;
        Texture mStatisticsTexture;
        RenderTexture mTempRT;
        Texture2D mResultTex2D;
        CommandBuffer mCommandBuffer;

        float mRecGainValue;
        int mSingleVertGridSize;

        public RenderTexture TempRT { get { return mTempRT; } }
        public float RecGainValue { get { return mRecGainValue; } set { mRecGainValue = value; } }


        public RealtimeImageStatistics()
        {
            mRecGainValue = 0.05f;
        }

        public void Initialization(Texture statisticsTexture, Color statisticsColor, int singleVertGridSize = 3, int sampleIgnoreNum = 4, int sampleIgnoreNumMask = 2)
        {
            mSingleVertGridSize = singleVertGridSize;
            mStatisticsTexture = statisticsTexture;

            mMat = new Material(Shader.Find("Hidden/RealtimeImageStatisticsShader"));
            mMat.SetTexture("_Image", mStatisticsTexture);
            var loopImageSize = new Vector4(mStatisticsTexture.width / (float)mSingleVertGridSize, mStatisticsTexture.height / (float)mSingleVertGridSize);
            mMat.SetVector("_LoopImageSize", loopImageSize);
            mMat.SetColor("_Rec_Color", statisticsColor);
            mMat.SetVector("_SampleFilter", new Vector4(singleVertGridSize, singleVertGridSize, sampleIgnoreNum, sampleIgnoreNumMask));
            mMat.SetVector("_GainValue", new Vector4(mRecGainValue, 0, 0, 0));

            mTempRT = RenderTexture.GetTemporary(16, 16, 0);

            mCommandBuffer = new CommandBuffer();
            mCommandBuffer.BeginSample("---Rec Test---");
            mCommandBuffer.SetRenderTarget(mTempRT);
            mCommandBuffer.ClearRenderTarget(true, true, Color.clear);
            var pointsCount = Mathf.CeilToInt(loopImageSize.x * loopImageSize.y);
            mCommandBuffer.SetProjectionMatrix(Matrix4x4.Perspective(60f, 1f, 0.0001f, 1f));
            mCommandBuffer.DrawProcedural(Matrix4x4.TRS(Vector3.zero, Quaternion.identity, Vector3.one), mMat, 0, MeshTopology.Points, pointsCount, 1);
            mCommandBuffer.EndSample("---Rec Test---");
        }

        public void Release()
        {
            RenderTexture.ReleaseTemporary(mTempRT);
            UnityEngine.Object.Destroy(mResultTex2D);
            UnityEngine.Object.Destroy(mMat);
            mCommandBuffer.Dispose();
        }

        public float ExecuteStatistics()
        {
            var cacheActive = RenderTexture.active;
            Graphics.ExecuteCommandBuffer(mCommandBuffer);
            RenderTexture.active = mTempRT;
            if (mResultTex2D == null)
                mResultTex2D = new Texture2D(1, 1);
            mResultTex2D.ReadPixels(new Rect(0, 0, 1, 1), 0, 0);

            RenderTexture.active = cacheActive;

            var color = mResultTex2D.GetPixel(0, 0);
            return color.r + color.g + color.b + color.a;
        }
    }
}

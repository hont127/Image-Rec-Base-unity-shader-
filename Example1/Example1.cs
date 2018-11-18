using UnityEngine;
using UnityEngine.Rendering;

namespace Hont
{
    public class Example1 : MonoBehaviour
    {
        public Color recColor;
        public Texture2D image;
        float mResult;

        RealtimeImageStatistics mRealtimeImageStatistics;

        CommandBuffer mCommandBuffer;
        Texture2D mResultTex2D;


        void Start()
        {
            mRealtimeImageStatistics = new RealtimeImageStatistics();
            mRealtimeImageStatistics.Initialization(image, recColor, 9, 4, 0);
        }

        void OnDisable()
        {
            mRealtimeImageStatistics.Release();
        }

        void Update()
        {
            mResult = mRealtimeImageStatistics.ExecuteStatistics();
        }

        void OnGUI()
        {
            if (mRealtimeImageStatistics.TempRT != null)
                GUILayout.Box(mRealtimeImageStatistics.TempRT);

            if (mResult > 0)
            {
                GUILayout.Label("Success " + mResult);
            }
            else
            {
                GUILayout.Label("Fail " + mResult);
            }
        }
    }
}

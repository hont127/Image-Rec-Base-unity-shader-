using UnityEngine;
using UnityEngine.Rendering;
using System.Collections;
using Hont;

public class RecTest2 : MonoBehaviour
{
    public GameObject drawItem;
    public Transform brushBall;

    RealtimeImageStatistics mRealtimeImageStatistics;

    RenderTexture mMaskRT;

    Material mCacheMaskBrushMat;
    Material mCacheMaskCombineMat;

    Texture2D mRecResultTex2D;

    CommandBuffer mCommandBuffer;


    void Start()
    {
        mMaskRT = RenderTexture.GetTemporary(256, 256);

        mRealtimeImageStatistics = new RealtimeImageStatistics();
        mRealtimeImageStatistics.RecGainValue = 0.03f;
        mRealtimeImageStatistics.Initialization(mMaskRT, Color.white, 9, 4, 1);

        mCommandBuffer = new CommandBuffer();
        Camera.main.AddCommandBuffer(CameraEvent.AfterEverything, mCommandBuffer);
        mCacheMaskBrushMat = new Material(Shader.Find("Hidden/MaskBrush_Update"));
        mCacheMaskCombineMat = new Material(Shader.Find("Hidden/MaskCombine"));
        drawItem.GetComponent<MeshRenderer>().sharedMaterial.SetTexture("_MaskTex", mMaskRT);
    }

    void Update()
    {
        if (mCommandBuffer == null) return;

        mCommandBuffer.Clear();

        var lastMaskTexID = Shader.PropertyToID("_LastMaskTexCache");
        var tempRTID = Shader.PropertyToID("_TempRTID");
        mCommandBuffer.GetTemporaryRT(lastMaskTexID, mMaskRT.descriptor);

        mCommandBuffer.SetRenderTarget(lastMaskTexID);
        //mCommandBuffer.ClearRenderTarget(true, true, Color.black);
        mCommandBuffer.SetGlobalVector("_BrushPoint", brushBall.position);
        mCommandBuffer.SetGlobalMatrix("_ObjectToWorldMatrix", drawItem.transform.localToWorldMatrix);
        mCommandBuffer.SetProjectionMatrix(Matrix4x4.Perspective(60f, 1f, 0.001f, 10f));
        mCommandBuffer.DrawMesh(drawItem.GetComponent<MeshFilter>().sharedMesh, Matrix4x4.TRS(new Vector3(0f, 0f, -9f), Quaternion.identity, Vector3.one), mCacheMaskBrushMat);
        mCommandBuffer.SetRenderTarget(BuiltinRenderTextureType.CameraTarget);

        mCommandBuffer.GetTemporaryRT(tempRTID, mMaskRT.descriptor);
        mCommandBuffer.Blit(mMaskRT, tempRTID);

        mCommandBuffer.SetGlobalTexture("_WaitCombine_BTex", tempRTID);
        mCommandBuffer.Blit(lastMaskTexID, mMaskRT, mCacheMaskCombineMat);

        mCommandBuffer.ReleaseTemporaryRT(tempRTID);
        mCommandBuffer.ReleaseTemporaryRT(lastMaskTexID);

        var r = mRealtimeImageStatistics.ExecuteStatistics();
        Debug.Log("r: " + r);
        if (r >= 2.7f)
        {
            StartCoroutine(Show());
            Camera.main.RemoveCommandBuffer(CameraEvent.AfterEverything, mCommandBuffer);
            mCommandBuffer.Dispose();
            mCommandBuffer = null;
        }
    }

    void OnDisable()
    {
        if (mCommandBuffer != null && Camera.main != null)
        {
            Camera.main.RemoveCommandBuffer(CameraEvent.AfterEverything, mCommandBuffer);
            mCommandBuffer.Dispose();
        }

        RenderTexture.ReleaseTemporary(mMaskRT);
        mRealtimeImageStatistics.Release();
    }

    IEnumerator Show()
    {
        var mat = drawItem.GetComponent<MeshRenderer>().material;

        var beginTime = Time.time;
        for (var duration = 1f; Time.time - beginTime <= duration;)
        {
            var t = (Time.time - beginTime) / duration;

            mat.SetColor("_Color", Color.Lerp(new Color(0f, 0f, 0f, 0f), new Color(1f, 1f, 1f, 1f), t));

            yield return null;
        }
        mat.SetColor("_Color", new Color(1f, 1f, 1f, 1f));
        yield return null;

    }
}

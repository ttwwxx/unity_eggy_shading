using UnityEngine;

public class SoftBodyController : MonoBehaviour
{
    [Header("Soft Body Parameters")]
    public Vector3 softBodyCenter = Vector3.zero;
    public Vector3 softBodyScale = Vector3.one;
    public Vector3 softBodyNegativeScale = Vector3.one;

    [Header("UV Offset")]
    public float faceUVOffset = 0f;
    public float charOffset = 0f;

    private Material material;

    void Start()
    {
        material = GetComponent<Renderer>().material;
        UpdateMaterialProperties();
    }

    void Update()
    {
        UpdateMaterialProperties();
    }

    void UpdateMaterialProperties()
    {
        if (material != null)
        {
            // 设置软体变形参数
            material.SetVector("_SoftBodyCenter", softBodyCenter);
            material.SetVector("_SoftBodyX", new Vector3(softBodyScale.x, 0, 0));
            material.SetVector("_SoftBodyY", new Vector3(0, softBodyScale.y, 0));
            material.SetVector("_SoftBodyZ", new Vector3(0, 0, softBodyScale.z));
            material.SetVector("_SoftBodyNX", new Vector3(softBodyNegativeScale.x, 0, 0));
            material.SetVector("_SoftBodyNY", new Vector3(0, softBodyNegativeScale.y, 0));
            material.SetVector("_SoftBodyNZ", new Vector3(0, 0, softBodyNegativeScale.z));

            // 设置UV偏移参数
            material.SetFloat("_FaceUVOffset", faceUVOffset);
            material.SetFloat("_CharOffset", charOffset);
        }
    }
}
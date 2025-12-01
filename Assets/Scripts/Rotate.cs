using UnityEngine;

/// <summary>
/// 让物体绕自身Z轴自动旋转的脚本
/// 挂在任意Unity物体上即可生效
/// </summary>
public class AutoRotateAroundZ : MonoBehaviour
{
    [Header("旋转配置")]
    [Tooltip("旋转速度（度/秒），正数顺时针，负数逆时针")]
    public float rotateSpeed = 30f; // 默认30度/秒，可在Inspector调整

    void Update()
    {
        // 核心逻辑：绕自身Z轴旋转
        // Rotate参数：(x轴旋转角度, y轴旋转角度, z轴旋转角度)，Space.Self表示自身坐标系
        transform.Rotate(0f, 0f, rotateSpeed * Time.deltaTime, Space.Self);
    }
}
using UnityEngine;
using System.Collections;
using UnityEngine.Assertions;

[ExecuteInEditMode]
public class MainCamera : MonoBehaviour
{
    [SerializeField] [HideInInspector] Camera thisCamera;

    static Camera m_camera;
    public static Camera Instance
    {
        get { return m_camera ?? Camera.main; }  // Camera.main will be removed
    }

    void OnValidate()
    {
        thisCamera = GetComponent<Camera>();
    }

    void OnEnable()
    {
        Assert.IsNotNull(thisCamera, "MainCamera component is not attached to a camera!");
        Assert.IsNull(m_camera, "More than one MainCamera component is active!");
        m_camera = thisCamera;
    }

    void OnDisable()
    {
		Assert.IsTrue(m_camera == thisCamera, "Currently not active MainCamera component.");
        if (m_camera == thisCamera)
            m_camera = null;
    }
}

using UnityEngine;
using UnityEditor;
using System.Collections;

public class VFXEditorTools {

	[MenuItem("Tools/VFX/RestartCurrentEffect % ")]
    public static void RestartCurrentEffect()
    {
        if(Selection.gameObjects.Length > 0)
            foreach(GameObject o in Selection.gameObjects)
            {
                var ps = o.GetComponent<ParticleSystem>();
                ps.time = 0.0f;
                ps.Clear(true);
                ps.Stop(true);
                ps.Play(true);
            }
 
    
    }

}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;

public class RestartTimeline : MonoBehaviour
{
	public PlayableDirector timeline;

	void Update()
	{
		if (Input.GetKey(KeyCode.R))
		{
			timeline.time = 0;
		}
	}
}

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShaderProperties : MonoBehaviour
{
    private Renderer targetRenderer;

    private void Awake()
    {
        targetRenderer = GetComponent<Renderer>();
    }
}

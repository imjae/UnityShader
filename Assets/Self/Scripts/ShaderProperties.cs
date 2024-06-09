using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

public class ShaderProperties : MonoBehaviour
{
    public Renderer targetRenderer;
    public List<PropertyAnimationCurve> propertyAnimationCurveList = new List<PropertyAnimationCurve>();

    private void Awake()
    {
        targetRenderer = GetComponent<Renderer>();
    }

    [Serializable]
    public class PropertyAnimationCurve
    {
        public ShaderUtil.ShaderPropertyType shaderPropertyType;
        public string propertyName;
        public string propertyDescription;
        public float duration;
        public AnimationCurve curve = AnimationCurve.Linear(0, 0, 1, 1);
    }
}

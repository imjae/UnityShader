using UnityEngine;
using UnityEditor;
using Unity.VisualScripting;

[CustomEditor(typeof(ShaderProperties))]
public class ShaderPropertiesInspector : Editor
{
    ShaderProperties self;
    Renderer targetRenderer;

    private void OnEnable()
    {
        self = (ShaderProperties)target;

        if (targetRenderer == null)
        {
            targetRenderer = self.GetComponent<Renderer>();
        }
    }

    public override void OnInspectorGUI()
    {
        Material material = targetRenderer.sharedMaterial;

        if (material != null)
        {
            Shader shader = material.shader;
            ShaderInfo sd = ShaderUtil.GetShaderInfo(shader);
            // sd.Get
            int propertyCount = ShaderUtil.GetPropertyCount(shader);

            EditorGUI.BeginChangeCheck();
            for (int i = 0; i < propertyCount; i++)
            {
                ShaderUtil.ShaderPropertyType propertyType = ShaderUtil.GetPropertyType(shader, i);
                string propertyName = ShaderUtil.GetPropertyName(shader, i);
                string propertyDescription = ShaderUtil.GetPropertyDescription(shader, i);

                switch (propertyType)
                {
                    case ShaderUtil.ShaderPropertyType.Color:
                        Color colorValue = material.GetColor(propertyName);
                        colorValue = EditorGUILayout.ColorField(propertyDescription, colorValue);
                        material.SetColor(propertyName, colorValue);
                        break;
                    case ShaderUtil.ShaderPropertyType.Float:
                        float floatValue = material.GetFloat(i);
                        floatValue = EditorGUILayout.FloatField(propertyDescription, floatValue);
                        material.SetFloat(propertyName, floatValue);
                        break;
                }
            }
            if (EditorGUI.EndChangeCheck())
            {
                EditorUtility.SetDirty(material);
            }
        }

        // 기본 인스펙터 요소를 그대로 유지
        // DrawDefaultInspector();
    }
}

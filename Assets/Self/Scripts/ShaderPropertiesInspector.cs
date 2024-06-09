using UnityEngine;
using UnityEditor;
using System.Runtime.CompilerServices;
using static ShaderProperties;
using System.Collections.Generic;

[CustomEditor(typeof(ShaderProperties))]
public class ShaderPropertiesInspector : Editor
{
    ShaderProperties self;
    Renderer targetRenderer;

    SerializedProperty propertyAnimationCurveList;

    private void OnEnable()
    {
        self = (ShaderProperties)target;

        if (targetRenderer == null)
        {
            targetRenderer = self.GetComponent<Renderer>();
        }

        propertyAnimationCurveList = serializedObject.FindProperty("propertyAnimationCurveList");
        propertyAnimationCurveList.ClearArray();
        self.propertyAnimationCurveList = new List<PropertyAnimationCurve>();

        InitializeShaderProperties();
    }

    public override void OnInspectorGUI()
    {
        Material material = targetRenderer.sharedMaterial;

        if (material != null)
        {
            Shader shader = material.shader;
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
                    case ShaderUtil.ShaderPropertyType.Range:
                        float rangeValue = material.GetFloat(propertyName);
                        rangeValue = EditorGUILayout.FloatField(propertyDescription, rangeValue);
                        material.SetFloat(propertyName, rangeValue);
                        break;
                    case ShaderUtil.ShaderPropertyType.Float:
                        float floatValue = material.GetFloat(propertyName);
                        floatValue = EditorGUILayout.FloatField(propertyDescription, floatValue);
                        material.SetFloat(propertyName, floatValue);
                        break;

                    default:
                        // Debug.Log($"{i} - {propertyName}");
                        break;
                }
            }
            if (EditorGUI.EndChangeCheck())
            {
                EditorUtility.SetDirty(material);
            }
        }

        // 기본 인스펙터 요소를 그대로 유지
        DrawDefaultInspector();
    }

    private void InitializeShaderProperties()
    {
        Material material = targetRenderer.sharedMaterial;

        if (material != null)
        {
            Shader shader = material.shader;
            int propertyCount = ShaderUtil.GetPropertyCount(shader);

            for (int i = 0; i < propertyCount; i++)
            {
                ShaderUtil.ShaderPropertyType propertyType = ShaderUtil.GetPropertyType(shader, i);
                string propertyName = ShaderUtil.GetPropertyName(shader, i);
                string propertyDescription = ShaderUtil.GetPropertyDescription(shader, i);

                AddElement(propertyAnimationCurveList, propertyName, propertyType);
            }
        }

    }

    private void AddElement(SerializedProperty listProperty, string elementName, ShaderUtil.ShaderPropertyType shaderPropertyType)
    {
        listProperty.arraySize++;
        SerializedProperty elementProperty = listProperty.GetArrayElementAtIndex(listProperty.arraySize - 1);

        // 직렬화된 객체의 필드에 접근하여 값을 설정합니다.
        elementProperty.FindPropertyRelative("propertyName").stringValue = elementName;
        elementProperty.FindPropertyRelative("shaderPropertyType").enumValueIndex = (int)shaderPropertyType;

        listProperty.serializedObject.ApplyModifiedProperties();
    }
    private void DrawProperty()
    {

    }
}

using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

namespace TTFrame.Editor
{
    public static class CustomSceneDrawModes
    {
        private const string SECTION = "Debug";

        private static Dictionary<string, Shader> drawModes;

        private static Dictionary<string, Shader> DrawModes
        {
            get
            {
                if (drawModes == null)
                {
                    drawModes = new Dictionary<string, Shader>()
                    {
                        {"BaseColor", Shader.Find("Hidden/CustomDrawMode_BaseColor") },
                        {"Grayscale", Shader.Find("Hidden/CustomDrawMode_Grayscale") },
                        {"Grayscale(Desaturation)", Shader.Find("Hidden/CustomDrawMode_Grayscale_Desaturation") },
                        {"Metallic", Shader.Find("Hidden/CustomDrawMode_Metallic") },
                        {"Smoothness", Shader.Find("Hidden/CustomDrawMode_Smoothness") },
                        {"Roughness", Shader.Find("Hidden/CustomDrawMode_Roughness") },
                        {"Occlusion", Shader.Find("Hidden/CustomDrawMode_Occlusion") },
                        {"Normal(World)", Shader.Find("Hidden/CustomDrawMod_Normal_World") },
                        {"Normal(Tangent)", Shader.Find("Hidden/CustomDrawMode_Normal_Tangent") },
                        {"Emission", Shader.Find("Hidden/CustomDrawMode_Emission") },
                        {"VertexColor", Shader.Find("Hidden/CustomDrawMode_VertexColor") },
                        {"UV0", Shader.Find("Hidden/CustomDrawMode_UV0") },
                        {"UV1", Shader.Find("Hidden/CustomDrawMode_UV1") },
                    };

                    if (GetCurrentRenderPipeline() == RenderPipelineType.UniversalRP)
                    {
                        drawModes["Metallic"] = Shader.Find("Hidden/CustomDrawMode_Metallic_URP");
                        drawModes["Roughness"] = Shader.Find("Hidden/CustomDrawMode_Roughness_URP");
                        drawModes["Smoothness"] = Shader.Find("Hidden/CustomDrawMode_Smoothness_URP");
                    }

                    Texture2D texture = Resources.Load<Texture2D>("CustomDrawMode/UVChecker_4K");
                    Shader.SetGlobalTexture("_UVCheckerboard", texture);
                }

                return drawModes;
            }
        }

        private static SceneView currentSceneView;

        [InitializeOnLoadMethod]
        private static void HookIntoSceneView()
        {
            EditorApplication.delayCall += () =>
            {
                SceneView.ClearUserDefinedCameraModes();

                foreach (var mode in DrawModes)
                {
                    SceneView.AddCameraMode(mode.Key, SECTION);
                }

                EditorApplication.update += OnUpdateEditor;
            };
        }

        private static void OnUpdateEditor()
        {
            if (SceneView.lastActiveSceneView != currentSceneView)
            {
                if (currentSceneView != null)
                {
                    currentSceneView.onCameraModeChanged -= OnDrawModeChanged;
                }
                if (SceneView.lastActiveSceneView != null)
                {
                    currentSceneView = SceneView.lastActiveSceneView;
                    //为OnDrawModeChanged添加回调函数
                    currentSceneView.onCameraModeChanged += OnDrawModeChanged;
                }
            }
        }

        private static void OnDrawModeChanged(SceneView.CameraMode mode)
        {
            if (currentSceneView == null) return;

            if (mode.section == SECTION && DrawModes.ContainsKey(mode.name))
            {
                currentSceneView.SetSceneViewShaderReplace(DrawModes[mode.name], "");
            }
            else
            {
                currentSceneView.SetSceneViewShaderReplace(null, null);
            }
        }

        private static RenderPipelineType GetCurrentRenderPipeline()
        {
            RenderPipelineAsset renderPipelineAsset = GraphicsSettings.renderPipelineAsset;

            if (renderPipelineAsset == null)
            {
                // Built-in Render Pipeline
                return RenderPipelineType.BuiltIn;
            }
            else if (renderPipelineAsset.GetType().ToString().Contains("UniversalRenderPipelineAsset"))
            {
                // Universal Render Pipeline (URP)
                return RenderPipelineType.UniversalRP;
            }
            else if (renderPipelineAsset.GetType().ToString().Contains("HDRenderPipelineAsset"))
            {
                // High Definition Render Pipeline (HDRP)
                return RenderPipelineType.HighDefinitionRP;
            }
            else
            {
                // Unknown Render Pipeline
                return RenderPipelineType.Unknown;
            }
        }

        public enum RenderPipelineType
        {
            BuiltIn,
            UniversalRP,
            HighDefinitionRP,
            Unknown
        }
    }
}
using UnityEditor;

public static class BuildProject
{
    public static void Build()
    {
        PlayerSettings.defaultIsFullScreen = false;
        PlayerSettings.companyName = "pocky";
        PlayerSettings.productName = "Texture_Normal";
        PlayerSettings.resizableWindow = false;
        PlayerSettings.displayResolutionDialog = ResolutionDialogSetting.Disabled;

        string[] levels = { "Assets/Scenes/Texture_Normal.unity" };
        BuildPipeline.BuildPlayer(levels, "test.apk", BuildTarget.Android, BuildOptions.None);
    }
}
# GodotSfxr

Godot plugin that adds the SfxrStreamPlayer node to generate sound effects inside the editor.

![SfxrStreamPlayer Node](images/icon_big.png)

Ported from [jsfxr](https://sfxr.me/) (by Eric Fredricksen), which is a port from the original [sfxr](https://www.drpetter.se/project_sfxr.html) (by DrPetter).

## Installation

- Install from the [Godot Asset Library](https://godotengine.org/asset-library/asset/1195)*.

- Clone or download this repository, and copy the contents of the "addons" directory to the "addons" directory of your Godot Project.

> \* The download from the Godot Asset Library might not be up to date. You can use Github to always get the latest version.

## Usage

Add the node: ``SfxrStreamPlayer``.

![image](https://user-images.githubusercontent.com/8657959/152902270-77ed5d3d-d1a3-4efc-8907-83d5a0313f8c.png)

Select a preset sound effect under the ``Generators`` group in the inspector.

That will generate and save an ``AudioStreamSample`` resource with the audio data.

![image](https://user-images.githubusercontent.com/8657959/152902343-408276c1-dc8a-49d1-bdd6-e6de5fd4138d.png)

You can adjust the sound parameters on the inspector as needed.

The sound will play automatically after being generated, but you can also click on the ``Playing`` property to make it play.

If for some reason you need to regenerate the sound (maybe you deleted the stream resource), you can use the ``Force Rebuild`` option under the ``Actions`` group.

![image](https://user-images.githubusercontent.com/8657959/152902707-267a9be9-02a9-43b7-8f9b-73641474c8b3.png)

Everything else works as in the regular ``AudioStreamPlayer`` node.

For example, you can call the ``play`` function on the node, or connect to the ``finished`` signal.

![image](https://user-images.githubusercontent.com/8657959/152903349-cb60ba13-e2b3-456f-b741-61550a78dde4.png)

You can also save the generated stream as a resource so you can reuse it elsewhere (like in an ``AudioStreamPlayer2D`` or ``AudioStreamPlayer3D``).

![image](https://user-images.githubusercontent.com/8657959/152903898-adb61ed0-27bf-422c-8606-5bae131588be.png)

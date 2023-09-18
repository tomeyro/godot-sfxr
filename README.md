# GodotSfxr

Godot plugin that adds the SfxrStreamPlayer node and SfxrAudioStream Resource to generate sound effects inside the editor.

![SfxrStreamPlayer Node](images/icon_big.png)

Ported from [jsfxr](https://sfxr.me/) (by Eric Fredricksen), which is a port from the original [sfxr](https://www.drpetter.se/project_sfxr.html) (by DrPetter).

## Installation

- Install options:

  1. Install from the [Godot Asset Library](https://godotengine.org/asset-library/asset?filter=GodotSfxr&category=5&godot_version=&cost=&sort=updated)*.

  2. Clone or download this repository, and copy the contents of the "addons" directory to the "addons" directory of your Godot Project.

  > \* The download from the Godot Asset Library might not be up to date. You can use Github to always get the latest version.

- After installing the plugin you need to enable it on the menu: ``Project`` > ``Project Settings...`` > ``Plugins`` > ``GodotSfxr``.

## Usage

Add the desired node: ``SfxrStreamPlayer``, ``SfxrStreamPlayer2D``, or ``SfxrStreamPlayer3D``.

![Node selection](https://user-images.githubusercontent.com/8657959/156293234-b7273f72-ce67-4f6c-94c9-2d8739361d45.png)

Select a preset sound effect under the ``Generators`` group in the inspector.

That will generate and save an ``AudioStreamSample`` resource with the audio data (embedded on the node).

![Node options](https://user-images.githubusercontent.com/8657959/152902343-408276c1-dc8a-49d1-bdd6-e6de5fd4138d.png)

You can adjust the sound parameters on the inspector as needed.

The sound will play automatically after being generated, but you can also click on the ``Playing`` property to make it play.

If for some reason you need to regenerate the sound (maybe you deleted the stream resource), you can use the ``Force Rebuild`` option under the ``Actions`` group.

![Node regen](https://user-images.githubusercontent.com/8657959/152902707-267a9be9-02a9-43b7-8f9b-73641474c8b3.png)

Everything else works as in the regular ``AudioStreamPlayer*`` nodes.

For example, you can call the ``play`` function on the node, or connect to the ``finished`` signal.

![Code example](https://user-images.githubusercontent.com/8657959/152903349-cb60ba13-e2b3-456f-b741-61550a78dde4.png)

Depending on your needs, you can also create a ``SfxrAudioStream`` Resource that will contain the audio data, and has all the same options as the nodes above.

![Resource Creation](https://github.com/tomeyro/godot-sfxr/assets/8657959/3e80511d-0895-4dc6-a781-71c6e9374190)

Then you can use that resource by setting it to the ``stream`` parameter of any ``AudioStreamPlayer``.

![Node with resource](https://github.com/tomeyro/godot-sfxr/assets/8657959/5877916e-20e9-47ef-b805-fb10948faaa6)

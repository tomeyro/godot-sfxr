# GodotSfxr

Godot plugin that adds the SfxrStreamPlayer node to generate sound effects inside the editor.

![SfxrStreamPlayer Node](images/icon_big.png)

Ported from [jsfxr](https://sfxr.me/) (by Eric Fredricksen), which is a port from the original [sfxr](https://www.drpetter.se/project_sfxr.html) (by DrPetter).

## Installation

- Install from the Godot Asset Library (under review, link pending).

- Clone or download this repository, and copy the contents of the "addons" directory to the "addons" directory of your Godot Project.

## Usage

Add the node "SfxrStreamPlayer".

![20220124174216](https://user-images.githubusercontent.com/8657959/150886613-d318ee4b-25ff-4cda-8e3a-f116c43f5220.png)

Select a preset sound effect under the "Actions" group in the inspector.

![20220124174501](https://user-images.githubusercontent.com/8657959/150886575-f7bea696-a5fe-4661-a508-679dd50a9db2.png)

You can adjust the sound parameters on the inspector as needed.

Click the "Play" checkbox under the "Actions" group to hear the sound effect.

![20220124174603](https://user-images.githubusercontent.com/8657959/150886583-b0d77ca8-7b5b-4327-b5d7-fc799c46af99.png)

To trigger the sound effect, call the "play_sfx" function on the node.

![20220124175030](https://user-images.githubusercontent.com/8657959/150886591-52bd3386-108d-4589-a76f-d6ce6ef0f04d.png)

This custom node is made using the AudioStreamGenerator resource, which is filled with the Audio data to be streamed. The first time the audio data is computed it might take some time (due to gdscript), so it is suggested you "pre-load" it before needing it with the "_build_buffer" function. This will cache the audio data and stream it instantly the next time you play it.

![20220124180307](https://user-images.githubusercontent.com/8657959/150886606-e30c21d1-3b0e-435d-b413-92ee19598d01.png)


Another drawback is that because it is an AudioStreamGenerator, the player node is always "playing", as it is always waiting for audio data to be streamed, so the "finished" signal is never triggered for this node.

@tool
extends EditorPlugin


var audio_player: AudioStreamPlayer


func _enter_tree() -> void:
    add_custom_type(
        "SfxrStreamPlayer", "AudioStreamPlayer", load("res://addons/godot_sfxr/SfxrStreamPlayer.gd"),
        get_editor_interface().get_base_control().get_theme_icon("AudioStreamPlayer", "EditorIcons"))
    add_custom_type(
        "SfxrStreamPlayer2D", "AudioStreamPlayer2D", load("res://addons/godot_sfxr/SfxrStreamPlayer2D.gd"),
        get_editor_interface().get_base_control().get_theme_icon("AudioStreamPlayer2D", "EditorIcons"))
    add_custom_type(
        "SfxrStreamPlayer3D", "AudioStreamPlayer3D", load("res://addons/godot_sfxr/SfxrStreamPlayer3D.gd"),
        get_editor_interface().get_base_control().get_theme_icon("AudioStreamPlayer3D", "EditorIcons"))
    add_custom_type(
        "SfxrAudioStream", "AudioStreamWAV", load("res://addons/godot_sfxr/SfxrAudioStream.gd"),
        get_editor_interface().get_base_control().get_theme_icon("AudioStreamWAV", "EditorIcons"))
    # Add an audio player to the tree so we can play audio when creating sfx as resources.
    audio_player = AudioStreamPlayer.new()
    audio_player.add_to_group("SfxrInternalAudioPlayer")
    get_tree().root.add_child.call_deferred(audio_player)


func _exit_tree() -> void:
    remove_custom_type("SfxrStreamPlayer")
    remove_custom_type("SfxrStreamPlayer2D")
    remove_custom_type("SfxrStreamPlayer3D")
    remove_custom_type("SfxrAudioStream")
    audio_player.queue_free()

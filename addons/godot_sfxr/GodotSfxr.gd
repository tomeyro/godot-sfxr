tool
extends EditorPlugin


func _enter_tree() -> void:
    add_custom_type(
        "SfxrStreamPlayer", "AudioStreamPlayer", load("res://addons/godot_sfxr/SfxrStreamPlayer.gd"),
        get_editor_interface().get_base_control().get_icon("AudioStreamPlayer", "EditorIcons"))
    add_custom_type(
        "SfxrStreamPlayer2D", "AudioStreamPlayer2D", load("res://addons/godot_sfxr/SfxrStreamPlayer2D.gd"),
        get_editor_interface().get_base_control().get_icon("AudioStreamPlayer2D", "EditorIcons"))
    add_custom_type(
        "SfxrStreamPlayer3D", "AudioStreamPlayer3D", load("res://addons/godot_sfxr/SfxrStreamPlayer3D.gd"),
        get_editor_interface().get_base_control().get_icon("AudioStreamPlayer3D", "EditorIcons"))


func _exit_tree() -> void:
    remove_custom_type("SfxrStreamPlayer")
    remove_custom_type("SfxrStreamPlayer2D")
    remove_custom_type("SfxrStreamPlayer3D")

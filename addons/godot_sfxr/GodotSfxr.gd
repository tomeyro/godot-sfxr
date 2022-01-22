tool
extends EditorPlugin
class_name GodotSfxr


func _enter_tree() -> void:
    add_custom_type(
        "SfxrStreamPlayer", "AudioStreamPlayer", load("res://addons/godot_sfxr/SfxrStreamPlayer.gd"),
        get_editor_interface().get_base_control().get_icon("AudioStreamPlayer", "EditorIcons"))


func _exit_tree() -> void:
    remove_custom_type("SfxrStreamPlayer")

@tool
extends AudioStreamPlayer3D


# Wave Shape
var wave_type: int

# Envelope
var p_env_attack: float
var p_env_sustain: float
var p_env_punch: float
var p_env_decay: float

# Tone
var p_base_freq: float
var p_freq_limit: float
var p_freq_ramp: float
var p_freq_dramp: float

# Vibrato
var p_vib_strength: float
var p_vib_speed: float

# Tonal Change
var p_arp_mod: float
var p_arp_speed: float

# Square wve duty (proportion of time signal is high vs low)
var p_duty: float
var p_duty_ramp: float

# Repeat
var p_repeat_speed: float

# Flanger
var p_pha_offset: float
var p_pha_ramp: float

# Low-pass filter
var p_lpf_freq: float
var p_lpf_ramp: float
var p_lpf_resonance: float

# High-pass filter
var p_hpf_freq: float
var p_hpf_ramp: float

# Sample parameters
var sound_vol: float
var sample_rate: float

# Sfx Generation
var sfx_timer: SceneTreeTimer


##################################
# Inspector Properties
##################################


func _get_property_list() -> Array:
    return SfxrStreamPlayerInterface.object_get_property_list()


func _get(property):
    return SfxrStreamPlayerInterface.object_get(self, property)


func _set(property, value):
    return SfxrStreamPlayerInterface.object_set(self, property, value)


##################################
# Defaults
##################################


func _init():
    SfxrStreamPlayerInterface.object_set_defaults(self)


func property_can_revert(property: StringName):
    return SfxrStreamPlayerInterface.object_property_can_revert(property)


func property_get_revert(property: StringName):
    return SfxrStreamPlayerInterface.object_property_get_revert(property)


##################################
# Presets
##################################


func random_preset() -> bool:
    return SfxrStreamPlayerInterface.random_preset(self)


func preset_values(preset_key: int) -> bool:
    return SfxrStreamPlayerInterface.preset_values(self, preset_key)


##################################
# Playback
##################################


func _on_sfx_timer_timeout(timer: SceneTreeTimer, play_after_build: bool):
    SfxrStreamPlayerInterface._on_sfx_timer_timeout(self, timer, play_after_build)


func build_sfx(play_after_build: bool = false):
    SfxrStreamPlayerInterface.build_sfx(self, play_after_build)


func play(from_position: float = 0.0):
    if playing:
        stop()
    super.play(from_position)

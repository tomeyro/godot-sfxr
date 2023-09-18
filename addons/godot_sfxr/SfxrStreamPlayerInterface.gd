extends Object
class_name SfxrStreamPlayerInterface


##################################
# Inspector Properties
##################################


const PROPERTY_MAP = {
    # Sample params
    "sample_params/sound_vol": {"name": "sound_vol", "hint_string": "0,1,0.000000001", "default": 0.25},
    "sample_params/sample_rate": {"name": "sample_rate", "hint_string": "6000,44100,1", "default": 44100.0},
    # Envelope
    "envelope/attack_time": {"name": "p_env_attack", "hint_string": "0,1,0.000000001", "default": 0.0},
    "envelope/sustain_time": {"name": "p_env_sustain", "hint_string": "0,1,0.000000001", "default": 0.6641},
    "envelope/punch_time": {"name": "p_env_punch", "hint_string": "0,1,0.000000001", "default": 0.0},
    "envelope/decay_time": {"name": "p_env_decay", "hint_string": "0,1,0.000000001", "default": 0.0},
    # Frequency
    "frequency/start_frequency": {"name": "p_base_freq", "hint_string": "0,1,0.000000001", "default": 0.35173364},
    "frequency/min_freq_cutoff": {"name": "p_freq_limit", "hint_string": "0,1,0.000000001", "default": 0.0},
    "frequency/slide": {"name": "p_freq_ramp", "hint_string": "-1,1,0.000000001", "default": 0.0},
    "frequency/delta_slide": {"name": "p_freq_dramp", "hint_string": "-1,1,0.000000001", "default": 0.0},
    # Vibrato
    "vibrato/depth": {"name": "p_vib_strength", "hint_string": "0,1,0.000000001", "default": 0.0},
    "vibrato/speed": {"name": "p_vib_speed", "hint_string": "0,1,0.000000001", "default": 0.0},
    # Arpeggiation
    "arpeggiation/frequency_mult": {"name": "p_arp_mod", "hint_string": "-1,1,0.000000001", "default": 0.0},
    "arpeggiation/change_speed": {"name": "p_arp_speed", "hint_string": "0,1,0.000000001", "default": 0.0},
    # Duty cycle
    "duty_cycle/duty_cycle": {"name": "p_duty", "hint_string": "0,1,0.000000001", "default": 0.0},
    "duty_cycle/sweep": {"name": "p_duty_ramp", "hint_string": "-1,1,0.000000001", "default": 0.0},
    # Retrigger
    "retrigger/rate": {"name": "p_repeat_speed", "hint_string": "0,1,0.000000001", "default": 0.0},
    # Flanger
    "flanger/offset": {"name": "p_pha_offset", "hint_string": "-1,1,0.000000001", "default": 0.0},
    "flanger/sweep": {"name": "p_pha_ramp", "hint_string": "-1,1,0.000000001", "default": 0.0},
    # Low-pass filter
    "low_pass_filter/cutoff_frequency": {"name": "p_lpf_freq", "hint_string": "0,1,0.000000001", "default": 1.0},
    "low_pass_filter/cutoff_sweep": {"name": "p_lpf_ramp", "hint_string": "-1,1,0.000000001", "default": 0.0},
    "low_pass_filter/resonance": {"name": "p_lpf_resonance", "hint_string": "0,1,0.000000001", "default": 0.0},
    # High-pass filter
    "high_pass_filter/cutoff_frequency": {"name": "p_hpf_freq", "hint_string": "0,1,0.000000001", "default": 0.0},
    "high_pass_filter/cutoff_sweep": {"name": "p_hpf_ramp", "hint_string": "-1,1,0.000000001", "default": 0.0},
}


static func object_get_property_list() -> Array:
    var presets = SfxrGlobals.PRESETS.keys()
    presets.pop_front()
    var props = []
    props.append({
        "name": "SfxrAudioStream",
        "type": TYPE_NIL,
        "usage": PROPERTY_USAGE_CATEGORY | PROPERTY_USAGE_SCRIPT_VARIABLE,
    })
    for preset in presets:
        props.append({
            "name": "generators/" + str(preset).to_lower(),
            "type": TYPE_BOOL,
            "usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_NO_INSTANCE_STATE,
        })
    props.append({
        "name": "wave/type",
        "type": TYPE_INT,
        "hint": PROPERTY_HINT_ENUM,
        "hint_string": ",".join(PackedStringArray(SfxrGlobals.WAVE_SHAPES.keys())),
    })
    for property in PROPERTY_MAP:
        props.append({
            "name": property,
            "type": TYPE_FLOAT,
            "hint": PROPERTY_HINT_RANGE,
            "hint_string": PROPERTY_MAP[property]["hint_string"],
        })
    props.append_array([
        {
            "name": "actions/force_rebuild",
            "type": TYPE_BOOL,
            "usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_NO_INSTANCE_STATE,
        },
     ])
    return props


static func object_get(object: Object, property: StringName):
    if property in PROPERTY_MAP:
        return object[PROPERTY_MAP[property]["name"]]
    elif property == "wave/type":
        return object.wave_type


static func object_set(object: Object, property: StringName, value) -> bool:
    var auto_build = Engine.is_editor_hint() and (object is Resource or object.is_inside_tree())
    if property in PROPERTY_MAP:
        object[PROPERTY_MAP[property]["name"]] = value
        if auto_build:
            _schedule_build_sfx(object, true)
        return true
    elif property == "wave/type":
        object.wave_type = value
        if auto_build:
            _schedule_build_sfx(object, true)
        return true
    elif property == "actions/force_rebuild":
        if value and auto_build:
            build_sfx(object, true)
        return true
    elif property == "sfxr_generator":
        if not value:
            value = 0
        if preset_values(object, value) and auto_build:
            build_sfx(object, true)
        return true
    elif property.begins_with("generators/"):
        property = property.replace("generators/", "").to_upper()
        if preset_values(object, SfxrGlobals.PRESETS.get(property, -1)) and auto_build:
            build_sfx(object, true)
        return true
    return false


##################################
# Defaults
##################################


static func object_set_defaults(object: Object):
    object.wave_type = SfxrGlobals.WAVE_SHAPES.SAWTOOTH
    for property in PROPERTY_MAP:
        object[PROPERTY_MAP[property]["name"]] = PROPERTY_MAP[property]["default"]


static func object_property_can_revert(property: StringName):
    return property in PROPERTY_MAP


static func object_property_get_revert(property: StringName):
    return PROPERTY_MAP[property]["default"]


##################################
# Helpers
##################################


static func frnd(rrange) -> float:
    return randf() * rrange


static func rndr(from, to) -> float:
    return randf() * (to - from) + from


static func rnd(rmax) -> float:
    return floor(randf() * (rmax + 1))


##################################
# Presets
##################################


static func _presets_pickup(object: Object):
    object_set_defaults(object)
    object.wave_type = SfxrGlobals.WAVE_SHAPES.SAWTOOTH
    object.p_base_freq = 0.4 + frnd(0.5)
    object.p_env_attack = 0
    object.p_env_sustain = frnd(0.1)
    object.p_env_decay = 0.1 + frnd(0.4)
    object.p_env_punch = 0.3 + frnd(0.3)
    if rnd(1):
        object.p_arp_speed = 0.5 + frnd(0.2)
        object.p_arp_mod = 0.2 + frnd(0.4)


static func _presets_laser(object: Object):
    object_set_defaults(object)
    object.wave_type = rnd(2)
    if object.wave_type == SfxrGlobals.WAVE_SHAPES.SINE and rnd(1):
        object.wave_type = rnd(1)
    if rnd(2) == 0:
        object.p_base_freq = 0.3 + frnd(0.6)
        object.p_freq_limit = frnd(0.1)
        object.p_freq_ramp = -0.35 - frnd(0.3)
    else:
        object.p_base_freq = 0.5 + frnd(0.5)
        object.p_freq_limit = object.p_base_freq - 0.2 - frnd(0.6)
        if object.p_freq_limit < 0.2:
            object.p_freq_limit = 0.2
        object.p_freq_ramp = -0.15 - frnd(0.2)
    if object.wave_type == SfxrGlobals.WAVE_SHAPES.SAWTOOTH:
        object.p_duty = 1
    if rnd(1):
        object.p_duty = frnd(0.5)
        object.p_duty_ramp = frnd(0.2)
    else:
        object.p_duty = 0.4 + frnd(0.5)
        object.p_duty_ramp = -frnd(0.7)
    object.p_env_attack = 0
    object.p_env_sustain = 0.1 + frnd(0.2)
    object.p_env_decay = frnd(0.4)
    if rnd(1):
        object.p_env_punch = frnd(0.3)
    if rnd(2) == 0:
        object.p_pha_offset = frnd(0.2)
        object.p_pha_ramp = -frnd(0.2)
    object.p_hpf_freq = frnd(0.3)


static func _presets_explosion(object: Object):
    object_set_defaults(object)
    object.wave_type = SfxrGlobals.WAVE_SHAPES.NOISE
    if rnd(1):
        object.p_base_freq = pow(0.1 + frnd(0.4), 2)
        object.p_freq_ramp = -0.1 + frnd(0.4)
    else:
        object.p_base_freq = pow(0.2 + frnd(0.7), 2)
        object.p_freq_ramp = -0.2 - frnd(0.2)
    if rnd(4) == 0:
        object.p_freq_ramp = 0
    if rnd(2) == 0:
        object.p_repeat_speed = 0.3 + frnd(0.5)
    object.p_env_attack = 0
    object.p_env_sustain = 0.1 + frnd(0.3)
    object.p_env_decay = frnd(0.5)
    if rnd(1):
        object.p_pha_offset = -0.3 + frnd(0.9)
        object.p_pha_ramp = -frnd(0.3)
    object.p_env_punch = 0.2 + frnd(0.6)
    if rnd(1):
        object.p_vib_strength = frnd(0.7)
        object.p_vib_speed = frnd(0.6)
    if rnd(2) == 0:
        object.p_arp_speed = 0.6 + frnd(0.3)
        object.p_arp_mod = 0.8 - frnd(1.6)


static func _presets_powerup(object: Object):
    object_set_defaults(object)
    if rnd(1):
        object.wave_type = SfxrGlobals.WAVE_SHAPES.SAWTOOTH
        object.p_duty = 1
    else:
        object.p_duty = frnd(0.6)
    object.p_base_freq = 0.2 + frnd(0.3)
    if rnd(1):
        object.p_freq_ramp = 0.1 + frnd(0.4)
        object.p_repeat_speed = 0.4 + frnd(0.4)
    else:
        object.p_freq_ramp = 0.05 + frnd(0.2)
        if rnd(1):
            object.p_vib_strength = frnd(0.7)
            object.p_vib_speed = frnd(0.6)
    object.p_env_attack = 0
    object.p_env_sustain = frnd(0.4)
    object.p_env_decay = 0.1 + frnd(0.4)


static func _presets_hit(object: Object):
    object_set_defaults(object)
    object.wave_type = rnd(2)
    if object.wave_type == SfxrGlobals.WAVE_SHAPES.SINE:
        object.wave_type = SfxrGlobals.WAVE_SHAPES.NOISE
    if object.wave_type == SfxrGlobals.WAVE_SHAPES.SQUARE:
        object.p_duty = frnd(0.6)
    if object.wave_type == SfxrGlobals.WAVE_SHAPES.SAWTOOTH:
        object.p_duty = 1
    object.p_base_freq = 0.2 + frnd(0.6)
    object.p_freq_ramp = -0.3 - frnd(0.4)
    object.p_env_attack = 0
    object.p_env_sustain = frnd(0.1)
    object.p_env_decay = 0.1 + frnd(0.2)
    if rnd(1):
        object.p_hpf_freq = frnd(0.3)


static func _presets_jump(object: Object):
    object_set_defaults(object)
    object.wave_type = SfxrGlobals.WAVE_SHAPES.SQUARE
    object.p_duty = frnd(0.6)
    object.p_base_freq = 0.3 + frnd(0.3)
    object.p_freq_ramp = 0.1 + frnd(0.2)
    object.p_env_attack = 0
    object.p_env_sustain = 0.1 + frnd(0.3)
    object.p_env_decay = 0.1 + frnd(0.2)
    if rnd(1):
        object.p_hpf_freq = frnd(0.3)
    if rnd(1):
        object.p_lpf_freq = 1 - frnd(0.6)


static func _presets_blip(object: Object):
    object_set_defaults(object)
    object.wave_type = rnd(1)
    if object.wave_type == SfxrGlobals.WAVE_SHAPES.SQUARE:
        object.p_duty = frnd(0.6)
    else:
        object.p_duty = 1
    object.p_base_freq = 0.2 + frnd(0.4)
    object.p_env_attack = 0
    object.p_env_sustain = 0.1 + frnd(0.1)
    object.p_env_decay = frnd(0.2)
    object.p_hpf_freq = 0.1


static func _presets_synth(object: Object):
    object_set_defaults(object)
    object.wave_type = rnd(1)
    object.p_base_freq = [0.2723171360931539, 0.19255692561524382, 0.13615778746815113][rnd(2)]
    object.p_env_attack = frnd(0.5) if rnd(4) > 3 else 0
    object.p_env_sustain = frnd(1)
    object.p_env_punch = frnd(1)
    object.p_env_decay = frnd(0.9) + 0.1
    object.p_arp_mod = [0, 0, 0, 0, -0.3162, 0.7454, 0.7454][rnd(6)]
    object.p_arp_speed = frnd(0.5) + 0.4
    object.p_duty = frnd(1)
    object.p_duty_ramp = frnd(1) if rnd(2) == 2 else 0
    object.p_lpf_freq = [1, frnd(1) * frnd(1)][rnd(1)]
    object.p_lpf_ramp = rndr(-1, 1)
    object.p_lpf_resonance = frnd(1)
    object.p_hpf_freq = frnd(1) if rnd(3) == 3 else 0
    object.p_hpf_ramp = frnd(1) if rnd(3) == 3 else 0


static func _presets_tone(object: Object):
    object_set_defaults(object)


static func _presets_click(object: Object):
    if rnd(1):
        _presets_hit(object)
    else:
        _presets_explosion(object)
    if rnd(1):
        object.p_freq_ramp = -0.5 + frnd(1.0)
    if rnd(1):
        object.p_env_sustain = (frnd(0.4) + 0.2) * object.p_env_sustain
        object.p_env_decay = (frnd(0.4) + 0.2) * object.p_env_decay
    if rnd(3) == 0:
        object.p_env_attack = frnd(0.3)
    object.p_base_freq = 1 - frnd(0.25)
    object.p_hpf_freq = 1 - frnd(0.1)


static func _presets_random(object: Object):
    object_set_defaults(object)
    object.wave_type = rnd(3)
    if rnd(1):
        object.p_base_freq = pow(frnd(2) - 1, 3) + 0.5
    else:
        object.p_base_freq = pow(frnd(1), 2)
    object.p_freq_limit = 0
    object.p_freq_ramp = pow(frnd(2) - 1, 5)
    if object.p_base_freq > 0.7 and object.p_freq_ramp > 0.2:
        object.p_freq_ramp = -object.p_freq_ramp
    if object.p_base_freq < 0.2 and object.p_freq_ramp < -0.05:
        object.p_freq_ramp = -object.p_freq_ramp
    object.p_freq_dramp = pow(frnd(2) - 1, 3)
    object.p_duty = frnd(2) - 1
    object.p_duty_ramp = pow(frnd(2) - 1, 3)
    object.p_vib_strength = pow(frnd(2) - 1, 3)
    object.p_vib_speed = rndr(-1, 1)
    object.p_env_attack = pow(rndr(-1, 1), 3)
    object.p_env_sustain = pow(rndr(-1, 1), 2)
    object.p_env_decay = rndr(-1, 1)
    object.p_env_punch = pow(frnd(0.8), 2)
    if object.p_env_attack + object.p_env_sustain + object.p_env_decay < 0.2:
        object.p_env_sustain += 0.2 + frnd(0.3)
        object.p_env_decay += 0.2 + frnd(0.3)
    object.p_lpf_resonance = rndr(-1, 1)
    object.p_lpf_freq = 1 - pow(frnd(1), 3)
    object.p_lpf_ramp = pow(frnd(2) - 1, 3)
    if object.p_lpf_freq < 0.1 and object.p_lpf_ramp < -0.05:
        object.p_lpf_ramp = -object.p_lpf_ramp
    object.p_hpf_freq = pow(frnd(1), 5)
    object.p_hpf_ramp = pow(frnd(2) - 1, 5)
    object.p_pha_offset = pow(frnd(2) - 1, 3)
    object.p_pha_ramp = pow(frnd(2) - 1, 3)
    object.p_repeat_speed = frnd(2) - 1
    object.p_arp_speed = frnd(2) - 1
    object.p_arp_mod = frnd(2) - 1


static func _presets_mutate(object: Object):
    if rnd(1): object.p_base_freq += frnd(0.1) - 0.05
    if rnd(1): object.p_freq_ramp += frnd(0.1) - 0.05
    if rnd(1): object.p_freq_dramp += frnd(0.1) - 0.05
    if rnd(1): object.p_duty += frnd(0.1) - 0.05
    if rnd(1): object.p_duty_ramp += frnd(0.1) - 0.05
    if rnd(1): object.p_vib_strength += frnd(0.1) - 0.05
    if rnd(1): object.p_vib_speed += frnd(0.1) - 0.05
    if rnd(1): object.p_env_attack += frnd(0.1) - 0.05
    if rnd(1): object.p_env_sustain += frnd(0.1) - 0.05
    if rnd(1): object.p_env_decay += frnd(0.1) - 0.05
    if rnd(1): object.p_env_punch += frnd(0.1) - 0.05
    if rnd(1): object.p_lpf_resonance += frnd(0.1) - 0.05
    if rnd(1): object.p_lpf_freq += frnd(0.1) - 0.05
    if rnd(1): object.p_lpf_ramp += frnd(0.1) - 0.05
    if rnd(1): object.p_hpf_freq += frnd(0.1) - 0.05
    if rnd(1): object.p_hpf_ramp += frnd(0.1) - 0.05
    if rnd(1): object.p_pha_offset += frnd(0.1) - 0.05
    if rnd(1): object.p_pha_ramp += frnd(0.1) - 0.05
    if rnd(1): object.p_repeat_speed += frnd(0.1) - 0.05
    if rnd(1): object.p_arp_speed += frnd(0.1) - 0.05
    if rnd(1): object.p_arp_mod += frnd(0.1) - 0.05


static func random_preset(object: Object) -> bool:
    return preset_values(object, (randi() % (len(SfxrGlobals.PRESETS) - 1)) + 1)


static func preset_values(object: Object, preset_key: int) -> bool:
    if preset_key >= 0 and preset_key < len(SfxrGlobals.PRESETS):
        var preset = SfxrGlobals.PRESETS.keys()[preset_key].to_lower()
        match preset:
            "pickup":
                _presets_pickup(object)
                return true
            "laser":
                _presets_laser(object)
                return true
            "explosion":
                _presets_explosion(object)
                return true
            "powerup":
                _presets_powerup(object)
                return true
            "hit":
                _presets_hit(object)
                return true
            "jump":
                _presets_jump(object)
                return true
            "click":
                _presets_click(object)
                return true
            "blip":
                _presets_blip(object)
                return true
            "synth":
                _presets_synth(object)
                return true
            "random":
                _presets_random(object)
                return true
            "tone":
                _presets_tone(object)
                return true
            "mutate":
                _presets_mutate(object)
                return true
    return false


##################################
# Playback
##################################


static func _schedule_build_sfx(object: Object, play_after_build: bool):
    var timer: SceneTreeTimer = Engine.get_main_loop().create_timer(.5)
    object.sfx_timer = timer
    timer.timeout.connect(func(): object._on_sfx_timer_timeout(timer, play_after_build))


static func _on_sfx_timer_timeout(object: Object, timer: SceneTreeTimer, play_after_build: bool):
    if timer == object.sfx_timer:
        build_sfx(object, play_after_build)


static func build_sfx(object: Object, play_after_build: bool = false):
    var sfxg = SfxrGenerator.new()
    sfxg.build_sample(object)
    if play_after_build:
        object.play()
    object.notify_property_list_changed()

tool
extends AudioStreamPlayer
class_name SfxrStreamPlayer


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

# Sfx buffer
var sfx_buffer: PoolVector2Array


##################################
# Inspector Properties
##################################


const PROPERTY_MAP = {
    # Sample params
    "sample_params/sound_vol": {"name": "sound_vol", "hint_string": "0,1,0.000000001", "default": 0.50},
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


func _get_property_list() -> Array:
    var props = []
    props.append({
        "name": "wave/type",
        "type": TYPE_INT,
        "hint": PROPERTY_HINT_ENUM,
        "hint_string": PoolStringArray(SfxrGlobals.WAVE_SHAPES.keys()).join(",").capitalize(),
    })
    for property in PROPERTY_MAP:
        props.append({
            "name": property,
            "type": TYPE_REAL,
            "hint": PROPERTY_HINT_RANGE,
            "hint_string": PROPERTY_MAP[property]["hint_string"],
        })
    var presets = SfxrGlobals.PRESETS.keys()
    presets.pop_front()
    props.append({
        "name": "actions/generator",
        "type": TYPE_INT,
        "hint": PROPERTY_HINT_ENUM,
        "hint_string": "-," + PoolStringArray(presets).join(",").capitalize(),
    })
    props.append({
        "name": "actions/play",
        "type": TYPE_BOOL,
    })
    return props


func _get(property: String):
    if property in PROPERTY_MAP:
        return self[PROPERTY_MAP[property]["name"]]
    elif property == "wave/type":
        return wave_type


func _set(property: String, value) -> bool:
    if property in PROPERTY_MAP:
        self[PROPERTY_MAP[property]["name"]] = value
        return true
    elif property == "wave/type":
        wave_type = value
        return true
    elif property == "actions/generator":
        if not value:
            value = 0
        var presets_method = "_presets_" + str(SfxrGlobals.PRESETS.keys()[value]).to_lower()
        if has_method(presets_method):
            call(presets_method)
            property_list_changed_notify()
            play_sfx(true)
        return true
    elif property == "actions/play":
        if value:
            play_sfx(true)
        return true
    return false


##################################
# Defaults
##################################


func _set_defaults():
    wave_type = SfxrGlobals.WAVE_SHAPES.SAWTOOTH
    for property in PROPERTY_MAP:
        self[PROPERTY_MAP[property]["name"]] = PROPERTY_MAP[property]["default"]


func _init() -> void:
    _set_defaults()


func property_can_revert(property: String):
    return property in PROPERTY_MAP


func property_get_revert(property: String):
    return PROPERTY_MAP[property]["default"]


##################################
# Helpers
##################################


func frnd(rrange) -> float:
    return randf() * rrange


func rndr(from, to) -> float:
    return randf() * (to - from) + from


func rnd(rmax) -> float:
    return floor(randf() * (rmax + 1))


##################################
# Presets
##################################


func _presets_pickup():
    _set_defaults()
    wave_type = SfxrGlobals.WAVE_SHAPES.SAWTOOTH
    p_base_freq = 0.4 + frnd(0.5)
    p_env_attack = 0
    p_env_sustain = frnd(0.1)
    p_env_decay = 0.1 + frnd(0.4)
    p_env_punch = 0.3 + frnd(0.3)
    if rnd(1):
        p_arp_speed = 0.5 + frnd(0.2)
        p_arp_mod = 0.2 + frnd(0.4)


func _presets_laser():
    _set_defaults()
    wave_type = rnd(2)
    if wave_type == SfxrGlobals.WAVE_SHAPES.SINE and rnd(1):
        wave_type = rnd(1)
    if rnd(2) == 0:
        p_base_freq = 0.3 + frnd(0.6)
        p_freq_limit = frnd(0.1)
        p_freq_ramp = -0.35 - frnd(0.3)
    else:
        p_base_freq = 0.5 + frnd(0.5)
        p_freq_limit = p_base_freq - 0.2 - frnd(0.6)
        if p_freq_limit < 0.2:
            p_freq_limit = 0.2
        p_freq_ramp = -0.15 - frnd(0.2)
    if wave_type == SfxrGlobals.WAVE_SHAPES.SAWTOOTH:
        p_duty = 1
    if rnd(1):
        p_duty = frnd(0.5)
        p_duty_ramp = frnd(0.2)
    else:
        p_duty = 0.4 + frnd(0.5)
        p_duty_ramp = -frnd(0.7)
    p_env_attack = 0
    p_env_sustain = 0.1 + frnd(0.2)
    p_env_decay = frnd(0.4)
    if rnd(1):
        p_env_punch = frnd(0.3)
    if rnd(2) == 0:
        p_pha_offset = frnd(0.2)
        p_pha_ramp = -frnd(0.2)
    p_hpf_freq = frnd(0.3)


func _presets_explosion():
    _set_defaults()
    wave_type = SfxrGlobals.WAVE_SHAPES.NOISE
    if rnd(1):
        p_base_freq = pow(0.1 + frnd(0.4), 2)
        p_freq_ramp = -0.1 + frnd(0.4)
    else:
        p_base_freq = pow(0.2 + frnd(0.7), 2)
        p_freq_ramp = -0.2 - frnd(0.2)
    if rnd(4) == 0:
        p_freq_ramp = 0
    if rnd(2) == 0:
        p_repeat_speed = 0.3 + frnd(0.5)
    p_env_attack = 0
    p_env_sustain = 0.1 + frnd(0.3)
    p_env_decay = frnd(0.5)
    if rnd(1):
        p_pha_offset = -0.3 + frnd(0.9)
        p_pha_ramp = -frnd(0.3)
    p_env_punch = 0.2 + frnd(0.6)
    if rnd(1):
        p_vib_strength = frnd(0.7)
        p_vib_speed = frnd(0.6)
    if rnd(2) == 0:
        p_arp_speed = 0.6 + frnd(0.3)
        p_arp_mod = 0.8 - frnd(1.6)


func _presets_powerup():
    _set_defaults()
    if rnd(1):
        wave_type = SfxrGlobals.WAVE_SHAPES.SAWTOOTH
        p_duty = 1
    else:
        p_duty = frnd(0.6)
    p_base_freq = 0.2 + frnd(0.3)
    if rnd(1):
        p_freq_ramp = 0.1 + frnd(0.4)
        p_repeat_speed = 0.4 + frnd(0.4)
    else:
        p_freq_ramp = 0.05 + frnd(0.2)
        if rnd(1):
            p_vib_strength = frnd(0.7)
            p_vib_speed = frnd(0.6)
    p_env_attack = 0
    p_env_sustain = frnd(0.4)
    p_env_decay = 0.1 + frnd(0.4)


func _presets_hit():
    _set_defaults()
    wave_type = rnd(2)
    if wave_type == SfxrGlobals.WAVE_SHAPES.SINE:
        wave_type = SfxrGlobals.WAVE_SHAPES.NOISE
    if wave_type == SfxrGlobals.WAVE_SHAPES.SQUARE:
        p_duty = frnd(0.6)
    if wave_type == SfxrGlobals.WAVE_SHAPES.SAWTOOTH:
        p_duty = 1
    p_base_freq = 0.2 + frnd(0.6)
    p_freq_ramp = -0.3 - frnd(0.4)
    p_env_attack = 0
    p_env_sustain = frnd(0.1)
    p_env_decay = 0.1 + frnd(0.2)
    if rnd(1):
        p_hpf_freq = frnd(0.3)


func _presets_jump():
    _set_defaults()
    wave_type = SfxrGlobals.WAVE_SHAPES.SQUARE
    p_duty = frnd(0.6)
    p_base_freq = 0.3 + frnd(0.3)
    p_freq_ramp = 0.1 + frnd(0.2)
    p_env_attack = 0
    p_env_sustain = 0.1 + frnd(0.3)
    p_env_decay = 0.1 + frnd(0.2)
    if rnd(1):
        p_hpf_freq = frnd(0.3)
    if rnd(1):
        p_lpf_freq = 1 - frnd(0.6)


func _presets_blip():
    _set_defaults()
    wave_type = rnd(1)
    if wave_type == SfxrGlobals.WAVE_SHAPES.SQUARE:
        p_duty = frnd(0.6)
    else:
        p_duty = 1
    p_base_freq = 0.2 + frnd(0.4)
    p_env_attack = 0
    p_env_sustain = 0.1 + frnd(0.1)
    p_env_decay = frnd(0.2)
    p_hpf_freq = 0.1


func _presets_synth():
    _set_defaults()
    wave_type = rnd(1)
    p_base_freq = [0.2723171360931539, 0.19255692561524382, 0.13615778746815113][rnd(2)]
    p_env_attack = frnd(0.5) if rnd(4) > 3 else 0
    p_env_sustain = frnd(1)
    p_env_punch = frnd(1)
    p_env_decay = frnd(0.9) + 0.1
    p_arp_mod = [0, 0, 0, 0, -0.3162, 0.7454, 0.7454][rnd(6)]
    p_arp_speed = frnd(0.5) + 0.4
    p_duty = frnd(1)
    p_duty_ramp = frnd(1) if rnd(2) == 2 else 0
    p_lpf_freq = [1, frnd(1) * frnd(1)][rnd(1)]
    p_lpf_ramp = rndr(-1, 1)
    p_lpf_resonance = frnd(1)
    p_hpf_freq = frnd(1) if rnd(3) == 3 else 0
    p_hpf_ramp = frnd(1) if rnd(3) == 3 else 0


func _presets_tone():
    _set_defaults()
    wave_type = SfxrGlobals.WAVE_SHAPES.SINE
    p_base_freq = 0.35173364 # 440 Hz
    p_env_attack = 0
    p_env_sustain = 0.6641 # 1 sec
    p_env_decay = 0
    p_env_punch = 0


func _presets_click():
    var base = ["explosion", "hit"][rnd(1)]
    call("_presets_" + base)
    if rnd(1):
        p_freq_ramp = -0.5 + frnd(1.0)
    if rnd(1):
        p_env_sustain = (frnd(0.4) + 0.2) * p_env_sustain
        p_env_decay = (frnd(0.4) + 0.2) * p_env_decay
    if rnd(3) == 0:
        p_env_attack = frnd(0.3)
    p_base_freq = 1 - frnd(0.25)
    p_hpf_freq = 1 - frnd(0.1)


func _presets_random():
    _set_defaults()
    wave_type = rnd(3)
    if rnd(1):
        p_base_freq = pow(frnd(2) - 1, 3) + 0.5
    else:
        p_base_freq = pow(frnd(1), 2)
    p_freq_limit = 0
    p_freq_ramp = pow(frnd(2) - 1, 5)
    if p_base_freq > 0.7 and p_freq_ramp > 0.2:
        p_freq_ramp = -p_freq_ramp
    if p_base_freq < 0.2 and p_freq_ramp < -0.05:
        p_freq_ramp = -p_freq_ramp
    p_freq_dramp = pow(frnd(2) - 1, 3)
    p_duty = frnd(2) - 1
    p_duty_ramp = pow(frnd(2) - 1, 3)
    p_vib_strength = pow(frnd(2) - 1, 3)
    p_vib_speed = rndr(-1, 1)
    p_env_attack = pow(rndr(-1, 1), 3)
    p_env_sustain = pow(rndr(-1, 1), 2)
    p_env_decay = rndr(-1, 1)
    p_env_punch = pow(frnd(0.8), 2)
    if p_env_attack + p_env_sustain + p_env_decay < 0.2:
        p_env_sustain += 0.2 + frnd(0.3)
        p_env_decay += 0.2 + frnd(0.3)
    p_lpf_resonance = rndr(-1, 1)
    p_lpf_freq = 1 - pow(frnd(1), 3)
    p_lpf_ramp = pow(frnd(2) - 1, 3)
    if p_lpf_freq < 0.1 and p_lpf_ramp < -0.05:
        p_lpf_ramp = -p_lpf_ramp
    p_hpf_freq = pow(frnd(1), 5)
    p_hpf_ramp = pow(frnd(2) - 1, 5)
    p_pha_offset = pow(frnd(2) - 1, 3)
    p_pha_ramp = pow(frnd(2) - 1, 3)
    p_repeat_speed = frnd(2) - 1
    p_arp_speed = frnd(2) - 1
    p_arp_mod = frnd(2) - 1


func _presets_mutate():
    if rnd(1): p_base_freq += frnd(0.1) - 0.05
    if rnd(1): p_freq_ramp += frnd(0.1) - 0.05
    if rnd(1): p_freq_dramp += frnd(0.1) - 0.05
    if rnd(1): p_duty += frnd(0.1) - 0.05
    if rnd(1): p_duty_ramp += frnd(0.1) - 0.05
    if rnd(1): p_vib_strength += frnd(0.1) - 0.05
    if rnd(1): p_vib_speed += frnd(0.1) - 0.05
    if rnd(1): p_env_attack += frnd(0.1) - 0.05
    if rnd(1): p_env_sustain += frnd(0.1) - 0.05
    if rnd(1): p_env_decay += frnd(0.1) - 0.05
    if rnd(1): p_env_punch += frnd(0.1) - 0.05
    if rnd(1): p_lpf_resonance += frnd(0.1) - 0.05
    if rnd(1): p_lpf_freq += frnd(0.1) - 0.05
    if rnd(1): p_lpf_ramp += frnd(0.1) - 0.05
    if rnd(1): p_hpf_freq += frnd(0.1) - 0.05
    if rnd(1): p_hpf_ramp += frnd(0.1) - 0.05
    if rnd(1): p_pha_offset += frnd(0.1) - 0.05
    if rnd(1): p_pha_ramp += frnd(0.1) - 0.05
    if rnd(1): p_repeat_speed += frnd(0.1) - 0.05
    if rnd(1): p_arp_speed += frnd(0.1) - 0.05
    if rnd(1): p_arp_mod += frnd(0.1) - 0.05


func _random_preset():
    var preset = SfxrGlobals.PRESETS.keys()[(randi() % (len(SfxrGlobals.PRESETS) - 1)) + 1].to_lower()
    call("_presets_" + preset)


##################################
# Playback
##################################


func _clear_buffer():
    sfx_buffer = PoolVector2Array([])


func _build_buffer():
    if not sfx_buffer:
        var gen = SfxrGenerator.new()
        gen.init(self)
        sfx_buffer = gen.get_raw_buffer()
    var duration = len(sfx_buffer) / sample_rate
    stream = AudioStreamGenerator.new()
    stream.mix_rate = sample_rate
    stream.buffer_length = duration
    var pb: AudioStreamGeneratorPlayback = get_stream_playback()
    pb.push_buffer(sfx_buffer)


func play_sfx(clear_buffer=false):
    if clear_buffer:
        _clear_buffer()
    _build_buffer()
    if not playing:
        play()

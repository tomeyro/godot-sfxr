extends Object
class_name SfxrGenerator


var params

var wave_shape: int

var repeat_time: float
var elapsed_since_repeat: float

var arpeggio_time: float
var arpeggio_multiplier: float

var period: float
var period_mult: float
var period_mult_slide: float
var period_max: float

var enable_frequency_cutoff: bool = false

var duty_cycle: float
var duty_cycle_slide: float

var fltw: float
var fltw_d: float
var fltdmp: float
var flthp: float
var flthp_d: float
var enable_low_pass_filter: bool

var vibrato_speed: float
var vibrato_amplitude: float

var envelope_length: Array
var envelope_punch: float

var flanger_offset: float
var flanger_offset_slide: float

var gain: float
var sample_rate: float


func init(_params) -> void:
    params = _params
    init_for_repeat()

    # Wave shape
    wave_shape = params.wave_type

    # Filter
    fltw = pow(params.p_lpf_freq, 3) * 0.1
    enable_low_pass_filter = params.p_lpf_freq != 1
    fltw_d = 1 + params.p_lpf_ramp * 0.0001
    fltdmp = 5 / (1 + pow(params.p_lpf_resonance, 2) * 20) * (0.01 + fltw)
    if fltdmp > 0.8:
        fltdmp = 0.8
    flthp = pow(params.p_hpf_freq, 2) * 0.1
    flthp_d = 1 + params.p_hpf_ramp * 0.0003

    # Vibrato
    vibrato_speed = pow(params.p_vib_speed, 2) * 0.01
    vibrato_amplitude = params.p_vib_strength * 0.5

    # Envelope
    envelope_length = [
        floor(pow(params.p_env_attack, 2) * 100000),
        floor(pow(params.p_env_sustain, 2) * 100000),
        floor(pow(params.p_env_decay, 2) * 100000),
    ]
    envelope_punch = params.p_env_punch

    # Flanger
    flanger_offset = pow(params.p_pha_offset, 2) * 1020
    if params.p_pha_offset < 0:
        flanger_offset = -flanger_offset
    flanger_offset_slide = pow(params.p_pha_ramp, 2) * 1
    if params.p_pha_ramp < 0:
        flanger_offset_slide = -flanger_offset_slide

    # Repeat
    repeat_time = floor(pow(1 - params.p_repeat_speed, 2) * 20000 + 32)
    if params.p_repeat_speed == 0:
        repeat_time = 0

    gain = exp(params.sound_vol) - 1
    sample_rate = params.sample_rate


func init_for_repeat() -> void:
    elapsed_since_repeat = 0

    period = 100 / (params.p_base_freq * params.p_base_freq + 0.001)
    period_max = 100 / (params.p_freq_limit * params.p_freq_limit + 0.001)
    enable_frequency_cutoff = params.p_freq_limit > 0
    period_mult = 1 - pow(params.p_freq_ramp, 3) * 0.01
    period_mult_slide = -pow(params.p_freq_dramp, 3) * 0.000001

    duty_cycle = 0.5 - params.p_duty * 0.5
    duty_cycle_slide = -params.p_duty_ramp * 0.00005

    if params.p_arp_mod >= 0:
        arpeggio_multiplier = 1 - pow(params.p_arp_mod, 2) * 0.9
    else:
        arpeggio_multiplier = 1 + pow(params.p_arp_mod, 2) * 10
    arpeggio_time = floor(pow(1 - params.p_arp_speed, 2) * 20000 + 32)
    if params.p_arp_speed == 1:
        arpeggio_time = 0


func get_raw_buffer() -> PoolVector2Array:
    var fltp = 0;
    var fltdp = 0;
    var fltphp = 0;

    var noise_buffer = []
    for i in 32:
        noise_buffer.append(randf() * 2 - 1)

    var envelope_stage = 0
    var envelope_elapsed = 0

    var vibrato_phase = 0;

    var phase = 0
    var ipp = 0
    var flanger_buffer = []
    for i in 1024:
        flanger_buffer.append(0)

    var buffer: PoolVector2Array

    var sample_sum = 0
    var num_summed = 0
    var summands = floor(44100 / sample_rate)

    var t = 0
    while t < INF:
        t += 1

        # Repeats
        elapsed_since_repeat += 1
        if repeat_time != 0 and elapsed_since_repeat >= repeat_time:
            init_for_repeat()

        # Arpeggio (single)
        if arpeggio_time != 0 and t >= arpeggio_time:
            arpeggio_time = 0
            period *= arpeggio_multiplier

        # Frequency slide, and frequency slide slide!
        period_mult += period_mult_slide
        period *= period_mult
        if period > period_max:
            period = period_max
            if enable_frequency_cutoff:
                break

        # Vibrato
        var rfperiod = period
        if vibrato_amplitude > 0:
            vibrato_phase += vibrato_speed
            rfperiod = period * (1 + sin(vibrato_phase) * vibrato_amplitude)
        var iperiod = max(floor(rfperiod), SfxrGlobals.OVERSAMPLING)

        # Square wave duty cycle
        duty_cycle = clamp(duty_cycle + duty_cycle_slide, 0, 0.5)

        # Volume envelope
        envelope_elapsed += 1
        if envelope_elapsed > envelope_length[envelope_stage]:
            envelope_elapsed = 0
            envelope_stage += 1
            if envelope_stage > 2:
                break
        if not envelope_length[envelope_stage]:
            continue
        var env_vol: float
        var envf = envelope_elapsed / envelope_length[envelope_stage]
        if envelope_stage == 0: # Attack
            env_vol = envf
        elif envelope_stage == 1: # Sustain
            env_vol = 1 + (1 - envf) * 2 * envelope_punch
        else: # Decay
            env_vol = 1 - envf

        # Flanger step
        flanger_offset += flanger_offset_slide
        var iphase = min(abs(floor(flanger_offset)), 1023)

        if flthp_d != 0:
            flthp = clamp(flthp * flthp_d, 0.00001, 0.1)

        # 8x oversampling
        var sample = 0
        for si in SfxrGlobals.OVERSAMPLING - 1:
            var sub_sample = 0
            phase += 1
            if phase >= iperiod:
                phase = fmod(phase, iperiod)
                if wave_shape == SfxrGlobals.WAVE_SHAPES.NOISE:
                    for i in 32:
                        noise_buffer[i] = randf() * 2 - 1

            # Base waveform
            var fp = phase / iperiod
            if wave_shape == SfxrGlobals.WAVE_SHAPES.SQUARE:
                if fp < duty_cycle:
                    sub_sample = 0.5
                else:
                    sub_sample = -0.5
            elif wave_shape == SfxrGlobals.WAVE_SHAPES.SAWTOOTH:
                if fp < duty_cycle:
                    sub_sample = -1 + 2 * fp / duty_cycle
                else:
                    sub_sample = 1 - 2 * (fp - duty_cycle) / (1 - duty_cycle)
            elif wave_shape == SfxrGlobals.WAVE_SHAPES.SINE:
                sub_sample = sin(fp * 2 * PI)
            elif wave_shape == SfxrGlobals.WAVE_SHAPES.NOISE:
                sub_sample = noise_buffer[floor(phase * 32 / iperiod)]
            else:
                print("ERROR: Bad wave type: ", wave_shape)
                sub_sample = 0

            # Low-pass filter
            var pp = fltp
            fltw = clamp(fltw * fltw_d, 0, 0.1)
            if enable_low_pass_filter:
                fltdp += (sub_sample - fltp) * fltw
                fltdp -= fltdp * fltdmp
            else:
                fltp = sub_sample
                fltdp = 0
            fltp += fltdp

            # High-pass filter
            fltphp += fltp - pp
            fltphp -= fltphp * flthp
            sub_sample = fltphp

            # Flanger
            flanger_buffer[ipp & 1023] = sub_sample
            sub_sample += flanger_buffer[int(floor(ipp - iphase + 1024)) & 1023]

            ipp = int(floor((ipp + 1))) & 1023

            # Final accumulation and envelope application
            sample += sub_sample * env_vol

        # Accumulate samples appropriately for sample rate
        sample_sum += sample
        num_summed += 1
        if num_summed >= summands:
            num_summed = 0
            sample = sample_sum / summands
            sample_sum = 0
        else:
            continue

        sample = sample / SfxrGlobals.OVERSAMPLING * SfxrGlobals.MASTER_VOLUME
        sample *= gain

        buffer.append(Vector2(sample, sample))
    return buffer

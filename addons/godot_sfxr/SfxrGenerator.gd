extends RefCounted
class_name SfxrGenerator


var params

var wave_shape: int

var repeat_time: float
var elapsed_since_repeat: float

var arpeggio_time: int
var arpeggio_multiplier: float

var period: float
var period_mult: float
var period_mult_slide: float
var period_max: float

var enable_frequency_cutoff: bool

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


func init_params(stream_player) -> void:
    params = stream_player

    prepare_values()

    # Wave shape
    wave_shape = params.wave_type

    # Filter
    fltw = pow(params.p_lpf_freq, 3.0) * 0.1
    enable_low_pass_filter = params.p_lpf_freq != 1.0
    fltw_d = 1.0 + params.p_lpf_ramp * 0.0001
    fltdmp = 5.0 / (1.0 + pow(params.p_lpf_resonance, 2.0) * 20.0) * (0.01 + fltw)
    if (fltdmp > 0.8):
        fltdmp = 0.8
    flthp = pow(params.p_hpf_freq, 2.0) * 0.1
    flthp_d = 1 + params.p_hpf_ramp * 0.0003

    # Vibrato
    vibrato_speed = pow(params.p_vib_speed, 2.0) * 0.01
    vibrato_amplitude = params.p_vib_strength * 0.5

    # Envelope
    envelope_length = [
        floor(params.p_env_attack * params.p_env_attack * 100000.0),
        floor(params.p_env_sustain * params.p_env_sustain * 100000.0),
        floor(params.p_env_decay * params.p_env_decay * 100000.0),
    ]
    envelope_punch = params.p_env_punch

    # Flanger
    flanger_offset = pow(params.p_pha_offset, 2.0) * 1020.0
    if (params.p_pha_offset < 0.0):
        flanger_offset = -flanger_offset
    flanger_offset_slide = pow(params.p_pha_ramp, 2.0) * 1.0
    if (params.p_pha_ramp < 0.0):
        flanger_offset_slide = -flanger_offset_slide

    # Repeat
    repeat_time = floor(pow(1 - params.p_repeat_speed, 2.0) * 20000.0 + 32.0)
    if (params.p_repeat_speed == 0.0):
        repeat_time = 0.0

    gain = exp(params.sound_vol) - 1.0
    sample_rate = params.sample_rate


func prepare_values() -> void:
    elapsed_since_repeat = 0.0

    period = 100.0 / (params.p_base_freq * params.p_base_freq + 0.001)
    period_max = 100.0 / (params.p_freq_limit * params.p_freq_limit + 0.001)
    enable_frequency_cutoff = params.p_freq_limit > 0.0
    period_mult = 1.0 - pow(params.p_freq_ramp, 3.0) * 0.01
    period_mult_slide = -pow(params.p_freq_dramp, 3.0) * 0.000001

    duty_cycle = 0.5 - params.p_duty * 0.5
    duty_cycle_slide = -params.p_duty_ramp * 0.00005

    if (params.p_arp_mod >= 0.0):
        arpeggio_multiplier = 1.0 - pow(params.p_arp_mod, 2.0) * 0.9
    else:
        arpeggio_multiplier = 1.0 + pow(params.p_arp_mod, 2.0) * 10.0
    arpeggio_time = floor(pow(1.0 - params.p_arp_speed, 2.0) * 20000.0 + 32.0)
    if (params.p_arp_speed == 1.0):
        arpeggio_time = 0


func get_raw_buffer() -> Array:
    randomize()

    var fltp: float = 0.0
    var fltdp: float = 0.0
    var fltphp: float = 0.0

    var noise_buffer_length: int = 32
    var noise_buffer: Array = []
    for i in noise_buffer_length:
        noise_buffer.append(randf() * 2.0 - 1.0)

    var envelope_stage: int = 0
    var envelope_elapsed: float = 0.0

    var vibrato_phase: float = 0.0

    var phase: int = 0
    var ipp: int = 0
    var flanger_buffer_length: int = 1024
    var flanger_buffer: Array = []
    for i in flanger_buffer_length:
        flanger_buffer.append(0.0)

    var _buffer: Array = []

    var sample_sum: float = 0.0
    var num_summed: float = 0.0
    var summands: int = floor(44100.0 / sample_rate)

    var t: float = -1.0
    while t < INF:
        t += 1

        # Repeats
        elapsed_since_repeat += 1.0
        if (repeat_time != 0.0 and elapsed_since_repeat >= repeat_time):
            prepare_values()

        # Arpeggio (single)
        if (arpeggio_time != 0 and t >= arpeggio_time):
            arpeggio_time = 0
            period *= arpeggio_multiplier

        # Frequency slide, and frequency slide slide!
        period_mult += period_mult_slide
        period *= period_mult
        if (period > period_max):
            period = period_max
            if (enable_frequency_cutoff):
                break

        # Vibrato
        var rfperiod: float = period
        if (vibrato_amplitude > 0.0):
            vibrato_phase += vibrato_speed
            rfperiod = period * (1.0 + sin(vibrato_phase) * vibrato_amplitude)
        var iperiod: int = floor(rfperiod)
        if (iperiod < SfxrGlobals.OVERSAMPLING):
            iperiod = SfxrGlobals.OVERSAMPLING

        # Square wave duty cycle
        duty_cycle = duty_cycle + duty_cycle_slide
        if (duty_cycle > 0.5):
            duty_cycle = 0.5
        elif (duty_cycle < 0.0):
            duty_cycle = 0.0

        # Volume envelope
        envelope_elapsed += 1.0
        if (envelope_elapsed > envelope_length[envelope_stage]):
            envelope_elapsed = 0.0
            envelope_stage += 1.0
            if (envelope_stage > 2.0):
                break

        if (envelope_length[envelope_stage] == 0):
            continue

        var env_vol: float = 0.0
        var envf: float = envelope_elapsed / envelope_length[envelope_stage]
        if (envelope_stage == 0.0): # Attack
            env_vol = envf
        elif (envelope_stage == 1.0): # Sustain
            env_vol = 1.0 + (1.0 - envf) * 2.0 * envelope_punch
        else: # Decay
            env_vol = 1.0 - envf

        # Flanger step
        flanger_offset += flanger_offset_slide
        var iphase: int = abs(floor(flanger_offset))
        if (iphase > 1023):
            iphase = 1023

        if (flthp_d != 0.0):
            flthp = flthp * flthp_d
            if (flthp > 0.1):
                flthp = 0.1
            elif (flthp < 0.00001):
                flthp = 0.00001

        # 8x Oversampling
        var sample: float = 0.0
        for i in SfxrGlobals.OVERSAMPLING:
            var sub_sample: float = 0.0
            phase += 1
            if (phase >= iperiod):
                phase %= iperiod
                if (wave_shape == SfxrGlobals.WAVE_SHAPES.NOISE):
                    for j in noise_buffer_length:
                        noise_buffer[i] = randf() * 2.0 - 1.0

            # Base waveform
            var fp: float = float(phase) / float(iperiod)
            if (wave_shape == SfxrGlobals.WAVE_SHAPES.SQUARE):
                if (fp < duty_cycle):
                    sub_sample = 0.5
                else:
                    sub_sample = -0.5
            elif (wave_shape == SfxrGlobals.WAVE_SHAPES.SAWTOOTH):
                if (fp < duty_cycle):
                    sub_sample = -1.0 + 2.0 * fp / duty_cycle
                else:
                    sub_sample = 1.0 - 2.0 * (fp - duty_cycle) / (1 - duty_cycle)
            elif (wave_shape == SfxrGlobals.WAVE_SHAPES.SINE):
                sub_sample = sin(fp * 2.0 * PI)
            elif (wave_shape == SfxrGlobals.WAVE_SHAPES.NOISE):
                sub_sample = noise_buffer[int(floor(phase * 32.0 / iperiod))]
            else:
                printerr("ERROR: Bad wave type: " + str(wave_shape))
                sub_sample = 0

            # Low-pass filter
            var pp: float = fltp
            fltw *= fltw_d
            if (fltw > 0.1):
                fltw = 0.1
            elif (fltw < 0.0):
                fltw = 0.0
            if (enable_low_pass_filter):
                fltdp += (sub_sample - fltp) * fltw
                fltdp -= fltdp * fltdmp
            else:
                fltp = sub_sample
                fltdp = 0.0
            fltp += fltdp

            # High-pass filter
            fltphp += fltp - pp
            fltphp -= fltphp * flthp
            sub_sample = fltphp

            # Flanger
            flanger_buffer[ipp & 1023] = sub_sample
            sub_sample += flanger_buffer[(ipp - iphase + 1024) & 1023]

            ipp = (ipp + 1) & 1023

            # Final accumulation and envelope application
            sample += sub_sample * env_vol

        # Accumulate samples appropriately for sample rate
        sample_sum += sample
        num_summed += 1.0
        if (num_summed >= summands):
            num_summed = 0.0
            sample = sample_sum / summands
            sample_sum = 0.0
        else:
            continue

        sample = sample / SfxrGlobals.OVERSAMPLING * SfxrGlobals.MASTER_VOLUME
        sample *= gain

        sample = floor((sample + 1) * 128)
        if (sample > 255):
            sample = 255;
        elif (sample < 0):
            sample = 0
        sample += 128
        if sample > 255:
            sample -= 255

        _buffer.append(sample)

    return _buffer


func build_sample(stream_player):
    init_params(stream_player)
    var sample: AudioStreamWAV = stream_player if stream_player is Resource else stream_player.stream
    if (not sample):
        stream_player.stream = AudioStreamWAV.new()
        sample = stream_player.stream
    sample.mix_rate = sample_rate
    sample.data = PackedByteArray(get_raw_buffer())
    return sample

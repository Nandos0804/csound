; Csound Oscillator Example for PS Vita
; Demonstrates basic oscillator synthesis

<CsoundSynthesizer>
<CsOptions>
-odac
</CsOptions>

<CsInstrument>
sr = 44100
kr = 4410
ksmps = 10
nchnls = 1
0dbfs = 1

; Simple sine wave oscillator
instr 1
    kamp = 0.1                    ; Amplitude
    kfreq = 440                   ; Frequency in Hz
    asig oscil kamp, kfreq        ; Generate sine wave
    out asig
endin

; FM Synthesis Example
instr 2
    kamp = 0.1
    kcar = 200                    ; Carrier frequency
    kmod = 5                      ; Modulator oscillator
    kindex = 100                  ; Modulation index
    
    kmod_osc oscil kindex, kmod   ; Generate modulation signal
    asig oscil kamp, kcar + kmod_osc
    out asig
endin

; Simple melody - plays a scale
instr 3
    kamp = 0.1
    kfreq = p4                    ; Frequency passed as parameter
    asig oscil kamp, kfreq
    out asig * linseg(1, p3*0.9, 1, p3*0.1, 0)
endin

</CsInstrument>

<CsScore>
; Play 440 Hz sine wave for 5 seconds
i 1 0 5

; Play FM synthesis for 3 seconds starting at time 6
i 2 6 3

; Play a simple C major scale
i 3 10 1 262    ; C
i 3 11 1 294    ; D
i 3 12 1 330    ; E
i 3 13 1 349    ; F
i 3 14 1 392    ; G
i 3 15 1 440    ; A
i 3 16 1 494    ; B
i 3 17 1 523    ; C

e
</CsScore>

</CsoundSynthesizer>

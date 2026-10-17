"""Throwaway generator for ArrowSpark's original UI sounds (stdlib only).

Usage: python -I generate_ui_sounds.py <output_dir>
Writes focus.wav, press.wav and tab.wav: short, soft, mono 16-bit 44.1 kHz.
"""
import math
import struct
import sys
import wave
from pathlib import Path

RATE = 44100


def tone(duration, freq_start, freq_end, amplitude, decay, attack=0.004):
    samples = []
    phase = 0.0
    count = int(duration * RATE)
    for i in range(count):
        t = i / RATE
        freq = freq_start + (freq_end - freq_start) * (i / count)
        phase += 2 * math.pi * freq / RATE
        envelope = min(1.0, t / attack) * math.exp(-t * decay)
        # A touch of the octave gives a rounder, less synthetic click.
        value = math.sin(phase) + 0.25 * math.sin(2 * phase)
        samples.append(amplitude * envelope * value / 1.25)
    fade = int(0.003 * RATE)
    for i in range(fade):
        samples[-1 - i] *= i / fade
    return samples


def write(path, samples):
    with wave.open(str(path), "wb") as out:
        out.setnchannels(1)
        out.setsampwidth(2)
        out.setframerate(RATE)
        out.writeframes(b"".join(struct.pack("<h", int(max(-1.0, min(1.0, s)) * 32767)) for s in samples))


def main():
    out_dir = Path(sys.argv[1])
    out_dir.mkdir(parents=True, exist_ok=True)
    write(out_dir / "focus.wav", tone(0.035, 1760, 1760, 0.18, 120))
    press = tone(0.040, 660, 660, 0.30, 70) + tone(0.060, 990, 990, 0.26, 60)
    write(out_dir / "press.wav", press)
    write(out_dir / "tab.wav", tone(0.045, 1320, 1180, 0.20, 90))
    print("WROTE", sorted(p.name for p in out_dir.glob("*.wav")))


if __name__ == "__main__":
    main()

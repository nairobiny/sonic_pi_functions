# sonic_pi_functions
A collection of useful functions for Sonic Pi

## s(a, b)
Shortcut to the inbuilt spread() function.
I saw someone else using this and it seemed like a decent idea

## auto_sample(sample_name, opts)
Attempt to stretch a sample so that it matches your existing pattern.
This has its limitations. It attempts to work out the nearest power of 2 and then stretch the sample to fit that number of beats.
Most of the time this is what you want. If it's not, you can use the `override_factor:` option to stretch it.

### Options
- `volume:` set the volume for the sample playback (minimum: 0.0, maximum: 1.0, default: 1.0)
- `override_factor:` override the calculated beat_stretch. For example, if you want it to play half as fast, use an `override_factor:` of 0.5 (default: 1.0)

### Example usage
`auto_sample :loop_amen_full, volume: 0.4`

## arpeggiator(chord_root, opts)
A very basic arpeggiator that can still produce some quite acceptable results. The playback synth and synth_defaults can be modified using the `set_arpeggiator` and `set_arpeggiator_defaults` functions.

### Options
- `chord_type:` one of the inbuilt chord types (default: `:major`)
- `steps:` the number of steps in the arpeggio (default: 8)
- `speed:` the speed of each step (default: 0.125)
- `volume:` the playback volume for the arpeggio (default: 0.3)
- `pattern:` the pattern to use for playback. This can be one of `:ascending`, `:descending`, `:up_and_down` or `:random` (default: `:ascending`)

### Example usage
`arpeggiator :d3, chord_type: 'm7+9', steps: 12, speed: (1.0 / 6.0), pattern: [:ascending, :descending].choose, volume: 0.2`

## riffer(root_note, opts)
A very basic riff generator. It produces a set of notes and a replay pattern that can be replayed using the `play_riffer_pattern` function. This way you can create a random pattern and then reuse it in your music.

### Options
- `key:` one of the inbuilt scales (default: `:major`)
- `length:` the total length of your pattern, including both notes and rests (default: 16)
- `octaves:` the number of octaves from which to select notes (default: 1)
- `root_count:` how many of the root note to include in your pattern (default: 2)
- `pattern_notes:` how many notes to include in your pattern. The difference between this and `length:` will be rests.
- `speed:` the speed of each pattern step (default: 0.25)

### Example usage
`note_pattern, timing_pattern = riffer(:C3, key: :minor, length: 16, octaves: 2, root_count: 5, pattern_notes: 9, speed: 0.25)`

## play_riffer_pattern(note_pattern, timing_pattern)
Play back a note_pattern created by the `riffer` function with the associated timing_pattern. To be honest, the timing_pattern is a bit janky at the moment, as every step is the same. Syncopation is created by using rests. The playback synth and synth_defaults can be modified using the `set_riffer` and `set_riffer_defaults` functions. 

### Example usage
`play_riffer_pattern(note_pattern, timing_pattern)`

# set_arpeggiator(synth)
# set_riffer(synth)
Set the synth to be used for replaying arpeggiator and riffer patterns respectively. The default synth for each is `:beep`.

### Example usage
`set_arpeggiator :supersaw`

# set_arpeggiator_defaults(opts)
# set_riffer_defaults(opts)
Set the synth_defaults to be used for the selected synth for arpeggiator and riffer playback respectively. These are unset prior to first use.

### Example usage
`set_arpeggiator_defaults pan: 0.3, res: 0.6, cutoff: 85, release: 0.1`

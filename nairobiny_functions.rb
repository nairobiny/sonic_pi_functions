# Simple control function
# Put flag(myvar) in a live loop then toggle myvar to turn it on or off
define :flag do |flag|
  if flag == 0 then
    stop
  end
end

# shortcut to the bools() function
define :b do | x |
  b(x)
end

# shortcut to the spread() function
define :s do |a, b|
  spread(a, b)
end

# Automatically play samples at something approximating to the right speed
# volume can be used to make the sample quieter if needed
# override_factor scales the sample in case it's too fast/slow.
# An override_factor of 0.5 will play the sample at half-speed, for example.
# 
# Example call
# 
# auto_sample(:loop_amen_full, volume: 0.8, override_factor: 2.0)
define :auto_sample do |sample_name, opts = {}|
  # Default options
  defaults = {
    volume: 1.0,
    override_factor: 1.0
  }
  opts = defaults.merge(opts)

  # Parameter Validation
  if opts[:volume] < 0 || opts[:volume] > 1
    puts "Warning: Volume level should be between 0 and 1. Clamping value."
    opts[:volume] = [[opts[:volume], 0].max, 1].min
  end

  if opts[:override_factor] == 0
    puts "Error: Override factor cannot be zero."
    return
  end

  # Calculate beat_stretch using log2 and sample_duration
  duration_log = Math.log2(sample_duration(sample_name)).round
  beat_stretch = (2 ** duration_log) / opts[:override_factor]
  
  # Play sample with the calculated beat_stretch and volume
  sample sample_name, beat_stretch: beat_stretch, amp: opts[:volume]
  sleep beat_stretch

  # Optional Logging
  puts "Playing sample #{sample_name} with beat_stretch #{beat_stretch} at volume #{opts[:volume]}"
end



define :set_arpeggiator do |synth_type|
  set :arpeggiator_synth, synth_type
end

define :set_riffer do |synth_type|
  set :riffer_synth, synth_type
end

# Function to set synth defaults
define :set_arpeggiator_defaults do |defaults|
  set :arpeggiator_defaults, defaults
end

define :set_riffer_defaults do |defaults|
  set :riffer_defaults, defaults
end


# Basic arpeggiator
# Accepts chord root, chord type, number of steps, speed, volume and a pattern.
define :arpeggiator do |chord_root, opts = {}|
  defaults = {
    chord_type: :major,
    steps: 8,
    speed: 0.125,
    volume: 0.3,
    pattern: :ascending
  }
  opts = defaults.merge(opts)

  use_synth get(:arpeggiator_synth) || :beep

  sd = get(:arpeggiator_defaults) || {}
  sd.each do | k, v |
    puts "Setting key #{k} to #{v}"
    use_merged_synth_defaults k => v
  end
  
  # Define the chord and calculate the number of required octaves
  notes = chord(chord_root, opts[:chord_type])
  num_notes = notes.length
  num_octaves = (opts[:steps].to_f / num_notes).ceil
  
  # Extend the chord to cover the required octaves
  extended_chord = (0...num_octaves).flat_map { |octave| notes.map { |n| n + (octave * 12) } }.sort
  
  # Generate the note pattern based on the chosen arpeggio pattern
  sequence = case opts[:pattern]
  when :ascending
    (0...extended_chord.size).to_a
  when :descending
    (0...extended_chord.size).to_a.reverse
  when :random
    (0...extended_chord.size).to_a.shuffle
  when :up_and_down
    mid_point = extended_chord.size / 2
    ascending = (0..mid_point).to_a
    ascending + ascending.reverse.drop(1)
  when Array
    opts[:pattern]
  else
    (0...extended_chord.size).to_a
  end.cycle
  
  # Play the arpeggio pattern
  opts[:steps].times do
    with_fx :reverb, room: 0.7, damp: 0.7 do
      play extended_chord[sequence.next], amp: opts[:volume]
      sleep opts[:speed]
    end
  end
end

# Basic riffer function to create simple riffs
# Example call parameters to generate and store the pattern:
# note_pattern, timing_pattern = riffer(:C4, key: :muhayyer, length: 16, octaves: 2, root_count: 3, pattern_notes: 10, speed: 0.25)
# Then call play_riffer_pattern(note_pattern, timing_pattern)
define :riffer do |root_note, opts = {}|
  # Default options
  defaults = {
    key: :major,
    length: 16,
    octaves: 1,
    root_count: 2,
    pattern_notes: 8,
    speed: 0.25
  }
  opts = defaults.merge(opts)
  
  # Ensure different patterns each call by using a dynamic seed
  use_random_seed Time.now.to_i
  
  # Generate scale and initial pattern
  scale_notes = scale(root_note, opts[:key], num_octaves: opts[:octaves])
  notes_only_pattern = scale_notes.pick(opts[:pattern_notes])
  rests_pattern = [:rest] * (opts[:length] - opts[:pattern_notes])
  initial_pattern = (notes_only_pattern + rests_pattern).shuffle  # Combine and shuffle
  
  # Ensure root note appears correct number of times (add root note in random positions)
  pattern = initial_pattern.to_a
  root_indices = (0...opts[:length]).to_a.pick(opts[:root_count])
  root_indices.each { |i| pattern[i] = root_note }
  
  # Convert pattern back to a ring and create timing pattern
  note_pattern = pattern.ring
  timing_pattern = (ring opts[:speed]) * opts[:length]
  
  # Return both the pattern of notes and timings
  return note_pattern, timing_pattern
end

# Play the riffer pattern
define :play_riffer_pattern do | note_pattern, timing_pattern |
  puts "play_riffer_pattern() received #{note_pattern} and #{timing_pattern}"
  use_synth get(:riffer_synth) || :beep
  
  sd = get(:riffer_defaults) || {}
  sd.each do | k, v |
    puts "Setting key #{k} to #{v}"
    use_merged_synth_defaults k => v
  end
  
  timing_pattern.size.times do
    note = note_pattern.tick
    timing = timing_pattern.look
    if note != :rest
      play note
    end
    sleep timing
  end
end

# MidiCleaner

MidiCleaner processes MIDI files to remove extraneous data. It currently has three functions:

- set MIDI channel
- remove Program Change events
- delete CC events where all the values are 0

Each one is optional when running the command line.

## Usage

```bash
midi_cleaner \
  --remove-program-changes \
  --remove-unchanging-cc-val0 \
  --set-midi-channel=0 \
  --output=clean \
  1.mid 2.mid path/to/3.mid \
  dir/of/midi/files another/dir
```

The above command will read the given MIDI files, and any files in the given folders, process them with all options, and write the processed files to a folder named `clean`.

## A note about MIDI channels

Humans refer to MIDI channels 1-16.
Computers refer to MIDI channels 0-15, and MidiCleaner currently uses this convention.

## TODO

* Replace StatsServer with Telemetry.Metrics
* Update typespecs (?) in @callback definitions
* Review expected vs actual convention in ExUnit
* Report results
* Report progress
* Handle failures
* Make CLI use channels 1-15?

# Cosmos
Cosmos is tetris like game (落ちゲー).

It is inspired by Chaos which is a game for Windows.


## Runtime requirements

* SDL 2.0
* SDL_image 2.0
* SDL_ttf 2.0

## Build requirements
* DMD
* Derelict

### How to compile

* Locate Derelict sources to /path/to/cosmosdir/derelict
* Locate Derelict library files (.a) to /path/to/cosmosdir/lib
* Run make:

```
$ make
```

## How to play

```
./cosmos
```

* Space: Rotate
* Right, Left: Move piece
* Down: Speed up
* p: Pause
* r: Resume
* q: Quit

## Rules

* Three (horizontal, vertical and aslant) consective same faces will be vanished.
* Each face can be lotated as the following sequence:
  - Smile (Yellow)
  - Smile-Angry (Yellow on the left side, and red on the right side)
  - Angry (Red)
  - Angry-Smile (Red on the left side, and yellow on the right side)

## Notice

* Poor documentation
* No sound
* Quit when game is over
* I cannot find a link to the original Chaos.
  Please let me know if you know the link to Chaos.

# Cosmos
Cosmos is tetris like game (落ちゲー).

It is inspired by Chaos which is a game for Windows.

## Runtime requirements

* SDL 2.0
* SDL_image 2.0

## Build requirements
* DMD
* [DUB](https://github.com/rejectedsoftware/dub)
* [Derelict](https://github.com/aldacron/Derelict3) (DUB will automatically install it)

### How to compile

* run `dub build` in the source directory.

## Rules

* Three (horizontal, vertical and aslant) consective same faces will be vanished.
* Each face can be lotated as the following sequence:
  - Smile (Yellow)
  - Smile-Angry (Yellow on the left side, and red on the right side)
  - Angry (Red)
  - Angry-Smile (Red on the left side, and yellow on the right side)

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

## Notice

* Poor documentation
* No sound
* Quit when game is over
* Chaotic source codes
* I cannot find a link to the original Chaos.
  Please let me know if you know the link to Chaos.

# Miners4k in D

I ported Notch's Miners4k from Java to D during a few lunch breaks in summer 2017.  I finished the "game" parts, but haven't attempted to port the UI.

## TODO

- Finish UI port
- Fix byte order issue in the sprites
- Make the code more idiomatic D instead of a direct port
- Get this working on Windows and Linux.  It should work already, but I haven't tested it.

## Note

- The original java code is attached for reference
- The resulting D binary is greater than 4k in size.  ;)

## How to build

First, install a [D compiler](https://dlang.org).
Then build with `dub`
```
# dub build -b release --compiler=ldc2
```

## How to play

Left click and drag to create dirt.  Right click and drag to remove dirt.  Try to pile the gold at the top of the level.
sdl2-ffi
========

A LuaJIT interface to SDL2

# Installation #

First, make sure SDL2 is installed on your system. This package only requires the binary shared libraries (.so, .dylib, .dll).
Please see your package management system to install SDL2. You can also download yourself binaries on the
[SDL2 web page](http://libsdl.org/download-2.0.php)

```sh
luarocks install https://raw.github.com/torch/sdl2-ffi/master/rocks/sdl2-scm-1.rockspec
```

*Note*: this SDL interface supports only SDL2, not SDL 1.2.

# Usage #

```lua
local sdl = require 'sdl2'
sdl.init(sdl.INIT_VIDEO)
...
```

All SDL C functions are available in the `sdl` namespace returned by require. The only difference is the naming, which is not prefixed
by `SDL_` anymore. The same goes for all C defines (like `SDL_INIT_VIDEO`, which can now be accessed with `sdl.INIT_VIDEO`).

Although the interface is quite complete, there are still few defines not ported in this package. Fill free to post a message about it,
or to request pulls.



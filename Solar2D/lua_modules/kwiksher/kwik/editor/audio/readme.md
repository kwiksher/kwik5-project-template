http://localhost:1313/design/workflow/

```
App/bookFree
  ├── assets
  │   ├── audios
  │   │   ├── long
  │   │   │   ├── GentleRain.mp3
  │   │   │   └── page3
  |   |   |        └──Tranquility.mp3
  │   │   ├── short
  │   │   │   └── ballsCollision.mp3
  │   │   └── sync
  │   │       ├── alphabet
  │   │       │   ├── a.mp3
  │   │       │   ├── b.mp3
  │   │       │   └── c.mp3
  │   │       ├── alphabet.mp3
  │   │       ├── alphabet.txt
  │   │       ├── en
  │   │       │   ├── i_am_a_cat
  │   │       │   |      ├── i.mp3
  │   │       │   |      ├── am.mp3
  │   │       │   |      └── cat.mp3
  │   │       │   ├── i_am_a_cat.mp3
  │   │       │   ├── i_am_a_cat.txt
  |   │       │   └── page3
  │   │       │        ├── my_name_is_kwik.mp3
  │   │       │        └── my_name_is_kwik.txt
  │   │       └── jp
  │   │           ├── i_am_a_cat
  │   │           |      ├── i.mp3
  │   │           |      ├── am.mp3
  │   │           |      └── cat.mp3
  │   │           ├── i_am_a_cat.mp3
  │   │           ├── i_am_a_cat.txt
  |   │           └── page3
  │   │                 ├── my_name_is_kwik.mp3
  │   │                 └── my_name_is_kwik.txt
  |   └── index.json
  ├── commands
  ├── components
  │   ├── page3
  │       ├── audios
  │           ├── long
  │           │   ├── GentleRain.lua
  │           │   └── Tranquility.lua
  │           ├── short
  │               └── ballsCollision.lua
  |
  ├── mediators
  ├── models
  │   ├── page3
  │       ├── audios
  │       |     ├── long
  │       |     │   ├── GentleRain.json
  │       |     │   └── Tranquility.json
  │       |     ├── short
  │       |     │   └── ballsCollision.json
  │       |     └── sync
  │       |         ├── alphabet.json
  │       |         ├── i_am_a_cat.json
  │       |         └── my_name_is_kwik.json
  |       |
  │       ├── index.json
  |       ├── alphabet_sync.json
  |       ├── alphabet.json
  |       ├── iamacat_sync.json
  |       ├── iamacat.json
  |       ├── mynameiskwik_sync.json
  |       ├── mynameiskwik.json
  │
  └── scenes
      ├── page3
          ├── index.lua
          ├── alphabet_sync.lua
          ├── alphabet.lua
          ├── iamacat_sync.lua
          ├── iamacat.lua
          ├── mynameiskwik_sync.lua
          ├── mynameiskwik.lua

```


http://localhost:1313/design/project_model/components/audio/


models/assets/index.json

```
{
  "language": {"en", "jp"},
  "data":[
    {"name":"", "path":"audios/short/ballsCollide.mp3"},
    {"name":"", "path":"audios/long/GentleRain.mp3"},
    {"name":"", "path":"audios/long/page3/Tranquility.mp3"},
    {"name":"", "path":"audios/sync/alphabet.mp3"},
    {"name":"", "path":"audios/sync/alphabet.txt"},
    ...
    ...
  ]
}
```

components/page3/audios/long/GentleRain.lua
```
local Props = {
    name     = "GentleRain",
    type     = "stream",
    autoPlay = true,
    channel  = 1
}
return Props
```

components/page3/audios/long/Tranquility.lua
```
local Props = {
    name     = "GentleRain",
    type     = "stream",
    autoPlay = true,
    channel  = 1,
    folder = "page3"
}
return Props
```

components/page3/audios/sync/alphabet.lua
```
local Props = {
    name     = "alphabet",
    type     = "sync",
    wordclick = true,
    autoPlay = true,
    channel  = 2
}
return Props
```

components/page3/audios/sync/i_am_a_cat.lua
```
local Props = {
    name     = "i_am_a_cat",
    type     = "sync",
    language = {"en", "jp"},
    wordclick = true,
    autoPlay = true,
    channel  = 2
}
return Props
```


http://localhost:1313/introduction/

scenes/page3/index.lua
```
layers = {
  { bg={}},
  { alphabet    = {class={"sync"}}},
  { iamacat     = {class={"sync"}}},
  { mynameiswik = {class={"sync"}}},
},
language = {"en", "jp"},
components = {
  audios = {
    long  = {"GentleRain", "Tranquility" },
    short ={"ballsCollision"} ,
    sync  = {
      "alphabet",
      "i_am_a_cat",
      "my_name_is_kwik",
    }
  }
  groups = {},
  timers = {},
  variables = {},
},

```


M = {}

M.menu = {
  {name = "Animation", icon = "toolAnim", commandClass = "animation"},
  {name = "Audio", icon = "addAudio", commandClass = "audio"},
  {name = "Image", icon = "toolLayer", commandClass = "image"},
  {name = "Layer", icon = "toolLayer", commandClass = "layer"},
  {name = "Page", icon = "toolPage", commandClass = "page"},
  {
    name = "Controls",
    icon = "actions",
    children = {
      {name = "Action", icon = "actions", commandClass = "action"},
      {name = "Condition", icon = "", commandClass = "condition"},
      {name = "Loop", icon = "", commandClass = "loop"},
      {
        name = "External Code",
        icon = "AddCode",
        commandClass = "externalcode"
      },
      {name = "Language", icon = "Lang", commandClass = "language"},
      -- {name = "Random", icon = "", commandClass = "random"},
      {name = "Timer", icon = "Timers", commandClass = "timer"},
      {
        name = "Variable",
        icon = "addVar",
        commandClass = "variable"
      }
    }
  },
  {
    name = "Interactions",
    icon = "toolInter",
    children = {
      {
        name = "Button",
        icon = "intButton",
        commandClass = "button"
      },
      -- {name = "App Rating", icon = "", commandClass = "app"},
      {
        name = "canvas",
        icon = "intCanvas",
        commandClass = "canvas"
      },
      {name = "Screenshot", icon = "", commandClass = "screenshot"},
      -- {name = "Purchase", icon = "", commandClass = "purchase"}
    }
  },
  {
    name = "Replacements",
    icon = "toolLayer",
    children = {
      {name = "Countdown", icon = "", commandClass = "countdown"},
      {
        name = "filter",
        icon = "animFilter",
        commandClass = "filter"
      },
      {
        name = "Multiplier",
        icon = "repMultiplier",
        commandClass = "multiplier"
      },
      {
        name = "Partciles",
        icon = "repParticles",
        commandClass = "particles"
      },
      {name = "ReadMe", icon = "repSync", commandClass = "readme"},
      {
        name = "Sprite",
        icon = "repSprite",
        commandClass = "sprite"
      },
      {name = "Video", icon = "repVideo", commandClass = "video"},
      {name = "Web", icon = "repWeb", commandClass = "web"}
    }
  },
  {name = "Physics", icon = "toolPhysics", commandClass = "physics"}
}

M.commands = {
  action = {
    play = {_trigger = ""},
    playAll = {actions = {}, random = true},

  },
  animation = {
    pause = {_target = ""},
    resume = {_target = ""},
    play = {_target = ""},
    playAll = { animations = {}}
  },
  audio = {
    record = {
      duration = 0,
      mmFile = "",
      malfa = "",
      audiotype = ""
    },
    muteUnmute = {
      _target = {}
    },
    play = {
      _target = "",
      type = "",
      channel = "",
      repeatable = "",
      delay = "",
      loop = "",
      fade = "",
      volume = "",
      tm = "", -- timer id
      _trigger = "",
    },
    rewind = {
      _target = "",
      type = "",
      channel = "",
      repeatable = "",
    },
    pause = {
      _target = "",
      type = "",
      channel = "",
      repeatable = "",
    },
    stop = {
      _target = "",
      type = "",
      channel = "",
      repeatable = "",
    },
    resume = {
      _target = "",
      type = "",
      channel = "",
      repeatable = "",
    },
    setVolume = {
      volume = "",
      channel = "",
    },
  },
  button = {
    onOff = {_target = "", toggle = true, enable = true},
  },
  condition = {
      __if = {
        A1_ = "",
        A2_Operand = "==",
        A3_ = "",
        AB_Condition = "",
        B1_ = "",
        B2_Operand = "",
        B3_ = ""
      },
      _elseif = {
        A1_ = "",
        A2_Operand = "==",
        A3_ = "",
        AB_Condition = "",
        B1_ = "",
        B2_Operand = "",
        B3_ = ""
      },
    __if_ = {expression=""},
    _elseif_={expression=""},
    _else = {},
    _end = {}
  },
  loop ={
    _while = {condition=""},
    _for_next = {condition=""},
    _for_pairs = {condition=""},
    _repeat = {},
    _until = {condition=""}
  },
  canvas = {
    brush = {
      size = NIL,
      color = NIL,
    },
    erase = {},
    undo  = {},
    redo = {}
  },
  countdown = {
    play = {_target = "", time = 5, uptime=""}
  },
  externalcode = {
    code = {_trigger = ""}
  },
  filter = {
    pause = {_target = ""},
    resume = {_target = ""},
    play = {_target = ""},
    cancel = {_target = ""},
  },
  image = {
		edit = {
      _target = "",
       x = 0,
       y = 0,
       width = 0,
       height = 0,
       xScale = 0,
       yScale = 0,
       rotation = 0
    }
  },
  language = {
    name = "",
    reload = true
  },
  layer = {
			showHide = {
        _target = "",
        hide = true,
      toggle = true,
      time = 0,
      delay = 0
      },
      frontBack = {
        _target = "",
        front = true
      }
  },
  multiplier = {
    play = {_target = ""},
    stop = {_target = ""},
  },
  page = {
    autoPlay = {
      time = 10,
    },
    showHideNavigation = {},
    reload = {canvas = true},
    gotoPage = {
      page = "",
      easing = "",
      delay = 0,
      duration = 0,
    }
  },
  particles = {
    play = {_target = ""},
    stop = {_target = ""},
  },
  physics = {
    applyForce = {_target = "", xForce = 0, yForce = 0},
    bodyType = {_target = "", type = ""},
    gravity = {_target = "", xGravity =0, yGravity = 0 }
  },
  purchase = {
    buy = {_target = ""},
    restore = {_target = ""}
  },
  syncAudioText = {
    play = {_target = "", language = "", type = "", channel = ""},
  },
  screenshot = {
    take = {
      title = "",
      message = "",
      shutter = true,
      hideLayers = {}
    }
  },
  sprite = {
    play = {
      _target = "",
      sequence = ""
    },
    pause = {
      _target = ""
    }
  },
  timer = {
    create = {
      _target = "",
      delay = "",
      _trigger = "",
      loop = 0,
    },
    cancel = {
      _target = ""
    },
    pause = {
      _target = ""
    },
    resume = {
      _target = ""
    }
  },
  variable = {
    restartTrackVars = {},
    editVar = {_target="", value="", type=""} -- string is "{{value}}" otherwise {{value}} is rendered
  },
  video = {
    play = {_target = ""},
    pause = {_target = ""},
    resume = {_target = ""},
    rewind = {_target = ""},
    muteUnmute = {videos = {}}
  },
  web = {
    goto = {url = ""}
  }
}
return M

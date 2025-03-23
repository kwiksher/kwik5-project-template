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
    play = {name = "", params = ""},
    playRandom = {filter = "", playOnce = true},
    playSequential = {filter = "", playOnce = true}
  },

  animation = {
    pause = {_target = ""},
    resume = {_target = ""},
    play = {_target = ""},
    playRandom = {filter = "", playOnce = true},
    playSequential = {filter = "", playOnce = true}
  },
  audio = {
    record = {
      duration = 0,
      mmFile = "",
      malfa = "",
      audiotype = ""
    },
    muteUnmute = {},
    play = {
      _target = "",
      channel = "",
      delay = "",
      loops = "",
      fadein = "",
      volume = "",
      listener = ""
      -- timerName = "", -- timer id
    },
    rewind = {
      _target = "",
    },
    pause = {
      _target = "",
    },
    stop = {
      _target = "",
    },
    resume = {
      _target = "",
    },
    setVolume = {
      _target = "",
      volume = "",
    },
    setMasterVolume = {
      volume = "",
    },
    fade = {
      _target = "",
      duration = "",
      volume = ""
    },
    fadeOut = {
      _target = "",
      duration = "",
    },
  },

  button = {
    onOff = {_target = "", toggle = true, enable = true},
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

  countdown = {
    play = {_target =""},
    stop = { _target = ""},
    reset = { _target = ""}
  },

  externalcode = {
    code = {line = ""}
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
       x = "",
       y = "",
       width = "",
       height = "",
       xScale = "",
       yScale = "",
       rotation = ""
    }
  },

  language = {
    set = {
      lang = "",
      reload = true
    }
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
      front = true
    }
  },

  loop = {
    _while = {condition=""},
    _for_next = {condition=""},
    _for_pairs = {condition=""},
    _repeat = {},
    _until = {condition=""}
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
      pageName = "",
      effect = "",
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
    setBodyType = {_target = "", type = ""},
    gravity = {_target = "", xg =0, yg = 0 }
  },

  purchase = {
    buy = {_target = ""},
    restore = {_target = ""}
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

  syncAudioText = {
    play = {_target = "", language = "", type = "", channel = ""},
  },

  timer = {
    create = {
      name = "",
      delay = "",
      loop = 0,
      autoStart = true,
      onComplete = "",
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
    seek = {_target = "", seconds=0},
    muteUnmute = {}
  },

  web = {
    goto = {url = ""}
  }
}

return M

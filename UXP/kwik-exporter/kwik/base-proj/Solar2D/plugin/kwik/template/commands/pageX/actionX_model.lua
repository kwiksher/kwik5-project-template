local model = {}
-- actions
model = {
    {
        condition = {
            __if = {exp1 = "", exp1Op = "", exp1Comp = "", exp2Cond = "", exp2 = "", exp2Op = "", exp2Comp = "" },
            __if_ = {condition = "" },
            _else = true,
            __elseif = {exp1 = "", exp1Op = "", exp1Comp = "", exp2Cond = "", exp2 = "", exp2Op = "", exp2Comp = "" },
            __elseif_ = {condition = "" },
            _end = true
        },
      },
      statement = {
          _for_next = {i_exp="", v_exp ="", t_exp=""},
          _for_pair = {k_exp="", v_exp ="", t_exp=""},
          _while = {condition=""},
          _repeat = false,
          _end = true,
          _until = {condition=""}
        }
    },
    {
        action = {
            playAction = {trigger = ""}
        }
    },
    {
        animation = {
            pauseAnimation  = {target = ""},
            resumeAnimation = {target = ""},
            playAnimation   = {target = ""}
        }
    },
    {
        button = {
            enableDisableButton = {target = "", toggle = "", enable = ""}
        }
    },
    {
        fiter = {
            pauseFilter  = {target = ""},
            resumeFilter = {target = ""},
            playFilter   = {target = ""},
            cancelFilter = {target = ""}
        }
    },
    {
        app = {
            rateApp = {appleID = ""}
        }
    },
    {
        audio = {
            recordAudio = {duraiton = "", mmFile = "", malfa = "", audiotype = ""},
            muteUnmute  = {
                videos = {
                    {target=""},
                    {target=""},
                },
            },
            playAudio = {audiotype = "", vaudio = "", vchan="", vrepeat = "",  vdelay = "", vloop = "", toFade = "", vvol = "", tm = "", trigger = ""},
            rewindAudio = {audiotype = "", vaudio = "", vchan="", vrepeat = ""},
            pauseAudio = {audiotype = "", vaudio = "", vchan="", vrepeat = ""},
            stopAudio = {audiotype = "", vaudio = "", vchan="", vrepeat = ""},
            resumeAudio = {audiotype = "", vaudio = "", vchan="", vrepeat = ""},
            setVolume =  {vvol = "",  vchan=""},
        }
    },
    {
        canvas = {
            brushSize = {size = "", alpha = ""},
            brushColor = {color = ""},
            eraseCanvas = {},
            undo = {},
            redo = {}
    },
    {
        countdown = {
            playCountDown = {target = "", ttime= "", tname = ""}
        }
    },
    {
        external = {
            externalCode = {triggerName = ""}
        }
    },
    {
        image = {
            editImage = {
                target = "", mx = "", mY = "", sw = "", sh = "", fh = "", fv = "", ro=""
            }
        }
    },
    {
        language = {
            setLanguage = {lang = "", reload = ""}
        }
    },
    {
        layerAct = {
            showHide = {target = "", hides = "", toggles = "", time="", delay = ""},
            frontBack = {showLay = "", front="", target = ""},
        }
    },
    {
        multiplier = {
            playMultiplier = {target = ""},
            stopMultiplier = {target = ""}
        }
    },
    {
        page = {
            autoPlay = {autoPlaySec = "", goNext = true},
            showHideNavigation = {target = ""},
            reloadPage         = {cavas = ""},
            gotoPage  = {pnum = "", ptrans = "", delay="", duration = ""},

        }
    },
    {
        particle = {
            playParticle = {target = ""},
            stopParticle = {target = ""}
        }
    },
    {
        physics = {
            applyForce = {target ="", xFor="", yFor=""},
            bodyType   = {target = "", btype = ""},
            invertGravity = {target = "", xgra = ""}
        }
    },
    {
        purchase = {
            restorePurchase = {},
            refoundPurchase = {},
            buyProduct      = {product = ""}
        }
    },
    {
        random = {
            playRandom = {
                id="",
                randArr = {
                    {play = ""},
                    {play = ""}
                },
                playRand = ""
            },
            playRandomAnimation = {
                id="",
                randArr = {
                    {play = ""},
                    {play = ""}
                },
                playOnce = ""
            },
        }
    },
    {
        readme = {
            playReadMe = {
                audiotype = "", vchan = ""
            },
            readMe = {bReadme = "", goNext = true },
            playSync = {langSync = "", audiotype = "", audioSent = "", line = "", button = "", dois =""}
        }
    },
    {
        screenshot = {
            takeScreenShot = {ptit = "", pmsg = "", shutter = "", buttonArr = {
                {name = ""},
                {name = ""}
                }},
            screenRecording = {delay = "", target = "", filename = "", numFrames = ""}

        }
    },
    {
        sprite = {
            playSprite = {target = "", vseq = ""},
            pauseSprite = {target = ""}
        }
    },
    {
        timer = {
            createTimer = {target = "", trigger = "", loop = ""},
            cancelTimer = {target = ""},
            resumeTimer = {target = ""},
            pauseTimer  = {target = ""}
        }
    },
    {
        variables = {
            restartTrackVars = {},
            editVars = {triggerName = ""}
        }
    },
    {
        video = {
            playVideo = { target = ""},
            resumeVideo = {target = ""},
            rewindVideo = {target = ""},
            pauseVideo = {target = ""},
            muteVideo  = {videos = {
                {target = ""},
                {target = ""}
            }},
            unmuteVideo  = {videos = {
                {target = ""},
                {target = ""}
            }}

        }
    },
    {
        web = {
            gotoURL = {pLink = ""}
        }
    }
}

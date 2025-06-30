local _M = {}



--[[

  local model = require("components.page001.images.background_morning.lua")

  model.rotate = nil -- not updating the value of rotation

  Runtime:dispatchEvent("state_"..model.name, {model=model})

]]


--[[
  --
  -- Application (global) state
  --
  stateGroups = {
    language = {
      English  = {buttonEn, imageEn},
      Japanese = {buttonJp, imageJp}
    },
    time = {
      morning  = { house, background_morning },
      evening  = { house, background_evening }
    }
  }

  "stateGroup":[
    {
      "@id":"",
      "name":"language"
      "states":[
        {
          "name":"English",
           "models":["buttonEn", "imageEn"]
        }
      ]
    }
  ]

  local model = require("components.page001.images.background_morning.lua")

  _K.bindState("language", model)

  local model = require("components.page001.images.button_en.lua")
  _K.bindState("time", model)

  _K.dispathStateEvent("time", "morning")
  _K.dispathStateEvent("language", "English)


  -- for animation
    kwik.transition.to(layer.imageObj, {state="evening", time=1000, onComplete = function()
      _K.dispathStateEvent("time", "evening")
    end}) --x, y, rotation, alpha, xScale, yScale

  -- stateActions
     English
        onState
            pauseAnim
            playSound
            ...
        offState

  --
  -- Object (instanced) state
  --

  local model_smile = require("components.page001.images.dog_smile.lua")

  Runtime:dispatchEvent("state_dog", {model=model_smile})

  --
  -- UI like a create state group or a state for single object
  --

    * new state group
    * select layers to add to the group
        * remove a layer
    * new state
      * start time  and duration (optional)
    * select state
    * delete state
    * reset
    * save
    * save AS

    save the props of each layer proporties of Photoshop

      "width":0,
      "height":0,
      "x":0,
      "y":0,
      "xScale":1,
      "yScale":1,
      "alpha":1,
      "rotation":0,

    NOT support for saving the pros of kwik components. Use Kwik Action for hiding, diable button etc

        new action
            * audio.seek
            * audio.seek with synAudioText
            * video.seek


    Kwik UI panel
        page list/component list/state list
            language
                english
                    titleEn, goorMoningEn, goodEveningEn
                japanese
                    titleJp, goodMorningJP, goodEveningJp
            time
                morning
                    Sun
                    house, background_morning
                    dog[sleep]
                    goorMoningEn
                    goodMorningJP
                evening
                    Sun
                    Moon
                    house, background_evening
                    dog[hungry]
                    goodEveningEn
                    goodEveningJp

        spritehseet panel for dog
            current state: time > morning
                smile
                angry
                sleep
                hungry

        animation panel
            Sun
                state > time:morning to evening
                wait for the state starts
                path animtion
            Moon
                time:evening
                wait for the state starts

        timer
            state > time:evening
            wait for the state starts
            15 sec
            go to next page

        state list > morning
            initAction = {
                Hide layerA -- hide the photoshop layer too
                Disable buttonB
                Diable  dragD
                DogSprite Sleep
            },
            exitAction = {

            }

      state box lang > english
                time > morning
      search box compnent:anim

]]

return _M
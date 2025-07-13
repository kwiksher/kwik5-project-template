local M = {}

local selectors
local UI
local bookTable
local pageTable
local layerTable
local buttons = require("editor.parts.buttons")
local scriptsCommands = require("editor.scripts.commands")
local assetTable = require("editor.asset.assetTable")
local helper = require("test.helper")

local _TMP = "/Users/ymmtny/Documents/GitHub/kwik-visual-code/develop/Solar2D/kwik-editor-proj/tmp"

function M.init(props)
  selectors = props.selectors
  UI        = props.UI
  bookTable = props.bookTable
  pageTable = props.pageTable
  layerTable = props.layerTable
  ---
  helper.init(props)
end

function M.suite_setup()
  -- selectors.projectPageSelector:show()
  -- selectors.projectPageSelector:onClick(true)

  -- selectors.componentSelector.iconHander()
  -- selectors.componentSelector:onClick(true,  "layerTable")

end

function M.setup()
end

function M.teardown()
end

function M.xtest_click_assetIcon()
    selectors.componentSelector.iconHander()
    selectors.assetsSelector:iconHander()
    selectors.assetsSelector:onClick(true, "audios")
    --selectors.assetsSelector:onClick(true, "particles")
end

function M.xtest_create_praticles()
  selectors.componentSelector.iconHander()
  selectors.assetsSelector:iconHander()
  selectors.assetsSelector:onClick(true, "particles")
  --select firstone
  helper.clickAsset(assetTable.objs, "particles/particle.png")
end

function M.test_create_sprite()
  selectors.componentSelector.iconHander()
  selectors.assetsSelector:iconHander()
  selectors.assetsSelector:onClick(true, "sprites")
  helper.clickAsset(assetTable.objs, "sprites/sprites.png")
end

function M.xtest_lfs()
  local expected  = {
    audios = {
      {
        name = "shutter.mp3",
        path = "audios/short",
        links = {}
      }
    },
    videos = {
      {
      name = "kwikplanet.mp4",
      path = "videos",
      links = {}
      },
    },
    sprites = {}

  }


  ---
  selectors.assetsSelector:show()
  -- selectors.assetsSelector:onClick(true, nil)
  -- selectors.assetsSelector:onClick(true, "videos")
  local video_index = 5
  local target = selectors.assetsSelector.objs[video_index]
  print(target.text)
  target:dispatchEvent({name="tap", target=target})

  assert_not_nil(UI.editor.assets.videos)
  assert_equal(UI.editor.assets.videos[1].name, expected.videos[1].name)

  --select kwikplanet.mp4
  local assetTable = require("editor.asset.assetTable")
  assetTable.objs[1]:touch({phase="ended"})



  -- audio
  assert_equal(UI.editor.assets.audios[1].name, expected.audios[1].name)

end
---
--- multi select and new from assetTable, edit/delete/vscode are not supported so it opens asset folder in Finder instead
---
function M.xtest_create_audio_multi()
end

function M.xtest_create_video_multi()
end

function M.xtest_create_praticles_multi()
end

function M.xtest_sync_text_multi()
end

function M.xtest_create_video()
  -- save a replacement component e.x. kwikplanent.mp4 to layerOne
  -- save UI.editor.assets with the linked layer value in videos as json in model folder
  --
  -- TBI load(readAsset) the json model and merge to make UI.editor.assets
  --   if an asset not found in App/book folder delete the entry in json model
  --
  -- REST api to add a new asset to App/book folder
  ---
  selectors.assetsSelector:show()
  -- selectors.assetsSelector:onClick(true, nil)
  -- selectors.assetsSelector:onClick(true, "videos")
  local video_index = 5
  local target = selectors.assetsSelector.objs[video_index]
  target:dispatchEvent({name="tap", target=target})

  --select kwikplanet.mp4
  local assetTable = require("editor.asset.assetTable")
  assetTable.objs[2]:touch({phase="ended"})

  -- click video icon
  assetTable:iconsHandler({target={muiOptions={name="repVideo-icon"}}}, "video", "selectTool")

  -- click a layer
  local args = {"book", "page1", "imageTwo"}
  local layerObj = layerTable.findObj(layerTable.objs, args, 3)
  layerObj:touch({phase="ended"})

  local videoEditor = require("editor.replacement.index")
  local urlField = videoEditor.controller.classProps.objs[5]
  urlField:dispatchEvent{name="tap", target=urlField}

  --select Gen2
  assetTable.objs[1]:touch({phase="ended"})
  --TBI touching Gen2, dipatch event to update url's value to be Gen2

  -- click save. Internally calls publishForSelections() in scripts.commands.lua
  --buttons.objs["save"]:tap()
  --
  -- TBI UI.editor.assets entry is updated with the layer name that is linked with it when a replacement component is created
  --
  -- TBI merge the saved UI.editor.assets json model with the assets model read with lfs? YES
end

function M.xtest_save_video_renderAssets()
  -- save button -- buttons.objs["save"] calls this command
  --
  -- when layer_video' props has kwikplanet.mp4, and it will be added to assets/model.lua
  -- though links[1].layers will be emtpy because "imageOne" is set with videoA.mp4
  --
  -- old url in props(imageOne_video.lua) is checked for duplicateted layer replacement for one layer,
  -- so layer_video is rendered too in this test like  publishForSelections() in scripts.commands.lua

  local controller = require("editor.controller.index")
  controller.view = {UI = UI}

  local book = "book"
  local page = "page1"
  local classFolderName = "replacement" -- this is id in editor.model.lua to get a folder name of template for lustache
  local class = "video"
  local props = {
    loop = false,
    rewind = false,
    isLocal = true,
    url = "kwikplanet.mp4",
    autoPlay = true,
    onCompelete = nil
  }

  local callScriptCommand = function(fileInSandbox, layer, filename)
    --book, page, layer, class
    local files = {fileInSandbox}
    props.url = filename
    props.name = class -- model.name is mondatory for selecting a tmplt
    --
    files[#files+1] = controller:render(book, page, layer, classFolderName, class, props)
    scriptsCommands.copyFiles(files, _TMP)
    --
    -- TBI is it better to render scene's index.lua too?
    --

  end
  --
  local cases = {
    {layer="imageOne", video="videoA.mp4"}, --kwikplanet.mp4
    {layer="imageOne", video="videoB.mp4"},
    {layer="imageTwo", video="videoA.mp4"},
    {layer="imageTwo", video="videoB.mp4"},
  }

  local index = 4

  --
  -- test each case with the following asset setups
  --
  --  UI.editor.assets = {audios = {}, videos = {}, sprites = {}}
  --
  -- UI.editor.assets.videos =  {
  --   {
  --     name = "videoA.mp4",
  --     path = "videos",
  --     links = {
  --       {page= "page1", layers = {"imageOne"}},
  --     },
  --   }
  -- }

  --   UI.editor.assets.videos =  {
  --   {
  --     name = "videoB.mp4",
  --     path = "videos",
  --     links = {
  --       {page= "page1", layers = {"imageOne"}},
  --     },
  --   }
  -- }

  -- UI.editor.assets.videos =  {
  --   {
  --     name = "videoA.mp4",
  --     path = "videos",
  --     links = {
  --       {page= "page1", layers = {"imageTwo"}},
  --     },
  --   }
  -- }
  -- UI.editor.assets.videos =  {
  --   {
  --     name = "videoB.mp4",
  --     path = "videos",
  --     links = {
  --       {page= "page1", layers = {"imageTwo"}},
  --     },
  --   }
  -- }
  --
  -- UI.editor.assets.videos =  {
  --   {
  --     name = "videoA.mp4",
  --     path = "videos",
  --     links = {
  --       {page= "page1", layers = {"imageOne", "imageTwo"}},
  --     },
  --   }
  -- }
  --
  UI.editor.assets.videos =  {
    {
      name = "videoA.mp4",
      path = "videos",
      links = {
        {page= "page1", layers = {"imageOne"}},
      },
    },
    {
      name = "videoB.mp4",
      path = "videos",
      links = {
        {page= "page1", layers = {"imageTwo"}},
      },
    }
  }


  --
  local model = {
    loop = false,
    rewind = false,
    isLocal = true,
    url = cases[index].video,
    autoPlay = true,
    onCompelete = nil
  }

  local fileInSandbox = controller:renderAssets(book, page, cases[index].layer,"replacement", "video", model)

  local expected = {
    videos = {
    {
      name = cases[index].video,
      path = "videos",
      links = {
        {page= page, layers = {cases[index].layer}},
      },
    }
   }}

  for i, entry in next,UI.editor.assets.videos do
    print(i, entry.name)
    if entry.name == model.url then
      for j, entryLink in next, entry.links do
        if entryLink.page == expected.videos[1].links[1].page then
          for k, entryLayer in next, entryLink.layers do
            if entryLayer == expected.videos[1].links[1].layers[1] then
            -- success --
              callScriptCommand(fileInSandbox, entryLayer, entry.name)
              return
            end
          end
        end
      end
    end
  end
  assert(false)
end

function M.xtest_save_audio()
  local controller = require("editor.controller.index")
  local model = {
    name     = "click",
    type     = "short",
    autoPlay = false,
    channel  = 1,
    folder   = nil,
    filename = "click.mp3",
  }

  local fileInSandbox = controller:renderAssets("book", "page1", nil ,"audio", nil, model)

  local expected = {
    audios = {
      {
        name = "click.mp3",
        path = "audios/short",
        links = {{page = "page1"}}}
      }
    }
  for i, entry in next,UI.editor.assets.audios do
    if entry.name == model.url then
        asset(entry.links[1].page == expected.audios[1].links[1].page)
        -- success --
        scriptsCommands.copyFiles({fileInSandbox}, _TMP)
      return
    end
  end
  assert(false)
end

function M.xtest_spreitesheet()
  -- TBI display spriteseet icon if Spirtesheet is selected in assetTable.lua
end

function M.xtest_assets_lfs()
  -- only lfs
  -- add media files into assets folder and run this test
  --
  -- crund a media file by a command?
  -- and then run readAsset()

  --
  -- this is returned by lfs
  local lfs_assets = {
    audios = {
      {
        name = "shutter.mp3",
        path = "audios/short",
        links = {}
      }
    },
    videos = {
      {
        name = "kwikplanet.mp4",
        path = "videos",
        links = {},
      }
    },
    sprites = {}
  }
  --
  -- this is from assets/model.lua if exists in lfs_assets, this is used. new assets is append if not exists in model.lua
  local model_assets = {
    audios = {
      {
        name = "shutter.mp3",
        path = "audios/short",
        links = {{page = "page1"}, {page = "page2"}}
      }
    },
    videos = {
      -- {
      --   name = "kwikplanet.mp4",
      --   path = "videos",
      --   links = {
      --     {page= "page01", layers = {"layerA1", "layerA10"}},
      --     {page= "page02", layers = {"layerA2", "layerA20"}}
      --   },
      -- },
      -- {
      --   name = "videoA.mp4",
      --   path = "videos",
      --   links = {{page= "page01", layers = {"layerB"}}}
      --   }
    },
    sprites = {}
  }

  local controller = require("editor.asset.index").controller
  local updated, map = controller:read("book") -- read assets/model.lua
  -- local updated, map = controller:read("book", model_assets)

  local json = require("json")
  print(json.encode(updated))
  -- print(json.encode(map))


  -- case1: lfs and model has been syncronized
  -- ret == model_assets

  -- case2: a media file is added, so model.lua nees to append it too ( this case is same for deleteing an entry in model)

  -- case3: a file in lfs is deleted, so mapEntry.isExist is nil (see editor.asset.index:readAsset)
  --      TBI show it assets table UI to it is deleted


end

function M.xtest_assets_generator()
  -- put media files int assets
  -- run editor to get assets/model.lua by lfs
  -- edit assets/model.lua (lua, yml)
  -- run assets_generator
  -- verify whether the lua files are created or not
  --
  -- modify assets/model.lua and run assets_generator
  --
end

function M.xtest_change_replacement_class()
  -- for instance, from video to spritsheet
  -- user should delete video and then add spreiteseet
end

function M.xtest_edit_index_manually()
  -- setup: user edit pageX/index.lua manually to add a compoennent
  -- modify index.lua for a component, CRUD and then run this test
  --
  -- modify scene.layers in runtime for CRUD?
    -- for adding a new component, add a media file to assets folder too?
      -- if not exist a media file, error
  -- and then run readAsset()
  -- verify:assets/model.lua is updated out of the modification of index.lua
end


function M.xtest_save_spritesheet_same_size()
  -- user puts an imagesheet
  -- first time sheetInfo is empy
  -- user inputs sheetInfo
  -- assets/model.lua is updated with sheetInfo
end

function M.xtest_save_spritesheet_texturePacker()
  -- sheetInfo.lua and imageSheet are exported from texture packer
  -- TBI gnerate each sprite automatically one by one from frames
end

function M.xtest_linked_layer_CRUD()
  -- setup: one asset ex. kwikplanet.mp4 is displayed with the linked layer in assetTable
  --      pageX/index.lua has layerOne with video to play kwikplanet.mp4
  --      UI.editor.assets table has  links.layers = {"layerX" , ...}
  -- test update layer with a different video
  -- test delete video replacment from layer
end

function M.xtest_load()
  UI.editor.assets = {
    audios = {
      {
        name = "click.mp3",
        path = "audios/short",
        links = {{page = "page1"}}
      }
    },
    videos = {
      {
      name = "videoA.mp4",
      path = "videos",
      links = {{page= "page01", layers = {"imageOne"}},
               {page= "page02", layers = {"iamgeTwo"}}}
      },
      {
        name = "videoB.mp4",
        path = "videos",
        links = {
          {page= "page01", layers = {"iamgeTwo"}}}
      }
    },
    sprites = {}

  }
  ---
  selectors.assetsSelector:show()
  -- selectors.assetsSelector:onClick(true, nil)
  selectors.assetsSelector:onClick(true, "videos")
end

function M.xtest_load()
  UI.editor.assets = {
    audios = {
      {
        name = "click.mp3",
        path = "audios/short",
        links = {{page = "page1"}}
      }
    },
    videos = {
      {
      name = "videoA.mp4",
      path = "videos",
      links = {{page= "page01", layers = {"imageOne"}},
              }
      },
      {
        name = "videoB.mp4",
        path = "videos",
        links = {
          {page= "page01", layers = {"iamgeTwo"}}}
      }
    },
    sprites = {}

  }
  ---
  selectors.assetsSelector:show()
  -- selectors.assetsSelector:onClick(true, nil)
  selectors.assetsSelector:onClick(true, "videos")

  local assetTable = require("editor.asset.assetTable")
  assetTable.objs[1]:touch({phase="ended"})

end

function M.xtest_load()
  UI.editor.assets = {
    audios = {
      {
        name = "click.mp3",
        path = "audios/short",
        links = {{page = "page1"}}
      }
    },
    videos = {
      {
        name = "videoA.mp4",
        path = "videos",
        links = {}
      },
      {
        name = "videoB.mp4",
        path = "videos",
        links = {}
      }
    },
    sprites = {
        {
          name = "butflysprite.png",
          path = "sprites",
          links = {}
        },
        {
          name = "slotes.png",
          path = "sprites",
          links = {}
        },
        {
          name = "SpriteTiles/sprites.png",
          path = "sprites",
          links = {}
        }
    }

  }
  ---
  selectors.assetsSelector:show()
  -- selectors.assetsSelector:onClick(true, nil)
  -- selectors.assetsSelector:onClick(true, "videos")
  selectors.assetsSelector:onClick(true, "sprites")
  assetTable.objs[1]:touch({phase="ended"})

end

function M.xtest_load()
  -- UI.editor.assets = {
  --   audios = {
  --     {
  --       name = "click.mp3",
  --       path = "audios/short",
  --       links = {{page = "page1"}, {page = "page2"}}
  --     }
  --   },
  --   videos = {
  --     {
  --       name = "videoA.mp4",
  --       path = "videos",
  --       links = {
  --         {page= "page01", layers = {"layerA1", "layerA10"}},
  --         {page= "page02", layers = {"layerA2", "layerA20"}}
  --       },
  --     },
  --     {
  --       name = "videoB.mp4",
  --       path = "videos",
  --       links = {{page= "page01", layers = {"layerB"}}}
  --       }
  --   },
  --   sprites = {}

  -- }
  -- ---
  selectors.assetsSelector:show()

  -- selectors.assetsSelector:onClick(true, "audios")
  -- assetTable.objs[2]:touch({phase="ended"})

  -- selectors.assetsSelector:onClick(true, "videos")
  -- assetTable.objs[2]:touch({phase="ended"})

  selectors.assetsSelector:onClick(true, "sprites")
  -- assetTable.objs[2]:touch({phase="ended"})

end

function M.xtest_click_new_icon()
  selectors.assetsSelector:onClick(true, "audios")
  -- assetTable.objs[2]:touch({phase="ended"})
  -- assetTable:iconsHandler({target={muiOptions={name="addAudio"}}}, "audio", "selectAudio")

  -- selectors.assetsSelector:onClick(true, "videos")
  -- assetTable.objs[2]:touch({phase="ended"})
  -- assetTable:iconsHandler({target={muiOptions={name="repVideo-icon"}}}, "video", "selectTool")

end

return M

# kwik5-project-template


- plugin kwik5 for Solar2D simulator

  you may use install_plugin.sh in this repo to fetch it, the script installs the plugin to ~/Library/Application Support/Corona/Simulator/Plugins/plugin/ folder.

    ```
    source ./install_plugin.sh
    ```

  or manually download it

  - https://github.com/kwiksher/kwik5-project-template/releases/latest/download/plugin.data.tgz

    copy it to ~/Library/Application Support/Corona/Simulator/Plugins/plugin/

      <img src="./img/2025-03-23-15-44-21.png" width="800" class="popup-image">

- Photoshop UXP

  - https://github.com/kwiksher/kwik5-project-template/releases/latest/download/com.kwiksher.kwik5.exporter_PS.ccx


    - download the ccx and double click it to install it.

    - Creative Cloud app opens and shows the dialog, click install button

      <img src="./img/2025-03-23-15-47-42.png" width="800" class="popup-image">

      click yes

      <img src="./img/2025-03-23-15-48-24.png" width="800" class="popup-image">

      open photoshop

      <img src="./img/2025-03-23-15-49-01.png" width="600" class="popup-image">


-  kwik5-project-template

   Photoshop > book
    - landscape.psd
    - portrait.psd


      <img src="./img/2025-03-23-16-15-10.png" width="400" class="popup-image">


   - Solar2D/main.lua

     open it Solar2D Simulator

      - kwikEditorLandscape.lua: this file should be created by install_plugin.sh or you can manually copy it to ~/Library/Application Support/Corona/Simulator/Skins folder

   - install_plugin.sh

   - UXP/kwik-exporter

       you may use Adobe UXP Developer Tools to open kwik-exporter instead of clicking com.kwiksher.kwik5.exporter_PS.ccx

## Photoshop kwik-exporter

  Plugins > Kwik Exporter to open it. Kwik Exporter needs to know where is a photoshop file, and where is Solar2D/App/book folder where Kwik Exporter publishes images and lua files of a psd file.

  <img src="./img/2025-03-23-15-59-19.png" width="600" class="popup-image">

  1. Select **kwik5-project-template** folder

      <img src="./img/2025-03-23-16-04-08.png" width="600" class="popup-image">

  1. Select **Photoshop** folder

  1. Select **Solar2D/App/book** folder


  You may change these settings by selecting Reset checkbox and then click Open to browse a new folder

  - Settings Tab to change the root project folder

    <img src="./img/2025-03-23-16-08-55.png" width="400" class="popup-image">

  - Menu Tab for Photoshop and Solar2D

    <img src="./img/2025-03-23-16-20-04.png" width="400" class="popup-image">

  ### Open a psd file

  You can click the name of psd file to open

  <img src="./img/2025-03-23-16-27-21.png" width="1600" class="popup-image">


  - Guide Layout is created by Kwik_ATN actions. You may use your own guide layout

    <img src="./img/2025-03-23-16-29-02.png" width="400" class="popup-image">


  ### Publish

  1. select the psd files to be published. you may use the **all** checkbox, then click Publish button

      <img src="./img/2025-03-23-16-33-02.png" width="400" class="popup-image">


  1. it shows a publish dialog

      <img src="./img/2025-03-23-16-34-23.png" width="400" class="popup-image">

      Because of the well-knonw bug of Photoshop UXP, you need to check export images works before using the script to automate the export tasks. If not work, you need to restart Photoshop.

      The check process is that simply try an export png manually.

      - Select a layer and then righ click Quick Export as PNG. Once done, you don't need to repeat this check again.

        <img src="./img/2025-03-23-16-38-23.png" width="400" class="popup-image">

      OK, if you have checked it works, then select Publish again, then ckick **Continue** for publishing the selected psd files by Kwik Exporter.


      Make sure the checkboxes for publsih options, and the App/book folder path.

      <img src="./img/2025-03-23-16-42-02.png" width="400" class="popup-image">

      Kwik expoerter traverses the psf files and the layers, and it shows the dialog at the end

      <img src="./img/2025-03-23-16-47-50.png" width="300" class="popup-image">

 1. Load Simulator


    <img src="./img/2025-03-23-20-29-59.png" width="600" class="popup-image">


    Kwik Edito Landscape is selected which has been installed by install_plugin.sh

    <img src="./img/2025-03-23-20-47-38.png" width="600" class="popup-image">

 ### Active Document

  - Validate Name & Opacity

    Japanese katakana is converted to alphabet

    Opacity zero is adjusted because Photoshop does not export transparent layer as png

  - Export Code

    only exports lua files

  - Skip scenes: this is useful if you open a psd file not in the list of Photoshop files.

      Unchked, the scenes(pages) index is always updated with the list of Photoshop files. This is default behavior.

  - Export Images

    - (option) press shift key

      it only exports one single layer selected while **Export images** in Active Document

    - layer names with starting "-" (hyphen) are ignored when exporting code & images


    <img src="./img/2025-03-23-20-55-50.png" width="600" class="popup-image">


 ### Layer Groups
  - Unmerge

    select a layer group in Layer panel, and you can specify exportting each child

  - Cancel

    cancel Unmerge

  - Refresh

    if there is a sub folder as same name as layer group in App/book/assets/images/page, then Unmerge is triggered. So you can manually create sub folders there, such case you can use Refresh button

    <img src="./img/2025-03-23-21-05-35.png" width="300" class="popup-image">

---

See more detail information in the online document

- https://kwiksher.github.io/kwik5docs/get_started/index.html

---

## Solar2D/main.lua

Please set the mode variable either "editing" or "production"

> "production" creates the plugin folder in Solar2D folder because plugin.kwik has not been registered in Solar2D official plugins, it won't be integreted automatically.

> setting back to "production" to "editing", the plugin folder created in production mode will be deleted automatically, and you can go back to use plugin.kwik in Application Support/Corona/Plugins folder

main .lua

```lua
local kwik = require "plugin.kwik"
local lfs = require("lfs")
--
system.setTapDelay(0.2)

--display.setDefault( "background", 0.2, 0.2, 0.2, 0.1 )
kwik.useGradientBackground()
--
local mode = "editing"
-- local mode = "production"
-- local mode = "dev"
--
local props
--
if mode == "editing" or mode == "dev" then
  props = {
    name = "book",
    editor = true,
    gotoPage = "landscape",
    language = "", -- empty string "" is for a single language project
    position = {x = 0, y = 0},
    gotoLastBook = true,
    unitTest = false,
    httpServer = false,
    showPageName = true
  }
elseif mode == "production" then
  props = {
    name = "book",
    editor = false,
    gotoPage = "landscape",
    language = "", -- empty string "" is for a single language project
    position = {x = 0, y = 0},
    gotoLastBook = false,
    unitTest = false,
    httpServer = false,
    showPageName = false
  }
end
...
```

### config.lua

for the final build for device, you need to change the scale as "letterbox"

```lua
application = {
	content =
	{
		fps = 60,
		width = 320,
		height = 480,
		-- scale = "adaptive",
		scale = "letterbox",
		xAlign = "center",
		yAlign = "center",
 ...
 ```


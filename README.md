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

      ⭐️ open it Solar2D Simulator

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

      - [ ] Load Simulator
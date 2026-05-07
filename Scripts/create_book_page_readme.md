## simple case: bg.lua are copied to --pages

```
Scripts/create_book_page.command --book=MyBook --pages=page1,page2 --src=Solar2D/template/components/pageX/layer/bg.lua
```

## generate particles class lua

rect_0_paticles.lua is copied to each page, and inside sed -i '' "s/emitter_gemini\.lua/${page}.json/g" is applied 

```bash
PAGES=(
  "air_stars"
  "aurora_3b"
  "big_orange_flame"
  "blood"
  "blue_galaxy"
  "blue_vortex_field"
  "bp_firefly_final"
  "comet"
  "crazy_blue"
  "electrons"
  "fireplace_flame"
  "giving"
  "heart04"
  "hongshizi"
  "im_seeing_stars"
  "lava_flow"
  "my_galaxy"
  "real_popcorn"
  "smoke"
  "trippy"
  "water_fountain"
  "waterfall"
  "wdemitter"
)

pages_arg=$(IFS=,; echo "${PAGES[*]}")

source Scripts/create_book_page.command --book=particles --pages="$pages_arg" --src=./App/replacement/components/particles/layers/rect_0.lua --class=particles
```
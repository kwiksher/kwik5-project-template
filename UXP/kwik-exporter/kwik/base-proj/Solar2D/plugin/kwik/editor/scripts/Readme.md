# cd Solar2D
./editor/scripts/create_book_page.command --book=MyBook --pages=page1,page2 --src=Solar2D/template/components/pageX/layer/bg.lua

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

source ./editor/scripts/create_book_page.command --book=particles --pages="$pages_arg" --src=./App/replacement/components/particles/layers/rect_0.lua --class=particles
```
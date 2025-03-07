local M = {
  audios = {}, sprites = {},
  videos = {
    {{#videos}}
    {
      name = "{{name}}",
      path = "{{path}}",
      links = {
        {{#links}}
          {page= "{{page}}", layers = {
            {{#layers}}
            "{{.}}",
            {{/layers}}
          }},
        {{/links}}
      },
    },
    {{/videos}}
  }
}

return M
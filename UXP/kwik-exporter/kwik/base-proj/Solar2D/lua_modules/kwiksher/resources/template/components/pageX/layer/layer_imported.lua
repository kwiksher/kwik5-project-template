-- $weight={{weight}}
--
local M={
  path = "{{path}}",
  name = "{{name}}",
}

M.props = {
  {{#layers}}
  {  {{name}}={
        {{>recursive}}
    } },
{{/layers}}
}

--[[
  local M={
    path = "bookTest.components.page2.layers.three.index",
    name = "three",
  }

  M.props = {
     four={layerProps = {color={1,0,1}}},
     five={layerProps = {color={0,1,0}}},
     five_transition2 = {classOption="to", params={}},
     six={
        seven = {layerProps = {color={1,0,0}}},
        seven_myClass = {},
        seven_linear = {},
        eight = {layerProps = {color={1,1,0}}}
      }
  }
--]]

local layerProps = {
  blendMode = "{{blendMode}}",
  height    =  {{bounds.bottom}} - {{bounds.top}},
  width     = {{bounds.right}} - {{bounds.left}} ,
  kind      = {{kind}},
  name      = "{{parent}}{{name}}",
  type      = "png",
  x         = {{bounds.right}} + ({{bounds.left}} -{{bounds.right}})/2,
  y         = {{bounds.top}} + ({{bounds.bottom}} - {{bounds.top}})/2,
  alpha     = {{opacity}}/100,
}

M.layerProps = layerProps
M.classProps = {
  {{#class}}
    {{.}} = {},
  {{/class}}
}

return require("components.kwik.importer").new(M)


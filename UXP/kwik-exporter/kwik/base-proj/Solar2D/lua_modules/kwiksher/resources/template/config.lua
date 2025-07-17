application = {
	content =
	{
		fps = 60,
		width = 320,
		height = 480,
		scale = "adaptive",
		-- scale = "letterbox",
		xAlign = "center",
		yAlign = "center",

		imageSuffix =
		{
			["@2x"] = 2.000,
			["@4x"] = 4.000
		},
  {{#expansion}}
   license  =
   {
        google  =
        {
            key  = "{{googleKey}}"
        },
   },
   {{/expansion}}
  }
}
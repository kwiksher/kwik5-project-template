-- for simple pool
-- application =
-- {
-- 	content =
-- 	{
-- 		width = 768,
-- 		height = 1024,
-- 		scale = "letterBox"

-- 	}
-- }

application =
{
	content =
	{
		fps = 60,
		width = 320,
		height = 480,
		scale = "letterbox",
		xAlign = "center",
		yAlign = "center",

		imageSuffix =
		{
			["@2x"] = 2.000,
			["@4x"] = 4.000
		}
	}
}

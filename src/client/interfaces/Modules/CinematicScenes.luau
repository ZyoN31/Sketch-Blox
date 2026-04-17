--[[
	Cinematic scene template.
	Quick usage:
	1) Create a folder in Workspace.SceneMovements named Scene_01, Scene_02, etc.
	2) Add alphabetically named points (A, B, C, D...) as Part/Camera/Model.
	3) In each scene below, use api.move(scene, duration, startPoint, endPoint)
	   or api.move(duration, startPoint, endPoint) to use the current scene.
	4) Use api.wait(seconds) for pauses between movements.
	5) Use api.endScene() when you want to finish and return to the previous camera.
	   (api["end"]() also exists, but endScene is more convenient in Luau)

	Example:
	api.move(4, "A", "B")
	api.wait(0.5)
	api.move(3, "B", "C")
	api.endScene()
]]

local Scenes = {}

-- Example scene 01
Scenes.Scene_01 = function(api)
	api.move(1, "A", "B")
	api.wait(0.5)
	api.move(2, "B", "B")
	api.wait(0.3)
	api.endScene()
end

-- Example scene 02
Scenes.Scene_02 = function(api)
	api.move(100, "A", "B")
	api.wait(0.1)
	api.endScene()
end

return Scenes

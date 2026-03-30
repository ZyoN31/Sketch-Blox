--[[
	Plantilla de escenas cinematograficas
	Uso rapido:
	1) Crea una carpeta en Workspace.SceneMovements con nombre Scene_01, Scene_02, etc.
	2) Dentro agrega puntos con nombres alfabeticos (A, B, C, D...) como Part/Camera/Model.
	3) En cada escena de abajo, usa api.move(scene, duracion, puntoInicio, puntoFin).
	4) Usa api.wait(segundos) para pausas entre movimientos.
	5) Usa api.endScene() cuando quieras terminar y regresar a la camara anterior.
	   (Tambien existe api["end"](), pero endScene es mas comodo en Luau)

	Ejemplo:
	api.move("Scene_01", 4, "A", "B")
	api.wait(0.5)
	api.move("Scene_01", 3, "B", "C")
	api.endScene()
]]

local Scenes = {}

-- Escena de ejemplo 01
Scenes.Scene_01 = function(api)
	api.move("Scene_01", 1, "A", "B")
	api.wait(0.5)
	api.move("Scene_01", 2, "B", "B")
	api.wait(0.3)
	api.endScene()
end

-- Escena de ejemplo 02
Scenes.Scene_02 = function(api)
	api.move("Scene_02", 2.0, "A", "B")
	api.wait(0.25)
	api.move("Scene_02", 4.0, "B", "D")
end

return Scenes

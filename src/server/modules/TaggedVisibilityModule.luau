local TaggedVisibilityModule = {}

function TaggedVisibilityModule.SetUp_InvisibilityBlocks()
	local CollectionService = game:GetService("CollectionService")
	local Cameras = CollectionService:GetTagged("Cameras")
	local Teleports = CollectionService:GetTagged("Teleports")

	for _, camera in pairs(Cameras) do
		camera.Transparency = 1
		camera.CanCollide = false
		camera.Decal.Transparency = 1
	end

	for _, teleport in pairs(Teleports) do
		teleport.Transparency = 1
		teleport.CanCollide = false
	end
end

return TaggedVisibilityModule

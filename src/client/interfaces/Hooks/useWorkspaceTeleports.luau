local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local REMOTES_FOLDER_NAME = "Teleports"

local function useWorkspaceTeleports()
	local localPlayer = Players.LocalPlayer

	local function getTeleportsFolder(): Folder?
		local folder = Workspace:FindFirstChild(REMOTES_FOLDER_NAME)
		if folder and folder:IsA("Folder") then
			return folder
		end
		return nil
	end

	local function getCharacterRootPart(): BasePart?
		local character = localPlayer.Character
		if not character then
			return nil
		end

		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if rootPart and rootPart:IsA("BasePart") then
			return rootPart
		end

		return nil
	end

	local function resolveTeleportTarget(name: string): CFrame?
		local teleportsFolder = getTeleportsFolder()
		if not teleportsFolder then
			warn("[useWorkspaceTeleports] Workspace.Teleports was not found")
			return nil
		end

		local target = teleportsFolder:FindFirstChild(name)
		if not target then
			warn(string.format("[useWorkspaceTeleports] Teleport '%s' was not found", name))
			return nil
		end

		if target:IsA("BasePart") then
			return target.CFrame
		end

		if target:IsA("Model") and target.PrimaryPart then
			return target.PrimaryPart.CFrame
		end

		warn(string.format("[useWorkspaceTeleports] '%s' is not a BasePart/Model with PrimaryPart", name))
		return nil
	end

	local function teleportByName(name: string): boolean
		local rootPart = getCharacterRootPart()
		if not rootPart then
			warn("[useWorkspaceTeleports] HumanoidRootPart was not found")
			return false
		end

		local targetCFrame = resolveTeleportTarget(name)
		if not targetCFrame then
			return false
		end

		rootPart.CFrame = targetCFrame
		return true
	end

	local function teleportByIndex(index: number): boolean
		local teleportName = string.format("Teleport_%02d", index)
		return teleportByName(teleportName)
	end

	return {
		teleportByName = teleportByName,
		teleportByIndex = teleportByIndex,
	}
end

return useWorkspaceTeleports

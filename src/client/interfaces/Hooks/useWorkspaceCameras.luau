local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local React = require(ReplicatedStorage.Packages.React)

type CameraState = {
	CameraType: Enum.CameraType,
	CameraSubject: Instance?,
	CFrame: CFrame,
	FieldOfView: number,
}

local function useWorkspaceCameras()
	local localPlayer = Players.LocalPlayer
	local savedStateRef = React.useRef(nil :: CameraState?)

	local function getCurrentCamera(): Camera?
		return Workspace.CurrentCamera
	end

	local function getCamerasFolder(): Folder?
		local folder = Workspace:FindFirstChild("Cameras")
		if folder and folder:IsA("Folder") then
			return folder
		end
		return nil
	end

	local function saveCurrentState(camera: Camera)
		if savedStateRef.current ~= nil then
			return
		end

		savedStateRef.current = {
			CameraType = camera.CameraType,
			CameraSubject = camera.CameraSubject,
			CFrame = camera.CFrame,
			FieldOfView = camera.FieldOfView,
		}
	end

	local function resolveCameraTarget(name: string): CFrame?
		local camerasFolder = getCamerasFolder()
		if not camerasFolder then
			warn("[useWorkspaceCameras] No se encontro Workspace.Cameras")
			return nil
		end

		local target = camerasFolder:FindFirstChild(name)
		if not target then
			warn(string.format("[useWorkspaceCameras] No se encontro la camara '%s'", name))
			return nil
		end

		if target:IsA("Camera") then
			return target.CFrame
		end

		if target:IsA("BasePart") then
			return target.CFrame
		end

		if target:IsA("Model") and target.PrimaryPart then
			return target.PrimaryPart.CFrame
		end

		warn(string.format("[useWorkspaceCameras] '%s' no es Camera/BasePart/Model con PrimaryPart", name))
		return nil
	end

	local function switchToCameraByName(name: string): boolean
		local camera = getCurrentCamera()
		if not camera then
			warn("[useWorkspaceCameras] Workspace.CurrentCamera es nil")
			return false
		end

		local targetCFrame = resolveCameraTarget(name)
		if not targetCFrame then
			return false
		end

		saveCurrentState(camera)
		camera.CameraType = Enum.CameraType.Scriptable
		camera.CFrame = targetCFrame
		return true
	end

	local function switchToCameraByIndex(index: number): boolean
		local cameraName = string.format("Camera_%02d", index)
		return switchToCameraByName(cameraName)
	end

	local function restoreCamera()
		local camera = getCurrentCamera()
		if not camera then
			return
		end

		local savedState = savedStateRef.current
		if savedState then
			camera.CameraType = savedState.CameraType
			camera.CameraSubject = savedState.CameraSubject
			camera.CFrame = savedState.CFrame
			camera.FieldOfView = savedState.FieldOfView
			savedStateRef.current = nil
			return
		end

		camera.CameraType = Enum.CameraType.Custom
		local character = localPlayer.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				camera.CameraSubject = humanoid
			end
		end
	end

	React.useEffect(function()
		local connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed or UserInputService:GetFocusedTextBox() then
				return
			end

			if input.KeyCode == Enum.KeyCode.G then
				restoreCamera()
			end
		end)

		return function()
			connection:Disconnect()
			restoreCamera()
		end
	end, {})

	return {
		switchToCameraByName = switchToCameraByName,
		switchToCameraByIndex = switchToCameraByIndex,
		restoreCamera = restoreCamera,
	}
end

return useWorkspaceCameras

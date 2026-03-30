local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local React = require(ReplicatedStorage.Packages.React)

local FOLLOW_REFRESH_INTERVAL = 0.25
local FOLLOW_SMOOTH_SPEED = 3
local FOLLOW_BOOTSTRAP_DISTANCE = 24

type CameraState = {
	CameraType: Enum.CameraType,
	CameraSubject: Instance?,
	CFrame: CFrame,
	FieldOfView: number,
}

type FollowState = {
	enabled: boolean,
	playersInFront: { Player },
	selectedIndex: number,
	lastRefresh: number,
	lookAtPosition: Vector3?,
}

local function useWorkspaceCameras()
	local localPlayer = Players.LocalPlayer
	local savedStateRef = React.useRef(nil :: CameraState?)
	local anchorCFrameRef = React.useRef(nil :: CFrame?)
	local followStateRef = React.useRef({
		enabled = false,
		playersInFront = {},
		selectedIndex = 1,
		lastRefresh = 0,
		lookAtPosition = nil,
	} :: FollowState)

	local function getCurrentCamera(): Camera?
		return Workspace.CurrentCamera
	end

	local function getCharacterRootPart(player: Player): BasePart?
		local character = player.Character
		if not character then
			return nil
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then
			return nil
		end

		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if rootPart and rootPart:IsA("BasePart") then
			return rootPart
		end

		return nil
	end

	local function resetFollowState()
		followStateRef.current = {
			enabled = false,
			playersInFront = {},
			selectedIndex = 1,
			lastRefresh = 0,
			lookAtPosition = nil,
		}
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

	local function getPlayersInFront(camera: Camera): { Player }
		local cameraPosition = camera.CFrame.Position
		local referenceCFrame = anchorCFrameRef.current or camera.CFrame
		local cameraLook = referenceCFrame.LookVector
		local candidates = {}
		local ignoredInstances = {}
		if localPlayer.Character then
			table.insert(ignoredInstances, localPlayer.Character)
		end

		for _, player in Players:GetPlayers() do
			if player ~= localPlayer and player.Character then
				table.insert(ignoredInstances, player.Character)
			end
		end

		for _, player in Players:GetPlayers() do
			local rootPart = getCharacterRootPart(player)
			if rootPart then
				local offset = rootPart.Position - cameraPosition
				local distance = offset.Magnitude
				if distance > 0.001 then
					local direction = offset.Unit
					local isInFront = direction:Dot(cameraLook) > 0
					if isInFront then
						local rayParams = RaycastParams.new()
						rayParams.FilterType = Enum.RaycastFilterType.Exclude
						rayParams.FilterDescendantsInstances = ignoredInstances
						local rayResult = Workspace:Raycast(cameraPosition, offset, rayParams)

						local hasLineOfSight = rayResult == nil

						if hasLineOfSight then
							table.insert(candidates, {
								player = player,
								distance = distance,
							})
						end
					end
				end
			end
		end

		table.sort(candidates, function(a, b)
			return a.distance < b.distance
		end)

		local playersInFront = {}
		for _, item in candidates do
			table.insert(playersInFront, item.player)
		end

		return playersInFront
	end

	local function refreshFollowTargets()
		local camera = getCurrentCamera()
		if not camera or camera.CameraType ~= Enum.CameraType.Scriptable then
			return
		end

		local state = followStateRef.current
		local selectedPlayer = state.playersInFront[state.selectedIndex]
		local newPlayers = getPlayersInFront(camera)
		state.playersInFront = newPlayers
		state.lastRefresh = os.clock()

		if #newPlayers == 0 then
			state.selectedIndex = 1
			return
		end

		if selectedPlayer then
			for index, player in ipairs(newPlayers) do
				if player == selectedPlayer then
					state.selectedIndex = index
					return
				end
			end
		end

		state.selectedIndex = 1
	end

	local function toggleFollowMode()
		local camera = getCurrentCamera()
		if not camera or camera.CameraType ~= Enum.CameraType.Scriptable then
			warn("[useWorkspaceCameras] Debes estar en una camara de Workspace para usar seguimiento")
			return false
		end

		local state = followStateRef.current
		state.enabled = not state.enabled

		if state.enabled then
			state.lookAtPosition = camera.CFrame.Position + camera.CFrame.LookVector * FOLLOW_BOOTSTRAP_DISTANCE
			refreshFollowTargets()
			if #state.playersInFront == 0 then
				warn("[useWorkspaceCameras] No hay jugadores al frente para seguir")
				state.enabled = false
				state.lookAtPosition = nil
				return false
			end
		else
			state.lookAtPosition = nil
		end

		return state.enabled
	end

	local function cycleFollowTarget(step: number)
		local state = followStateRef.current
		if not state.enabled then
			return
		end

		if #state.playersInFront <= 1 then
			return
		end

		local nextIndex = state.selectedIndex + step
		if nextIndex < 1 then
			nextIndex = #state.playersInFront
		elseif nextIndex > #state.playersInFront then
			nextIndex = 1
		end
		state.selectedIndex = nextIndex
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
		anchorCFrameRef.current = targetCFrame
		resetFollowState()
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

		resetFollowState()
		anchorCFrameRef.current = nil

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
		local inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed or UserInputService:GetFocusedTextBox() then
				return
			end

			if input.KeyCode == Enum.KeyCode.G then
				restoreCamera()
				return
			end

			if input.KeyCode == Enum.KeyCode.X then
				toggleFollowMode()
				return
			end

			if input.KeyCode == Enum.KeyCode.Q then
				cycleFollowTarget(1)
				return
			end

			if input.KeyCode == Enum.KeyCode.E then
				cycleFollowTarget(-1)
			end
		end)

		local renderConnection = RunService.RenderStepped:Connect(function(deltaTime)
			local state = followStateRef.current
			if not state.enabled then
				return
			end

			local camera = getCurrentCamera()
			if not camera or camera.CameraType ~= Enum.CameraType.Scriptable then
				return
			end

			if os.clock() - state.lastRefresh > FOLLOW_REFRESH_INTERVAL then
				refreshFollowTargets()
			end

			local targetPlayer = state.playersInFront[state.selectedIndex]
			if not targetPlayer then
				refreshFollowTargets()
				targetPlayer = state.playersInFront[state.selectedIndex]
				if not targetPlayer then
					state.enabled = false
					return
				end
			end

			local rootPart = getCharacterRootPart(targetPlayer)
			if not rootPart then
				refreshFollowTargets()
				return
			end

			local anchorCFrame = anchorCFrameRef.current or camera.CFrame
			local desiredLookAt = rootPart.Position
			local currentLookAt = state.lookAtPosition
				or (anchorCFrame.Position + anchorCFrame.LookVector * FOLLOW_BOOTSTRAP_DISTANCE)
			local alpha = 1 - math.exp(-FOLLOW_SMOOTH_SPEED * deltaTime)
			state.lookAtPosition = currentLookAt:Lerp(desiredLookAt, alpha)
			camera.CFrame = CFrame.lookAt(anchorCFrame.Position, state.lookAtPosition)
		end)

		return function()
			inputConnection:Disconnect()
			renderConnection:Disconnect()
			resetFollowState()
			restoreCamera()
		end
	end, {})

	return {
		switchToCameraByName = switchToCameraByName,
		switchToCameraByIndex = switchToCameraByIndex,
		restoreCamera = restoreCamera,
		toggleFollowMode = toggleFollowMode,
	}
end

return useWorkspaceCameras

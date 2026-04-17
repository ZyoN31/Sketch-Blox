local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local React = require(ReplicatedStorage.Packages.React)

local FOLLOW_REFRESH_INTERVAL = 0.25
local FOLLOW_SMOOTH_SPEED = 3
local FOLLOW_BOOTSTRAP_DISTANCE = 24
local CHARACTER_ROTATE_SPEED = 5
local CHARACTER_ROTATE_DURATION = 3

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

type CharacterRotateState = {
	isRotating: boolean,
	targetCFrame: CFrame?,
	startCFrame: CFrame?,
	startTime: number,
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
	local characterRotateStateRef = React.useRef({
		isRotating = false,
		targetCFrame = nil,
		startCFrame = nil,
		startTime = 0,
	} :: CharacterRotateState)

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
			warn("[useWorkspaceCameras] Workspace.Cameras was not found")
			return nil
		end

		local target = camerasFolder:FindFirstChild(name)
		if not target then
			warn(string.format("[useWorkspaceCameras] Camera '%s' was not found", name))
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

		warn(string.format("[useWorkspaceCameras] '%s' is not a Camera/BasePart/Model with PrimaryPart", name))
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
			warn("[useWorkspaceCameras] You must be on a Workspace camera to use follow mode")
			return false
		end

		local state = followStateRef.current
		state.enabled = not state.enabled

		if state.enabled then
			state.lookAtPosition = camera.CFrame.Position + camera.CFrame.LookVector * FOLLOW_BOOTSTRAP_DISTANCE
			refreshFollowTargets()
			if #state.playersInFront == 0 then
				warn("[useWorkspaceCameras] No players in front to follow")
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

	local function rotateCharacterTowardCamera()
		local character = localPlayer.Character
		if not character then
			warn("[useWorkspaceCameras] Character was not found")
			return
		end

		local rootPart = getCharacterRootPart(localPlayer)
		if not rootPart then
			warn("[useWorkspaceCameras] HumanoidRootPart was not found")
			return
		end

		local camera = getCurrentCamera()
		if not camera then
			warn("[useWorkspaceCameras] No camera available")
			return
		end

		-- Calculate direction toward the camera.
		local characterPos = rootPart.Position
		local cameraPos = camera.CFrame.Position
		local direction = (cameraPos - characterPos).Unit

		-- Build a CFrame facing the camera.
		local targetCFrame = CFrame.lookAt(characterPos, characterPos + direction)

		local rotateState = characterRotateStateRef.current
		rotateState.isRotating = true
		rotateState.targetCFrame = targetCFrame
		rotateState.startCFrame = rootPart.CFrame
		rotateState.startTime = os.clock()
	end

	local function switchToCameraByName(name: string): boolean
		local camera = getCurrentCamera()
		if not camera then
			warn("[useWorkspaceCameras] Workspace.CurrentCamera is nil")
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
				return
			end

			if input.KeyCode == Enum.KeyCode.L then
				rotateCharacterTowardCamera()
				return
			end
		end)

		local renderConnection = RunService.RenderStepped:Connect(function(deltaTime)
			-- Follow-mode update.
			local state = followStateRef.current
			if state.enabled then
				local camera = getCurrentCamera()
				if camera and camera.CameraType == Enum.CameraType.Scriptable then
					if os.clock() - state.lastRefresh > FOLLOW_REFRESH_INTERVAL then
						refreshFollowTargets()
					end

					local targetPlayer = state.playersInFront[state.selectedIndex]
					if not targetPlayer then
						refreshFollowTargets()
						targetPlayer = state.playersInFront[state.selectedIndex]
						if targetPlayer then
							local rootPart = getCharacterRootPart(targetPlayer)
							if rootPart then
								local anchorCFrame = anchorCFrameRef.current or camera.CFrame
								local desiredLookAt = rootPart.Position
								local currentLookAt = state.lookAtPosition
									or (anchorCFrame.Position + anchorCFrame.LookVector * FOLLOW_BOOTSTRAP_DISTANCE)
								local alpha = 1 - math.exp(-FOLLOW_SMOOTH_SPEED * deltaTime)
								state.lookAtPosition = currentLookAt:Lerp(desiredLookAt, alpha)
								camera.CFrame = CFrame.lookAt(anchorCFrame.Position, state.lookAtPosition)
							end
						else
							state.enabled = false
						end
					else
						local rootPart = getCharacterRootPart(targetPlayer)
						if rootPart then
							local anchorCFrame = anchorCFrameRef.current or camera.CFrame
							local desiredLookAt = rootPart.Position
							local currentLookAt = state.lookAtPosition
								or (anchorCFrame.Position + anchorCFrame.LookVector * FOLLOW_BOOTSTRAP_DISTANCE)
							local alpha = 1 - math.exp(-FOLLOW_SMOOTH_SPEED * deltaTime)
							state.lookAtPosition = currentLookAt:Lerp(desiredLookAt, alpha)
							camera.CFrame = CFrame.lookAt(anchorCFrame.Position, state.lookAtPosition)
						else
							refreshFollowTargets()
						end
					end
				end
			end

			-- Character rotation update.
			local rotateState = characterRotateStateRef.current
			if rotateState.isRotating then
				local character = localPlayer.Character
				if character then
					local rootPart = getCharacterRootPart(localPlayer)
					if rootPart and rotateState.targetCFrame and rotateState.startCFrame then
						local elapsed = os.clock() - rotateState.startTime
						local progress = math.min(elapsed / CHARACTER_ROTATE_DURATION, 1)

						-- Smooth interpolation with easing.
						local easeProgress
						if progress < 0.5 then
							easeProgress = 2 * progress * progress
						else
							easeProgress = 1 - 2 * (1 - progress) * (1 - progress)
						end

						-- Direct CFrame interpolation avoids Euler-angle issues.
						local charPosition = rootPart.Position
						local startCF = rotateState.startCFrame
						local targetCF = rotateState.targetCFrame

						-- Extract target Y rotation only.
						local _, targetY, _ = targetCF:ToEulerAnglesXYZ()
						local currentX, currentY, currentZ = rootPart.CFrame:ToEulerAnglesXYZ()

						-- Interpolate angular delta on the shortest path.
						local angleDiff = targetY - currentY
						if angleDiff > math.pi then
							angleDiff = angleDiff - 2 * math.pi
						elseif angleDiff < -math.pi then
							angleDiff = angleDiff + 2 * math.pi
						end

						local newY = currentY + angleDiff * easeProgress

						rootPart.CFrame = CFrame.new(charPosition) * CFrame.Angles(currentX, newY, currentZ)

						if progress >= 1 then
							rotateState.isRotating = false
						end
					else
						rotateState.isRotating = false
					end
				else
					rotateState.isRotating = false
				end
			end
		end)

		return function()
			inputConnection:Disconnect()
			renderConnection:Disconnect()
			resetFollowState()
			characterRotateStateRef.current = {
				isRotating = false,
				targetCFrame = nil,
				startCFrame = nil,
				startTime = 0,
			}
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

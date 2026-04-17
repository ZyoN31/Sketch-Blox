local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local SCENE_MOVEMENTS_FOLDER_NAME = "SceneMovements"

type CameraSessionState = {
	active: boolean,
	canceled: boolean,
	savedCameraType: Enum.CameraType?,
	savedCameraSubject: Instance?,
	savedCFrame: CFrame?,
	savedFieldOfView: number?,
}

local function getCurrentCamera(): Camera?
	return Workspace.CurrentCamera
end

local function getSceneMovementsFolder(): Folder?
	local folder = Workspace:FindFirstChild(SCENE_MOVEMENTS_FOLDER_NAME)
	if folder and folder:IsA("Folder") then
		return folder
	end
	return nil
end

local function resolveSceneFolder(sceneName: string): Folder?
	local sceneMovements = getSceneMovementsFolder()
	if not sceneMovements then
		warn("[useSceneMovements] Workspace.SceneMovements was not found")
		return nil
	end

	local sceneFolder = sceneMovements:FindFirstChild(sceneName)
	if sceneFolder and sceneFolder:IsA("Folder") then
		return sceneFolder
	end

	warn(string.format("[useSceneMovements] Scene '%s' was not found", sceneName))
	return nil
end

local function getSortedPointNames(sceneName: string): { string }
	local sceneFolder = resolveSceneFolder(sceneName)
	if not sceneFolder then
		return {}
	end

	local names = {}
	for _, child in sceneFolder:GetChildren() do
		if child:IsA("Camera") or child:IsA("BasePart") or child:IsA("Model") then
			table.insert(names, child.Name)
		end
	end
	table.sort(names, function(a, b)
		return a < b
	end)
	return names
end

local function resolvePointName(sceneName: string, pointRef: any): string?
	local pointNames = getSortedPointNames(sceneName)
	if #pointNames == 0 then
		return nil
	end

	if type(pointRef) == "number" then
		local index = math.floor(pointRef)
		if index >= 1 and index <= #pointNames then
			return pointNames[index]
		end
		return nil
	end

	if type(pointRef) ~= "string" then
		return nil
	end

	local directName = pointRef
	if table.find(pointNames, directName) then
		return directName
	end

	local lowerRef = string.lower(directName)
	for _, pointName in ipairs(pointNames) do
		if string.lower(pointName) == lowerRef then
			return pointName
		end
	end

	return nil
end

local function resolvePointCFrame(sceneName: string, pointName: string): CFrame?
	local sceneFolder = resolveSceneFolder(sceneName)
	if not sceneFolder then
		return nil
	end

	local point = sceneFolder:FindFirstChild(pointName)
	if not point then
		warn(string.format("[useSceneMovements] Point '%s' was not found in %s", pointName, sceneName))
		return nil
	end

	if point:IsA("Camera") then
		return point.CFrame
	end

	if point:IsA("BasePart") then
		return point.CFrame
	end

	if point:IsA("Model") and point.PrimaryPart then
		return point.PrimaryPart.CFrame
	end

	warn(string.format("[useSceneMovements] '%s' is not a Camera/BasePart/Model with PrimaryPart", pointName))
	return nil
end

local function tweenCameraLinear(
	fromCFrame: CFrame,
	toCFrame: CFrame,
	duration: number,
	shouldStop: (() -> boolean)?
): boolean
	local camera = getCurrentCamera()
	if not camera then
		warn("[useSceneMovements] Workspace.CurrentCamera is nil")
		return false
	end

	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = fromCFrame

	if duration <= 0 then
		camera.CFrame = toCFrame
		return true
	end

	if
		(fromCFrame.Position - toCFrame.Position).Magnitude < 0.001
		and fromCFrame.LookVector:Dot(toCFrame.LookVector) > 0.999
	then
		task.wait(duration)
		camera.CFrame = toCFrame
		return true
	end

	local cframeValue = Instance.new("CFrameValue")
	cframeValue.Value = fromCFrame

	local completed = false
	local connection = cframeValue:GetPropertyChangedSignal("Value"):Connect(function()
		local currentCamera = getCurrentCamera()
		if currentCamera and currentCamera.CameraType == Enum.CameraType.Scriptable then
			currentCamera.CFrame = cframeValue.Value
		end
	end)

	local tween =
		TweenService:Create(cframeValue, TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {
			Value = toCFrame,
		})

	tween.Completed:Connect(function()
		completed = true
	end)
	tween:Play()

	while not completed do
		if shouldStop and shouldStop() then
			tween:Cancel()
			connection:Disconnect()
			cframeValue:Destroy()
			return false
		end
		task.wait()
	end

	connection:Disconnect()
	cframeValue:Destroy()
	camera.CFrame = toCFrame
	return true
end

local function useSceneMovements()
	local sessionStateRef = {
		active = false,
		canceled = false,
		savedCameraType = nil,
		savedCameraSubject = nil,
		savedCFrame = nil,
		savedFieldOfView = nil,
	} :: CameraSessionState

	local function beginSession(): boolean
		if sessionStateRef.active then
			return true
		end

		local camera = getCurrentCamera()
		if not camera then
			warn("[useSceneMovements] Could not start session: CurrentCamera is nil")
			return false
		end

		sessionStateRef.active = true
		sessionStateRef.canceled = false
		sessionStateRef.savedCameraType = camera.CameraType
		sessionStateRef.savedCameraSubject = camera.CameraSubject
		sessionStateRef.savedCFrame = camera.CFrame
		sessionStateRef.savedFieldOfView = camera.FieldOfView
		return true
	end

	local function restoreSessionCamera()
		local camera = getCurrentCamera()
		if not camera then
			return
		end

		if sessionStateRef.savedCameraType then
			camera.CameraType = sessionStateRef.savedCameraType
		end
		camera.CameraSubject = sessionStateRef.savedCameraSubject
		if sessionStateRef.savedCFrame then
			camera.CFrame = sessionStateRef.savedCFrame
		end
		if sessionStateRef.savedFieldOfView then
			camera.FieldOfView = sessionStateRef.savedFieldOfView
		end
	end

	local function closeSession(restoreCamera: boolean)
		if sessionStateRef.active and restoreCamera then
			restoreSessionCamera()
		end

		sessionStateRef.active = false
		sessionStateRef.canceled = false
		sessionStateRef.savedCameraType = nil
		sessionStateRef.savedCameraSubject = nil
		sessionStateRef.savedCFrame = nil
		sessionStateRef.savedFieldOfView = nil
	end

	local function endSession(): boolean
		if not sessionStateRef.active then
			return false
		end

		sessionStateRef.canceled = true
		closeSession(true)
		return true
	end

	local function discardSession()
		if not sessionStateRef.active then
			return
		end

		closeSession(false)
	end

	local function playMovement(sceneName: string, duration: number, fromPoint: any, toPoint: any): boolean
		if not sessionStateRef.active then
			beginSession()
		end

		if sessionStateRef.canceled then
			return false
		end

		if type(sceneName) ~= "string" or sceneName == "" then
			warn("[useSceneMovements] Invalid sceneName")
			return false
		end

		if type(duration) ~= "number" then
			warn("[useSceneMovements] duration must be a number")
			return false
		end

		if duration ~= duration then
			warn("[useSceneMovements] duration is NaN")
			return false
		end

		local resolvedFromPoint = resolvePointName(sceneName, fromPoint)
		if not resolvedFromPoint then
			local names = getSortedPointNames(sceneName)
			warn(
				string.format(
					"[useSceneMovements] Invalid start point '%s' in %s. Available: %s",
					tostring(fromPoint),
					sceneName,
					table.concat(names, ", ")
				)
			)
			return false
		end

		local resolvedToPoint = resolvePointName(sceneName, toPoint)
		if not resolvedToPoint then
			local names = getSortedPointNames(sceneName)
			warn(
				string.format(
					"[useSceneMovements] Invalid destination point '%s' in %s. Available: %s",
					tostring(toPoint),
					sceneName,
					table.concat(names, ", ")
				)
			)
			return false
		end

		local fromCFrame = resolvePointCFrame(sceneName, resolvedFromPoint)
		if not fromCFrame then
			return false
		end

		local toCFrame = resolvePointCFrame(sceneName, resolvedToPoint)
		if not toCFrame then
			return false
		end

		return tweenCameraLinear(fromCFrame, toCFrame, math.max(duration, 0), function()
			return sessionStateRef.canceled
		end)
	end

	local function getSceneNames(): { string }
		local sceneMovements = getSceneMovementsFolder()
		if not sceneMovements then
			return {}
		end

		local names = {}
		for _, child in sceneMovements:GetChildren() do
			if child:IsA("Folder") then
				table.insert(names, child.Name)
			end
		end

		table.sort(names, function(a, b)
			return a < b
		end)
		return names
	end

	return {
		beginSession = beginSession,
		endSession = endSession,
		discardSession = discardSession,
		playMovement = playMovement,
		getSceneNames = getSceneNames,
		getSortedPointNames = getSortedPointNames,
	}
end

return useSceneMovements

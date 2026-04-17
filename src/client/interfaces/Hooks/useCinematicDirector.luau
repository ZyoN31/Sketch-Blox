local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.Packages.React)

local useSceneMovements = require(script.Parent.useSceneMovements)
local CinematicScenes = require(script.Parent.Parent.Modules.CinematicScenes)

local PRE_ROLL_SECONDS = 3
local EXTRA_BUFFER_SECONDS = 1

local function useCinematicDirector()
	local sceneMovements = useSceneMovements()
	local countdownText, setCountdownText = React.useState(nil :: string?)
	local activeSceneName, setActiveSceneName = React.useState(nil :: string?)
	local isPlayingRef = React.useRef(false)

	local function getSceneNames(): { string }
		local names = {}
		for sceneName, runner in CinematicScenes do
			if type(sceneName) == "string" and type(runner) == "function" then
				table.insert(names, sceneName)
			end
		end

		table.sort(names, function(a, b)
			return a < b
		end)

		if #names > 0 then
			return names
		end

		return sceneMovements.getSceneNames()
	end

	local function isPlaying(): boolean
		return isPlayingRef.current
	end

	local function playScene(sceneName: string): boolean
		if isPlayingRef.current then
			warn("[useCinematicDirector] A scene is already playing")
			return false
		end

		local sceneRunner = CinematicScenes[sceneName]
		if type(sceneRunner) ~= "function" then
			warn(string.format("[useCinematicDirector] No choreography exists for '%s'", sceneName))
			return false
		end

		isPlayingRef.current = true
		setActiveSceneName(sceneName)

		task.spawn(function()
			local endedRef = { value = false }
			sceneMovements.beginSession()
			local currentSceneName = sceneName

			local function endSceneNow(): boolean
				if endedRef.value then
					return false
				end

				endedRef.value = true
				return sceneMovements.endSession()
			end

			for seconds = PRE_ROLL_SECONDS, 1, -1 do
				setCountdownText(string.format("Scene starts in %d", seconds))
				task.wait(1)
			end

			setCountdownText("Ready...")
			task.wait(EXTRA_BUFFER_SECONDS)
			setCountdownText(nil)

			local api = {
				move = function(a: any, b: any, c: any, d: any): boolean
					if endedRef.value then
						return false
					end

					local movementSceneName
					local duration
					local fromPoint
					local toPoint

					if d == nil then
						movementSceneName = currentSceneName
						duration = a
						fromPoint = b
						toPoint = c
					else
						movementSceneName = a
						duration = b
						fromPoint = c
						toPoint = d
					end

					if type(duration) ~= "number" then
						error(
							string.format(
								"[useCinematicDirector] Invalid duration in scene '%s': %s",
								currentSceneName,
								tostring(duration)
							)
						)
					end

					local ok = sceneMovements.playMovement(movementSceneName, duration, fromPoint, toPoint)
					if not ok then
						error(
							string.format(
								"[useCinematicDirector] Move failed in '%s' (%s -> %s)",
								tostring(movementSceneName),
								tostring(fromPoint),
								tostring(toPoint)
							)
						)
					end

					return true
				end,
				wait = function(seconds: number)
					if endedRef.value then
						return false
					end

					if type(seconds) ~= "number" then
						error(
							string.format(
								"[useCinematicDirector] Invalid wait value in scene '%s': %s",
								currentSceneName,
								tostring(seconds)
							)
						)
					end

					local remaining = math.max(seconds, 0)
					while remaining > 0 do
						if endedRef.value then
							return false
						end

						local step = math.min(remaining, 0.1)
						task.wait(step)
						remaining -= step
					end

					return true
				end,
				["end"] = function(): boolean
					return endSceneNow()
				end,
				endScene = function(): boolean
					return endSceneNow()
				end,
			}

			local ok, err = pcall(function()
				sceneRunner(api)
			end)

			if not ok then
				warn(string.format("[useCinematicDirector] Error in scene '%s': %s", sceneName, tostring(err)))
			end

			if not endedRef.value then
				sceneMovements.discardSession()
			end

			isPlayingRef.current = false
			setActiveSceneName(nil)
			setCountdownText(nil)
		end)

		return true
	end

	return {
		playScene = playScene,
		countdownText = countdownText,
		activeSceneName = activeSceneName,
		isPlaying = isPlaying,
		getSceneNames = getSceneNames,
	}
end

return useCinematicDirector

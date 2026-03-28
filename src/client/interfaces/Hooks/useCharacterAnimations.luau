local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local React = require(ReplicatedStorage.Packages.React)

local REMOTES_FOLDER_NAME = "SketchBloxRemotes"
local PLAY_ANIMATION_EVENT_NAME = "PlayCharacterAnimation"

local KEY_TO_SLOT = {
	[Enum.KeyCode.One] = 1,
	[Enum.KeyCode.Two] = 2,
	[Enum.KeyCode.Three] = 3,
	[Enum.KeyCode.Four] = 4,
	[Enum.KeyCode.Five] = 5,
}

local function useCharacterAnimations()
	local function getPlayAnimationEvent(): RemoteEvent?
		local remotesFolder = ReplicatedStorage:FindFirstChild(REMOTES_FOLDER_NAME)
		if not remotesFolder then
			return nil
		end

		local remote = remotesFolder:FindFirstChild(PLAY_ANIMATION_EVENT_NAME)
		if remote and remote:IsA("RemoteEvent") then
			return remote
		end

		return nil
	end

	local function playAnimationBySlot(slot: number): boolean
		local remoteEvent = getPlayAnimationEvent()
		if not remoteEvent then
			warn("[useCharacterAnimations] No se encontro RemoteEvent de animaciones")
			return false
		end

		if type(slot) ~= "number" then
			return false
		end

		remoteEvent:FireServer(slot)
		return true
	end

	React.useEffect(function()
		local connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed or UserInputService:GetFocusedTextBox() then
				return
			end

			local slot = KEY_TO_SLOT[input.KeyCode]
			if slot then
				playAnimationBySlot(slot)
			end
		end)

		return function()
			connection:Disconnect()
		end
	end, {})

	return {
		playAnimationBySlot = playAnimationBySlot,
	}
end

return useCharacterAnimations

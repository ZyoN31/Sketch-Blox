local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TaggedVisibilityModule = require(script.modules.TaggedVisibilityModule)

local REMOTES_FOLDER_NAME = "SketchBloxRemotes"
local PLAY_ANIMATION_EVENT_NAME = "PlayCharacterAnimation"

local ANIMATION_BY_SLOT = {
	[1] = "rbxassetid://507771019",
	[2] = "rbxassetid://507770677",
	[3] = "rbxassetid://507770453",
}

local activeTracksByPlayer = {}

TaggedVisibilityModule.SetUp_InvisibilityBlocks()

local function ensureRemotesFolder(): Folder
	local folder = ReplicatedStorage:FindFirstChild(REMOTES_FOLDER_NAME)
	if folder and folder:IsA("Folder") then
		return folder
	end

	folder = Instance.new("Folder")
	folder.Name = REMOTES_FOLDER_NAME
	folder.Parent = ReplicatedStorage
	return folder
end

local function ensurePlayAnimationEvent(parentFolder: Folder): RemoteEvent
	local remote = parentFolder:FindFirstChild(PLAY_ANIMATION_EVENT_NAME)
	if remote and remote:IsA("RemoteEvent") then
		return remote
	end

	remote = Instance.new("RemoteEvent")
	remote.Name = PLAY_ANIMATION_EVENT_NAME
	remote.Parent = parentFolder
	return remote
end

local remotesFolder = ensureRemotesFolder()
local playAnimationEvent = ensurePlayAnimationEvent(remotesFolder)

local function stopCurrentTrack(player: Player)
	local currentTrack = activeTracksByPlayer[player]
	if currentTrack then
		pcall(function()
			currentTrack:Stop(0.15)
			currentTrack:Destroy()
		end)
		activeTracksByPlayer[player] = nil
	end
end

local function getAnimatorFromCharacter(character: Model): Animator?
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return nil
	end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if animator then
		return animator
	end

	animator = Instance.new("Animator")
	animator.Parent = humanoid
	return animator
end

playAnimationEvent.OnServerEvent:Connect(function(player: Player, slot: number)
	if type(slot) ~= "number" then
		return
	end

	local animationId = ANIMATION_BY_SLOT[slot]
	if not animationId then
		return
	end

	local character = player.Character
	if not character then
		return
	end

	local animator = getAnimatorFromCharacter(character)
	if not animator then
		return
	end

	stopCurrentTrack(player)

	local animation = Instance.new("Animation")
	animation.AnimationId = animationId

	local ok, track = pcall(function()
		return animator:LoadAnimation(animation)
	end)

	animation:Destroy()

	if not ok or not track then
		return
	end

	track.Priority = Enum.AnimationPriority.Action
	track.Looped = false
	track:Play(0.15, 1, 1)

	activeTracksByPlayer[player] = track

	track.Stopped:Connect(function()
		if activeTracksByPlayer[player] == track then
			activeTracksByPlayer[player] = nil
		end
		track:Destroy()
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	stopCurrentTrack(player)
end)

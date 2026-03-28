local ReplicatedStorage = game:GetService("ReplicatedStorage")

local App = require(script.Parent.Parent.App)
local React = require(ReplicatedStorage.Packages.React)
local ReactRoblox = require(ReplicatedStorage.Packages.ReactRoblox)

local e = React.createElement

return function(parent)
	local root = ReactRoblox.createRoot(parent)
	local app = e(App)
	root:render(app)

	return function()
		root:unmount()
	end
end

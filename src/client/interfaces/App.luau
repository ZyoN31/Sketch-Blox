local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local SidebarLayout = require(script.Parent.Layout.SidebarLayout)

local e = React.createElement

local function AppUI()
	return e(SidebarLayout)
end

return AppUI

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local SidebarLayout = require(script.Parent.Parent.Layout.SidebarLayout)

local e = React.createElement

local function SidebarPage()
	return e(SidebarLayout)
end

return SidebarPage

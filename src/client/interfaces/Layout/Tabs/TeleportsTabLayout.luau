local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local SidebarButton = require(script.Parent.Parent.Parent.Components.SidebarButton)

local e = React.createElement

type TeleportsTabLayoutProps = {
	teleportHook: any,
	buttonPrimary: Color3,
	buttonSecondary: Color3,
	buttonStroke: Color3,
	buttonText: Color3,
	sectionTextColor: Color3,
}

local function TeleportsTabLayout(props: TeleportsTabLayoutProps)
	return e("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		UIListLayout = e("UIListLayout", {
			Padding = UDim.new(0, 10),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
		}),

		SectionTeleports = e("TextLabel", {
			Text = "TELEPORTS",
			FontFace = Font.new("rbxasset://fonts/families/Kanit.json", Enum.FontWeight.Bold),
			TextSize = 14,
			TextColor3 = props.sectionTextColor,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(0.9, 0.06),
			LayoutOrder = 1,
		}),

		TeleportButton1 = e(SidebarButton, {
			Text = "Tp_Z1",
			ColorPrimary = props.buttonPrimary,
			ColorSecondary = props.buttonSecondary,
			ColorStroke = props.buttonStroke,
			TextColor = props.buttonText,
			LayoutOrder = 2,
			OnClick = function()
				props.teleportHook.teleportByIndex(1)
			end,
		}),

		TeleportButton2 = e(SidebarButton, {
			Text = "Tp_Z2",
			ColorPrimary = props.buttonPrimary,
			ColorSecondary = props.buttonSecondary,
			ColorStroke = props.buttonStroke,
			TextColor = props.buttonText,
			LayoutOrder = 3,
			OnClick = function()
				props.teleportHook.teleportByIndex(2)
			end,
		}),

		TeleportButton3 = e(SidebarButton, {
			Text = "Tp_Z3",
			ColorPrimary = props.buttonPrimary,
			ColorSecondary = props.buttonSecondary,
			ColorStroke = props.buttonStroke,
			TextColor = props.buttonText,
			LayoutOrder = 4,
			OnClick = function()
				props.teleportHook.teleportByIndex(3)
			end,
		}),
	})
end

return TeleportsTabLayout

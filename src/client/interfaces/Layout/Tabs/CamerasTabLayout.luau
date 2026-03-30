local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local SidebarButton = require(script.Parent.Parent.Parent.Components.SidebarButton)

local e = React.createElement

type CamerasTabLayoutProps = {
	cameraHook: any,
	buttonPrimary: Color3,
	buttonSecondary: Color3,
	buttonStroke: Color3,
	buttonText: Color3,
	sectionTextColor: Color3,
}

local function CamerasTabLayout(props: CamerasTabLayoutProps)
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

		SectionCameras = e("TextLabel", {
			Text = "CAMARAS",
			FontFace = Font.new("rbxasset://fonts/families/Kanit.json", Enum.FontWeight.Bold),
			TextSize = 14,
			TextColor3 = props.sectionTextColor,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(0.9, 0.06),
			LayoutOrder = 1,
		}),

		CameraButton1 = e(SidebarButton, {
			Text = "Cam_Z1",
			ColorPrimary = props.buttonPrimary,
			ColorSecondary = props.buttonSecondary,
			ColorStroke = props.buttonStroke,
			TextColor = props.buttonText,
			LayoutOrder = 2,
			OnClick = function()
				props.cameraHook.switchToCameraByIndex(1)
			end,
		}),

		CameraButton2 = e(SidebarButton, {
			Text = "Cam_Z2",
			ColorPrimary = props.buttonPrimary,
			ColorSecondary = props.buttonSecondary,
			ColorStroke = props.buttonStroke,
			TextColor = props.buttonText,
			LayoutOrder = 3,
			OnClick = function()
				props.cameraHook.switchToCameraByIndex(2)
			end,
		}),

		CameraButton3 = e(SidebarButton, {
			Text = "Cam_Z3",
			ColorPrimary = props.buttonPrimary,
			ColorSecondary = props.buttonSecondary,
			ColorStroke = props.buttonStroke,
			TextColor = props.buttonText,
			LayoutOrder = 4,
			OnClick = function()
				props.cameraHook.switchToCameraByIndex(3)
			end,
		}),
	})
end

return CamerasTabLayout

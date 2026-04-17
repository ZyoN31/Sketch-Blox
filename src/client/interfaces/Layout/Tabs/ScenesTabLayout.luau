local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local SidebarButton = require(script.Parent.Parent.Parent.Components.SidebarButton)

local e = React.createElement

type ScenesTabLayoutProps = {
	cinematicDirector: any,
	sceneNames: { string },
	isScenePlaying: boolean,
	buttonPrimary: Color3,
	buttonSecondary: Color3,
	buttonStroke: Color3,
	buttonText: Color3,
	sectionTextColor: Color3,
}

local function ScenesTabLayout(props: ScenesTabLayoutProps)
	local children = {
		UIListLayout = e("UIListLayout", {
			Padding = UDim.new(0, 10),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,
		}),

		SectionScenes = e("TextLabel", {
			Text = "SCENES",
			FontFace = Font.new("rbxasset://fonts/families/Kanit.json", Enum.FontWeight.Bold),
			TextSize = 14,
			TextColor3 = props.sectionTextColor,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(0.9, 0.06),
			LayoutOrder = 1,
		}),
	}

	if #props.sceneNames == 0 then
		children.EmptyScenes = e("TextLabel", {
			Text = "No scenes defined in Modules/CinematicScenes",
			FontFace = Font.new("rbxasset://fonts/families/Kanit.json", Enum.FontWeight.Medium),
			TextSize = 12,
			TextColor3 = Color3.fromRGB(185, 185, 185),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(0.9, 0.08),
			LayoutOrder = 2,
		})
	else
		for index, sceneName in ipairs(props.sceneNames) do
			children["SceneButton_" .. sceneName] = e(SidebarButton, {
				Text = sceneName,
				ColorPrimary = props.buttonPrimary,
				ColorSecondary = props.buttonSecondary,
				ColorStroke = props.buttonStroke,
				TextColor = props.buttonText,
				Disabled = props.isScenePlaying,
				LayoutOrder = index + 1,
				OnClick = function()
					props.cinematicDirector.playScene(sceneName)
				end,
			})
		end
	end

	return e("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, children)
end

return ScenesTabLayout

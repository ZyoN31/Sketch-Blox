local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local SidebarButton = require(script.Parent.Parent.Parent.Components.SidebarButton)

local e = React.createElement

type AnimationsTabLayoutProps = {
	animationHook: any,
	buttonPrimary: Color3,
	buttonSecondary: Color3,
	buttonStroke: Color3,
	buttonText: Color3,
	sectionTextColor: Color3,
}

local function AnimationsTabLayout(props: AnimationsTabLayoutProps)
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

		SectionAnims = e("TextLabel", {
			Text = "ANIMACIONES",
			FontFace = Font.new("rbxasset://fonts/families/Kanit.json", Enum.FontWeight.Bold),
			TextSize = 14,
			TextColor3 = props.sectionTextColor,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(0.9, 0.06),
			LayoutOrder = 1,
		}),

		AnimButton1 = e(SidebarButton, {
			Text = "Anim_1",
			ColorPrimary = props.buttonPrimary,
			ColorSecondary = props.buttonSecondary,
			ColorStroke = props.buttonStroke,
			TextColor = props.buttonText,
			LayoutOrder = 2,
			OnClick = function()
				props.animationHook.playAnimationBySlot(1)
			end,
		}),

		AnimButton2 = e(SidebarButton, {
			Text = "Anim_2",
			ColorPrimary = props.buttonPrimary,
			ColorSecondary = props.buttonSecondary,
			ColorStroke = props.buttonStroke,
			TextColor = props.buttonText,
			LayoutOrder = 3,
			OnClick = function()
				props.animationHook.playAnimationBySlot(2)
			end,
		}),

		AnimButton3 = e(SidebarButton, {
			Text = "Anim_3",
			ColorPrimary = props.buttonPrimary,
			ColorSecondary = props.buttonSecondary,
			ColorStroke = props.buttonStroke,
			TextColor = props.buttonText,
			LayoutOrder = 4,
			OnClick = function()
				props.animationHook.playAnimationBySlot(3)
			end,
		}),
	})
end

return AnimationsTabLayout

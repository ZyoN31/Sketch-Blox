--[[
	SidebarButton.luau
	Sidebar button component with TweenService animations.
	Includes: hover effects, click animations, smooth transitions
	Path: sketch-blox/src/client/interfaces/Components/SidebarButton.luau
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local ReactRipple = require(ReplicatedStorage.Packages.Ripple)

local e = React.createElement

type SidebarButtonProps = {
	Text: string,
	Icon: string?,
	ColorPrimary: Color3,
	ColorSecondary: Color3,
	ColorStroke: Color3,
	TextColor: Color3?,
	OnClick: (() -> ())?,
	Disabled: boolean?,
	LayoutOrder: number?,
}

local function SidebarButton(props: SidebarButtonProps)
	local scaleBinding, motion = ReactRipple.useSpring(1, {
		tension = 180,
		friction = 12,
	})

	local color1 = props.Disabled and Color3.fromRGB(181, 181, 181) or props.ColorPrimary
	local color2 = props.Disabled and Color3.fromRGB(120, 120, 120) or props.ColorSecondary
	local strokeColor = props.Disabled and Color3.fromRGB(66, 66, 66) or props.ColorStroke

	return e("TextButton", {
		Text = props.Text,
		FontFace = Font.new("rbxasset://fonts/families/Kanit.json", Enum.FontWeight.SemiBold),

		Size = scaleBinding:map(function(s)
			return UDim2.fromScale(0.85 * s, 0.06 * s)
		end),

		AnchorPoint = Vector2.new(0, 0.5),
		TextScaled = true,
		TextColor3 = props.Disabled and Color3.fromRGB(180, 180, 180)
			or props.TextColor
			or Color3.fromRGB(255, 255, 255),
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromRGB(35, 35, 35),
		LayoutOrder = props.LayoutOrder or 0,

		[React.Event.MouseEnter] = function()
			if not props.Disabled then
				motion:setGoal(1.05)
			else
				motion:setGoal(1.02)
			end
		end,

		[React.Event.MouseLeave] = function()
			motion:setGoal(1)
		end,

		[React.Event.Activated] = function()
			if props.Disabled then
				motion:setGoal(1.05)
				task.delay(0.1, function()
					motion:setGoal(1)
				end)
			else
				motion:setGoal(0.95)
				if props.OnClick then
					props.OnClick()
				end
				task.delay(0.15, function()
					motion:setGoal(1)
				end)
			end
		end,
	}, {
		UICorner = e("UICorner", { CornerRadius = UDim.new(0, 8) }),

		UIGradient = e("UIGradient", {
			Rotation = 90,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, color1),
				ColorSequenceKeypoint.new(1, color2),
			}),
		}),

		UIStroke = e("UIStroke", { Thickness = 2, Color = strokeColor }),

		-- Text padding
		UIPadding = e("UIPadding", {
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
			PaddingTop = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
		}),
	})
end

return SidebarButton

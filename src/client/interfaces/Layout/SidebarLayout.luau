--[[
	SidebarLayout.luau
	Layout principal del sidebar con animaciones de despliegue/escondimiento
	Incluye: UserInputService logic (R para toggle, H para modo grabación)
	Tematización dinámica basada en UserId
	Path: sketch-blox/src/client/interfaces/Layout/SidebarLayout.luau
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
local TweenService = game:GetService("TweenService")

local SidebarButton = require(script.Parent.Parent.Components.SidebarButton)
local useSidebarState = require(script.Parent.Parent.Hooks.useSidebarState)
local Themes = require(script.Parent.Parent.Themes)

local e = React.createElement

type SidebarLayoutProps = {
	children: any?,
}

local function SidebarLayout(props: SidebarLayoutProps)
	local theme = Themes.getTheme()
	local sidebarState = useSidebarState()

	-- Referencias para animación
	local containerRef = React.useRef(nil)
	local screenGuiRef = React.useRef(nil)
	local isAnimating, setIsAnimating = React.useState(false)
	local sidebarWidthScale = 0.16

	-- Effect para animar el sidebar cuando cambia visibilidad
	React.useEffect(function()
		local container = containerRef.current
		if not container then
			return
		end

		if isAnimating then
			return
		end

		setIsAnimating(true)

		local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut, 0, false, 0)

		local targetPosition = sidebarState.sidebarVisible and UDim2.fromScale(0, 0)
			or UDim2.fromScale(-sidebarWidthScale, 0)
		local tween = TweenService:Create(container, tweenInfo, { Position = targetPosition })

		tween.Completed:Connect(function()
			setIsAnimating(false)
		end)

		tween:Play()

		return function()
			if tween and tween.PlaybackState == Enum.PlaybackState.Playing then
				tween:Cancel()
			end
		end
	end, { sidebarState.sidebarVisible })

	React.useEffect(function()
		local container = containerRef.current
		if not container then
			return
		end

		screenGuiRef.current = container:FindFirstAncestorOfClass("ScreenGui")
		local screenGui = screenGuiRef.current
		if screenGui then
			screenGui.Enabled = not sidebarState.uiHidden
		end
	end, { sidebarState.uiHidden })

	return e("Frame", {
		Name = "SidebarContainer",
		Size = UDim2.fromScale(sidebarWidthScale, 1),
		Position = UDim2.fromScale(0, 0),
		AnchorPoint = Vector2.new(0, 0),
		BackgroundColor3 = theme.SidebarBg,
		BorderSizePixel = 0,
		ref = function(instance)
			containerRef.current = instance
		end,
	}, {
		-- Gradiente de fondo
		UIGradient = e("UIGradient", {
			Rotation = -90,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, theme.Primary),
				ColorSequenceKeypoint.new(1, theme.Secondary),
			}),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.15),
				NumberSequenceKeypoint.new(1, 0.15),
			}),
		}),

		-- Borde decorativo derecho
		UIStroke = e("UIStroke", {
			Thickness = 2,
			Color = theme.Stroke,
			Transparency = 0.3,
		}),

		-- Glow effect (UICorner en el borde derecho)
		UICorner = e("UICorner", {
			CornerRadius = UDim.new(0, 0),
		}),

		-- Padding general dentro del sidebar
		UIPadding = e("UIPadding", {
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
			PaddingTop = UDim.new(0, 16),
			PaddingBottom = UDim.new(0, 16),
		}),

		-- Contenedor de botones con layout automático
		ButtonsContainer = e("Frame", {
			Name = "ButtonsContainer",
			Size = UDim2.fromScale(1, 0.8),
			Position = UDim2.fromScale(0, 0),
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

			-- Botón de ejemplo 1
			Button1 = e(SidebarButton, {
				Text = "Herramienta 1",
				ColorPrimary = theme.Primary,
				ColorSecondary = theme.Secondary,
				ColorStroke = theme.Stroke,
				LayoutOrder = 1,
				OnClick = function()
					print("Herramienta 1 presionada")
				end,
			}),

			-- Botón de ejemplo 2
			Button2 = e(SidebarButton, {
				Text = "Herramienta 2",
				ColorPrimary = theme.Accent,
				ColorSecondary = theme.Secondary,
				ColorStroke = theme.Stroke,
				LayoutOrder = 2,
				OnClick = function()
					print("Herramienta 2 presionada")
				end,
			}),

			-- Botón de ejemplo 3
			Button3 = e(SidebarButton, {
				Text = "Configuración",
				ColorPrimary = theme.Primary,
				ColorSecondary = theme.Secondary,
				ColorStroke = theme.Stroke,
				LayoutOrder = 3,
				OnClick = function()
					print("Configuración presionada")
				end,
			}),
		}),

		-- Footer con información
		Footer = e("Frame", {
			Name = "FooterInfo",
			Size = UDim2.fromScale(1, 0.1),
			Position = UDim2.fromScale(0, 0.9),
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			InfoText = e("TextLabel", {
				Text = "(R) Toggle | (H) Hide",
				FontFace = Font.new("rbxasset://fonts/families/Kanit.json", Enum.FontWeight.Regular),
				TextSize = 11,
				TextColor3 = Color3.fromRGB(180, 180, 180),
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				TextScaled = false,
				TextWrapped = true,
				BorderSizePixel = 0,
			}),
		}),
	})
end

return SidebarLayout

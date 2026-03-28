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
local useWorkspaceCameras = require(script.Parent.Parent.Hooks.useWorkspaceCameras)
local useCharacterAnimations = require(script.Parent.Parent.Hooks.useCharacterAnimations)
local useWorkspaceTeleports = require(script.Parent.Parent.Hooks.useWorkspaceTeleports)
local Themes = require(script.Parent.Parent.Themes)

local e = React.createElement

type SidebarLayoutProps = {
	children: any?,
}

local function SidebarLayout(props: SidebarLayoutProps)
	local theme = Themes.getTheme()
	local sidebarState = useSidebarState()
	local cameraHook = useWorkspaceCameras()
	local animationHook = useCharacterAnimations()
	local teleportHook = useWorkspaceTeleports()
	local buttonPrimary = theme.Primary
	local buttonSecondary = theme.Secondary
	local buttonStroke = theme.Stroke
	local buttonText = theme.Text

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
			Size = UDim2.fromScale(1, 0.8),
			Position = UDim2.fromScale(0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			ButtonsPadding = e("UIPadding", {
				PaddingTop = UDim.new(0, 50),
			}),

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
				TextColor3 = Color3.fromRGB(225, 225, 225),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.fromScale(0.9, 0.04),
				LayoutOrder = 1,
			}),

			TeleportButton1 = e(SidebarButton, {
				Text = "Tp_Z1",
				ColorPrimary = buttonPrimary,
				ColorSecondary = buttonSecondary,
				ColorStroke = buttonStroke,
				TextColor = buttonText,
				LayoutOrder = 2,
				OnClick = function()
					teleportHook.teleportByIndex(1)
				end,
			}),

			TeleportButton2 = e(SidebarButton, {
				Text = "Tp_Z2",
				ColorPrimary = buttonPrimary,
				ColorSecondary = buttonSecondary,
				ColorStroke = buttonStroke,
				TextColor = buttonText,
				LayoutOrder = 3,
				OnClick = function()
					teleportHook.teleportByIndex(2)
				end,
			}),

			TeleportButton3 = e(SidebarButton, {
				Text = "Tp_Z3",
				ColorPrimary = buttonPrimary,
				ColorSecondary = buttonSecondary,
				ColorStroke = buttonStroke,
				TextColor = buttonText,
				LayoutOrder = 4,
				OnClick = function()
					teleportHook.teleportByIndex(3)
				end,
			}),

			SectionCameras = e("TextLabel", {
				Text = "CAMARAS",
				FontFace = Font.new("rbxasset://fonts/families/Kanit.json", Enum.FontWeight.Bold),
				TextSize = 14,
				TextColor3 = Color3.fromRGB(225, 225, 225),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.fromScale(0.9, 0.04),
				LayoutOrder = 5,
			}),

			-- Botón de ejemplo 1
			Button1 = e(SidebarButton, {
				Text = "Cam_Z1",
				ColorPrimary = buttonPrimary,
				ColorSecondary = buttonSecondary,
				ColorStroke = buttonStroke,
				TextColor = buttonText,
				LayoutOrder = 6,
				OnClick = function()
					cameraHook.switchToCameraByIndex(1)
				end,
			}),

			-- Botón de ejemplo 2
			Button2 = e(SidebarButton, {
				Text = "Cam_Z2",
				ColorPrimary = buttonPrimary,
				ColorSecondary = buttonSecondary,
				ColorStroke = buttonStroke,
				TextColor = buttonText,
				LayoutOrder = 7,
				OnClick = function()
					cameraHook.switchToCameraByIndex(2)
				end,
			}),

			-- Botón de ejemplo 3
			Button3 = e(SidebarButton, {
				Text = "Cam_Z3",
				ColorPrimary = buttonPrimary,
				ColorSecondary = buttonSecondary,
				ColorStroke = buttonStroke,
				TextColor = buttonText,
				LayoutOrder = 8,
				OnClick = function()
					cameraHook.switchToCameraByIndex(3)
				end,
			}),

			SectionAnims = e("TextLabel", {
				Text = "ANIMACIONES",
				FontFace = Font.new("rbxasset://fonts/families/Kanit.json", Enum.FontWeight.Bold),
				TextSize = 14,
				TextColor3 = Color3.fromRGB(225, 225, 225),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.fromScale(0.9, 0.04),
				LayoutOrder = 9,
			}),

			AnimButton1 = e(SidebarButton, {
				Text = "Anim_1",
				ColorPrimary = buttonPrimary,
				ColorSecondary = buttonSecondary,
				ColorStroke = buttonStroke,
				TextColor = buttonText,
				LayoutOrder = 10,
				OnClick = function()
					animationHook.playAnimationBySlot(1)
				end,
			}),

			AnimButton2 = e(SidebarButton, {
				Text = "Anim_2",
				ColorPrimary = buttonPrimary,
				ColorSecondary = buttonSecondary,
				ColorStroke = buttonStroke,
				TextColor = buttonText,
				LayoutOrder = 12,
				OnClick = function()
					animationHook.playAnimationBySlot(2)
				end,
			}),

			AnimButton3 = e(SidebarButton, {
				Text = "Anim_3",
				ColorPrimary = buttonPrimary,
				ColorSecondary = buttonSecondary,
				ColorStroke = buttonStroke,
				TextColor = buttonText,
				LayoutOrder = 13,
				OnClick = function()
					animationHook.playAnimationBySlot(3)
				end,
			}),
		}),

		-- Footer con información
		FooterInfo = e("Frame", {
			Size = UDim2.fromScale(1, 0.1),
			Position = UDim2.fromScale(0, 1.02),
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		}, {
			InfoText = e("TextLabel", {
				Text = "(R) Alternar UI\n(H) Esconder UI\n(G) Camara normal\n(1-5) Animaciones",
				FontFace = Font.new("rbxasset://fonts/families/HighwayGothic.json", Enum.FontWeight.Regular),
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

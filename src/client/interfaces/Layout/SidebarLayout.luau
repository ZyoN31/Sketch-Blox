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

local useSidebarState = require(script.Parent.Parent.Hooks.useSidebarState)
local useWorkspaceCameras = require(script.Parent.Parent.Hooks.useWorkspaceCameras)
local useCharacterAnimations = require(script.Parent.Parent.Hooks.useCharacterAnimations)
local useWorkspaceTeleports = require(script.Parent.Parent.Hooks.useWorkspaceTeleports)
local useCinematicDirector = require(script.Parent.Parent.Hooks.useCinematicDirector)
local CamerasTabLayout = require(script.Parent.Tabs.CamerasTabLayout)
local TeleportsTabLayout = require(script.Parent.Tabs.TeleportsTabLayout)
local AnimationsTabLayout = require(script.Parent.Tabs.AnimationsTabLayout)
local ScenesTabLayout = require(script.Parent.Tabs.ScenesTabLayout)
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
	local cinematicDirector = useCinematicDirector()
	local activeTab, setActiveTab = React.useState("Camaras")
	local buttonPrimary = theme.Primary
	local buttonSecondary = theme.Secondary
	local buttonStroke = theme.Stroke
	local buttonText = theme.Text
	local sectionTextColor = theme.Text
	local sceneNames = cinematicDirector.getSceneNames()
	local isScenePlaying = cinematicDirector.isPlaying()

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

	local function createTabButton(id: string, label: string, layoutOrder: number)
		local isActive = activeTab == id

		return e("TextButton", {
			Text = label,
			FontFace = Font.new("rbxasset://fonts/families/Kanit.json", Enum.FontWeight.SemiBold),
			TextSize = 12,
			TextColor3 = isActive and theme.Text or Color3.fromRGB(180, 180, 180),
			AutoButtonColor = false,
			BackgroundColor3 = isActive and theme.Accent or Color3.fromRGB(32, 32, 32),
			Size = UDim2.fromScale(0.235, 1),
			LayoutOrder = layoutOrder,
			BorderSizePixel = 0,
			[React.Event.Activated] = function()
				setActiveTab(id)
			end,
		}, {
			UICorner = e("UICorner", {
				CornerRadius = UDim.new(0, 6),
			}),
			UIStroke = e("UIStroke", {
				Thickness = 1,
				Color = isActive and theme.Stroke or Color3.fromRGB(70, 70, 70),
				Transparency = 0.2,
			}),
		})
	end

	local activeTabLayout
	if activeTab == "Teleports" then
		activeTabLayout = e(TeleportsTabLayout, {
			teleportHook = teleportHook,
			buttonPrimary = buttonPrimary,
			buttonSecondary = buttonSecondary,
			buttonStroke = buttonStroke,
			buttonText = buttonText,
			sectionTextColor = sectionTextColor,
		})
	elseif activeTab == "Animaciones" then
		activeTabLayout = e(AnimationsTabLayout, {
			animationHook = animationHook,
			buttonPrimary = buttonPrimary,
			buttonSecondary = buttonSecondary,
			buttonStroke = buttonStroke,
			buttonText = buttonText,
			sectionTextColor = sectionTextColor,
		})
	elseif activeTab == "Escenas" then
		activeTabLayout = e(ScenesTabLayout, {
			cinematicDirector = cinematicDirector,
			sceneNames = sceneNames,
			isScenePlaying = isScenePlaying,
			buttonPrimary = buttonPrimary,
			buttonSecondary = buttonSecondary,
			buttonStroke = buttonStroke,
			buttonText = buttonText,
			sectionTextColor = sectionTextColor,
		})
	else
		activeTabLayout = e(CamerasTabLayout, {
			cameraHook = cameraHook,
			buttonPrimary = buttonPrimary,
			buttonSecondary = buttonSecondary,
			buttonStroke = buttonStroke,
			buttonText = buttonText,
			sectionTextColor = sectionTextColor,
		})
	end

	return e("Frame", {
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0, 0),
		AnchorPoint = Vector2.new(0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, {
		SidebarPanel = e("Frame", {
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
				Size = UDim2.fromScale(1, 0.78),
				Position = UDim2.fromScale(0, 0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
			}, {
				ButtonsPadding = e("UIPadding", {
					PaddingTop = UDim.new(0, 55),
				}),

				TabsRow = e("Frame", {
					Size = UDim2.fromScale(1, 0.08),
					Position = UDim2.fromScale(0, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
				}, {
					UIListLayout = e("UIListLayout", {
						Padding = UDim.new(0, 4),
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						SortOrder = Enum.SortOrder.LayoutOrder,
						FillDirection = Enum.FillDirection.Horizontal,
					}),
					TabCamaras = createTabButton("Camaras", "CAM", 1),
					TabTeleports = createTabButton("Teleports", "TP", 2),
					TabAnimaciones = createTabButton("Animaciones", "AN", 3),
					TabEscenas = createTabButton("Escenas", "SCN", 4),
				}),

				TabContent = e("Frame", {
					Size = UDim2.fromScale(1, 0.88),
					Position = UDim2.fromScale(0, 0.11),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
				}, {
					ActiveTabLayout = activeTabLayout,
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
					Text = "(R) Alternar UI\n(H) Esconder UI\n(G) Camara normal\n(X) Seguir jugador\n(E/Q) Cambiar objetivo",
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
		}),

		CinematicCountdown = cinematicDirector.countdownText and e("Frame", {
			Size = UDim2.fromOffset(330, 58),
			Position = UDim2.fromScale(0.5, 0.94),
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundColor3 = Color3.fromRGB(15, 15, 15),
			BackgroundTransparency = 0.12,
			BorderSizePixel = 0,
			ZIndex = 20,
		}, {
			UICorner = e("UICorner", {
				CornerRadius = UDim.new(0, 10),
			}),
			UIStroke = e("UIStroke", {
				Thickness = 2,
				Color = theme.Stroke,
				Transparency = 0.1,
			}),
			UIGradient = e("UIGradient", {
				Rotation = 90,
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 22, 22)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 10)),
				}),
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.05),
					NumberSequenceKeypoint.new(1, 0.15),
				}),
			}),
			CountdownText = e("TextLabel", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Text = cinematicDirector.countdownText,
				FontFace = Font.new("rbxasset://fonts/families/Kanit.json", Enum.FontWeight.Bold),
				TextSize = 28,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextStrokeTransparency = 0.5,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				ZIndex = 21,
			}),
		}),
	})
end

return SidebarLayout

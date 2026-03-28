--[[
	Themes.luau
	Archivo de configuración de temas dinámicos basado en UserId
	Path: sketch-blox/src/client/interfaces/Themes.luau
]]

local Players = game:GetService("Players")

local player = Players.LocalPlayer
local userId = player.UserId

-- Tipos de tema
type Theme = {
	Primary: Color3,
	Secondary: Color3,
	Accent: Color3,
	Text: Color3,
	Background: Color3,
	Stroke: Color3,
	SidebarBg: Color3,
	Hover: Color3,
}

-- Tema Rosa (UserId: 3456438496)
local ThemePink: Theme = {
	Primary = Color3.fromRGB(255, 101, 255),
	Secondary = Color3.fromRGB(114, 14, 200),
	Accent = Color3.fromRGB(255, 160, 247),
	Text = Color3.fromRGB(255, 255, 255),
	Background = Color3.fromRGB(40, 35, 40),
	Stroke = Color3.fromRGB(255, 101, 255),
	SidebarBg = Color3.fromRGB(35, 35, 35),
	Hover = Color3.fromRGB(200, 100, 200),
}

-- Tema Azul (UserId: 182328532)
local ThemeBlue: Theme = {
	Primary = Color3.fromRGB(100, 150, 255),
	Secondary = Color3.fromRGB(30, 80, 180),
	Accent = Color3.fromRGB(150, 200, 255),
	Text = Color3.fromRGB(255, 255, 255),
	Background = Color3.fromRGB(25, 35, 50),
	Stroke = Color3.fromRGB(100, 150, 255),
	SidebarBg = Color3.fromRGB(30, 40, 55),
	Hover = Color3.fromRGB(100, 150, 200),
}

-- Tema Negro (UserId: 168423191)
local ThemeBlack: Theme = {
	Primary = Color3.fromRGB(200, 200, 200),
	Secondary = Color3.fromRGB(100, 100, 100),
	Accent = Color3.fromRGB(150, 150, 150),
	Text = Color3.fromRGB(255, 255, 255),
	Background = Color3.fromRGB(20, 20, 20),
	Stroke = Color3.fromRGB(80, 80, 80),
	SidebarBg = Color3.fromRGB(25, 25, 25),
	Hover = Color3.fromRGB(60, 60, 60),
}

-- Tema Default (Glassmorphism Oscuro)
local ThemeDefault: Theme = {
	Primary = Color3.fromRGB(100, 200, 255),
	Secondary = Color3.fromRGB(50, 150, 220),
	Accent = Color3.fromRGB(150, 220, 255),
	Text = Color3.fromRGB(220, 220, 220),
	Background = Color3.fromRGB(30, 30, 35),
	Stroke = Color3.fromRGB(80, 120, 150),
	SidebarBg = Color3.fromRGB(25, 25, 30),
	Hover = Color3.fromRGB(80, 150, 200),
}

-- Función para obtener el tema actual
local function getTheme(): Theme
	if userId == 3456438496 then
		return ThemePink
	elseif userId == 182328532 then
		return ThemeBlue
	elseif userId == 168423191 then
		return ThemeBlack
	else
		return ThemeDefault
	end
end

return {
	getTheme = getTheme,
	ThemePink = ThemePink,
	ThemeBlue = ThemeBlue,
	ThemeBlack = ThemeBlack,
	ThemeDefault = ThemeDefault,
}

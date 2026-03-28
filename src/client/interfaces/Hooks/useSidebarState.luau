--[[
	useSidebarState.luau
	Hook personalizado para manejar la lógica del sidebar
	Incluye: toggle de visibilidad (tecla R), modo grabación (tecla H)
	Path: sketch-blox/src/client/interfaces/Hooks/useSidebarState.luau
]]

local React = require(game:GetService("ReplicatedStorage").Packages.React)
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local function useSidebarState()
	local sidebarVisible, setSidebarVisible = React.useState(true)
	local uiHidden, setUIHidden = React.useState(false)

	-- Effect para manejar input de teclado
	React.useEffect(function()
		local function onInputBegan(input, gameProcessed)
			if gameProcessed or UserInputService:GetFocusedTextBox() then
				return
			end

			-- Tecla R: Alterna visibilidad del sidebar
			if input.KeyCode == Enum.KeyCode.R then
				setSidebarVisible(function(prev)
					return not prev
				end)
			end

			-- Tecla H: Alterna modo grabación (ocultar toda la UI)
			if input.KeyCode == Enum.KeyCode.H then
				setUIHidden(function(prev)
					local nextHidden = not prev
					pcall(function()
						StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, not nextHidden)
					end)
					return nextHidden
				end)
			end
		end

		local connection = UserInputService.InputBegan:Connect(onInputBegan)

		-- Cleanup
		return function()
			connection:Disconnect()
		end
	end, {})

	return {
		sidebarVisible = sidebarVisible,
		setSidebarVisible = setSidebarVisible,
		uiHidden = uiHidden,
		setUIHidden = setUIHidden,
	}
end

return useSidebarState

--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------
local ZenHUD = _G.ZenHUD
local StateManager = ZenHUD.StateManager

local EventHandler = CreateFrame("Frame")

EventHandler:RegisterEvent("PLAYER_ENTERING_WORLD")
EventHandler:RegisterEvent("PLAYER_REGEN_DISABLED")

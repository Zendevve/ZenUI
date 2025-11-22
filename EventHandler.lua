--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------
local ZenHUD = _G.ZenHUD
local StateManager = ZenHUD.StateManager

local EventHandler = CreateFrame("Frame")

EventHandler:RegisterEvent("PLAYER_ENTERING_WORLD")
EventHandler:RegisterEvent("PLAYER_REGEN_DISABLED")
EventHandler:RegisterEvent("PLAYER_REGEN_ENABLED")
EventHandler:RegisterEvent("PLAYER_TARGET_CHANGED")
EventHandler:RegisterEvent("PLAYER_UPDATE_RESTING")
EventHandler:RegisterEvent("ZONE_CHANGED")

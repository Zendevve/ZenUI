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
EventHandler:RegisterEvent("ZONE_CHANGED_INDOORS")
EventHandler:RegisterEvent("ZONE_CHANGED_NEW_AREA")
EventHandler:RegisterEvent("UNIT_AURA")
EventHandler:RegisterEvent("PLAYER_DEAD")
EventHandler:RegisterEvent("PLAYER_ALIVE")
EventHandler:RegisterEvent("PLAYER_UNGHOST")
EventHandler:RegisterEvent("PLAYER_CONTROL_LOST")
EventHandler:RegisterEvent("PLAYER_CONTROL_GAINED")
EventHandler:RegisterEvent("UNIT_ENTERED_VEHICLE")
EventHandler:RegisterEvent("UNIT_EXITED_VEHICLE")
EventHandler:RegisterEvent("PLAYER_FLAGS_CHANGED")
EventHandler:RegisterEvent("ADDON_LOADED")  -- For ElvUI detection

EventHandler:SetScript("OnEvent", function(self, event, ...)
    -- Re-fetch StateManager if needed
    StateManager = ZenHUD.StateManager
    local Utils = ZenHUD.Utils

    if event == "PLAYER_ENTERING_WORLD" then
        ZenHUD:Initialize()

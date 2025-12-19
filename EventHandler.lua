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

    elseif event == "PLAYER_REGEN_DISABLED" then
        StateManager:SetCombat(true)

    elseif event == "PLAYER_REGEN_ENABLED" then
        StateManager:SetCombat(false)

    elseif event == "PLAYER_TARGET_CHANGED" then
        local hasTarget = UnitExists("target")
        local isAlive = hasTarget and not UnitIsDeadOrGhost("target")
        StateManager:SetTarget(hasTarget, isAlive)

    elseif event == "PLAYER_UPDATE_RESTING" then
        StateManager:SetResting(IsResting())

        -- Failsafe timers to ensure UI shows when entering city
        if IsResting() then
            Utils.After(1.0, function()
                if ZenHUD.loaded and IsResting() then
                    StateManager:Update()
                end
            end)
            Utils.After(3.5, function()
                if ZenHUD.loaded and IsResting() then
                    StateManager:Update()
                end
            end)
        end

    elseif event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "ZONE_CHANGED_NEW_AREA" then
        -- Use debounced zone handling
        StateManager:OnZoneChanged()

    elseif event == "UNIT_AURA" then
        local unit = ...
        if unit == "player" then
            StateManager:SetMounted(IsMounted())
        end

    elseif event == "PLAYER_DEAD" then
        StateManager:SetDead(true)

    elseif event == "PLAYER_ALIVE" or event == "PLAYER_UNGHOST" then
        StateManager:SetDead(UnitIsDeadOrGhost("player"))

    elseif event == "PLAYER_CONTROL_LOST" or event == "PLAYER_CONTROL_GAINED" then
        StateManager:SetTaxi(UnitOnTaxi("player"))

    elseif event == "UNIT_ENTERED_VEHICLE" then
        local unit = ...
        if unit == "player" then
            StateManager:SetVehicle(true)
        end

    elseif event == "UNIT_EXITED_VEHICLE" then
        local unit = ...
        if unit == "player" then
            StateManager:SetVehicle(false)
        end

    elseif event == "PLAYER_FLAGS_CHANGED" then
        StateManager:SetAFK(UnitIsAFK("player") or UnitIsDND("player"))

    elseif event == "ADDON_LOADED" then
        local addon = ...
        -- Re-scan for ElvUI/Tukui frames when they load
        if addon == "ElvUI" or addon == "Tukui" then
            if ZenHUD.FrameManager then
                Utils.After(1.0, function()
                    ZenHUD.FrameManager:InitializeElvUIFrames()
                end)
            end
            if ZenHUD.MouseoverDetector then
                Utils.After(1.0, function()
                    ZenHUD.MouseoverDetector:CreateElvUIHotspots()
                end)
            end
        end
    end
end)

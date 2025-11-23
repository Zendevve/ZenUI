--------------------------------------------------------------------------------
-- State Manager - Determines when UI should be visible
--------------------------------------------------------------------------------
local ZenHUD = _G.ZenHUD
local Config = ZenHUD.Config
local Utils = ZenHUD.Utils

local StateManager = {
    inCombat = false,
    hasLivingTarget = false,
    isResting = false,
    isMounted = false,
    isDead = false,
    onTaxi = false,
    inVehicle = false,

    -- Transition tracking
    lastVisibilityDecision = nil,  -- Track last show/hide decision to avoid redundant calls
    isAFK = false,
    mouseoverUI = false,

    -- Grace period tracking
    graceUntil = {
        combat = 0,
        target = 0,
        mouseover = 0,
    },

    -- Zone debouncing
    lastZoneTime = 0,
    pendingZoneCheck = false,
    zoneDebounceTimer = nil,
}

function StateManager:OnZoneChanged()
    local ZONE_DEBOUNCE = 0.6
    local now = Utils.GetTime()

    -- If we're within debounce window, schedule delayed check
    if now - self.lastZoneTime < ZONE_DEBOUNCE then
        self.pendingZoneCheck = true

        if not self.zoneDebounceTimer then
            self.zoneDebounceTimer = CreateFrame("Frame")
        end

        local timeLeft = ZONE_DEBOUNCE - (now - self.lastZoneTime)
        if timeLeft < 0.05 then timeLeft = 0.05 end

        Utils.Print(string.format("Zone debounce: %.2fs", timeLeft), true)

        Utils.After(timeLeft, function()
            if self.pendingZoneCheck then
                self.pendingZoneCheck = false
                self:SetResting(IsResting())
            end
        end)
        return
    end

    -- Outside debounce window - update immediately
    self.lastZoneTime = now
    self:SetResting(IsResting())

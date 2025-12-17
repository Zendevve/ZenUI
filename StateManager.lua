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
end

function StateManager:Update()
    -- Don't run until addon is fully loaded
    if not ZenHUD.loaded then return end
    if not Config:Get("enabled") then return end

    local time = Utils.GetTime()
    local inGrace = false
    local graceReason = nil

    -- Check grace periods
    for reason, deadline in pairs(self.graceUntil) do
        if deadline > time then
            inGrace = true
            graceReason = reason
            break
        end
    end

    -- Determine visibility with clear priority
    local shouldShow = self.inCombat
        or (Config:Get("showOnTarget") and self.hasLivingTarget)
        or self.mouseoverUI
        or inGrace
        or self.isResting
        or self.inVehicle
        or Config:ShouldShowInZone()  -- Zone-based override (dungeons, raids, etc.)

    -- Only call Show/Hide if decision has changed (avoid redundant calls)
    if shouldShow ~= self.lastVisibilityDecision then
        self.lastVisibilityDecision = shouldShow

        if shouldShow then
            local priority = self.inCombat or self.hasLivingTarget or self.mouseoverUI
            Utils.Print(string.format("Showing UI (combat=%s, target=%s, mouseover=%s, grace=%s, resting=%s, vehicle=%s)",
                tostring(self.inCombat), tostring(self.hasLivingTarget), tostring(self.mouseoverUI),
                graceReason or "none", tostring(self.isResting), tostring(self.inVehicle)), true)
            if ZenHUD.FrameManager then
                ZenHUD.FrameManager:ShowAll(priority)
            end
        else
            Utils.Print("Hiding UI", true)
            if ZenHUD.FrameManager then
                ZenHUD.FrameManager:HideAll()
            end
        end
    end
end

function StateManager:SetCombat(inCombat)
    self.inCombat = inCombat

    if inCombat then
        -- Entering combat - clear all grace periods for immediate UI response
        for k in pairs(self.graceUntil) do
            self.graceUntil[k] = 0
        end
        Utils.Print("Combat: ENTERING combat", true)
    else
        -- Leaving combat - start grace period with timer callback
        local grace = Config:Get("gracePeriods").combat
        self.graceUntil.combat = Utils.GetTime() + grace

        Utils.Print(string.format("Combat: LEAVING combat, %.1fs grace period", grace), true)

        -- Timer callback to hide UI after grace expires
        Utils.After(grace, function()
            -- Clear this grace period and force update
            self.graceUntil.combat = 0
            Utils.Print("Combat grace expired, updating visibility", true)
            self:Update()
        end)
    end

    self:Update()
end

function StateManager:SetTarget(hasTarget, isAlive)
    local hadLivingTarget = self.hasLivingTarget
    self.hasLivingTarget = hasTarget and isAlive

    if hasTarget and isAlive then
        -- Acquired living target - clear grace
        self.graceUntil.target = 0
        Utils.Print("Target: acquired living target", true)
    elseif not hasTarget and hadLivingTarget then
        -- Lost living target - start grace period with timer callback
        local grace = Config:Get("gracePeriods").target
        self.graceUntil.target = Utils.GetTime() + grace

        Utils.Print(string.format("Target: lost target, %.1fs grace period", grace), true)

        -- Timer callback to hide UI after grace expires
        Utils.After(grace, function()
            -- Clear this grace period and force update
            self.graceUntil.target = 0
            Utils.Print("Target grace expired, updating visibility", true)

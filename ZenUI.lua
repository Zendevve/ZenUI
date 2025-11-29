--------------------------------------------------------------------------------
-- ZenUI - Minimalist UI Automation for WotLK 3.3.5a
-- Author: Zendevve
-- Version: 1.1.0-wotlk
--------------------------------------------------------------------------------

local ADDON_NAME = "ZenUI"
local VERSION = "1.1.0"

--------------------------------------------------------------------------------
-- Core Namespace
--------------------------------------------------------------------------------
local ZenUI = {
    version = VERSION,
    loaded = false,
    startupDelay = 5.0,
}

-- Store in global namespace
_G.ZenUI = ZenUI

--------------------------------------------------------------------------------
-- Config Module - Settings Management
--------------------------------------------------------------------------------
local Config = {
    defaults = {
        enabled = true,
        debug = false,
        showOnTarget = true,
        fadeTime = 0.8,

        gracePeriods = {
            combat = 8.0,
            target = 2.0,
            mouseover = 2.0,
        },

        -- Per-character settings control
        useCharacterSettings = false,  -- If true, use character-specific settings
    }
}

function Config:Initialize()
    -- Initialize account-wide settings
    if type(ZenUIDB) ~= "table" then
        ZenUIDB = self:Clone(self.defaults)
    else
        -- Merge with defaults for any missing keys
        for k, v in pairs(self.defaults) do
            if ZenUIDB[k] == nil then
                ZenUIDB[k] = type(v) == "table" and self:Clone(v) or v
            end
        end
    end

    -- Initialize per-character settings
    if type(ZenUICharDB) ~= "table" then
        ZenUICharDB = {}
    end
end

function Config:Clone(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = type(v) == "table" and self:Clone(v) or v
    end
    return copy
end

function Config:Get(key)
    -- If using character settings and key exists in character DB, use it
    if ZenUIDB.useCharacterSettings and ZenUICharDB[key] ~= nil then
        return ZenUICharDB[key]
    end
    -- Otherwise use account-wide setting
    return ZenUIDB[key]
end

function Config:Set(key, value)
    -- Set to appropriate DB based on mode
    if ZenUIDB.useCharacterSettings then
        ZenUICharDB[key] = value
    else
        ZenUIDB[key] = value
    end
end

function Config:ToggleCharacterSettings()
    ZenUIDB.useCharacterSettings = not ZenUIDB.useCharacterSettings
    return ZenUIDB.useCharacterSettings
end

function Config:IsUsingCharacterSettings()
    return ZenUIDB.useCharacterSettings == true
end

ZenUI.Config = Config

--------------------------------------------------------------------------------
-- Utilities
--------------------------------------------------------------------------------
local Utils = {}

function Utils.Print(msg, debugOnly)
    if debugOnly and not Config:Get("debug") then return end
    DEFAULT_CHAT_FRAME:AddMessage("|cFF66C2FF[ZenUI]|r " .. msg)
end

function Utils.Clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

function Utils.GetTime()
    return GetTime and GetTime() or 0
end

ZenUI.Utils = Utils

--------------------------------------------------------------------------------
-- Zone Text Detection & Failsafe
--------------------------------------------------------------------------------
local ZoneText = {}

function ZoneText.IsFrameActive(frame)
    if not frame or not frame.IsShown or not frame:IsShown() then
        return false
    end
    if frame.GetAlpha then
        local alpha = frame:GetAlpha() or 1
        if alpha <= 0.1 then
            return false
        end
    end
    return true
end

function ZoneText.IsActive()
    local zoneFrame = _G["ZoneTextFrame"]
    local subZoneFrame = _G["SubZoneTextFrame"]
    return ZoneText.IsFrameActive(zoneFrame) or ZoneText.IsFrameActive(subZoneFrame)
end

ZenUI.ZoneText = ZoneText

--------------------------------------------------------------------------------
-- Failsafe Timer - Forces UI to show if logic breaks
--------------------------------------------------------------------------------
local Failsafe = {
    timer = nil,
    timeout = 4.0,
    elapsed = 0,
}

function Failsafe:Start()
    if not self.timer then
        self.timer = CreateFrame("Frame")
        self.timer:SetScript("OnUpdate", function(_, dt)
            self.elapsed = self.elapsed + dt
            if self.elapsed >= self.timeout then
                self:Stop()
                Utils.Print("Failsafe triggered - forcing UI show", true)
                if FrameManager then
                    FrameManager:ShowAll(false)
                end
            end
        end)
    end

    self.elapsed = 0
    self.timer:Show()
end

function Failsafe:Stop()
    if self.timer then
        self.timer:Hide()
    end
    self.elapsed = 0
end

ZenUI.Failsafe = Failsafe

--------------------------------------------------------------------------------
-- Frame Controller - Manages fade animations for individual frames
--------------------------------------------------------------------------------
local FrameController = {}
FrameController.__index = FrameController

function FrameController:New(frame)
    local instance = {
        frame = frame,
        name = frame:GetName() or "Unknown",
        visible = frame:IsShown(),

        -- Animation state
        animating = false,
        startAlpha = frame:GetAlpha() or 1,
        targetAlpha = 1,
        currentAlpha = frame:GetAlpha() or 1,
        duration = 0,
        elapsed = 0,

        -- Behavior flags
        fadeOnly = false,  -- Don't call Hide(), just set alpha to 0
        conditional = false,  -- Don't force Show() if frame is hidden

        -- Buff frame anti-flicker (defer system)
        deferFadeIn = false,
        deferFadeOut = false,
        deferReason = nil,
    }

    setmetatable(instance, self)
    return instance
end

function FrameController:SetFadeOnly(value)
    self.fadeOnly = value
    return self
end

function FrameController:SetConditional(value)
    self.conditional = value
    return self
end

function FrameController:FadeTo(alpha, duration)
    -- Buff frame anti-flicker logic
    local isBuffFrame = (self.name == "BuffFrame" or self.name == "TemporaryEnchantFrame")

    if isBuffFrame then
        -- If fading IN and a fade OUT is requested, defer the OUT
        if alpha == 0 and self.animating and self.targetAlpha == 1 then
            self.deferFadeOut = true
            self.deferReason = "deferred_buff_fadeout"
            return
        end

        -- If fading OUT and a fade IN is requested, defer the IN
        if alpha == 1 and self.animating and self.targetAlpha == 0 then
            self.deferFadeIn = true
            self.deferReason = "deferred_buff_fadein"
            return
        end
    end

    -- Don't force show conditional frames
    if alpha > 0 and self.conditional and not self.frame:IsShown() then
        return
    end

    -- Skip if already at target
    if not self.animating and math.abs(self.currentAlpha - alpha) < 0.01 then
        return
    end

    self.targetAlpha = Utils.Clamp(alpha, 0, 1)
    self.startAlpha = self.currentAlpha  -- Capture starting point for interpolation
    self.duration = math.max(0.05, duration or Config:Get("fadeTime"))
    self.elapsed = 0
    self.animating = true

    -- Prepare for fade-in
    if alpha > self.currentAlpha then
        self.frame:Show()
        self.frame:SetAlpha(self.currentAlpha)
    end
end

function FrameController:Update(dt)
    if not self.animating then return end

    self.elapsed = self.elapsed + dt
    local progress = math.min(1, self.elapsed / self.duration)

    -- Linear interpolation from start to target
    self.currentAlpha = self.startAlpha + (self.targetAlpha - self.startAlpha) * progress
    self.frame:SetAlpha(self.currentAlpha)

    -- Animation complete
    if progress >= 1 then
        self.animating = false
        self.currentAlpha = self.targetAlpha
        self.frame:SetAlpha(self.targetAlpha)

        local isBuffFrame = (self.name == "BuffFrame" or self.name == "TemporaryEnchantFrame")

        -- Execute deferred fade-out after fade-in completes (buff frames only)
        if self.targetAlpha == 1 and self.deferFadeOut and isBuffFrame then
            local reason = self.deferReason or "deferred_buff_fadeout"
            self.deferFadeOut = false
            self.deferReason = nil
            self:FadeTo(0, Config:Get("fadeTime"))
            return
        end

        -- Execute deferred fade-in after fade-out completes (buff frames only)
        if self.targetAlpha == 0 and self.deferFadeIn and isBuffFrame then
            local reason = self.deferReason or "deferred_buff_fadein"
            self.deferFadeIn = false
            self.deferReason = nil
            -- Show at alpha 0 then fade in
            self.frame:Show()
            self.frame:SetAlpha(0)
            self:FadeTo(1, Config:Get("fadeTime"))
            return
        end

        -- Hide frame at end of fade-out (unless fade-only)
        if self.targetAlpha == 0 and not self.fadeOnly then
            self.frame:Hide()
        end
    end
end

function FrameController:Show(priority)
    local duration = priority and 0.8 or Config:Get("fadeTime")
    self:FadeTo(1, duration)
    self.visible = true
end

function FrameController:Hide()
    self:FadeTo(0, Config:Get("fadeTime"))
    self.visible = false
end

ZenUI.FrameController = FrameController

--------------------------------------------------------------------------------
-- Frame Manager - Manages all controlled frames
--------------------------------------------------------------------------------
local FrameManager = {
    controllers = {},
    updateFrame = nil,
}

-- Frames to control
local CONTROLLED_FRAMES = {
    -- Action bars
    "MainMenuBar", "MultiBarBottomLeft", "MultiBarBottomRight",
    "MultiBarLeft", "MultiBarRight", "PetActionBarFrame", "ShapeshiftBarFrame",

    -- XP/Rep
    "MainMenuExpBar", "MainMenuBarMaxLevelBar", "ReputationWatchBar",
    "MainMenuBarArtFrame",

    -- Micro menu
    "CharacterMicroButton", "SpellbookMicroButton", "TalentMicroButton",
    "QuestLogMicroButton", "SocialsMicroButton", "WorldMapMicroButton",
    "MainMenuMicroButton", "HelpMicroButton",

    -- Bags
    "MainMenuBarBackpackButton", "CharacterBag0Slot", "CharacterBag1Slot",
    "CharacterBag2Slot", "CharacterBag3Slot", "KeyRingButton",

    -- Unit frames
    "PlayerFrame", "PetFrame", "TargetFrameToT",

    -- Buffs
    "BuffFrame", "TemporaryEnchantFrame",

    -- Quest tracker
    "WatchFrame", "QuestWatchFrame",

    -- Chat buttons
    "ChatFrameMenuButton", "ChatFrame1UpButton", "ChatFrame1DownButton",
    "ChatFrame1BottomButton",

    -- Cast bars
    "PetCastingBarFrame",

    -- WotLK-specific frames
    "VehicleMenuBar",           -- Vehicle encounters (Flame Leviathan, etc.)
    "RuneFrame",                -- Death Knight rune cooldowns
    "QuestTimerFrame",          -- Timed quest indicators
    "BonusActionBarFrame",      -- Vehicle/special abilities bar
}

-- Frames that should only fade (not hide)
local FADE_ONLY_FRAMES = {
    MainMenuBar = true,
    MultiBarBottomLeft = true,
    MultiBarBottomRight = true,
    MultiBarLeft = true,
    MultiBarRight = true,
    PetActionBarFrame = true,
    ShapeshiftBarFrame = true,
    PetFrame = true,
}

-- Conditional frames (don't force show)
local CONDITIONAL_FRAMES = {
    PetFrame = true,
    TargetFrameToT = true,
    PetCastingBarFrame = true,

    -- WotLK conditionals
    VehicleMenuBar = true,      -- Only when in vehicle
    RuneFrame = true,           -- Only for Death Knights
    BonusActionBarFrame = true, -- Only when vehicle/special abilities active
}

function FrameManager:Initialize()
    for _, frameName in ipairs(CONTROLLED_FRAMES) do
        local frame = _G[frameName]
        if frame and frame.SetAlpha and frame.Show and frame.Hide then
            local controller = FrameController:New(frame)

            if FADE_ONLY_FRAMES[frameName] then
                controller:SetFadeOnly(true)
            end

            if CONDITIONAL_FRAMES[frameName] then
                controller:SetConditional(true)
            end

            self.controllers[frame] = controller
            Utils.Print("Controlling: " .. frameName, true)
        else
            Utils.Print("Skipped: " .. frameName .. " (not found)", true)
        end
    end

    -- Create update frame
    self.updateFrame = CreateFrame("Frame")
    self.updateFrame:SetScript("OnUpdate", function(_, elapsed)
        self:Update(elapsed)
    end)

    Utils.Print(string.format("Managing %d frames", self:Count()), true)
end

function FrameManager:Update(dt)
    for _, controller in pairs(self.controllers) do
        controller:Update(dt)
    end
end

function FrameManager:ShowAll(priority)
    -- Check for zone text - delay if active
    if ZoneText.IsActive() then
        Utils.Print("Zone text active - delaying show", true)
        Failsafe:Start()
        C_Timer.After(0.2, function()
            if not ZoneText.IsActive() then
                self:ShowAll(priority)
            else
                -- Retry with timeout
                C_Timer.After(3.0, function()
                    Failsafe:Stop()
                    self:ShowAll(priority)
                end)
            end
        end)
        return
    end

    Failsafe:Stop()
    for _, controller in pairs(self.controllers) do
        controller:Show(priority)
    end
end

function FrameManager:HideAll()
    -- Check for zone text - delay if active
    if ZoneText.IsActive() then
        Utils.Print("Zone text active - delaying hide", true)
        C_Timer.After(0.2, function()
            if not ZoneText.IsActive() then
                self:HideAll()
            else
                -- Retry with timeout
                C_Timer.After(3.0, function()
                    self:HideAll()
                end)
            end
        end)
        return
    end

    for _, controller in pairs(self.controllers) do
        controller:Hide()
    end
end

function FrameManager:Count()
    local count = 0
    for _ in pairs(self.controllers) do
        count = count + 1
    end
    return count
end

ZenUI.FrameManager = FrameManager

--------------------------------------------------------------------------------
-- State Manager - Determines when UI should be visible
--------------------------------------------------------------------------------
local StateManager = {
    inCombat = false,
    hasLivingTarget = false,
    isResting = false,
    isMounted = false,
    isDead = false,
    onTaxi = false,
    inVehicle = false,
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

        C_Timer.After(timeLeft, function()
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
    if not ZenUI.loaded then return end
    if not Config:Get("enabled") then return end

    local time = Utils.GetTime()
    local inGrace = false

    -- Check grace periods
    for _, deadline in pairs(self.graceUntil) do
        if deadline > time then
            inGrace = true
            break
        end
    end

    -- Determine visibility
    local shouldShow = self.inCombat
        or (Config:Get("showOnTarget") and self.hasLivingTarget)
        or self.mouseoverUI
        or inGrace
        or self.isResting
        or self.isDead
        or self.inVehicle
        or self.isAFK

    if shouldShow then
        local priority = self.inCombat or self.hasLivingTarget or self.mouseoverUI
        FrameManager:ShowAll(priority)
    else
        FrameManager:HideAll()
    end
end

function StateManager:SetCombat(inCombat)
    self.inCombat = inCombat

    if inCombat then
        -- Entering combat - clear all grace periods
        for k in pairs(self.graceUntil) do
            self.graceUntil[k] = 0
        end
    else
        -- Leaving combat - start grace period with timer callback
        local grace = Config:Get("gracePeriods").combat
        self.graceUntil.combat = Utils.GetTime() + grace

        -- Timer callback to hide UI after grace expires
        C_Timer.After(grace, function()
            if not self.inCombat then
                self.graceUntil.combat = 0
                self:Update()
            end
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
    elseif not hasTarget and hadLivingTarget then
        -- Lost living target - start grace period with timer callback
        local grace = Config:Get("gracePeriods").target
        self.graceUntil.target = Utils.GetTime() + grace

        -- Timer callback to hide UI after grace expires
        C_Timer.After(grace, function()
            if not (UnitExists("target")) and not self.inCombat then
                self.graceUntil.target = 0
                self:Update()
            end
        end)
    end

    self:Update()
end

function StateManager:SetResting(isResting)
    self.isResting = isResting
    self:Update()
end

function StateManager:SetMounted(isMounted)
    self.isMounted = isMounted
    self:Update()
end

function StateManager:SetDead(isDead)
    self.isDead = isDead
    self:Update()
end

function StateManager:SetTaxi(onTaxi)
    self.onTaxi = onTaxi
    self:Update()
end

function StateManager:SetVehicle(inVehicle)
    self.inVehicle = inVehicle
    self:Update()
end

function StateManager:SetAFK(isAFK)
    self.isAFK = isAFK
    self:Update()
end

function StateManager:SetMouseover(mouseoverUI)
    local wasMouseover = self.mouseoverUI
    self.mouseoverUI = mouseoverUI

    if mouseoverUI then
        -- Entered UI - cancel grace period
        self.graceUntil.mouseover = 0
    else
        -- Left UI - start grace period with timer callback
        if wasMouseover then
            local grace = Config:Get("gracePeriods").mouseover
            local now = Utils.GetTime()
            self.graceUntil.mouseover = now + grace

            -- Timer callback to hide UI after grace expires
            C_Timer.After(grace, function()
                if not self.mouseoverUI and not self.inCombat then
                    self.graceUntil.mouseover = 0
                    self:Update()
                end
            end)
        end
    end

    self:Update()
end

ZenUI.StateManager = StateManager

--------------------------------------------------------------------------------
-- Mouseover Detection
--------------------------------------------------------------------------------
local MouseoverDetector = {
    checkFrame = nil,
    lastState = false,
}

-- PlayerFrame hover hotspot for reliable detection when faded
local playerHoverFrame = nil
local function CreatePlayerHoverHotspot()
    if playerHoverFrame or not PlayerFrame then return end

    playerHoverFrame = CreateFrame("Frame", "ZenUI_PlayerHoverFrame", UIParent)
    playerHoverFrame:SetFrameStrata("LOW")
    playerHoverFrame:SetAllPoints(PlayerFrame)
    playerHoverFrame:EnableMouse(true)
    playerHoverFrame:Show()

    Utils.Print("Created PlayerFrame hover hotspot", true)
end

local function IsUIFrame(name)
    if not name then return false end

    -- Action buttons
    if string.find(name, "ActionButton") or string.find(name, "MultiBar") or
       string.find(name, "PetActionButton") or string.find(name, "ShapeshiftButton") then
        return true
    end

    -- Action bar containers
    if name == "MainMenuBar" or name == "PetActionBarFrame" or name == "ShapeshiftBarFrame" then
        return true
    end

    -- Player frame (including hover hotspot)
    if name == "PlayerFrame" or name == "ZenUI_PlayerHoverFrame" or string.find(name, "^PlayerFrame") then
        return true
    end

    return false
end

function MouseoverDetector:Initialize()
    self.checkFrame = CreateFrame("Frame")
    self.checkFrame:SetScript("OnUpdate", function(_, elapsed)
        self:Check()
    end)
    -- Start hidden, will be shown when addon activates
    self.checkFrame:Hide()
end

function MouseoverDetector:Start()
    if self.checkFrame then
        self.checkFrame:Show()
    end
end

function MouseoverDetector:Check()
    local focus = GetMouseFocus()
    local name = focus and focus.GetName and focus:GetName()
    local isOver = IsUIFrame(name)

    if isOver ~= self.lastState then
        self.lastState = isOver
        StateManager:SetMouseover(isOver)
    end
end

ZenUI.MouseoverDetector = MouseoverDetector

--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------
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

EventHandler:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        ZenUI:Initialize()

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
            C_Timer.After(1.0, function()
                if ZenUI.loaded and IsResting() then
                    StateManager:Update()
                end
            end)
            C_Timer.After(3.5, function()
                if ZenUI.loaded and IsResting() then
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
    end
end)

--------------------------------------------------------------------------------
-- Slash Commands
--------------------------------------------------------------------------------
SLASH_ZENUI1 = "/zenui"

local function ShowHelp()
    Utils.Print("Available commands:")
    print("  /zenui - Show this help")
    print("  /zenui toggle - Enable/disable addon")
    print("  /zenui debug - Toggle debug mode")
    print("  /zenui status - Show current state")
    print("  /zenui frames - List controlled frames")
    print("  /zenui reload - Reload configuration")
    print(" ")
    print("Settings:")
    print("  /zenui fade <seconds> - Set fade animation duration")
    print("  /zenui grace combat <seconds> - Post-combat grace period")
    print("  /zenui grace target <seconds> - Post-target grace period")
    print("  /zenui grace mouseover <seconds> - Post-mouseover grace period")
    print("  /zenui settings - Show all current settings")
    print("  /zenui character - Toggle per-character settings mode")
end

local function ShowSettings()
    Utils.Print("Current Settings:")

    -- Show which settings mode is active
    local usingChar = Config:IsUsingCharacterSettings()
    print(string.format("  Settings Mode: %s", usingChar and "Character-Specific" or "Account-Wide"))
    print(" ")

    print(string.format("  Fade Time: %.2fs", Config:Get("fadeTime")))

    local grace = Config:Get("gracePeriods")
    print(string.format("  Grace Period (Combat): %.1fs", grace.combat))
    print(string.format("  Grace Period (Target): %.1fs", grace.target))
    print(string.format("  Grace Period (Mouseover): %.1fs", grace.mouseover))
    print(" ")
    print("  Show on Target: " .. (Config:Get("showOnTarget") and "Yes" or "No"))
end

local function ShowStatus()
    Utils.Print("Current Status:")
    print(string.format("  Enabled: %s", Config:Get("enabled") and "Yes" or "No"))
    print(string.format("  Debug: %s", Config:Get("debug") and "Yes" or "No"))
    print(string.format("  Loaded: %s", ZenUI.loaded and "Yes" or "No"))
    print(string.format("  In Combat: %s", StateManager.inCombat and "Yes" or "No"))
    print(string.format("  Has Target: %s", StateManager.hasLivingTarget and "Yes" or "No"))
    print(string.format("  Resting: %s", StateManager.isResting and "Yes" or "No"))
    print(string.format("  Mounted: %s", StateManager.isMounted and "Yes" or "No"))
    print(string.format("  Dead/Ghost: %s", StateManager.isDead and "Yes" or "No"))
    print(string.format("  On Taxi: %s", StateManager.onTaxi and "Yes" or "No"))
    print(string.format("  In Vehicle: %s", StateManager.inVehicle and "Yes" or "No"))
    print(string.format("  AFK/DND: %s", StateManager.isAFK and "Yes" or "No"))
    print(string.format("  Mouseover: %s", StateManager.mouseoverUI and "Yes" or "No"))

    -- Grace periods
    local now = Utils.GetTime()
    local hasGrace = false
    for name, deadline in pairs(StateManager.graceUntil) do
        if deadline > now then
            local remaining = deadline - now
            print(string.format("  Grace (%s): %.1fs", name, remaining))
            hasGrace = true
        end
    end
    if not hasGrace then
        print("  Grace: None")
    end
end

local function ListFrames()
    local count = FrameManager:Count()
    Utils.Print(string.format("Controlling %d frames:", count))

    local frameList = {}
    for frame, controller in pairs(FrameManager.controllers) do
        local name = controller.name
        local visible = controller.visible and "visible" or "hidden"
        local animating = controller.animating and " (animating)" or ""
        table.insert(frameList, string.format("  %s - %s%s", name, visible, animating))
    end

    table.sort(frameList)
    for _, line in ipairs(frameList) do
        print(line)
    end
end

SlashCmdList["ZENUI"] = function(msg)
    msg = string.lower(msg or "")

    -- Split message into arguments
    local args = {}
    for word in string.gmatch(msg, "%S+") do
        table.insert(args, word)
    end

    local cmd = args[1] or ""

    if cmd == "" or cmd == "help" then
        ShowHelp()

    elseif cmd == "toggle" then
        local enabled = not Config:Get("enabled")
        Config:Set("enabled", enabled)
        Utils.Print(string.format("Addon %s", enabled and "enabled" or "disabled"))
        if enabled then
            StateManager:Update()
        end

    elseif cmd == "debug" then
        local debug = not Config:Get("debug")
        Config:Set("debug", debug)
        Utils.Print(string.format("Debug mode %s", debug and "enabled" or "disabled"))

    elseif cmd == "status" then
        ShowStatus()

    elseif cmd == "frames" then
        ListFrames()

    elseif cmd == "settings" then
        ShowSettings()

    elseif cmd == "fade" then
        local value = tonumber(args[2])
        if not value or value <= 0 then
            Utils.Print("Usage: /zenui fade <seconds>")
            Utils.Print("Example: /zenui fade 0.5")
            return
        end

        Config:Set("fadeTime", value)
        Utils.Print(string.format("Fade time set to %.2fs", value))

    elseif cmd == "grace" then
        local graceType = args[2]  -- combat, target, or mouseover
        local value = tonumber(args[3])

        if not graceType or not value or value < 0 then
            Utils.Print("Usage: /zenui grace <type> <seconds>")
            Utils.Print("Types: combat, target, mouseover")
            Utils.Print("Example: /zenui grace combat 10.0")
            return
        end

        local grace = Config:Get("gracePeriods")
        if not grace[graceType] then
            Utils.Print(string.format("Unknown grace type: %s", graceType))
            Utils.Print("Valid types: combat, target, mouseover")
            return
        end

        grace[graceType] = value
        Utils.Print(string.format("Grace period (%s) set to %.1fs", graceType, value))

    elseif cmd == "character" then
        local enabled = Config:ToggleCharacterSettings()
        if enabled then
            Utils.Print("Switched to character-specific settings")
            Utils.Print("Settings will now be saved per-character")
        else
            Utils.Print("Switched to account-wide settings")
            Utils.Print("Settings will be shared across all characters")
        end

    elseif cmd == "reload" then
        Config:Initialize()
        Utils.Print("Configuration reloaded")
        StateManager:Update()

    else
        Utils.Print(string.format("Unknown command: %s", cmd))
        ShowHelp()
    end
end

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------
function ZenUI:Initialize()
    if self.loaded then return end

    -- Initialize config
    Config:Initialize()

    Utils.Print(string.format("v%s loaded", VERSION))
    Utils.Print(string.format("Startup delay: %.1fs", self.startupDelay))

    -- Initialize frame management (but don't start yet)
    FrameManager:Initialize()

    -- Retry after 300ms for late-loading frames (some frames load after PEW)
    C_Timer.After(0.3, function()
        FrameManager:Initialize()
    end)

    MouseoverDetector:Initialize()

    -- Create PlayerFrame hover hotspot for better mouseover detection
    CreatePlayerHoverHotspot()

    -- Delayed activation
    C_Timer.After(self.startupDelay, function()
        self.loaded = true

        -- Set initial states
        StateManager.inCombat = false
        StateManager.hasLivingTarget = false
        StateManager.isResting = IsResting()
        StateManager.isMounted = IsMounted()
        StateManager.isDead = UnitIsDeadOrGhost("player")
        StateManager.onTaxi = UnitOnTaxi("player")
        StateManager.inVehicle = false  -- Can't reliably detect on load
        StateManager.isAFK = UnitIsAFK("player") or UnitIsDND("player")
        StateManager.mouseoverUI = false

        -- Force initial evaluation
        StateManager:Update()

        -- Start mouseover detection
        MouseoverDetector:Start()

        Utils.Print("Activated", true)
    end)
end

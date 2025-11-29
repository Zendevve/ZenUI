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
-- Configuration
--------------------------------------------------------------------------------
local Config = {
    defaults = {
        enabled = true,
        debug = false,
        showOnTarget = true,
        fadeTime = 3.0,
        gracePeriods = {
            combat = 8.0,
            target = 2.0,
            mouseover = 2.0,
        },
    }
}

function Config:Initialize()
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
end

function Config:Clone(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = type(v) == "table" and self:Clone(v) or v
    end
    return copy
end

function Config:Get(key)
    return ZenUIDB[key]
end

function Config:Set(key, value)
    ZenUIDB[key] = value
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
    mouseoverUI = false,

    -- Grace period tracking
    graceUntil = {
        combat = 0,
        target = 0,
        mouseover = 0,
    },
}

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
        -- Entering combat - clear grace periods
        for k in pairs(self.graceUntil) do
            self.graceUntil[k] = 0
        end
    else
        -- Leaving combat - start grace period
        local grace = Config:Get("gracePeriods").combat
        self.graceUntil.combat = Utils.GetTime() + grace

        -- Schedule update when grace expires
        C_Timer.After(grace, function()
            self:Update()
        end)
    end

    self:Update()
end

function StateManager:SetTarget(hasTarget, isAlive)
    local hadLivingTarget = self.hasLivingTarget
    self.hasLivingTarget = hasTarget and isAlive

    if not hasTarget and hadLivingTarget then
        -- Lost living target - start grace period
        local grace = Config:Get("gracePeriods").target
        self.graceUntil.target = Utils.GetTime() + grace

        -- Schedule update when grace expires
        C_Timer.After(grace, function()
            self:Update()
        end)
    elseif self.hasLivingTarget then
        -- Acquired living target - clear grace
        self.graceUntil.target = 0
    end

    self:Update()
end

function StateManager:SetResting(isResting)
    self.isResting = isResting
    self:Update()
end

function StateManager:SetMouseover(mouseoverUI)
    local wasMouseover = self.mouseoverUI
    self.mouseoverUI = mouseoverUI

    if not mouseoverUI and wasMouseover then
        -- Left UI - start grace period
        local grace = Config:Get("gracePeriods").mouseover
        self.graceUntil.mouseover = Utils.GetTime() + grace

        -- Schedule update when grace expires
        C_Timer.After(grace, function()
            self:Update()
        end)
    elseif mouseoverUI then
        -- Entered UI - clear grace
        self.graceUntil.mouseover = 0
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
    end
end)

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
        StateManager.mouseoverUI = false

        -- Force initial evaluation
        StateManager:Update()

        -- Start mouseover detection
        MouseoverDetector:Start()

        Utils.Print("Activated", true)
    end)
end

--------------------------------------------------------------------------------
-- ZenUI - Minimalist UI Automation for WotLK 3.3.5a
-- Author: Zendevve
-- Version: 1.1.0-wotlk
--------------------------------------------------------------------------------

local ADDON_NAME = "ZenUI"
local VERSION = "1.1.0"

--------------------------------------------------------------------------------
-- Core Namespace (created by Config.lua, now just reference it)
--------------------------------------------------------------------------------
local ZenUI = _G.ZenUI
-- Update version info
ZenUI.version = VERSION

--------------------------------------------------------------------------------
-- Module References (loaded from separate files via .toc)
--------------------------------------------------------------------------------
-- Config.lua, Utils.lua, and all other modules are loaded first (see .toc file)
local Config = ZenUI.Config
local Utils = ZenUI.Utils
local FrameManager = ZenUI.FrameManager
local StateManager = ZenUI.StateManager
local MouseoverDetector = ZenUI.MouseoverDetector

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
    Utils.After(0.3, function()
        FrameManager:Initialize()
    end)

    MouseoverDetector:Initialize()

    -- Create hover hotspots for all action bars
    MouseoverDetector:CreateHotspots()

    -- Delayed activation
    Utils.After(self.startupDelay, function()
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

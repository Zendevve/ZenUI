--------------------------------------------------------------------------------
-- ZenHUD - Minimalist UI Automation for WotLK 3.3.5a
-- Author: Zendevve
-- Version: 1.1.0-wotlk
--------------------------------------------------------------------------------

local ADDON_NAME = "ZenHUD"
local VERSION = "1.2.0"

--------------------------------------------------------------------------------
-- Core Namespace (created by Config.lua, now just reference it)
--------------------------------------------------------------------------------
local ZenHUD = _G.ZenHUD
-- Update version info
ZenHUD.version = VERSION

--------------------------------------------------------------------------------
-- Module References (loaded from separate files via .toc)
--------------------------------------------------------------------------------
-- Config.lua, Utils.lua, and all other modules are loaded first (see .toc file)
local Config = ZenHUD.Config
local Utils = ZenHUD.Utils
local FrameManager = ZenHUD.FrameManager
local StateManager = ZenHUD.StateManager
local MouseoverDetector = ZenHUD.MouseoverDetector

--------------------------------------------------------------------------------
-- Slash Commands
--------------------------------------------------------------------------------
SLASH_ZenHUD1 = "/ZenHUD"

local function ShowHelp()
    Utils.Print("Available commands:")
    print("  /ZenHUD - Show this help")
    print("  /ZenHUD options - Open options panel")
    print("  /ZenHUD toggle - Enable/disable addon")
    print("  /ZenHUD debug - Toggle debug mode")
    print("  /ZenHUD status - Show current state")
    print("  /ZenHUD frames - List controlled frames")
    print("  /ZenHUD minimap - Toggle minimap button")
    print("  /ZenHUD reload - Reload configuration")
    print(" ")
    print("Settings:")
    print("  /ZenHUD fade <seconds> - Set fade animation duration")
    print("  /ZenHUD grace combat <seconds> - Post-combat grace period")
    print("  /ZenHUD grace target <seconds> - Post-target grace period")
    print("  /ZenHUD grace mouseover <seconds> - Post-mouseover grace period")
    print("  /ZenHUD settings - Show all current settings")
    print("  /ZenHUD character - Toggle per-character settings mode")
    print(" ")
    print("Profiles:")
    print("  /ZenHUD profile save <name> - Save current settings")
    print("  /ZenHUD profile load <name> - Load a profile")
    print("  /ZenHUD profile delete <name> - Delete a profile")
    print("  /ZenHUD profile list - List all profiles")
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
    print(string.format("  Loaded: %s", ZenHUD.loaded and "Yes" or "No"))
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

SlashCmdList["ZenHUD"] = function(msg)
    msg = string.lower(msg or "")

    -- Split message into arguments
    local args = {}
    for word in string.gmatch(msg, "%S+") do
        table.insert(args, word)
    end

    local cmd = args[1] or ""

    if cmd == "" or cmd == "help" then
        ShowHelp()

    elseif cmd == "options" or cmd == "config" or cmd == "settings" then
        -- Open the Blizzard Interface Options panel
        InterfaceOptionsFrame_OpenToCategory("ZenHUD")
        InterfaceOptionsFrame_OpenToCategory("ZenHUD")  -- Called twice due to Blizzard bug
        Utils.Print("Opening options panel...")

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
            Utils.Print("Usage: /ZenHUD fade <seconds>")
            Utils.Print("Example: /ZenHUD fade 0.5")
            return
        end

        Config:Set("fadeTime", value)
        Utils.Print(string.format("Fade time set to %.2fs", value))

    elseif cmd == "grace" then
        local graceType = args[2]  -- combat, target, or mouseover
        local value = tonumber(args[3])

        if not graceType or not value or value < 0 then
            Utils.Print("Usage: /ZenHUD grace <type> <seconds>")
            Utils.Print("Types: combat, target, mouseover")
            Utils.Print("Example: /ZenHUD grace combat 10.0")
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

    elseif cmd == "minimap" then
        local show = not Config:Get("showMinimapButton")
        Config:Set("showMinimapButton", show)
        if ZenHUD.MinimapButton then
            if show then
                ZenHUD.MinimapButton:Show()
            else

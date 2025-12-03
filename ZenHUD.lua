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

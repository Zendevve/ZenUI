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

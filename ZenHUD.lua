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

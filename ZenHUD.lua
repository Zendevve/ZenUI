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

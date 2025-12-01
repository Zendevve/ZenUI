--------------------------------------------------------------------------------
-- ZenHUD - Config Module
-- Settings Management for WotLK 3.3.5a
--------------------------------------------------------------------------------

local ADDON_NAME = "ZenHUD"

-- Create ZenHUD namespace if it doesn't exist (this is the first file loaded)
if not _G.ZenHUD then
    _G.ZenHUD = {
        version = "1.2.0",
        loaded = false,
        startupDelay = 5.0,
    }
end

local ZenHUD = _G.ZenHUD

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

        -- New Features
        fadedAlpha = 0.0, -- Alpha level when "hidden" (0.0 to 1.0)

        frameGroups = {
            actionBars = true,
            unitFrames = true,
            minimap = true,
            chat = true,
            buffs = true,
            quest = true,
            misc = true,
            elvui = true,  -- ElvUI frames (if detected)
        },

        -- Minimap button
        showMinimapButton = true,
        minimapAngle = 220,

        -- Zone-based behavior
        zoneOverrides = {
            alwaysShowInDungeons = true,
            alwaysShowInRaids = true,
            alwaysShowInArena = true,
            alwaysShowInBattleground = true,
        },

        -- Profiles

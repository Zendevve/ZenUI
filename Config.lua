--------------------------------------------------------------------------------
-- ZenUI - Config Module
-- Settings Management for WotLK 3.3.5a
--------------------------------------------------------------------------------

local ADDON_NAME = "ZenUI"

-- Create ZenUI namespace if it doesn't exist (this is the first file loaded)
if not _G.ZenUI then
    _G.ZenUI = {
        version = "1.1.0",
        loaded = false,
        startupDelay = 5.0,
    }
end

local ZenUI = _G.ZenUI

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
        },
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

function Config:ResetToDefaults()
    -- Clear current settings and restore defaults
    if ZenUIDB.useCharacterSettings then
        ZenUICharDB = {}
    else
        ZenUIDB = self:Clone(self.defaults)
    end
    self:Initialize()
end

-- Export to ZenUI namespace
ZenUI.Config = Config

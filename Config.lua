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
        activeProfile = "Default",
    },

    -- Profile storage (separate from settings)
    profiles = {},
}

function Config:Initialize()
    -- Initialize account-wide settings
    if type(ZenHUDDB) ~= "table" then
        ZenHUDDB = self:Clone(self.defaults)
    else
        -- Merge with defaults for any missing keys
        for k, v in pairs(self.defaults) do
            if ZenHUDDB[k] == nil then
                ZenHUDDB[k] = type(v) == "table" and self:Clone(v) or v
            end
        end
    end

    -- Initialize per-character settings
    if type(ZenHUDCharDB) ~= "table" then
        ZenHUDCharDB = {}
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
    if ZenHUDDB.useCharacterSettings and ZenHUDCharDB[key] ~= nil then
        return ZenHUDCharDB[key]
    end
    -- Otherwise use account-wide setting
    return ZenHUDDB[key]
end

function Config:Set(key, value)
    -- Set to appropriate DB based on mode
    if ZenHUDDB.useCharacterSettings then
        ZenHUDCharDB[key] = value
    else
        ZenHUDDB[key] = value
    end
end

function Config:ToggleCharacterSettings()
    ZenHUDDB.useCharacterSettings = not ZenHUDDB.useCharacterSettings
    return ZenHUDDB.useCharacterSettings
end

function Config:IsUsingCharacterSettings()
    return ZenHUDDB.useCharacterSettings == true
end

-- Check if we should always show UI in current zone type
function Config:ShouldShowInZone()
    local zoneOverrides = self:Get("zoneOverrides")
    if not zoneOverrides then return false end

    -- Check instance type
    local inInstance, instanceType = IsInInstance()
    if not inInstance then return false end

    if instanceType == "party" and zoneOverrides.alwaysShowInDungeons then
        return true
    elseif instanceType == "raid" and zoneOverrides.alwaysShowInRaids then
        return true
    elseif instanceType == "arena" and zoneOverrides.alwaysShowInArena then
        return true
    elseif instanceType == "pvp" and zoneOverrides.alwaysShowInBattleground then
        return true
    end

    return false
end

-- Check if a specific frame group is enabled
function Config:IsFrameGroupEnabled(group)
    local frameGroups = self:Get("frameGroups")
    if not frameGroups then return true end
    return frameGroups[group] ~= false
end

-- Get the minimum alpha for "hidden" frames
function Config:GetFadedAlpha()
    return self:Get("fadedAlpha") or 0.0
end

-- Export to ZenHUD namespace
ZenHUD.Config = Config

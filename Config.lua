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

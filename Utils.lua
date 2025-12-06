--------------------------------------------------------------------------------
-- ZenHUD - Utils Module
-- Utility Functions for WotLK 3.3.5a
--------------------------------------------------------------------------------

local ADDON_NAME = "ZenHUD"
local ZenHUD = _G.ZenHUD  -- Already created by Config.lua
local Config = ZenHUD.Config  -- Already exported by Config.lua

--------------------------------------------------------------------------------
-- Utilities
--------------------------------------------------------------------------------
local Utils = {}

function Utils.Print(msg, debugOnly)
    if debugOnly and not Config:Get("debug") then return end
    DEFAULT_CHAT_FRAME:AddMessage("|cFF66C2FF[ZenHUD]|r " .. msg)
end

function Utils.Clamp(value, min, max)

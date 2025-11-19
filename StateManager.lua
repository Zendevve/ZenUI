--------------------------------------------------------------------------------
-- State Manager - Determines when UI should be visible
--------------------------------------------------------------------------------
local ZenHUD = _G.ZenHUD
local Config = ZenHUD.Config
local Utils = ZenHUD.Utils

local StateManager = {
    inCombat = false,
    hasLivingTarget = false,
    isResting = false,
    isMounted = false,
    isDead = false,
    onTaxi = false,
    inVehicle = false,

    -- Transition tracking
    lastVisibilityDecision = nil,  -- Track last show/hide decision to avoid redundant calls
    isAFK = false,
    mouseoverUI = false,

    -- Grace period tracking
    graceUntil = {
        combat = 0,
        target = 0,

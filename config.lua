Config = {}

-- If true, /cuffme toggles on and off. If false, use /cuffme to cuff and /uncuffme to uncuff.
Config.ToggleOnSingleCommand = true

-- Command names (rename as you like)
Config.Commands = {
    Cuff   = 'cuffme',
    Uncuff = 'uncuffme'
}

-- Minimum delay between command uses (ms)
Config.CooldownMs = 1500

-- Animation settings
Config.AnimDict = 'mp_arresting'
Config.AnimName = 'idle'
-- Task flags: 49 loops upper-body, stays in place, 16 normal loop, 1 moves ped, etc.
Config.AnimFlags = 49
-- How long to wait for the animation dict to load
Config.AnimLoadTimeoutMs = 2500

-- Disable key actions while cuffed
Config.DisableControls = {
    21,   -- INPUT_SPRINT
    22,   -- INPUT_JUMP
    24,   -- INPUT_ATTACK
    25,   -- INPUT_AIM
    37,   -- INPUT_SELECT_WEAPON
    44,   -- INPUT_COVER
    75,   -- INPUT_VEH_EXIT
    140,  -- INPUT_MELEE_ATTACK_LIGHT
    141,  -- INPUT_MELEE_ATTACK_HEAVY
    142,  -- INPUT_MELEE_ATTACK_ALTERNATE
    143,  -- INPUT_MELEE_BLOCK
    257,  -- INPUT_ATTACK2
    263,  -- INPUT_MELEE_ATTACK1
    264   -- INPUT_MELEE_ATTACK2
}

-- Uncuff on player death/respawn
Config.AutoUncuffOnDeath = true

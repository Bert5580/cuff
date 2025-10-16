# cuff (Standalone)

A lightweight, **FX-standalone** self-cuff script for FiveM that lets a player cuff and uncuff themselves via commands.
No ESX / QBCore / MySQL required.

## Features
- `/cuffme` to cuff yourself (toggling allowed via config)
- `/uncuffme` to remove cuffs (or toggle via `/cuffme` again)
- Smooth animation loop with automatic dictionary loading & safe timeouts
- Disables combat, aiming, weapon usage, enter vehicles, sprint/jump while cuffed
- Applies Rockstar handcuff flag so other players see the correct stance
- Network sync broadcast so nearby clients see your cuffed state reliably
- Robust cleanup on resource stop and player drop
- Export for other resources: `exports.cuff:IsSelfCuffed(playerId)`

## Installation
1. Drop the `cuff` folder into your server's `resources/` directory.
2. Add `ensure cuff` to your **server.cfg** after your dependencies.
3. (Optional) Edit `config.lua` to adjust commands, behaviour, and animation.

## Commands
- **/cuffme** — Cuff yourself (or toggle on/off if `Config.ToggleOnSingleCommand = true`).
- **/uncuffme** — Uncuff yourself (always available, even if toggle is enabled).

> Both commands can be renamed in `config.lua`.

## Configuration (`config.lua`)
Key options:
- `ToggleOnSingleCommand` — enable `/cuffme` to toggle on/off.
- `AnimDict`, `AnimName` — animation dictionary & clip used while cuffed.
- `AnimFlags` — task flags (use 49 to loop upper body, 16 for normal repeat, etc.).
- `AnimLoadTimeoutMs` — how long to wait for the dict to load before aborting.
- `DisableControls` — list of control actions disabled while cuffed.
- `CooldownMs` — anti-spam delay between command uses.
- `AutoUncuffOnDeath` — automatically uncuff on death/respawn.

## Exports
```lua
-- Returns boolean: whether the local player is cuffed (client-side)
exports('IsSelfCuffed', function() return LocalPlayer.state.isCuffed or false end)
```

## Events
- `cuff:server:syncState (playerId, isCuffed)` — server broadcast for cuff state.
- `cuff:client:setState (serverId, isCuffed)` — client receives & applies visuals.

## Notes
- This resource **intentionally** removes all ESX/QBCore and MySQL usage.
- If you are migrating from older ESX-based versions, remove any DB tables related to this script; they are no longer used.

## License
MIT (see `LICENSE.md` if provided).


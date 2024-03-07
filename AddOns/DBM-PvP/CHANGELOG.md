# <DBM Mod> PvP

## [r170](https://github.com/DeadlyBossMods/DBM-PvP/tree/r170) (2024-03-03)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-PvP/compare/r169...r170) [Previous Releases](https://github.com/DeadlyBossMods/DBM-PvP/releases)

- Blood Moon: Add timer for resurrection  
- Fix LuaLS warnings  
    This exposed a real bug: Ashran had a typo in UnregisterShortTermEvents,  
    this wasn't detected before because LuaLS didn't know the type of the  
    self parameter.  
- Add LuaLS check action  

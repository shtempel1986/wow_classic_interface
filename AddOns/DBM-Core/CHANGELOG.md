# Deadly Boss Mods Core

## [2.5.9](https://github.com/DeadlyBossMods/DBM-TBC-Classic/tree/2.5.9) (2021-08-10)
[Full Changelog](https://github.com/DeadlyBossMods/DBM-TBC-Classic/compare/2.5.8...2.5.9) [Previous Releases](https://github.com/DeadlyBossMods/DBM-TBC-Classic/releases)

- I guess I forgot to actually do a TBC release a month ago  
- Minor timer update and optimisation to Hydross  
- Change netherspite timer to 30, closes #33  
- Update localization.cn.lua (#42)  
- Update localization.cn.lua (#41)  
- Update localization.cn.lua (#40)  
- Update localisations (#39)  
- Sync  
- Sync fix  
- Change how target count and cd count bars display so that they display the count next to spellname. reduces chance of the count being truncated and makes it more prominant in timers. It also makes it more uniform with warnings which already do count next to spell name. Don't worry this was done in a way that the arg order doesn't have to change nor does it break non updated locales. If you do localize though take note on syntax for flipping arg order in translated text from targetcount example.  
- Update DBM-Core.lua  
- Finish sync  
- Push this, can't sync core because conflict.  
- Fix dungeon ID's for heroic  
    Apparently blizzard wants to be "special egg" and add custom difficulties for these.  
    Also sync over the CheckBossDistance and NewSpecialWarningSoakCount stuff.  
- Update russian locale for Party-BC & Fix Romulo&Julianne yells (#38)  
- Sync hard reset  
- Update localization.ru.lua (#36)  
    - Sync with localization.en.lua  
    - Translated all strings  
- Update localization.ru.lua (#37)  
    - Sync with localization.en.lua  
    - Translated all strings  
- sync  
- Sync fix  
- Switch mind rend to a non filtered warning since it has no special version  
- Re-enable repent timer  
- Sync further fixes  
- Sync fix  
- fire stage callback on variable recovery  
- Prep next dev cycle  

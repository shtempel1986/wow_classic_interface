---@type l10n
local l10n = QuestieLoader:ImportModule("l10n")

local commsLocales = {
    ["A Major patch for Questie exists!"] = {
        ["ptBR"] = "Existe uma atualização importante para o Questie!",
        ["ruRU"] = "Выпущено важное обновление Questie!",
        ["deDE"] = "Es gibt eine neue Major-Version von Questie!",
        ["koKR"] = "퀘스티의 중요 업데이트가 존재합니다!",
        ["esMX"] = "¡Existe un parche importante para Questie!",
        ["enUS"] = true,
        ["frFR"] = "Une mise à jour majeure pour Questie est disponible !",
        ["esES"] = "¡Existe un parche importante para Questie!",
        ["zhTW"] = "任務位置提示插件 Questie 已有重要的更新版本!",
        ["zhCN"] = "任务提示插件 Questie 已发布重要的更新版本！",
    },
    ["Please update as soon as possible!"] = {
        ["ptBR"] = "Por favor, atualize o mais rápido possível!",
        ["ruRU"] = "Пожалуйста, обновите как можно скорее!",
        ["deDE"] = "Bitte update so bald wie möglich!",
        ["koKR"] = "최대한 빨리 업데이트를 해주세요",
        ["esMX"] = "¡Actualice lo antes posible!",
        ["enUS"] = true,
        ["frFR"] = "Veuillez mettre à jour dès que possible !",
        ["esES"] = "¡Actualice lo antes posible!",
        ["zhTW"] = "請盡快更新!",
        ["zhCN"] = "请尽快更新！",
    },
    ["You have an outdated version of Questie!"] = {
        ["ptBR"] = "Você tem uma versão desatualizada do Questie!",
        ["ruRU"] = "Вы используете устаревшую версию Questie!",
        ["deDE"] = "Du hast eine veraltete Questie-Version!",
        ["koKR"] = "오래된 퀘스티 버전을 사용 중입니다",
        ["esMX"] = "¡Tienes una versión desactualizada de Questie!",
        ["enUS"] = true,
        ["frFR"] = "Vous avez une version obsolète de Questie !",
        ["esES"] = "¡Tienes una versión desactualizada de Questie!",
        ["zhTW"] = "你的任務位置提示插件 Questie 已經過期! ",
        ["zhCN"] = "你的任务提示插件 Questie 已经过期！",
    },
    ["Please consider updating!"] = {
        ["ptBR"] = "Por favor, considere atualizar!",
        ["ruRU"] = "Пожалуйста, рассмотрите возможность обновления!",
        ["deDE"] = "Bitte erwäge eine Aktualisierung",
        ["koKR"] = "퀘스티 업데이트가 필요합니다",
        ["esMX"] = "¡Por favor considere actualizar!",
        ["enUS"] = true,
        ["frFR"] = "Veuillez envisager de mettre à jour !",
        ["esES"] = "¡Por favor considere actualizar!",
        ["zhTW"] = "請考慮更新插件!",
        ["zhCN"] = "请考虑更新插件！",
    },
    ["You have an incompatible QuestieComms message! Please update!"] = {
        ["ptBR"] = "Você tem uma mensagem QuestieComms incompatível! Por favor, atualize!",
        ["ruRU"] = "Имеется несовместимое сообщение QuestieComms! Пожалуйста, обновите!",
        ["deDE"] = "Du hast eine inkompatible QuestieComms-Nachricht! Bitte update!",
        ["koKR"] = "퀘스티 통신 오류! 퀘스티를 업데이트 해주세요",
        ["esMX"] = "¡Tienes un mensaje de QuestieComms incompatible! ¡Actualízalo!",
        ["enUS"] = true,
        ["frFR"] = "Vous avez un message QuestieComms incompatible ! Veuillez mettre à jour !",
        ["esES"] = "¡Tienes un mensaje de QuestieComms incompatible! ¡Actualízalo!",
        ["zhTW"] = "你有不相容版本的 QuestieComms 訊息! 請更新插件!",
        ["zhCN"] = "你有不兼容版本的 QuestieComms 信息！请更新插件！",
    },
    ["  Yours: v"] = {
        ["ptBR"] = "  Seu: v",
        ["ruRU"] = "  Ваша версия: v",
        ["deDE"] = "  Deine: v",
        ["koKR"] = false,
        ["esMX"] = "  Tuyo: v",
        ["enUS"] = true,
        ["frFR"] = "  Le vôtre : v",
        ["esES"] = "  Tuyo: v",
        ["zhTW"] = "  你的: v",
        ["zhCN"] = "  你的: v",
    },
    ["has an incompatible Questie version, QuestieComms won't work!"] = {
        ["ptBR"] = "possui uma versão incompatível do Questie, o QuestieComms não funcionará!",
        ["ruRU"] = "имеет несовместимую версию Questie, QuestieComms работать не будет!",
        ["deDE"] = "hat eine inkompatible Questie-Version, QuestieComms wird nicht funktionieren!",
        ["koKR"] = "호환 되지 않는 퀘스티 버전입니다. 퀘스티와 통신이 안됩니다!",
        ["esMX"] = "tiene una versión de Questie incompatible, ¡QuestieComms no funcionará!",
        ["enUS"] = true,
        ["frFR"] = "a une version incompatible de Questie, QuestieComms ne fonctionnera pas !",
        ["esES"] = "tiene una versión de Questie incompatible, ¡QuestieComms no funcionará!",
        ["zhTW"] = "是不相容版本的任務位置提示插件 Questie，QuestieComms 無法使用!",
        ["zhCN"] = "是不兼容版本的任务提示插件 Questie和 QuestieComms 无法使用！",
    },
}

for k, v in pairs(commsLocales) do
    l10n.translations[k] = v
end

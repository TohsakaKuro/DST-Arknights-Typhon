name = ChooseTranslationTable({
    en = "Typhon",
    zh = "提丰"
})
description = ChooseTranslationTable({
    en = [[If there are any anomalies in our cooperation, I will deal with them...... Code name? My name is TYPHON! That's the name I found on my mother's horn ornament, though some people say it sounds terrible.]],
    zh = [[合作时要是遇到了异常现象，我会替你们处理......代号？我就叫提丰呀！这可是我在妈妈留下的角饰上找到的名字，虽然有些人说听起来很可怕。]]
})
author = "望月心灵"
version = "0.0.1"
forumthread = "https://github.com/TohsakaKuro/DST-Arknights-Typhon/issues"

api_version = 10

dont_starve_compatible = false
reign_of_giants_compatible = false

dst_compatible = true
all_clients_require_mod = true

icon_atlas = "modicon.xml"
icon = "modicon.tex"

server_filter_tags = {"character", "tifeng", "arknights", "提丰", "明日方舟", "Typhon"}
configuration_options = {{
    name = "language",
    label = ChooseTranslationTable({
        en = "Choose Language",
        zh = "选择语言"
    }),
    hover = ChooseTranslationTable({
        en = "Choose the language of the mod",
        zh = "选择mod的语言"
    }),
    options = {{
        description = ChooseTranslationTable({
            en = "Chinese",
            zh = "中文"
        }),
        data = "zh"
    }, {
        description = ChooseTranslationTable({
            en = "Auto",
            zh = "自动"
        }),
        data = "auto"
    }},
    default = "auto"
}, {
    name = "voice_language",
    label = ChooseTranslationTable({
        en = "Choose Voice Language",
        zh = "选择角色语音语言"
    }),
    hover = ChooseTranslationTable({
        en = "Choose the language of the voice",
        zh = "选择角色语音的语言"
    }),
    options = {{
        description = ChooseTranslationTable({
            en = "Japanese",
            zh = "日语"
        }),
        data = "jp"
    }, {
        description = ChooseTranslationTable({
            en = "Auto",
            zh = "自动"
        }),
        data = "auto"
    }},
    default = "auto"
}, {
    name = "skill1_hotkey",
    label = ChooseTranslationTable({
        en = "Skill 1 Hotkey",
        zh = "技能 迅捷打击·γ型 快捷键"
    }),
    hover = ChooseTranslationTable({
        en = "Set the hotkey for skill 1",
        zh = "设置技能 迅捷打击·γ型 的快捷键"
    }),
    options = {{
        description = "Z",
        data = 122
    }},
    default = 122
}, {
    name = "skill2_hotkey",
    label = ChooseTranslationTable({
        en = "Skill 2 Hotkey",
        zh = "技能 冰原秩序 快捷键"
    }),
    hover = ChooseTranslationTable({
        en = "Set the hotkey for skill 2",
        zh = "设置技能 冰原秩序 的快捷键"
    }),
    options = {{
        description = "X",
        data = 120
    }},
    default = 120
}, {
    name = "skill3_hotkey",
    label = ChooseTranslationTable({
        en = "Skill 3 Hotkey",
        zh = "技能 “永恒狩猎” 快捷键"
    }),
    hover = ChooseTranslationTable({
        en = "Set the hotkey for skill 3",
        zh = "设置技能 “永恒狩猎” 的快捷键"
    }),
    options = {{
        description = "R",
        data = 114
    }},
    default = 114
}}

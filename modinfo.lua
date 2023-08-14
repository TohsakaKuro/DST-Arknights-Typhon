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

icon_atlas = "images/modicon.xml"
icon = "modicon.tex"

server_filter_tags = {"character", "tifeng", "arknights", "提丰", "明日方舟", "Typhon"}
configuration_options = {{
    name = ChooseTranslationTable({
        en = "Language",
        zh = "语言"
    }),
    label = ChooseTranslationTable({
        en = "Choose Language",
        zh = "选择语言"
    }),
    hover = "",
    options = {{
        description = ChooseTranslationTable({
            en = "English",
            zh = "英语"
        }),
        data = "en"
    }, {
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
}}

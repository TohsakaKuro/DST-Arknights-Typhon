-- 全局翻译文件
local i18ns = {
    [LANGUAGE.CHINESE_S] = {
        character = {
            typhon = {
                titile = '明日方舟 提丰',
                name = '提丰',
                description = '提丰，活跃于萨米的萨卡兹，以猎人自居，对萨米的自然环境和潜在威胁有着充足的知识储备和应对技巧。',
                quote = '代号？我就叫提丰呀！这可是我在妈妈留下的角饰上找到的名字，虽然有些人说听起来很可怕。'
            }
        }
    },
    en = {}
}

local loc = require 'languages/loc'
local language = loc and loc.GetLaanguage and loc.GetLanguage()
local get = require('utils').get
return function(path)
    local source = i18ns[language] or i18ns.en
    return get(source, path) or 'undefined path' .. path
end

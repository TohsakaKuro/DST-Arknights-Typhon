local utils = require('typhon_utils')
local i18ns = {
    ['zh'] = {
        character = {
            typhon = {
                title = '明日方舟 提丰',
                name = '提丰',
                description = '来自萨米的协作者提丰，熟悉这片冻土之规则的猎人。',
                quote = '代号？我就叫提丰呀！这可是我在妈妈留下的角饰上找到的名字，虽然有些人说听起来很可怕。',
            }
        },
        strings = {
            NAMES = {
                TYPHON_MECHAXBOW = '“污染”',
            },
            TYPHON = {
                DESCRIBE = {
                    TYPHON_MECHAXBOW = '每一支箭都能让萨米的雪晚一些染上黑色。',
                }
            },
            GENERIC = {
                DESCRIBE = {
                    TYPHON_MECHAXBOW = '好像有一些黑色的影子。',
                }
            }
        },
        skill = {
            skill1 = {
                title = '迅捷打击·γ型',
                hover_text = '攻击力获得提升',
                cd_text = '现在还不到时机',
                lock_text = '我还没有准备好',
                boost_text = '好时机',
                buff_end = '力量正在褪去',
            },
            skill2 = {
                title = '冰原秩序',
                hover_text = '重击敌人',
                cd_text = '我还没有恢复回来',
                lock_text = '我还没有准备好',
                boost_text = '是时候决定谁是猎物了',
                buff_end = '我不能坚持更久了',
            },
            skill3 = {
                title = '“永恒狩猎”',
                hover_text = '进入狩猎模式，需要被污染的箭',
                cd_text = '我还没有恢复回来',
                lock_text = '我还没有准备好',
                boost_text = '从我家里出去',
                buff_end = '我会钉住你的影子',
                no_target = '没有锁定目标',
            }
        },
        typhonSkill3ShootActionName = '射击',
    },
}

local languageMap = {
    [LANGUAGE.CHINESE_S] = 'zh',
    [LANGUAGE.CHINESE_T] = 'zh',
}

local function get(path)
    local lang = TUNING.TYPHON_CONFIG.language
    if (lang == 'auto') then
        -- 自动设置语言
        lang = languageMap[require"languages/loc".GetLanguage()] or 'zh'
    end
    local source = i18ns[lang]
    get = function(path)
        return utils.get(source, path) or 'undefined path ' .. path
    end
    return utils.get(source, path) or 'undefined path ' .. path
end
-- 播放角色语音
local function playCharacterSound(inst, sound, name)
    local soundPerfix = 'typhon/character_jp/';
    if TUNING.TYPHON_CONFIG.voice_language == 'jp' then
        soundPerfix = 'typhon/character_jp/';
    end
    playCharacterSound = function(inneerInst, sound, name)
        inneerInst.SoundEmitter:PlaySound(soundPerfix..sound, name)
        print('playCharacterSound', soundPerfix..sound, name)
    end
    playCharacterSound(inst, sound, name)
end

return {
    get = get,
    playCharacterSound = playCharacterSound
}

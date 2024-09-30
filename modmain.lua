GLOBAL.setmetatable(env, {
  __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end
})
PrefabFiles = {'typhon', 'typhon_mechaxbow_mark', 'typhon_mechaxbow', 'typhon_mechaxbow_arrow',
  'typhon_mechaxbow_arrow_shoot', 'typhon_mechaxbow_mark_range'}
Assets = {Asset('ATLAS', 'images/saveslot_portraits/typhon.xml'),
  Asset('ATLAS', 'images/selectscreen_portraits/typhon.xml'), Asset('ATLAS', 'images/map_icons/typhon.xml'),
  Asset('ATLAS', 'images/avatars/avatar_typhon.xml'), Asset('ATLAS', 'images/avatars/avatar_ghost_typhon.xml'),
  Asset('ATLAS', 'images/avatars/self_inspect_typhon.xml'), Asset('ATLAS', 'bigportraits/typhon.xml'),
  Asset('ANIM', 'anim/typhon.zip'), Asset('ANIM', 'anim/player_typhon.zip'),
  Asset('ANIM', 'anim/typhon_mechaxbow_mark.zip'), Asset('ANIM', 'anim/typhon_mechaxbow_mark_range.zip'),
  Asset('ANIM', 'anim/typhon_mechaxbow_arrow_shoot.zip'), Asset("ANIM", "anim/typhon_skill_ui.zip"),
  Asset('SOUND', 'sound/typhon.fsb'), Asset('SOUNDPACKAGE', 'sound/typhon.fev'),
  Asset('SOUND', 'sound/typhon_mechaxbow.fsb'), Asset('SOUNDPACKAGE', 'sound/typhon_mechaxbow.fev')}

AddMinimapAtlas('images/map_icons/typhon.xml')
AddMinimapAtlas('images/map_icons/typhon_mechaxbow_mark_range.xml')
AddModCharacter('typhon', 'FEMALE')

TUNING.TYPHON_CONFIG = {
  voice_language = nil,
  language = nil,
  skills = {
    skill1 = {
      hotkey = 122,
      cdTime = 5, -- 冷却
      buffTime = 3, -- 持续时间
      -- 攻击倍率
      attackMultiplier = 1.5,
      -- 攻速倍率
      attackPeriod = 0.5
    },
    skill2 = {
      hotkey = 120,
      cdTime = 3,
      buffTime = 30,
      -- 攻击倍率
      attackMultiplier = 1.5
    },
    skill3 = {
      hotkey = 99,
      cdTime = 3,
      -- 攻击倍率
      attackMultiplier = 1.5,
      -- 最大弹药数量
      ammo = 10,
      -- 搜索范围
      searchRange = 30,
      -- 标记范围
      markRange = 30
    }
  }
}
-- 初始化配置
modimport('scripts/modmain/typhon_config')
modimport('scripts/modmain/typhon_strings')
modimport('scripts/modmain/typhon_skill')
modimport('scripts/modmain/typhon_containers')
modimport('scripts/modmain/typhon_sg')
modimport('scripts/modmain/sg_typhon_skill3')

local i18n = require "typhon_i18n"
local MakePlayerCharacter = require "prefabs/player_common"
local utils = require('typhon_utils')
local common = require('typhon_common')

local assets = {Asset('ANIM', 'anim/typhon.zip'), Asset('ANIM', 'anim/player_typhon.zip'),
  Asset('ANIM', 'anim/ghost_typhon_build.zip'), Asset('SOUND', 'sound/typhon.fsb'),
  Asset('SOUNDPACKAGE', 'sound/typhon.fev'), Asset('SOUND', 'sound/typhon_mechaxbow.fsb'),
  Asset('SOUNDPACKAGE', 'sound/typhon_mechaxbow.fev')}

local prefabs = {}

-- Custom starting items
local start_inv = {}

-- When the character is revived from human
local function onbecamehuman(inst)
  -- Set speed when loading or reviving from ghost (optional)
  inst.components.locomotor.walkspeed = 6
  inst.components.locomotor.runspeed = 8.5
end

-- When loading or spawning the character
local function onload(inst)
  inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
  if not inst:HasTag("playerghost") then
    onbecamehuman(inst)
  end
end

local function onTalk(inst, args)
  if args and args.sgparam and args.sgparam.noVoice then
    return
  end
  local sound = "talk_LP"
  if not inst.SoundEmitter:PlayingSound(sound) then
    i18n.playCharacterSound(inst, 'talk', sound)
  end
end

local skillConfigs = TUNING.TYPHON_CONFIG.skills
local function getBuffEventName(skillName) return skillName .. '_buff' end
local function getCdEventName(skillName) return skillName .. '_cd' end
local function tryBuffEventName(eventName)
  if eventName:sub(-5) == '_buff' then
    return eventName:sub(1, -6)
  end
  return nil
end
local function tryCdEventName(eventName)
  if eventName:sub(-3) == '_cd' then
    return eventName:sub(1, -3)
  end
  return nil
end
local function initSkill(inst)
  if not inst.skillStatus then
    inst.skillStatus = {}
    for k, v in pairs(skillConfigs) do
      inst.skillStatus[k] = {
        -- 剩余弹药
        ammo = 0,
        lock = false -- 先全解锁
      }
    end
  end
  local function onSkill3TargetDeath()
    local markRange = inst.skill3MarkRange
    if not markRange then
      return
    end
    local x, y, z = markRange.Transform:GetWorldPosition()
    markRange.entity:SetParent(nil)
    markRange.Transform:SetPosition(x, y, z)
    local markCenter = inst.skill3MarkRangeCenter
    if markCenter then
      markCenter:Remove()
    end
  end
  -- 针对技能123单独处理的方法
  local function tryAndEmitSkill(skillName, forceAttack)
    print('tryAndEmitSkill', skillName, forceAttack)
    if skillName == 'skill3' then
      -- 搜索角色周围的怪物
      local range = TUNING.TYPHON_CONFIG.skills.skill3.searchRange
      local targets = common.findTyphonSkillTargetEntities(inst, inst, range, forceAttack)
      local maxHealth = 0
      local target = nil
      for _, innerTarget in ipairs(targets) do
        if innerTarget.components.health and innerTarget.components.health.maxhealth > maxHealth then
          maxHealth = innerTarget.components.health.maxhealth
          target = innerTarget
        end
      end
      if target then
        inst.skill3Trigger:set(true)
        print('标记最大生命值怪物', target.prefab)
        target:ListenForEvent('death', onSkill3TargetDeath)
        -- 标记怪物
        -- 生成一个 typhon_mechaxbow_mark 实体, 放在怪物身上
        local markCenter = SpawnPrefab('typhon_mechaxbow_mark')
        markCenter.entity:SetParent(target.entity)
        local offsetY = 0.2
        -- 如果是大型怪物, z提高一点
        if target:HasTag('largecreature') then
          offsetY = 2
        end
        markCenter.Transform:SetPosition(0, offsetY, 0)
        inst.skill3MarkRangeCenter = markCenter
        -- 生成一个 typhon_mechaxbow_mark_range 实体, 放在 typhone_mechaxbow_mark 实体上
        local markRange = SpawnPrefab('typhon_mechaxbow_mark_range')
        markRange.entity:SetParent(target.entity)
        inst.skill3MarkRange = markRange
        inst.sg:GoToState('typhon_skill3_squat', {
          directAttack = true,
          forceAttack = forceAttack,
        })
        inst.forceAttack = forceAttack
        return true
      end
      return false
    end
    return true
  end
  local function setBuff(skillName)
    local skillConfig = skillConfigs[skillName]
    -- 增加技能属性
    if skillConfig.attackMultiplier then
      inst.components.combat.damagemultiplier = (skillConfig.attackMultiplier
                                                  * (inst.components.combat.damagemultiplier or 1))
    end
    if skillConfig.attackPeriod then
      inst.components.combat:SetAttackPeriod(skillConfig.attackPeriod * inst.components.combat.min_attack_period)
    end
  end
  local function recoveryBuff(skillName)
    local skillConfig = skillConfigs[skillName]
    if skillConfig.attackMultiplier then
      -- 回收的时候, 没有值无法回收
      if inst.components.combat.damagemultiplier then
        inst.components.combat.damagemultiplier = inst.components.combat.damagemultiplier / skillConfig.attackMultiplier
      end
    end
    if skillConfig.attackPeriod then
      if inst.components.combat.min_attack_period then
        inst.components.combat:SetAttackPeriod(inst.components.combat.min_attack_period / skillConfig.attackPeriod)
      end
    end
  end
  local function closeSkill(skillName, showAmmo)
    local status = inst.skillStatus[skillName]
    local skillConfig = skillConfigs[skillName]
    -- 弹药清空
    status.ammo = 0
    local cdTime = skillConfig.cdTime
    -- buff 先不清除
    -- recoveryBuff(skillName)
    -- 如果有技能3标记, 清除技能3标记
    if skillName == 'skill3' and inst.skill3MarkRange then
      local centerMark = inst.skill3MarkRangeCenter
      if centerMark then
        centerMark:Remove()
      end
      local centerMonster = inst.skill3MarkRange.entity:GetParent()
      if centerMonster then
        centerMonster:RemoveEventCallback('death', onSkill3TargetDeath)
      end
      inst.skill3MarkRange:Remove()
      inst.skill3MarkRange = nil
    end
    inst.sg:GoToState('idle')
    inst.components.timer:StartTimer(getCdEventName(skillName), cdTime)
    if (skillName == 'skill3') then
      -- 延时半秒, 重置技能3标记
      inst:DoTaskInTime(0.5, function()
        inst.skill3Trigger:set(false)
        inst.skill3ReadyShoot:set(false)
      end)
    end
    -- 通知ui
    SendModRPCToClient(GetClientModRPC('typhon', 'setSkillStatus'), inst.userid, inst, skillName, cdTime, nil,
      showAmmo and status.ammo or nil)
  end
  local function cutAmmo(skillName)
    local skillConfig = skillConfigs[skillName]
    local status = inst.skillStatus[skillName]
    status.ammo = status.ammo - 1
    if status.ammo > 0 then
      SendModRPCToClient(GetClientModRPC('typhon', 'setSkillStatus'), inst.userid, inst, skillName, nil, nil,
        status.ammo)
      return true
    else
      closeSkill(skillName, false)
      return false
    end
  end
  local function emitSkill(skillName, forceAttack)
    local skillConfig = skillConfigs[skillName]
    local status = inst.skillStatus[skillName]
    -- 检查技能触发前置条件
    if status.lock then
      inst.components.talker:Say(i18n.get('skill.' .. skillName .. '.lock_text'), nil, nil, nil, nil, nil, nil, nil,
        nil, {
          noVoice = true
        })
      return
    end
    -- 如果还有弹药, 再次按技能键, 则关闭技能, 重新进入cd
    if status.ammo and status.ammo > 0 then
      closeSkill(skillName, true)
      return
    end
    local cdEventName = getCdEventName(skillName)
    if inst.components.timer:TimerExists(cdEventName) then
      inst.components.talker:Say(i18n.get('skill.' .. skillName .. '.cd_text'), nil, nil, nil, nil, nil, nil, nil, nil,
        {
          noVoice = true
        })
      return
    end
    -- 检查特定技能是否满足触发条件, 未触发则提示
    if (not tryAndEmitSkill(skillName, forceAttack)) then
      inst.components.talker:Say(i18n.get('skill.' .. skillName .. '.no_target'), nil, nil, nil, nil, nil, nil, nil,
        nil, {
          noVoice = true
        })
      return
    end
    -- 如果是弹药型技能, 触发后不会进入cd , 等待弹药用完
    local cdTime = nil
    if not skillConfig.ammo then
      cdTime = skillConfig.cdTime
      inst.components.timer:StartTimer(cdEventName, skillConfig.cdTime)
    end
    -- 重新填充弹药
    status.ammo = skillConfig.ammo
    -- 发动技能语音
    i18n.playCharacterSound(inst, skillName .. '_boost')
    -- 有buff时间, 则增加buff
    if skillConfig.buffTime then
      local buffEventName = getBuffEventName(skillName)
      local buffExist = inst.components.timer:TimerExists(buffEventName)
      -- 如果已经有buff, 则刷新buff时间
      if buffExist then
        inst.components.timer:SetTimeLeft(buffEventName, skillConfig.buffTime)
      else
        setBuff(skillName)
        inst.components.timer:StartTimer(buffEventName, skillConfig.buffTime)
      end
    end
    -- 通知客户端展示动画
    SendModRPCToClient(GetClientModRPC('typhon', 'setSkillStatus'), inst.userid, inst, skillName, cdTime,
      skillConfig.buffTime, status.ammo)
  end
  local function syncSkillStatus()
    -- 同步ui栏状态
    for skillName, status in pairs(inst.skillStatus) do
      local status = inst.skillStatus[skillName]
      local cdTime = inst.components.timer:GetTimeLeft(getCdEventName(skillName))
      local buffTime = inst.components.timer:GetTimeLeft(getBuffEventName(skillName))
      SendModRPCToClient(GetClientModRPC('typhon', 'setSkillStatus'), inst.userid, inst, skillName, cdTime, buffTime,
        status.ammo, status.lock)
    end
  end
  inst:ListenForEvent('timerdone', function(inst, data)
    local buffSkillName = tryBuffEventName(data.name)
    print('timerdone', data.name, buffSkillName)
    if buffSkillName then
      recoveryBuff(buffSkillName)
      return
    end
  end)
  local function trySkill3Shoot(forceAttack)
    local markRange = inst.skill3MarkRange
    print('trySkill3Shoot', markRange, forceAttack)
    if not markRange then
      return
    end
    -- 检查标记点周围有没有怪物
    local targets = common.findTyphonSkillTargetEntities(inst, markRange, skillConfigs.skill3.markRange,
      inst.forceAttack or forceAttack)
    print('skill3Shoot', #targets)
    if #targets == 0 then
      return
    end
    if not inst.skill3ReadyShoot:value() then
      inst.skill3ReadyShoot:set(true)
      inst.sg:GoToState('typhon_skill3_draw', {
        directAttack = true,
        forceAttack = inst.forceAttack,
        targets = targets,
      })
    else
      inst.sg:GoToState('typhon_skill3_shoot', {
        targets = targets,
        forceAttack = inst.forceAttack
      })
    end
  end
  inst.SyncSkillStatus = function(self) syncSkillStatus() end
  inst.EmitSkill = function(self, skillName, forceAttack) emitSkill(skillName, forceAttack) end
  inst.CutAmmo = function(self, skillName) cutAmmo(skillName) end
  inst.TrySkill3Shoot = function(self, forceAttack) trySkill3Shoot(forceAttack) end
  inst.TrySkill3ReadyShoot = function(self)
    if not inst.skill3MarkRange then
      return
    end
    inst.sg:GoToState('typhon_skill3_ready_shoot', {
      directAttack = false,
      forceAttack = inst.forceAttack
    })
  end
  inst.CloseSkill = function(self, skillName) closeSkill(skillName, false) end
end
-- This initializes for both the server and client. Tags can be added here.
local common_postinit = function(inst)
  inst:AddTag("typhon")
  inst.skill3Trigger = net_bool(inst.GUID, "typhon.skill3Trigger")
  inst.skill3ReadyShoot = net_bool(inst.GUID, "typhon.skill3ReadyShoot")
  -- Minimap icon
  inst.MiniMapEntity:SetIcon("typhon.tex")
  inst:ListenForEvent("ontalk", onTalk)
  -- 如果不是主服务器, 检查并切换sg
  if not TheWorld.ismastersim then
    inst:DoTaskInTime(0, function() SendModRPCToServer(MOD_RPC['typhon']['skill3ReadyShoot'], inst) end)
  end
end

-- This initializes for the server only. Components are added here.
local master_postinit = function(inst)
  -- choose which sounds this character will play
  inst.soundsname = "typhon"

  -- Stats	
  inst.components.health:SetMaxHealth(100)
  inst.components.hunger:SetMax(125)
  inst.components.sanity:SetMax(500)
  inst.OnNewSpawn = onload
  -- inst:AddComponent('timer')
  inst.OnSave = function(inst, data)
    data.skillStatus = inst.skillStatus
    data.skill3Trigger = inst.skill3Trigger:value()
    data.skill3ReadyShoot = inst.skill3ReadyShoot:value()
    if inst.skill3MarkRange then
      data.skill3MarkRangeGuid = inst.skill3MarkRange.GUID
    end
    if inst.skill3MarkRangeCenter then
      data.skill3MarkRangeCenterGuid = inst.skill3MarkRangeCenter.GUID
    end
    data.combatDamageMultiplier = inst.components.combat.damagemultiplier
    data.forceAttack = inst.forceAttack
  end
  inst.OnLoad = function(inst, data)
    if not data then
      return
    end
    inst.components.combat.damagemultiplier = data.combatDamageMultiplier
    inst.skill3Trigger:set(data.skill3Trigger or false)
    inst.skill3ReadyShoot:set(data.skill3ReadyShoot or false)
    inst.skillStatus = data.skillStatus
    inst.forceAttack = data.forceAttack
    inst:DoTaskInTime(0, function()
      if data.skill3MarkRangeGuid then
        inst.skill3MarkRange = Ents[data.skill3MarkRangeGuid]
      end
      if data.skill3MarkRangeCenterGuid then
        inst.skill3MarkRangeCenter = Ents[data.skill3MarkRangeCenterGuid]
      end
    end)
  end
  initSkill(inst)
  inst:ListenForEvent("death", function() inst:CloseSkill('skill3') end)
end

return MakePlayerCharacter("typhon", prefabs, assets, common_postinit, master_postinit, start_inv)

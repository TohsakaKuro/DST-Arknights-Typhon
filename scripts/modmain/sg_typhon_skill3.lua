local utils = require("../typhon_utils")
local common = require("../typhon_common")

local function CommonEquip() return EventHandler("equip", function(inst) inst.sg:GoToState("idle") end) end

local function CommonUnequip() return EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end) end

local function CommonAnimover(name) return
  EventHandler("animover", function(inst) inst.sg:GoToState(name or "idle") end) end

local typhon_skill3_squat = function(ismastersim)
  return State {
    name = "typhon_skill3_squat",
    tags = {"notalking", "abouttoattack", "busy"},
    onenter = function(inst, data)
      inst.components.locomotor:Stop()
      inst.AnimState:PlayAnimation("fishing_ocean_cast_pst")
      inst.SoundEmitter:PlaySound("typhon_mechaxbow/mechaxbow/p_skill_mechaxbow_s_aimboost")
      local markRange = inst.skill3MarkRange
      inst:FacePoint(markRange.Transform:GetWorldPosition())
      inst.sg.statemem.directAttack = data and data.directAttack
      inst.sg.statemem.forceAttack = data and data.forceAttack
      inst.sg.statemem.targets = data and data.targets
    end,
    events = {EventHandler("animover", function(inst)
      inst.sg:GoToState("typhon_skill3_ready_shoot", {
        directAttack = inst.sg.statemem.directAttack,
        forceAttack = inst.sg.statemem.forceAttack,
        targets = inst.sg.statemem.targets
      })
    end), CommonEquip(), CommonUnequip()}
  }
end

AddStategraphState("wilson", typhon_skill3_squat(true))
AddStategraphState("wilson_client", typhon_skill3_squat(false))

local function typhon_skill3_ready_shoot(ismastersim)
  return State {
    name = "typhon_skill3_ready_shoot",
    tags = {"notalking", "abouttoattack", "busy"},
    onenter = function(inst, data)
      print('进入了sg typhon_skill3_ready_shoot')
      inst.skill3ReadyShoot:set(true)
      inst.components.locomotor:Stop()
      inst.sg.statemem.forceAttack = data and data.forceAttack
      inst.sg.statemem.targets = data and data.targets
      inst.sg.statemem.directAttack = data and data.directAttack
      inst.AnimState:PlayAnimation("fishing_ocean_bite_heavy_loop", true)
    end,
    events = {EventHandler("animover", function(inst)
      if inst.sg.statemem.directAttack then
        inst.sg:GoToState("typhon_skill3_shoot", {
          forceAttack = inst.sg.statemem.forceAttack,
          targets = inst.sg.statemem.targets,
          directAttack = inst.sg.statemem.directAttack
        })
      end
    end), CommonEquip(), CommonUnequip()}
  }
end
AddStategraphState("wilson", typhon_skill3_ready_shoot(true))
AddStategraphState("wilson_client", typhon_skill3_ready_shoot(false))

-- 攻击敌人
local function typhon_skill3_arrow_attack(inst, target, arrowAtk, timeout)
  inst:DoTaskInTime(timeout, function(inst)
    local arrowMark = SpawnPrefab("typhon_mechaxbow_arrow")
    arrowMark.entity:SetParent(target.entity)
    arrowMark.SoundEmitter:PlaySound("typhon_mechaxbow/mechaxbow/p_imp_mechaxbow_s")
    arrowMark:ListenForEvent("animover", function() arrowMark:Remove() end)
    arrowMark:DoTaskInTime(0.2, function()
      if target and target:IsValid() then
        target.components.combat:GetAttacked(inst, arrowAtk)
      end
    end)
  end)
end

local MAX_ARROW_NUM = 5

local function typhon_skill3_shoot(ismastersim)
  return State {
    name = "typhon_skill3_shoot",
    tags = {"notalking", "attack", "busy"},
    onenter = function(inst, data)
      print('进入了sg typhon_skill3_shoot')
      inst.skill3ReadyShoot:set(false)
      inst.SoundEmitter:PlaySound("typhon_mechaxbow/mechaxbow/p_atk_mechaxbow_s")
      inst.AnimState:PlayAnimation("chop_lag")
      -- 生成一个预制体 typhon_mechaxbow_arrow_shoot
      local markRange = inst.skill3MarkRange
      local x, y, z = markRange.Transform:GetWorldPosition()
      local range = TUNING.TYPHON_CONFIG.skills.skill3.markRange
      local targets = data and data.targets or common.findTyphonSkillTargetEntities(inst, markRange, range, data.forceAttack)
      local centerMonster = inst.skill3MarkRange.entity:GetParent()
      -- TODO: 攻击力动态计算
      local arrowAtk = 10
      -- 攻击频率帧间隔
      local attackInterval = 3 * FRAMES
      local useCenterMode = false
      local lockedTargetArr = {}
      if useCenterMode and centerMonster then
        -- 检查标记中心, 确定标记中心分配几只箭
        local centerArrowNum = math.ceil(centerMonster.components.health.currenthealth / arrowAtk)
        centerArrowNum = math.min(centerArrowNum, MAX_ARROW_NUM)
        for i = 1, centerArrowNum do
          table.insert(lockedTargetArr, centerMonster)
        end
      end
      -- 带计数器的死循环
      local leftTargetArr = {}
      -- 根据怪物血量分配剩余箭
      for i, target in ipairs(targets) do
        -- 如果目标是中心目标, 且开启了中心模式, 则跳过
        if not useCenterMode or not target == centerMonster then
          local health = target.components.health.currenthealth
          local mallocArrowNum = math.ceil(health / arrowAtk)
          mallocArrowNum = math.min(mallocArrowNum, MAX_ARROW_NUM)
          for j = 1, mallocArrowNum do
            table.insert(leftTargetArr, target)
          end
        end
      end
      -- 打乱数组
      local leftArrowNum = MAX_ARROW_NUM - #lockedTargetArr
      utils.shuffleArray(leftTargetArr)
      utils.truncateArray(leftTargetArr, leftArrowNum)
      -- 合并数组
      local targetArr = utils.concatArray(lockedTargetArr, leftTargetArr)
      -- 遍历 targetArr
      for i, target in ipairs(targetArr) do
        local timeout = i * attackInterval
        typhon_skill3_arrow_attack(inst, target, arrowAtk, timeout)
      end
      local realArrowNum = #targetArr
      inst.sg:SetTimeout(realArrowNum * attackInterval + 0.2)
      if realArrowNum > 0 then
        local arrowShoot = SpawnPrefab("typhon_mechaxbow_arrow_shoot")
        arrowShoot.entity:SetParent(inst.entity)
        arrowShoot:ListenForEvent("animover", function() arrowShoot:Remove() end)
        arrowShoot.SoundEmitter:PlaySound("typhon_mechaxbow/mechaxbow/p_atk_mechaxbow_s")
      end
      local left = inst:CutAmmo("skill3")
    end,
    -- 超时
    ontimeout = function(inst)
      inst.SoundEmitter:PlaySound("typhon_mechaxbow/mechaxbow/p_imp_mechaxbow_s_end")
      -- 检查弹药还有没有
      local leftAmmo = inst.skillStatus.skill3.ammo
      if leftAmmo <= 0 then
        inst.sg:GoToState("typhon_skill3_standup")
      else
        inst.sg:GoToState("typhon_skill3_draw")
      end
    end,
    events = {CommonEquip(), CommonUnequip()}
  }
end
AddStategraphState("wilson", typhon_skill3_shoot(true))
AddStategraphState("wilson_client", typhon_skill3_shoot(false))

local typhon_skill3_draw = function()
  return State {
    name = "typhon_skill3_draw",
    tags = {"notalking", "busy"},

    onenter = function(inst, data)
      print('进入了sg typhon_skill3_draw')
      -- inst.AnimState:PlayAnimation("typhon_skill3_draw")
      inst.AnimState:PushAnimation("fishing_ocean_bite_heavy_pre")
      inst.AnimState:PushAnimation("fishing_ocean_bite_heavy_lag", false)
      inst.SoundEmitter:PlaySound("typhon_mechaxbow/mechaxbow/p_atk_mechaxbow_s_aim")
      inst.sg.statemem.directAttack = data and data.directAttack
      inst.sg.statemem.forceAttack = data and data.forceAttack
      inst.sg.statemem.targets = data and data.targets
    end,
    events = {EventHandler("animqueueover", function(inst)
      inst.sg:GoToState("typhon_skill3_ready_shoot", {
        directAttack = inst.sg.statemem.directAttack,
        forceAttack = inst.sg.statemem.forceAttack,
        targets = inst.sg.statemem.targets,
      })
    end)}
  }
end

AddStategraphState("wilson", typhon_skill3_draw())
AddStategraphState("wilson_client", typhon_skill3_draw())

local typhon_skill3_standup = function()
  return State {
    name = "typhon_skill3_standup",
    tags = {"notalking"},

    onenter = function(inst)
      print('进入了sg typhon_skill3_standup')
      -- inst.AnimState:PlayAnimation("fishing_ocean_catch")
      inst.sg:GoToState("idle")
    end,
    events = {EventHandler("animover", function(inst) inst.sg:GoToState("idle") end), CommonEquip(), CommonUnequip()}
  }
end

AddStategraphState("wilson", typhon_skill3_standup())
AddStategraphState("wilson_client", typhon_skill3_standup())

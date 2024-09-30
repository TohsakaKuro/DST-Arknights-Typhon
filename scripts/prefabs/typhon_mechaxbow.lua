local i18n = require('typhon_i18n')
local assets = {Asset("ANIM", "anim/typhon_mechaxbow.zip"), Asset("ANIM", "anim/swap_typhon_mechaxbow.zip"),
  Asset("ATLAS", "images/inventoryimages/typhon_mechaxbow.xml"),
  Asset("ATLAS_BUILD", "images/inventoryimages/typhon_mechaxbow.xml", 256)}

local function onattack(inst, attacker, target)
  if target == nil or not target:IsValid() then
    return
  end
end

local function onequip(inst, owner)
  owner.AnimState:OverrideSymbol("swap_object", "swap_typhon_mechaxbow", "typhon_mechaxbow")
  owner.AnimState:Show("ARM_carry")
  owner.AnimState:Hide("ARM_normal")
  -- TODO: 提丰注册攻击事件, 被动.
end

local function onunequip(inst, owner)
  owner.AnimState:Hide("ARM_carry")
  owner.AnimState:Show("ARM_normal")
  if inst.components.container ~= nil then
    inst.components.container:Close()
  end
end

local function onunequip() end

local function fn()
  local inst = CreateEntity()
  inst.entity:AddTransform()
  inst.entity:AddAnimState()
  inst.entity:AddNetwork()
  inst.entity:AddSoundEmitter()

  inst.AnimState:SetBank("typhon_mechaxbow")
  inst.AnimState:SetBuild("typhon_mechaxbow")
  inst.AnimState:PlayAnimation("idle")

  inst:AddTag("sharp")
  inst:AddTag("pointy")
  inst:AddTag("weapon")

  inst:AddTag("rangedweapon")
  inst:AddTag("typhon_mechaxbow")

  MakeInventoryPhysics(inst)
  MakeInventoryFloatable(inst, "small")

  inst.entity:SetPristine()
  if not TheWorld.ismastersim then
    inst.OnEntityReplicated = function(inst)
      if inst.replica.container then
        inst.replica.container:WidgetSetup("typhon_mechaxbow")
      end
    end
    return inst
  end

  inst.fxcolour = {0.8, 0.6, 0.8}

  inst:AddComponent("inspectable")

  inst.base_range = 2

  inst:AddComponent("weapon")
  inst.components.weapon:SetRange(2)
  inst.components.weapon:SetDamage(70)
  inst.components.weapon:SetOnAttack(onattack)
  -- inst.components.weapon:SetProjectile("typhon_mechaxbow_arrow")

  local GetDamage = inst.components.weapon.GetDamage
  inst.components.weapon.GetDamage = function(self, attacker, target)
    local damage, spdamage = GetDamage(self, attacker, target)
    -- TODO: Add damage multiplier
    return damage, spdamage
  end

  inst:AddComponent("inventoryitem")
  inst.components.inventoryitem.imagename = "typhon_mechaxbow"
  inst.components.inventoryitem.atlasname = "images/inventoryimages/typhon_mechaxbow.xml"
  -- inst.components.inventoryitem.keepondeath = true

  inst:AddComponent("equippable")
  inst.components.equippable:SetOnEquip(onequip)
  inst.components.equippable:SetOnUnequip(onunequip)
  inst.components.equippable.equipslot = EQUIPSLOTS.HANDS -- 设置装备槽位为手部
  inst.components.equippable.restrictedtag = "typhon" -- 只有具有 "typhon" 标签的角色才能装备

  inst:AddComponent("container")
  inst.components.container:WidgetSetup("typhon_mechaxbow")

  MakeHauntableLaunch(inst)
  return inst
end
return Prefab("typhon_mechaxbow", fn, assets)

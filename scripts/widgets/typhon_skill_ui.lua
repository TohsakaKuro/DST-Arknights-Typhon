local Widget = require "widgets/widget"
local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local Image = require "widgets/image"
local i18n = require "typhon_i18n"

local function createUIAnim(ui, bank, build, offset)
    local anim = ui:AddChild(UIAnim())
    anim:GetAnimState():SetBank(bank)
    anim:GetAnimState():SetBuild(build)
    anim:MoveToBack()
    anim:SetPosition(offset, 0, 0)
    anim:SetScale(.56, .56, .56)
    return anim
end
local function addSkillUi(ui, skill, index)
    local bank = "typhon_skill_ui"
    local build = "typhon_skill_ui"
    local offset = -175 * index

    local skillAnim = createUIAnim(ui, bank, build, offset)
    skillAnim:GetAnimState():AnimateWhilePaused(false)
    skillAnim:SetHoverText(i18n.get("skill." .. skill .. ".hover_text"), {
        offset_y = 60
    })
    -- skillAnim 监听播放完成事件
    skillAnim:HookCallback("animover", function(inst)
        -- 如果播放的是cd动画, cd动画播放完成后, 播放cd结束动画
        if skillAnim:GetAnimState():IsCurrentAnimation(skill .. "_cd") then
            skillAnim:GetAnimState():SetDeltaTimeMultiplier(1)
            skillAnim:GetAnimState():PlayAnimation(skill .. "_cd_end")
        end
    end)
    -- 默认cd完成的动画
    skillAnim:GetAnimState():SetPercent(skill .. "_cd_end", 1)
    local buffAnim = createUIAnim(ui, bank, build, offset)
    buffAnim:GetAnimState():AnimateWhilePaused(false)
    buffAnim:Hide()
    buffAnim:HookCallback("animover", function(inst)
        inst:Hide()
    end)
    local ammoAnim = createUIAnim(ui, bank, build, offset)
    ammoAnim:GetAnimState():AnimateWhilePaused(false)
    ammoAnim:Hide()
    local title = ui:AddChild(Text(BODYTEXTFONT, 26))
    title:SetPosition(offset + 3.2, -56, 0)
    title:SetScale(1.6, 1.6, 1.6)
    title:SetString(i18n.get("skill." .. skill .. ".title"))
    ui[skill] = {
        skillAnim = skillAnim,
        buffAnim = buffAnim,
        ammoAnim = ammoAnim
    }
end

local skillConfigs = TUNING.TYPHON_CONFIG.skills

local SkillUI = Class(Widget, function(ui, owner)
    Widget["_ctor"](ui, "TyphonSkillUI")
    ui["owner"] = owner
    -- 获取技能对象的key的数量
    local skillCount = 0
    for _ in pairs(TUNING.TYPHON_CONFIG.skills) do
        skillCount = skillCount + 1
    end
    for k, v in pairs(skillConfigs) do
        addSkillUi(ui, k, skillCount)
        skillCount = skillCount - 1
    end
    ui:SetPosition(-225, 235, 0)
    ui:MoveToBack()
    ui:Show()
end)
-- name, cd, buf, magazine, lock

SkillUI.SetSkillState = function(self, args)
    print('SetSkillState', args.skillName, args.cdTime, args.buffTime, args.ammo, args.lock)
    local skillName = args.skillName
    local cdTime = args.cdTime
    local buffTime = args.buffTime
    local ammo = args.ammo
    local lock = args.lock
    local skillAnims = self[skillName]
    if (not skillAnims) then
        return
    end
    if lock then
        skillAnims.skillAnim:GetAnimState():PlayAnimation(skillName .. "_lock")
        skillAnims.buffAnim:Hide()
        skillAnims.ammoAnim:Hide()
        return
    end
    if ammo ~= nil then
        if ammo > 10 then
            ammo = 10
        end
        if skillAnims.ammoAnim.hideTask then
            skillAnims.ammoAnim.hideTask:Cancel()
            skillAnims.ammoAnim.hideTask = nil
        end
        skillAnims.ammoAnim:Show()
        skillAnims.ammoAnim:GetAnimState():SetPercent('ammo', 1 - (ammo / 10)) -- 0.01修正显示问题
        if ammo == 0 then
            -- 定时1秒后隐藏该动画
            skillAnims.ammoAnim.hideTask = skillAnims.ammoAnim.inst:DoTaskInTime(1, function()
                skillAnims.ammoAnim:Hide()
            end)
        else
            skillAnims.skillAnim:GetAnimState():SetPercent(skillName .. "_stop", 1 - (ammo / 10))
        end
    else
        skillAnims.ammoAnim:Hide()
    end
    if cdTime ~= nil then
        skillAnims.skillAnim:GetAnimState():PlayAnimation(skillName .. "_cd")
        skillAnims.skillAnim:GetAnimState():SetDeltaTimeMultiplier(10 / cdTime)
    end
    if buffTime ~= nil then
        if buffTime > 0 then
            skillAnims.buffAnim:Show()
            skillAnims.buffAnim:GetAnimState():PlayAnimation("buff")
            skillAnims.buffAnim:GetAnimState():SetDeltaTimeMultiplier(10 / buffTime)
        else
            skillAnims.buffAnim:Hide()
        end
    end
end

return SkillUI

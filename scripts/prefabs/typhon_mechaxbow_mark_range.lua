local assets =
{
    Asset("ANIM", "anim/typhon_mechaxbow_mark_range.zip"),
    Asset("ATLAS", "images/map_icons/typhon_mechaxbow_mark_range.xml"),
    -- Add any additional assets here
}


local function init(inst)
    if inst.icon == nil and not inst:HasTag("burnt") then
        inst.icon = SpawnPrefab("globalmapicon")
        inst.icon.MiniMapEntity:SetIsFogRevealer(true)
        inst.icon:AddTag("fogrevealer")
        inst.icon:TrackEntity(inst)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddMiniMapEntity()
    inst:AddTag("typhon_mechaxbow_mark_range")

    inst.MiniMapEntity:SetIcon("typhon_mechaxbow_mark_range.tex")
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetDrawOverFogOfWar(true)


    inst:AddTag("maprevealer")

    inst.entity:SetPristine()

    -- Add components and functionality here


    if not TheWorld.ismastersim then
        return inst
    end
    inst.AnimState:SetBank("typhon_mechaxbow_mark_range")
    inst.AnimState:SetBuild("typhon_mechaxbow_mark_range")
    inst.AnimState:PlayAnimation("mark_range", true)
    inst:AddComponent("maprevealer")

    inst:DoTaskInTime(0, init)
    return inst
end

return Prefab("typhon_mechaxbow_mark_range", fn, assets)
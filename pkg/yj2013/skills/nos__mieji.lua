local nos__mieji = fk.CreateSkill {
  name = "nos__mieji"
}

Fk:loadTranslationTable{
  ['nos__mieji'] = '灭计',
  ['#nos__mieji-choose'] = '灭计：你可以为%arg额外指定一个目标',
  [':nos__mieji'] = '你使用黑色非延时类锦囊仅指定一个目标时，可以额外指定一个目标。',
  ['$nos__mieji1'] = '我要的是斩草除根。',
  ['$nos__mieji2'] = '叫天天不应，叫地地不灵~',
}

nos__mieji:addEffect(fk.AfterCardTargetDeclared, {
  anim_type = "offensive",
  can_trigger = function(skill, event, target, player, data)
    return target == player and player:hasSkill(nos__mieji.name) and
    data.card.color == Card.Black and data.card:isCommonTrick() and
    #TargetGroup:getRealTargets(data.tos) == 1 and #player.room:getUseExtraTargets(data) > 0
  end,
  on_cost = function(skill, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
    targets = room:getUseExtraTargets(data),
    min_num = 1,
    max_num = 1,
    prompt = "#nos__mieji-choose:::" .. data.card:toLogString(),
    skill_name = nos__mieji.name
    })
    if #to > 0 then
    event:setCostData(skill, {tos = to})
    return true
    end
  end,
  on_use = function(skill, event, target, player, data)
    table.insert(data.tos, event:getCostData(skill).tos[1])
  end,
})

return nos__mieji
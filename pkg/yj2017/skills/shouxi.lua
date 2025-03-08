local shouxi = fk.CreateSkill {
  name = "shouxi"
}

Fk:loadTranslationTable{
  ['shouxi'] = '守玺',
  ['@$shouxi'] = '守玺',
  ['#shouxi-discard'] = '守玺：1.弃置一张%arg并获得%dest一张牌2.此【杀】对%dest无效',
  [':shouxi'] = '当你成为【杀】的目标后，你可声明一种未以此法声明过的基本牌或锦囊牌的牌名，然后使用者选择一项：弃置一张你声明的牌，然后获得你的一张牌；或令此【杀】对你无效。',
  ['$shouxi1'] = '天子之位，乃归刘汉！',
  ['$shouxi2'] = '吾父功盖寰区，然且不敢篡窃神器。',
}

shouxi:addEffect(fk.TargetConfirmed, {
  anim_type = "defensive",
  can_trigger = function(skill, event, target, player, data)
    return target == player and player:hasSkill(skill.name) and data.card.trueName == "slash"
  end,
  on_cost = function (skill, event, target, player, data)
    local room = player.room
    local mark = player:getTableMark("@$shouxi")
    local names = {}
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id)
      if card.type ~= Card.TypeEquip and not card.is_derived and not table.contains(mark, card.trueName) then
        table.insertIfNeed(names, card.trueName)
      end
    end
    if #names > 0 then
      if room:askToSkillInvoke(player, { skill_name = skill.name }) then
        local choice = room:askToChoice(player, { choices = names, skill_name = skill.name })
        event:setCostData(skill, choice)
        return true
      end
    end
  end,
  on_use = function(skill, event, target, player, data)
    local room = player.room
    local name = event:getCostData(skill)
    room:addTableMark(player, "@$shouxi", name)
    local from = room:getPlayerById(data.from)
    if #room:askToDiscard(from, { min_num = 1, max_num = 1, pattern = name, skill_name = skill.name, prompt = "#shouxi-discard::"..player.id..":"..name }) == 0 then
      table.insertIfNeed(data.nullifiedTargets, player.id)
    elseif not player:isNude() then
      local card = room:askToChooseCard(from, { target = player, flag = "he", skill_name = skill.name })
      room:obtainCard(from, card, false, fk.ReasonPrey)
    end
  end,
})

return shouxi
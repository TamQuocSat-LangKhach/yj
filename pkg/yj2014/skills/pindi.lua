local pindi = fk.CreateSkill {
  name = "pindi"
}

Fk:loadTranslationTable{
  ['pindi'] = '品第',
  ['#pindi-active'] = '品第：弃置一张未弃置过类别的牌，令一名其他角色摸牌或弃牌（%arg张）',
  ['#pindi-draw'] = '令%dest摸%arg张牌',
  ['#pindi-discard'] = '令%dest弃置%arg张牌',
  [':pindi'] = '出牌阶段，你可以弃置一张于此回合内未以此法弃置过的类别的牌并选择此回合内未以此法选择过的一名其他角色，你选择：1.令其摸X张牌；2.令其弃置X张牌。若其已受伤，你横置。（X为你于此回合内发动过此技能的次数）',
  ['$pindi1'] = '观其风气，查其品行。',
  ['$pindi2'] = '推举贤才，兴盛大魏。',
}

pindi:addEffect('active', {
  anim_type = "control",
  card_num = 1,
  target_num = 1,
  prompt = function(skill, player)
    return "#pindi-active:::" .. (player:usedSkillTimes(pindi.name, Player.HistoryTurn) + 1)
  end,
  card_filter = function(skill, player, to_select, selected)
    if #selected == 0 and not player:prohibitDiscard(Fk:getCardById(to_select)) then
      local mark = player:getTableMark("pindi_types-turn")
      return not table.contains(mark, Fk:getCardById(to_select):getTypeString())
    end
  end,
  target_filter = function(skill, player, to_select, selected)
    return #selected == 0 and to_select ~= player.id and not table.contains(player:getTableMark("pindi_targets-turn"), to_select)
  end,
  on_use = function(skill, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])

    room:addTableMark(player, "pindi_types-turn", Fk:getCardById(effect.cards[1]):getTypeString())
    room:addTableMark(player, "pindi_targets-turn", target.id)

    room:throwCard(effect.cards, pindi.name, player)
    if player.dead or target.dead then return end
    local n = player:usedSkillTimes(pindi.name, Player.HistoryTurn)
    if target:isNude() or room:askToChoice(player, {choices={"#pindi-draw::" .. target.id .. ":" .. n,
                              "#pindi-discard::" .. target.id .. ":" .. n}, skill_name=pindi.name}):startsWith("#pindi-draw") then
      target:drawCards(n, pindi.name)
    else
      room:askToDiscard(target, {min_num=n, max_num=n, include_equip=true, skill_name=pindi.name, cancelable=false})
    end
    if not target.dead and target:isWounded() and not player.dead and not player.chained then
      player:setChainState(true)
    end
  end,
})

return pindi
local mingjian = fk.CreateSkill {
  name = "mingjian"
}

Fk:loadTranslationTable{
  ['mingjian'] = '明鉴',
  ['@@mingjian'] = '明鉴',
  ['@@mingjian-turn'] = '明鉴',
  [':mingjian'] = '出牌阶段限一次，你可以将所有手牌交给一名其他角色，然后该角色下回合的手牌上限+1，且出牌阶段内可以多使用一张【杀】。',
  ['$mingjian1'] = '你我推心置腹，岂能相负。',
  ['$mingjian2'] = '孰忠孰奸，朕尚能明辨！',
}

mingjian:addEffect('active', {
  anim_type = "support",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
  return not player:isKongcheng() and player:usedSkillTimes(mingjian.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
  return #selected == 0 and to_select ~= player.id
  end,
  on_use = function(self, room, effect)
  local player = room:getPlayerById(effect.from)
  local target = room:getPlayerById(effect.tos[1])
  room:moveCardTo(player.player_cards[Player.Hand], Player.Hand, target, fk.ReasonGive, mingjian.name, nil, false, player.id)
  room:addPlayerMark(target, "@@" .. mingjian.name, 1)
  end,
})

mingjian:addEffect(fk.TurnStart, {
  can_refresh = function(self, event, target, player, data)
  return player:getMark("@@mingjian") > 0 and target == player
  end,
  on_refresh = function(self, event, target, player, data)
  local room = player.room
  room:addPlayerMark(player, "@@mingjian-turn", player:getMark("@@mingjian"))
  room:addPlayerMark(player, MarkEnum.AddMaxCardsInTurn, player:getMark("@@mingjian"))
  room:setPlayerMark(player, "@@mingjian", 0)
  end,
})

mingjian:addEffect('targetmod', {
  residue_func = function(self, player, skill, scope)
  if skill.trueName == "slash_skill" and player:getMark("@@mingjian-turn") > 0 and scope == Player.HistoryPhase then
    return player:getMark("@@mingjian-turn")
  end
  end,
})

return mingjian
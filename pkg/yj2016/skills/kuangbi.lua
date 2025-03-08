local kuangbi = fk.CreateSkill {
  name = "kuangbi"
}

Fk:loadTranslationTable{
  ['kuangbi'] = '匡弼',
  ['#kuangbi'] = '匡弼：令一名角色将至多三张牌置为“匡弼”牌，你下回合开始时获得“匡弼”牌，其摸等量牌',
  ['#kuangbi-card'] = '匡弼：将至多三张牌置为 %src 的“匡弼”牌',
  ['$kuangbi'] = '匡弼',
  [':kuangbi'] = '出牌阶段限一次，你可以令一名其他角色将一至三张牌扣置于你的武将牌上。若如此做，你的下回合开始时，你获得武将牌上所有牌，其摸等量的牌。',
  ['$kuangbi1'] = '匡人助己，辅政弼贤。',
  ['$kuangbi2'] = '兴隆大化，佐理时务。',
}

-- 主动技能
kuangbi:addEffect('active', {
  anim_type = "support",
  card_num = 0,
  target_num = 1,
  prompt = "#kuangbi",
  can_use = function(skill, player)
  return player:usedSkillTimes(kuangbi.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(skill, player, to_select, selected, selected_cards)
  return #selected == 0 and to_select ~= player.id and not Fk:currentRoom():getPlayerById(to_select):isNude()
  end,
  on_use = function(skill, room, effect)
  local player = room:getPlayerById(effect.from)
  local target = room:getPlayerById(effect.tos[1])
  local cards = room:askToCards(target, {
    min_num = 1,
    max_num = 3,
    include_equip = true,
    skill_name = kuangbi.name,
    cancelable = false,
    pattern = ".",
    prompt = "#kuangbi-card:"..player.id
  })
  room:setPlayerMark(player, kuangbi.name, target.id)
  player:addToPile("$kuangbi", cards, false, kuangbi.name, target.id, {})
  end,
})

-- 触发技能
kuangbi:addEffect(fk.TurnStart, {
  mute = true,
  can_trigger = function(skill, event, target, player, data)
  return target == player and player:getMark("kuangbi") ~= 0 and #player:getPile("$kuangbi") ~= 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(skill, event, target, player, data)
  local room = player.room
  local to = room:getPlayerById(player:getMark("kuangbi"))
  room:setPlayerMark(player, "kuangbi", 0)
  local cards = player:getPile("$kuangbi")
  room:obtainCard(player, cards, false, fk.ReasonJustMove)
  if not to.dead then
    to:drawCards(#cards, kuangbi.name)
  end
  end,
})

return kuangbi
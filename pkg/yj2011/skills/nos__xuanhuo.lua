local nos__xuanhuo = fk.CreateSkill {
  name = "nos__xuanhuo"
}

Fk:loadTranslationTable{
  ['nos__xuanhuo'] = '眩惑',
  ['#nos__xuanhuo'] = '眩惑：你可以将一张<font color=>♥</font>手牌交给一名其他角色，获得其一张牌，然后交给任一角色',
  ['#nos__xuanhuo-choose'] = '眩惑：选择获得%arg的角色',
  [':nos__xuanhuo'] = '出牌阶段限一次，你可将一张<font color=>♥</font>手牌交给一名其他角色，然后你获得该角色的一张牌并交给除该角色外的其他角色。',
  ['$nos__xuanhuo1'] = '重用许靖，以眩远近。',
  ['$nos__xuanhuo2'] = '给你的，十倍奉还给我。',
}

nos__xuanhuo:addEffect('active', {
  anim_type = "control",
  card_num = 1,
  target_num = 1,
  prompt = "#nos__xuanhuo",
  can_use = function(skill, player)
    return player:usedSkillTimes(nos__xuanhuo.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = function(skill, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).suit == Card.Heart and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  target_filter = function(skill, player, to_select, selected)
    return #selected == 0 and to_select.id ~= player.id
  end,
  on_use = function(skill, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:obtainCard(target.id, effect.cards[1], false, fk.ReasonGive, player.id, nos__xuanhuo.name)
    if target:isNude() or player.dead or target.dead then return end
    local id = room:askToChooseCard(player, {
      target = target,
      flag = "he",
      skill_name = nos__xuanhuo.name
    })
    room:obtainCard(player.id, id, false, fk.ReasonPrey, player.id, nos__xuanhuo.name)
    if player.dead then return end
    local targets = table.map(room:getOtherPlayers(target), Util.IdMapper)
    if #targets == 0 or room:getCardOwner(id) ~= player or room:getCardArea(id) ~= Card.PlayerHand then return end
    local to = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#nos__xuanhuo-choose:::"..Fk:getCardById(id):toLogString(),
      skill_name = nos__xuanhuo.name
    })
    if #to > 0 then
      to = to[1]
    else
      to = player.id
    end
    if to ~= player.id then
      room:obtainCard(to.id, id, false, fk.ReasonGive, player.id)
    end
  end,
})

return nos__xuanhuo
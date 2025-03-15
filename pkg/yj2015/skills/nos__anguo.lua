local nos__anguo = fk.CreateSkill {
  name = "nos__anguo"
}

Fk:loadTranslationTable{
  ['nos__anguo'] = '安国',
  [':nos__anguo'] = '出牌阶段限一次，你可以选择其他角色场上的一张装备牌并令其获得之，然后若其攻击范围内的角色因此而变少，则你摸一张牌。',
  ['$nos__anguo1'] = '止干戈，休战事。',
  ['$nos__anguo2'] = '安邦定国，臣子分内之事。',
}

nos__anguo:addEffect('active', {
  anim_type = "support",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(nos__anguo.name, Player.HistoryPhase) == 0
  end,
  card_filter = function()
    return false
  end,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and to_select ~= player.id and #Fk:currentRoom():getPlayerById(to_select).player_cards[Player.Equip] > 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local n = #table.filter(room:getOtherPlayers(target), function(p) return (target:inMyAttackRange(p)) end)
    local equip = room:askToChooseCard(player, {
      target = target,
      flag = "e",
      skill_name = nos__anguo.name
    })
    room:obtainCard(target, equip, true, fk.ReasonJustMove)
    if n > #table.filter(room:getOtherPlayers(target), function(p) return (target:inMyAttackRange(p)) end) then
      player:drawCards(1, nos__anguo.name)
    end
  end,
})

return nos__anguo
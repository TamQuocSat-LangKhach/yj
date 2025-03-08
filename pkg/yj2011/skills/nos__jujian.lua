local nos__jujian = fk.CreateSkill {
  name = "nos__jujian"
}

Fk:loadTranslationTable{
  ['nos__jujian'] = '举荐',
  ['#nos__jujian'] = '举荐：你可以弃置至多三张牌，令一名角色摸等量牌，若你弃置了三张相同类别牌，你回复1点体力',
  [':nos__jujian'] = '出牌阶段限一次，你可以弃置至多三张牌，令一名其他角色摸等量的牌；若你以此法弃置了三张相同类别的牌，你回复1点体力。',
  ['$nos__jujian1'] = '我看好你！',
  ['$nos__jujian2'] = '将军岂愿抓牌乎？',
}

nos__jujian:addEffect('active', {
  anim_type = "support",
  min_card_num = 1,
  max_card_num = 3,
  target_num = 1,
  prompt = "#nos__jujian",
  can_use = function(skill, player)
    return player:usedSkillTimes(nos__jujian.name, Player.HistoryPhase) == 0 and not player:isNude()
  end,
  card_filter = function(skill, player, to_select, selected)
    return #selected < 3 and not player:prohibitDiscard(Fk:getCardById(to_select))
  end,
  target_filter = function(skill, player, to_select, selected)
    return #selected == 0 and to_select.id ~= player.id
  end,
  on_use = function(skill, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:throwCard(effect.cards, nos__jujian.name, player, player)
    if not target.dead then
      room:drawCards(target, #effect.cards, nos__jujian.name)
    end
    if #effect.cards == 3 and player:isWounded() and not player.dead and
      table.every(effect.cards, function (id) return Fk:getCardById(id).type == Fk:getCardById(effect.cards[1]).type end) then
      room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = nos__jujian.name
      })
    end
  end
})

return nos__jujian
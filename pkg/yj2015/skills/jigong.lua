local jigong = fk.CreateSkill {
  name = "jigong"
}

Fk:loadTranslationTable{
  ['jigong'] = '急攻',
  ['@jigong-turn'] = '急攻',
  [':jigong'] = '出牌阶段开始时，你可以摸两张牌，然后你本回合的手牌上限等于你本阶段造成的伤害值。',
  ['$jigong1'] = '不惜一切代价，拿下此人！',
  ['$jigong2'] = '曹贼势颓，主公速击之。',
}

jigong:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jigong.name) and player.phase == Player.Play
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(2, jigong.name)
  end,
})

jigong:addEffect(fk.Damage, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:usedSkillTimes(jigong.name, Player.HistoryPhase) > 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@jigong-turn", data.damage)
  end,
})

local jigong_maxcards_spec = {
  fixed_func = function (skill, player)
    if player:usedSkillTimes(jigong.name, Player.HistoryTurn) > 0 then
      return player:getMark("@jigong-turn")
    end
  end,
}

jigong:addEffect('maxcards', jigong_maxcards_spec)

return jigong
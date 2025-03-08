local jishe = fk.CreateSkill {
  name = "jishe"
}

Fk:loadTranslationTable{
  ['jishe'] = '极奢',
  ['#jishe'] = '极奢：摸一张牌，本回合你的手牌上限-1',
  ['@jishe-turn'] = '极奢',
  ['#jishe_trigger'] = '极奢',
  ['#jishe-choose'] = '极奢：你可以横置至多%arg名角色',
  [':jishe'] = '出牌阶段，若你的手牌上限大于0，你可以摸一张牌，然后本回合你的手牌上限-1；结束阶段，若你没有手牌，你可以横置至多X名角色（X为你的体力值）。',
  ['$jishe1'] = '孙吴正当盛世，兴些土木又何妨？',
  ['$jishe2'] = '当再建新殿，扬我国威！',
}

-- jishe 主动技
jishe:addEffect('active', {
  anim_type = "drawcard",
  card_num = 0,
  target_num = 0,
  prompt = "#jishe",
  can_use = function(self, player)
  return player:getMaxCards() > 0
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
  local player = room:getPlayerById(effect.from)
  player:drawCards(1, jishe.name)
  if not player.dead then
    room:addPlayerMark(player, "@jishe-turn", 1)
  end
  end,
})

-- jishe_maxcards 手牌上限技能
jishe:addEffect('maxcards', {
  correct_func = function(self, player)
  return -player:getMark("@jishe-turn")
  end,
})

-- jishe_trigger 触发技
jishe:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
  return target == player and player:hasSkill(jishe.name) and player.phase == Player.Finish and player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
  local room = player.room
  local targets = table.map(table.filter(room.alive_players, function(p)
    return not p.chained
  end), Util.IdMapper)

  if #targets == 0 then return end

  local n = player.hp
  local tos = room:askToChoosePlayers(player, {
    targets = targets,
    min_num = 1,
    max_num = n,
    prompt = "#jishe-choose:::"..tostring(n),
    skill_name = jishe.name,
    cancelable = true,
  })
  if #tos > 0 then
    room:sortPlayersByAction(tos)
    event:setCostData(self, {tos = tos})
    return true
  end
  end,
  on_use = function(self, event, target, player, data)
  local room = player.room
  for _, id in ipairs(event:getCostData(self).tos) do
    local to = room:getPlayerById(id)
    if not to.dead then
    to:setChainState(true)
    end
  end
  end,
})

return jishe
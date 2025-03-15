local yanyu = fk.CreateSkill {
  name = "yanyu"
}

Fk:loadTranslationTable{
  ['yanyu'] = '燕语',
  ['#yanyu_record'] = '燕语',
  ['#yanyu-draw'] = '燕语：你可以令一名男性角色摸两张牌',
  [':yanyu'] = '出牌阶段，你可以重铸【杀】；出牌阶段结束时，若你于此阶段内重铸过两张或更多的【杀】，则你可以令一名男性角色摸两张牌。',
  ['$yanyu1'] = '伴君一生不寂寞。',
  ['$yanyu2'] = '感君一回顾，思君朝与暮。',
}

-- 主动技能部分
yanyu:addEffect('active', {
  name = "yanyu",
  anim_type = "drawcard",
  card_num = 1,
  target_num = 0,
  can_use = function(self, player)
    return not player:isKongcheng()
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).trueName == "slash"
  end,
  on_use = function(self, room, effect)
    room:recastCard(effect.cards, room:getPlayerById(effect.from), yanyu.name)
  end,
})

-- 触发技能部分
yanyu:addEffect(fk.EventPhaseEnd, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
  return target == player and player.phase == player.Play and player:usedSkillTimes(yanyu.name, Player.HistoryPhase) > 1 and
    not table.every(player.room:getOtherPlayers(player), function(p) return p.gender ~= General.Male end)
  end,
  on_cost = function(self, event, target, player, data)
  local room = player.room
  local to = room:askToChoosePlayers(player, {
    targets = table.map(table.filter(room:getAlivePlayers(), function(p)
      return p:isMale()
    end), Util.IdMapper),
    min_num = 1,
    max_num = 1,
    prompt = "#yanyu-draw",
    skill_name = yanyu.name,
  })
  if #to > 0 then
    event:setCostData(skill, to[1])
    return true
  end
  end,
  on_use = function(self, event, target, player, data)
  local cost_data = event:getCostData(skill)
  cost_data:drawCards(2, yanyu.name)
  end,
})

return yanyu
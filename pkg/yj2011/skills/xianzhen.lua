local xianzhen = fk.CreateSkill {
  name = "xianzhen"
}

Fk:loadTranslationTable{
  ['xianzhen'] = '陷阵',
  ['#xianzhen'] = '陷阵：与一名角色拼点，若赢，你对其使用牌无距离限制且无视防具，对其使用【杀】无次数限制',
  ['@@xianzhen-turn'] = '陷阵',
  [':xianzhen'] = '出牌阶段限一次，你可以与一名角色拼点：若你赢，直到回合结束，你对该角色使用牌无距离限制且无视其防具牌，使用【杀】无次数限制；若你没赢，你不能使用【杀】直到回合结束。',
  ['$xianzhen1'] = '攻无不克，战无不胜！',
  ['$xianzhen2'] = '破阵斩将，易如反掌！',
}

-- 主动技能效果
xianzhen:addEffect('active', {
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  prompt = "#xianzhen",
  can_use = function(skill, player)
    return not player:isKongcheng() and player:usedSkillTimes(xianzhen.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(skill, player, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= player.id and player:canPindian(Fk:currentRoom():getPlayerById(to_select))
  end,
  on_use = function(skill, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local pindian = player:pindian({target}, xianzhen.name)
    if pindian.results[target.id].winner == player then
      room:addPlayerMark(target, "@@xianzhen-turn")
      room:addTableMark(player, "xianzhen_target-turn", target.id)
      room:addTableMark(player, fk.MarkArmorInvalidTo .. "-turn", target.id)
    else
      room:setPlayerMark(player, "xianzhen_lose-turn", 1)
    end
  end,
})

-- 目标修正技能效果
xianzhen:addEffect('targetmod', {
  bypass_times = function(skill, player, skill_name, scope, card, to)
    return card and to and table.contains(player:getTableMark("xianzhen_target-turn"), to.id)
  end,
  bypass_distances = function(skill, player, skill_name, card, to)
    return card and to and table.contains(player:getTableMark("xianzhen_target-turn"), to.id)
  end,
})

-- 禁用技能效果
xianzhen:addEffect('prohibit', {
  prohibit_use = function(skill, player, card)
    return player:getMark("xianzhen_lose-turn") > 0 and card.trueName == "slash"
  end,
})

return xianzhen
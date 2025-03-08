local gongqi = fk.CreateSkill {
  name = "gongqi"
}

Fk:loadTranslationTable{
  ['gongqi'] = '弓骑',
  ['#gongqi-choose'] = '弓骑：你可以弃置一名其他角色的一张牌',
  [':gongqi'] = '出牌阶段限一次，你可以弃置一张牌，此回合你的攻击范围无限。若你以此法弃置的牌为装备牌，你可以弃置一名其他角色的一张牌。',
  ['$gongqi1'] = '看我箭弩弓张，取你性命！',
  ['$gongqi2'] = '龙驹陷阵，神弓破敌！',
}

gongqi:addEffect('active', {
  anim_type = "offensive",
  card_num = 1,
  target_num = 0,
  can_use = function(skill, player)
    return player:usedSkillTimes(gongqi.name, Player.HistoryPhase) == 0 and not player:isNude()
  end,
  card_filter = function(skill, player, to_select, selected)
    return #selected == 0
  end,
  target_filter = Util.FalseFunc,
  on_use = function(skill, room, effect)
    local player = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, gongqi.name, player, player)
    if player.dead then return end
    room:addPlayerMark(player, "gongqi-turn", 999)
    if Fk:getCardById(effect.cards[1]).type == Card.TypeEquip then
      local to = room:askToChoosePlayers(player, {
        targets = table.map(table.filter(room:getOtherPlayers(player), function(p)
          return not p:isNude() 
        end), Util.IdMapper),
        min_num = 1,
        max_num = 1,
        prompt = "#gongqi-choose",
        skill_name = gongqi.name,
        cancelable = true
      })
      if #to > 0 then
        local target = room:getPlayerById(to[1])
        local id = room:askToChooseCard(player, {
          target = target,
          flag = "he",
          skill_name = gongqi.name
        })
        room:throwCard({id}, gongqi.name, target, player)
      end
    end
  end,
})

gongqi:addEffect('atkrange', {
  name = "#gongqi_attackrange",
  correct_func = function (skill, from, to)
    return from:getMark("gongqi-turn")  --ATTENTION: this is a status skill, shouldn't do arithmatic on it
  end,
})

return gongqi
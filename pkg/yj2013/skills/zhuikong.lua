local zhuikong = fk.CreateSkill {
  name = "zhuikong"
}

Fk:loadTranslationTable{
  ['zhuikong'] = '惴恐',
  ['#zhuikong-invoke'] = '惴恐：你可以与 %dest 拼点，若赢则其本回合使用牌只能指定自己为目标',
  [':zhuikong'] = '一名角色的回合开始时，若你已受伤，你可以与该角色拼点，若你赢，该角色本回合使用的牌不能指定除该角色以外的角色为目标；若你没赢，该角色与你的距离视为1直到回合结束。',
  ['$zhuikong1'] = '诚惶诚恐，夜不能寐。',
  ['$zhuikong2'] = '嘘，隔墙有耳。',
}

zhuikong:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(zhuikong.name) and target ~= player and target.phase == Player.Start then
      return player:isWounded() and player:canPindian(target)
    end
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = zhuikong.name,
      prompt = "#zhuikong-invoke::"..target.id
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local pindian = player:pindian({target}, zhuikong.name)
    if pindian.results[target.id].winner == player then
      room:addPlayerMark(target, "zhuikong_prohibit-turn", 1)
    else
      room:addPlayerMark(player, "zhuikong-turn", 1)
    end
  end
})

zhuikong:addEffect("prohibit", {
  name = "#zhuikong_prohibit",
  is_prohibited = function(self, from, to, card)
    return from:getMark("zhuikong_prohibit-turn") > 0 and from ~= to
  end,
})

zhuikong:addEffect("distance", {
  name = "#zhuikong_distance",
  fixed_func = function(self, from, to)
    if to:usedSkillTimes(zhuikong.name, Player.HistoryTurn) > 0 and to:getMark("zhuikong-turn") > 0 then
      return 1
    end
  end,
})

return zhuikong
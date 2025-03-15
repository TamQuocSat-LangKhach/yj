local nos__zhuikong = fk.CreateSkill {
  name = "nos__zhuikong"
}

Fk:loadTranslationTable{
  ['nos__zhuikong'] = '惴恐',
  ['#nos__zhuikong-invoke'] = '惴恐：你可以与 %dest 拼点，若赢则其本回合跳过出牌阶段',
  [':nos__zhuikong'] = '一名角色的回合开始时，若你已受伤，你可以和该角色进行一次拼点。若你赢，该角色跳过本回合的出牌阶段；若你没赢，该角色与你距离为1直到回合结束。',
  ['$nos__zhuikong1'] = '此密信，切勿落入曹贼手中。',
  ['$nos__zhuikong2'] = '此密诏一出，安知是福是祸？',
}

nos__zhuikong:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player)
    if player:hasSkill(nos__zhuikong.name) and target ~= player and target.phase == Player.Start then
      return player:isWounded() and player:canPindian(target)
    end
  end,
  on_cost = function(self, event, target, player)
    return player.room:askToSkillInvoke(player, {
      skill_name = nos__zhuikong.name,
      prompt = "#nos__zhuikong-invoke::" .. target.id
    })
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local pindian = player:pindian({target}, nos__zhuikong.name)
    if pindian.results[target.id].winner == player then
      target:skip(Player.Play)
    else
      room:addPlayerMark(player, "nos__zhuikong-turn", 1)
    end
  end,
})

nos__zhuikong:addEffect('distance', {
  name = "#nos__zhuikong_distance",
  correct_func = function(self, from, to) return 0 end,
  fixed_func = function(self, from, to)
    if to:usedSkillTimes(nos__zhuikong.name, Player.HistoryTurn) > 0 and to:getMark("nos__zhuikong-turn") > 0 then
      return 1
    end
  end,
})

return nos__zhuikong
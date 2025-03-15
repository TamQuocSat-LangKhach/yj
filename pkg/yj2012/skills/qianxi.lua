local qianxi = fk.CreateSkill {
  name = "qianxi"
}

Fk:loadTranslationTable{
  ['qianxi'] = '潜袭',
  ['#qianxi-choose'] = '潜袭：令一名角色本回合不能使用或打出%arg手牌',
  ['@qianxi-turn'] = '潜袭',
  [':qianxi'] = '准备阶段，你可以进行判定，然后令距离为1的一名角色本回合不能使用或打出与结果颜色相同的手牌。',
  ['$qianxi1'] = '喊什么喊？我敢杀你！',
  ['$qianxi2'] = '笑什么笑？叫你得意！'
}

qianxi:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player)
    return target == player and player:hasSkill(skill.name) and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local judge = {
      who = player,
      reason = skill.name,
      pattern = ".",
    }
    room:judge(judge)
    local targets = {}
    for _, p in ipairs(room.alive_players) do
      if player:distanceTo(p) == 1 then
        table.insert(targets, p.id)
      end
    end
    if #targets == 0 then return end
    local tos = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#qianxi-choose:::"..judge.card:getColorString(),
      skill_name = skill.name,
      cancelable = false,
    })
    room:setPlayerMark(room:getPlayerById(tos[1]), "@qianxi-turn", judge.card:getColorString())
  end,
})

qianxi:addEffect('prohibit', {
  prohibit_use = function(self, player, card)
    return player:getMark("@qianxi-turn") ~= 0 and card:getColorString() == player:getMark("@qianxi-turn")
  end,
  prohibit_response = function(self, player, card)
    return player:getMark("@qianxi-turn") ~= 0 and card:getColorString() == player:getMark("@qianxi-turn")
  end,
})

return qianxi
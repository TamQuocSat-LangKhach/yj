```lua
local jiangchi = fk.CreateSkill {
  name = "jiangchi"
}

Fk:loadTranslationTable{
  ['jiangchi'] = '将驰',
  ['jiangchi+1'] = '多摸一张牌，本回合不能使用或打出【杀】',
  ['jiangchi-1'] = '少摸一张牌，此阶段使用【杀】无距离限制且次数+1',
  [':jiangchi'] = '摸牌阶段，你可以选择一项：1.额外摸一张牌，此回合你不能使用或打出【杀】。2.少摸一张牌，此回合出牌阶段你使用【杀】无距离限制，且你【杀】的使用上限+1。',
  ['$jiangchi1'] = '谨遵父训，不可逞匹夫之勇。',
  ['$jiangchi2'] = '吾定当身先士卒，振魏武雄风！',
}

jiangchi:addEffect(fk.DrawNCards, {
  mute = true,
  on_use = function(self, event, target, player, data)
    local choices = {"jiangchi+1"}
    if data.n > 0 then
      table.insert(choices, "jiangchi-1")
    end
    local choice = player.room:askToChoice(player, {
      choices = choices,
      skill_name = jiangchi.name
    })
    if choice == "jiangchi+1" then
      data.n = data.n + 1
      player.room:notifySkillInvoked(player, jiangchi.name, "defensive")
      player:broadcastSkillInvoke(jiangchi.name, 1)
    else
      player.room:notifySkillInvoked(player, jiangchi.name, "offensive")
      player:broadcastSkillInvoke(jiangchi.name, 2)
      data.n = data.n - 1
    end
    player.room:addPlayerMark(player, choice.."-turn", 1)
  end,
})

jiangchi:addEffect('targetmod', {
  residue_func = function(self, player, skill, scope)
    if player:hasSkill(jiangchi) and skill.trueName == "slash_skill" and player:getMark("jiangchi-1-turn") > 0 and
      scope == Player.HistoryPhase then
      return 1
    end
  end,
})

jiangchi:addEffect('prohibit', {
  prohibit_use = function(self, player, card)
    return player:hasSkill(jiangchi) and player:getMark("jiangchi+1-turn") > 0 and card.trueName == "slash"
  end,
  prohibit_response = function(self, player, card)
    return player:hasSkill(jiangchi) and player:getMark("jiangchi+1-turn") > 0 and card.trueName == "slash"
  end,
})

return jiangchi
```
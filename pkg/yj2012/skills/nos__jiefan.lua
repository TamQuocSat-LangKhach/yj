local nos__jiefan = fk.CreateSkill {
  name = "nos__jiefan"
}

Fk:loadTranslationTable{
  ['nos__jiefan'] = '解烦',
  ['#nos__jiefan-slash'] = '解烦：你可以对 %dest 使用【杀】，若造成伤害，防止此伤害并视为对 %src 使用【桃】',
  [':nos__jiefan'] = '你的回合外，当一名角色处于濒死状态时，你可以对当前回合角色使用一张【杀】，此【杀】造成伤害时，你防止此伤害，视为对该濒死角色使用了一张【桃】。',
  ['$nos__jiefan1'] = '休想趁人之危！',
  ['$nos__jiefan2'] = '退后，这里交给我！',
}

nos__jiefan:addEffect(fk.AskForPeaches, {
  can_trigger = function(self, event, target, player)
    return player:hasSkill(nos__jiefan.name) and target.dying and player.room.current and player.room.current ~= player
  end,
  on_cost = function(self, event, target, player)
    local current_player_id = player.room.current.id
    event:setCostData(self, player.room:askToUseCard(player, {
      pattern = "slash",
      prompt = "#nos__jiefan-slash:" .. target.id .. ":" .. current_player_id,
      cancelable = true,
      extra_data = {must_targets = {current_player_id}}
    }))
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local use = event:getCostData(self)
    use.extra_data = use.extra_data or {}
    use.extra_data.jiefan = {player.id, target.id}
    room:useCard(use)
  end,
})

nos__jiefan:addEffect(fk.DamageCaused, {
  can_trigger = function(self, event, target, player, data)
    if target == player and data.card then
      local e = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      if e then
        local use = e.data[1]
        return use.extra_data and use.extra_data.jiefan and use.extra_data.jiefan[1] == player.id
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local e = room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
    if e then
      local use = e.data[1]
      local to = room:getPlayerById(use.extra_data.jiefan[2])
      if not to.dead then
        room:useVirtualCard("peach", nil, player, to, nos__jiefan.name)
      end
      return true
    end
  end,
})

return nos__jiefan
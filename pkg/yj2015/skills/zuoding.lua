local zuoding = fk.CreateSkill {
  name = "zuoding"
}

Fk:loadTranslationTable{
  ['zuoding'] = '佐定',
  ['#zuoding-choose'] = '佐定：你可以令一名目标角色摸一张牌',
  [':zuoding'] = '当其他角色于其出牌阶段内使用♠牌指定目标后，若本阶段没有角色受到过伤害，你可以令其中一名目标角色摸一张牌。',
  ['$zuoding1'] = '只有忠心，没有谋略，是不够的。',
  ['$zuoding2'] = '承君恩宠，报效国家！',
}

zuoding:addEffect(fk.TargetSpecified, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(zuoding) and target ~= player and target.phase == Player.Play and data.firstTarget
      and data.card.suit == Card.Spade
      and table.find(AimGroup:getAllTargets(data.tos), function(pid) return not player.room:getPlayerById(pid).dead end) then
      return #player.room.logic:getActualDamageEvents(1, Util.TrueFunc, Player.HistoryPhase) == 0
    end
  end,
  on_cost = function(self, event, target, player, data)
    local targets = table.filter(AimGroup:getAllTargets(data.tos), function(pid) return not player.room:getPlayerById(pid).dead end)
    local to = player.room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#zuoding-choose",
      skill_name = zuoding.name,
      cancelable = true
    })
    if #to > 0 then
      event:setCostData(self, to[1])
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local cost_data = event:getCostData(self)
    player.room:getPlayerById(cost_data):drawCards(1, zuoding.name)
  end,
})

return zuoding
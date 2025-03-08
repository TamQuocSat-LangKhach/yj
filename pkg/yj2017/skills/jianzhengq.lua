local jianzhengq = fk.CreateSkill {
  name = "jianzhengq"
}

Fk:loadTranslationTable{
  ['jianzhengq'] = '谏征',
  ['#jianzhengq-invoke'] = '谏征：%dest 使用%arg，你可以将一张手牌置于牌堆顶取消所有目标',
  [':jianzhengq'] = '当其他角色使用【杀】指定目标时，若你在其攻击范围内且你不是目标，你可以将一张手牌置于牌堆顶，取消所有目标，然后若此【杀】不为黑色，你成为目标。',
  ['$jianzhengq1'] = '且慢，此仗打不得！',
  ['$jianzhengq2'] = '天时不当，必难取胜！',
}

jianzhengq:addEffect(fk.TargetSpecifying, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(jianzhengq.name) and target ~= player and data.card.trueName == "slash" and
      not table.contains(AimGroup:getAllTargets(data.tos), player.id) and target:inMyAttackRange(player) and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = jianzhengq.name,
      cancelable = true,
      pattern = ".",
      prompt = "#jianzhengq-invoke::" .. target.id .. ":" .. data.card:toLogString()
    })
    if #card > 0 then
      event:setCostData(self, card)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    room:moveCards({
      ids = event:getCostData(self),
      from = player.id,
      fromArea = Card.PlayerHand,
      toArea = Card.DrawPile,
      moveReason = fk.ReasonPut,
      skillName = jianzhengq.name,
    })
    for _, id in ipairs(TargetGroup:getRealTargets(data.tos)) do
      AimGroup:cancelTarget(data, id)
    end
    if not player.dead and data.card.color ~= Card.Black then
      room:doIndicate(target.id, {player.id})
      AimGroup:addTargets(room, data, player.id)
    end
  end,
})

return jianzhengq
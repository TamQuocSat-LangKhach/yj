local chunlao = fk.CreateSkill {
  name = "chunlao"
}

Fk:loadTranslationTable{
  ['chunlao'] = '醇醪',
  ['chengpu_chun'] = '醇',
  ['#chunlao-cost'] = '醇醪：你可以将任意张【杀】置为“醇”',
  ['#chunlao-invoke'] = '醇醪：你可以将一张“醇”置入弃牌堆，视为 %dest 使用一张【酒】',
  [':chunlao'] = '结束阶段开始时，若你的武将牌上没有牌，你可以将任意数量的【杀】置于你的武将牌上，称为“醇”；当一名角色处于濒死状态时，若其为【酒】的合法目标，你可以将一张“醇”置入弃牌堆，视为该角色使用一张【酒】。',
  ['$chunlao1'] = '唉，帐中不可无酒啊！',
  ['$chunlao2'] = '无碍，且饮一杯！',
}

chunlao:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player)
    return target == player and player.phase == Player.Finish and #player:getPile("chengpu_chun") == 0 and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player)
    local room = player.room
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = player:getHandcardNum(),
      pattern = "slash",
      prompt = "#chunlao-cost"
    })
    if #cards > 0 then
      event:setCostData(self, cards)
      return true
    end
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local cost_data = event:getCostData(self)
    player:addToPile("chengpu_chun", cost_data, true, chunlao.name)
  end,
})

chunlao:addEffect(fk.AskForPeaches, {
  can_trigger = function(self, event, target, player)
    return target.dying and #player:getPile("chengpu_chun") > 0 and not target:isProhibited(target, Fk:cloneCard("analeptic")) and not target:prohibitUse(Fk:cloneCard("analeptic"))
  end,
  on_cost = function(self, event, target, player)
    local room = player.room
    local cards = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      pattern = ".|.|.|chengpu_chun|.|.",
      prompt = "#chunlao-invoke::"..target.id,
      expand_pile = "chengpu_chun"
    })
    if #cards > 0 then
      event:setCostData(self, cards)
      return true
    end
  end,
  on_use = function(self, event, target, player)
    local room = player.room
    local cost_data = event:getCostData(self)
    room:moveCards({
      from = player.id,
      ids = cost_data,
      toArea = Card.DiscardPile,
      moveReason = fk.ReasonPutIntoDiscardPile,
      skillName = chunlao.name,
      specialName = chunlao.name,
    })
    local analeptic = Fk:cloneCard("analeptic")
    room:useCard({
      card = analeptic,
      from = target.id,
      tos = {{target.id}},
      extra_data = {analepticRecover = true},
      skillName = chunlao.name,
    })
  end,
})

return chunlao
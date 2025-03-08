local zhongyong = fk.CreateSkill {
  name = "zhongyong"
}

Fk:loadTranslationTable{
  ['zhongyong'] = '忠勇',
  ['#zhongyong-choose'] = '忠勇：将此【闪】交给除 %dest 以外的一名角色，若不是你，你可以对其再使用一张【杀】',
  ['#zhongyong-slash'] = '忠勇：你可以对 %dest 再使用一张【杀】',
  [':zhongyong'] = '当你于出牌阶段内使用的【杀】被目标角色使用的【闪】抵消时，你可以将此【闪】交给除该角色外的一名角色，若获得此【闪】的角色不是你，你可以对相同的目标再使用一张【杀】。',
  ['$zhongyong1'] = '驱刀飞血，直取寇首！',
  ['$zhongyong2'] = '为将军提刀携马，万死不辞！'
}

zhongyong:addEffect(fk.CardUseFinished, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(zhongyong.name) and player.phase == Player.Play and data.card.name == "jink" and
      data.toCard and data.toCard.trueName == "slash" and data.responseToEvent.from == player.id and
      player.room:getCardArea(data.card) == Card.Processing
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      targets = table.map(room:getOtherPlayers(target), Util.IdMapper),
      min_num = 1,
      max_num = 1,
      prompt = "#zhongyong-choose::" .. target.id,
      skill_name = zhongyong.name,
      cancelable = true
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cost_data = event:getCostData(self)
    local to = cost_data.tos[1]
    room:obtainCard(to, data.card, true, fk.ReasonGive, player.id)
    if to ~= player.id then
      local use = room:askToUseCard(player, {
        pattern = "slash",
        prompt = "#zhongyong-slash::" .. target.id,
        cancelable = true,
        extra_data = {must_targets = {target.id}}
      })
      if use then
        use.extraUse = true
        room:useCard(use)
      end
    end
  end,
})

return zhongyong
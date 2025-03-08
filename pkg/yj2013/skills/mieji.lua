local mieji = fk.CreateSkill {
  name = "mieji"
}

Fk:loadTranslationTable{
  ['mieji'] = '灭计',
  ['#mieji-discard1'] = '灭计：弃置一张锦囊牌或依次弃置两张非锦囊牌',
  ['#mieji-discard2'] = '灭计：再弃置一张非锦囊牌',
  [':mieji'] = '出牌阶段限一次，你可以将一张黑色锦囊牌置于牌堆顶并选择一名其他角色，然后令该角色选择一项：1.弃置一张锦囊牌；2.依次弃置两张非锦囊牌。',
  ['$mieji1'] = '宁错杀，无放过！',
  ['$mieji2'] = '你能逃得出我的手掌心吗？',
}

mieji:addEffect('active', {
  anim_type = "offensive",
  card_num = 1,
  target_num = 1,
  can_use = function(skill, player)
    return player:usedSkillTimes(mieji.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = function(skill, player, to_select, selected)
    local card = Fk:getCardById(to_select)
    return #selected == 0 and card.type == Card.TypeTrick and card.color == Card.Black
  end,
  target_filter = function(skill, player, to_select, selected, selected_cards)
    return #selected == 0 and not Fk:currentRoom():getPlayerById(to_select):isNude()
  end,
  on_use = function(skill, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:moveCards({
      ids = effect.cards,
      from = player.id,
      fromArea = Card.PlayerHand,
      toArea = Card.DrawPile,
      moveReason = fk.ReasonJustMove,
      skillName = mieji.name,
    })
    local ids = room:askToDiscard(target, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = mieji.name,
      cancelable = false,
      pattern = ".",
      prompt = "#mieji-discard1"
    })
    if Fk:getCardById(ids[1]).type ~= Card.TypeTrick then
      room:askToDiscard(target, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = mieji.name,
      cancelable = false,
      pattern = ".|.|.|.|.|basic,equip",
      prompt = "#mieji-discard2"
      })
    end
  end,
})

return mieji
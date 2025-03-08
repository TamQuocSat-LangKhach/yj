local chengxiang = fk.CreateSkill {
  name = "chengxiang"
}

Fk:loadTranslationTable{
  ['chengxiang'] = '称象',
  ['#chengxiang-choose'] = '称象：获得任意点数之和小于或等于13的牌',
  [':chengxiang'] = '每当你受到一次伤害后，你可以亮出牌堆顶的四张牌，然后获得其中任意数量点数之和小于或等于13的牌，将其余的牌置入弃牌堆。',
  ['$chengxiang1'] = '依我看，小事一桩。',
  ['$chengxiang2'] = '孰重孰轻，一称便知。',
}

chengxiang:addEffect(fk.Damaged, {
  anim_type = "masochism",
  on_use = function(skill, event, target, player)
    local room = player.room
    local cards = room:getNCards(4)
    room:moveCards({
      ids = cards,
      toArea = Card.Processing,
      moveReason = fk.ReasonPut,
      proposer = player.id,
      skillName = chengxiang.name,
    })
    local get = room:askToArrangeCards(player, {
      skill_name = chengxiang.name,
      card_map = {cards},
      prompt = "#chengxiang-choose",
      box_size = 0,
      max_limit = {4, 4},
      min_limit = {0, 1},
      pattern = ".",
      poxi_type = "chengxiang_count",
      default_choice = {{}, {cards[1]}}
    })[2]
    room:moveCardTo(get, Player.Hand, player, fk.ReasonJustMove, chengxiang.name, "", true, player.id)
    cards = table.filter(cards, function(id) return room:getCardArea(id) == Card.Processing end)
    if #cards > 0 then
      room:moveCards({
        ids = cards,
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonPutIntoDiscardPile,
      })
    end
  end
})

return chengxiang
local nos__chengxiang = fk.CreateSkill {
  name = "nos__chengxiang"
}

Fk:loadTranslationTable{
  ['nos__chengxiang'] = '称象',
  ['#nos__chengxiang-choose'] = '称象：获得任意点数之和小于13的牌',
  [':nos__chengxiang'] = '每当你受到一次伤害后，你可以亮出牌堆顶的四张牌，然后获得其中任意数量点数之和小于13的牌。',
  ['$nos__chengxiang1'] = '以船载象，以石易象，称石则可得象斤重。',
  ['$nos__chengxiang2'] = '若以冲所言行事，则此象之重可称也。',
}

nos__chengxiang:addEffect(fk.Damaged, {
  anim_type = "masochism",
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:getNCards(4)
    room:moveCards({
      ids = cards,
      toArea = Card.Processing,
      moveReason = fk.ReasonPut,
      proposer = player.id,
      skillName = skill.name,
    })
    local get = {}
    for _, id in ipairs(cards) do
      if Fk:getCardById(id, true).number < 13 then
        table.insert(get, id)
        break
      end
    end
    get = room:askToArrangeCards(player, {
      skill_name = skill.name,
      card_map = {cards},
      prompt = "#nos__chengxiang-choose",
      box_size = 0,
      max_limit = {4, 4},
      min_limit = {0, #get},
      pattern = ".",
      poxi_type = "nos__chengxiang_count",
      default_choice = {{}, get}
    })[2]
    if #get > 0 then
      room:moveCardTo(get, Player.Hand, player, fk.ReasonJustMove, skill.name, "", true, player.id)
    end
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

return nos__chengxiang
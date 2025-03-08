```lua
local jinjiu = fk.CreateSkill {
  name = "jinjiu"
}

Fk:loadTranslationTable{
  ['jinjiu'] = '禁酒',
  [':jinjiu'] = '锁定技，你的【酒】及作为你的判定牌的【酒】的牌名视为【杀】且此【杀】为普【杀】。',
  ['$jinjiu1'] = '贬酒阙色，所以无污。',
  ['$jinjiu2'] = '避嫌远疑，所以无误。',
}

jinjiu:addEffect('filter', {
  card_filter = function(skill, player, card, isJudgeEvent)
    return player:hasSkill(jinjiu.name) and card.name == "analeptic" and
         (table.contains(player.player_cards[Player.Hand], card.id) or isJudgeEvent)
  end,
  view_as = function(skill, player, card)
    return Fk:cloneCard("slash", card.suit, card.number)
  end,
})

return jinjiu
```
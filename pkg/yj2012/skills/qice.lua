```lua
local qice = fk.CreateSkill {
  name = "qice"
}

Fk:loadTranslationTable{
  ['qice'] = '奇策',
  ['#qice-card'] = '发动 奇策，将所有手牌当任意普通锦囊牌使用',
  [':qice'] = '出牌阶段限一次，你可以将所有的手牌当任意普通锦囊牌使用。',
  ['$qice1'] = '倾力为国，算无遗策。',
  ['$qice2'] = '奇策在此，谁与争锋？'
}

qice:addEffect('viewas', {
  prompt = "#qice-card",
  interaction = function()
    local all_names = U.getAllCardNames("t")
    return U.CardNameBox {
      choices = U.getViewAsCardNames(Self, "qice", all_names),
      all_choices = all_names,
      default_choice = "AskToChooseCards"
    }
  end,
  card_filter = Util.FalseFunc,
  view_as = function(skill, player, cards)
    if Fk.all_card_types[skill.interaction.data] == nil then return end
    local card = Fk:cloneCard(skill.interaction.data)
    card:addSubcards(player:getCardIds(Player.Hand))
    card.skillName = skill.name
    return card
  end,
  enabled_at_play = function(skill, player)
    return player:usedSkillTimes(skill.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
})

return qice
```
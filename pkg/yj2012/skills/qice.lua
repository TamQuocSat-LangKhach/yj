
local qice = fk.CreateSkill {
  name = "qice",
}

Fk:loadTranslationTable{
  ["qice"] = "奇策",
  [":qice"] = "出牌阶段限一次，你可以将所有的手牌当任意普通锦囊牌使用。",

  ["#qice"] = "奇策：将所有手牌当任意普通锦囊牌使用",

  ["$qice1"] = "倾力为国，算无遗策。",
  ["$qice2"] = "奇策在此，谁与争锋？"
}

local U = require "packages/utility/utility"

qice:addEffect("viewas", {
  prompt = "#qice",
  interaction = function(self, player)
    local all_names = Fk:getAllCardNames("t")
    return U.CardNameBox {
      choices = player:getViewAsCardNames(qice.name, all_names, player:getCardIds("h")),
      all_choices = all_names,
      default_choice = "AskToChooseCards",
    }
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    if Fk.all_card_types[self.interaction.data] == nil then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcards(player:getCardIds("h"))
    card.skillName = self.name
    return card
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(qice.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
})

return qice

local jiaozhao = fk.CreateSkill {
  name = "jiaozhao"
}

Fk:loadTranslationTable{
  ['jiaozhaoVS'] = '矫诏',
  ['#jiaozhaoVS'] = '矫诏：你可以将“矫诏”牌当本回合被声明的牌使用（不能指定自己为目标）',
  ['jiaozhao'] = '矫诏',
  [':jiaozhaoVS'] = '你可以将“矫诏”牌当本回合被声明的牌使用（不能指定自己为目标）。',
}

jiaozhao:addEffect("viewas", {
  name = "jiaozhaoVS",
  pattern = ".",
  mute = true,
  prompt = "#jiaozhaoVS",
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select):getMark("jiaozhao-inhand") ~= 0
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard(Fk:getCardById(cards[1]):getMark("jiaozhao-inhand"))
    card.skillName = "jiaozhao"
    card:addSubcard(cards[1])
    return card
  end,
  before_use = function(self, player, use)
    local room = player.room
    player:broadcastSkillInvoke(jiaozhao.name)
    room:notifySkillInvoked(player, jiaozhao.name, "special")
    room:handleAddLoseSkills(player, jiaozhaoSkills[player:getMark("jiaozhao_status")].."|-jiaozhaoVS", nil, false, true)
  end,
  enabled_at_play = function(self, player)
    return table.find(player:getCardIds("h"), function(id) return Fk:getCardById(id):getMark("jiaozhao-inhand") ~= 0 end)
  end,
  enabled_at_response = function(self, player, response)
    return not response and player.phase ~= Player.NotActive and
      table.find(player:getCardIds("h"), function(id) return Fk:getCardById(id):getMark("jiaozhao-inhand") ~= 0 end)
  end,
})

jiaozhao:addEffect('prohibit', {
  name = "#jiaozhao_prohibit",
  is_prohibited = function(self, from, to, card)
    return card and from == to and table.contains(card.skillNames, jiaozhao.name)
  end,
})

return jiaozhao
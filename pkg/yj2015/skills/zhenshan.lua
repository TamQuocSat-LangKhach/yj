```lua
local zhenshan = fk.CreateSkill {
  name = "zhenshan"
}

Fk:loadTranslationTable{
  ['zhenshan'] = '振赡',
  ['#zhenshan-choose'] = '振赡：与一名手牌数少于你的角色交换手牌',
  [':zhenshan'] = '每回合限一次，当你需要使用或打出一张基本牌时，你可以与一名手牌数少于你的角色交换手牌，若如此做，视为你使用或打出此牌。',
  ['$zhenshan1'] = '看我如何以无用之力换己所需，哈哈哈！',
  ['$zhenshan2'] = '民不足食，何以养军？',
}

zhenshan:addEffect('viewas', {
  pattern = ".|.|.|.|.|basic",
  interaction = function(self)
    local all_names = U.getAllCardNames("b")
    local names = U.getViewAsCardNames(skill.player, zhenshan.name, all_names)
    if #names == 0 then return end
    return U.CardNameBox {choices = names, all_names = all_names}
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = zhenshan.name
    return card
  end,
  before_use = function(self, player)
    local room = player.room
    local targets = table.map(table.filter(room.alive_players, function(p)
      return (#p.player_cards[Player.Hand] < player:getHandcardNum()) end), Util.IdMapper)
    local tos = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#zhenshan-choose",
      skill_name = zhenshan.name,
      cancelable = false
    })
    if #tos < 1 then return "" end
    local to = room:getPlayerById(tos[1])
    U.swapHandCards(room, player, player, to, zhenshan.name)
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(zhenshan.name, Player.HistoryTurn) == 0 and
      table.find(Fk:currentRoom().alive_players, function(p) return p:getHandcardNum() < player:getHandcardNum() end)
  end,
  enabled_at_response = function(self, player)
    return player:usedSkillTimes(zhenshan.name, Player.HistoryTurn) == 0 and
      table.find(Fk:currentRoom().alive_players, function(p) return p:getHandcardNum() < player:getHandcardNum() end)
  end,
})

return zhenshan
```
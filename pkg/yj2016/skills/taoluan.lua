```lua
local taoluan = fk.CreateSkill {
  name = "taoluan"
}

Fk:loadTranslationTable{
  ['taoluan'] = '滔乱',
  ['#taoluan-prompt'] = '滔乱：每牌名限一次，你可将一张牌当任意一张基本牌或普通锦囊牌使用',
  ['@$taoluan'] = '滔乱',
  ['#taoluan-choose'] = '滔乱：令一名其他角色交给你一张非%arg，或你失去1点体力且本回合〖滔乱〗失效',
  ['#taoluan-card'] = '滔乱：你需交给 %src 一张非%arg，否则其失去1点体力且本回合〖滔乱〗失效',
  [':taoluan'] = '每种牌名限一次，当你需要使用基本牌/普通锦囊牌时，若没有角色处于濒死状态，你可以将一张牌当此基本牌/普通锦囊牌使用，然后你令一名其他角色选择：1.将一张不为基本牌/锦囊牌的牌交给你；2.令你失去1点体力，此技能于当前回合内无效。',
  ['$taoluan1'] = '国家承平，神器稳固，陛下勿忧。',
  ['$taoluan2'] = '睁开你的眼睛看看，现在是谁说了算？'
}

taoluan:addEffect('viewas', {
  pattern = ".",
  prompt = "#taoluan-prompt",
  interaction = function()
    local all_names = U.getAllCardNames("bt")
    return U.CardNameBox {
      choices = U.getViewAsCardNames(Self, "taoluan", all_names, nil, Self:getTableMark("@$taoluan")),
      all_choices = all_names,
      default_choice = "taoluan"
    }
  end,
  card_filter = function(self, player, to_select, selected)
    return #selected == 0 and Fk.all_card_types[self.interaction.data] ~= nil
  end,
  view_as = function(self, player, cards)
    if #cards ~= 1 or Fk.all_card_types[self.interaction.data] == nil then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcard(cards[1])
    card.skillName = taoluan.name
    return card
  end,
  before_use = function(self, player, use)
    player.room:addTableMark(player, "@$taoluan", use.card.trueName)
  end,
  after_use = function(self, player, use)
    if player.dead then return end
    local room = player.room
    local targets = table.map(room:getOtherPlayers(player, false), Util.IdMapper)
    if #targets == 0 then return end
    local type = use.card:getTypeString()
    local tos = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#taoluan-choose:::"..type,
      skill_name = "taoluan",
      cancelable = false
    })
    local to = room:getPlayerById(tos[1])
    local card = room:askToCards(to, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = "taoluan",
      cancelable = true,
      pattern = ".|.|.|.|.|^"..type,
      prompt = "#taoluan-card:"..player.id.."::"..type
    })
    if #card > 0 then
      room:obtainCard(player, card[1], false, fk.ReasonGive, to.id, taoluan.name)
    else
      room:invalidateSkill(player, taoluan.name, "-turn")
      room:loseHp(player, 1, "taoluan")
    end
  end,
  enabled_at_play = function(self, player)
    return table.every(Fk:currentRoom().alive_players, function(p) return not p.dying end)
  end,
  enabled_at_response = function(self, player, response)
    if not response and Fk.currentResponsePattern and
       table.every(Fk:currentRoom().alive_players, function(p) return not p.dying end) then
      local mark = Self:getTableMark("@$taoluan")
      for _, id in ipairs(Fk:getAllCardIds()) do
        local card = Fk:getCardById(id)
        if (card.type == Card.TypeBasic or card:isCommonTrick()) and not card.is_derived and
           Exppattern:Parse(Fk.currentResponsePattern):match(card) then
          if not table.contains(mark, card.trueName) then
            return true
          end
        end
      end
    end
  end,
  on_lose = function (self, player)
    player.room:setPlayerMark(player, "@$taoluan", 0)
  end,
})

return taoluan
```
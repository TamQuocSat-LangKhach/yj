local extension = Package("yczh2017")
extension.extensionName = "yj"

Fk:loadTranslationTable{
  ["yczh2017"] = "原创之魂2017",
}

local xushi = General(extension, "xushi", "wu", 3, 3, General.Female)
local wengua = fk.CreateActiveSkill{
  name = "wengua",
  anim_type = "support",
  card_num = 1,
  target_num = 0,
  prompt = "#wengua",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isNude()
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local choices = {"Cancel", "Top", "Bottom"}
    local choice = room:askForChoice(player, choices, self.name,
      "#wengua-choice::"..player.id..":"..Fk:getCardById(effect.cards[1]):toLogString())
    if choice == "Cancel" then return end
    local index = 1
    if choice == "Bottom" then
      index = -1
    end
    room:moveCards({
      ids = effect.cards,
      from = player.id,
      toArea = Card.DrawPile,
      moveReason = fk.ReasonJustMove,
      skillName = self.name,
      drawPilePosition = index,
    })
    if choice == "Top" then
      player:drawCards(1, self.name, "bottom")
      player:drawCards(1, self.name, "bottom")
    else
      player:drawCards(1, self.name)
      player:drawCards(1, self.name)
    end
  end,
}
local wengua_trigger = fk.CreateTriggerSkill{
  name = "#wengua_trigger",

  refresh_events = {fk.GameStart, fk.EventAcquireSkill, fk.EventLoseSkill, fk.Deathed},
  can_refresh = function(self, event, target, player, data)
    if event == fk.GameStart then
      return player:hasSkill(self.name, true)
    elseif event == fk.EventAcquireSkill or event == fk.EventLoseSkill then
      return data == self and not table.find(player.room:getOtherPlayers(player), function(p) return p:hasSkill("wengua", true) end)
    else
      return target == player and player:hasSkill(self.name, true, true) and
        not table.find(player.room:getOtherPlayers(player), function(p) return p:hasSkill("wengua", true) end)
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.GameStart or event == fk.EventAcquireSkill then
      if player:hasSkill(self.name, true) then
        for _, p in ipairs(room:getOtherPlayers(player)) do
          room:handleAddLoseSkills(p, "wengua&", nil, false, true)
        end
      end
    elseif event == fk.EventLoseSkill or event == fk.Deathed then
      for _, p in ipairs(room:getOtherPlayers(player)) do
        room:handleAddLoseSkills(p, "-wengua&", nil, false, true)
      end
    end
  end,
}
local wengua_active = fk.CreateActiveSkill{
  name = "wengua&",
  anim_type = "support",
  card_num = 1,
  target_num = 1,
  prompt = "#wengua&",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id and Fk:currentRoom():getPlayerById(to_select):hasSkill("wengua")
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local id = effect.cards[1]
    room:obtainCard(target.id, id, false, fk.ReasonGive)
    if room:getCardOwner(id) ~= target or room:getCardArea(id) ~= Card.PlayerHand then return end
    local choices = {"Cancel", "Top", "Bottom"}
    local choice = room:askForChoice(target, choices, "wengua",
      "#wengua-choice::"..player.id..":"..Fk:getCardById(id):toLogString())
    if choice == "Cancel" then return end
    local index = 1
    if choice == "Bottom" then
      index = -1
    end
    room:moveCards({
      ids = effect.cards,
      from = target.id,
      toArea = Card.DrawPile,
      moveReason = fk.ReasonJustMove,
      skillName = "wengua",
      drawPilePosition = index,
    })
    if choice == "Top" then
      player:drawCards(1, "wengua", "bottom")
      target:drawCards(1, "wengua", "bottom")
    else
      player:drawCards(1, "wengua")
      target:drawCards(1, "wengua")
    end
  end,
}
local fuzhu = fk.CreateTriggerSkill{
  name = "fuzhu",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and target ~= player and target.phase == Player.Finish and
      target.gender == General.Male and #player.room.draw_pile <= 10 * player.hp
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#fuzhu-invoke::"..target.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    local n = 0
    local cards = table.simpleClone(room.draw_pile)
    for _, id in ipairs(cards) do
      local card = Fk:getCardById(id, true)
      if card.trueName == "slash" then
        room:useCard({
          from = player.id,
          tos = {{target.id}},
          card = card,
        })
        n = n + 1
      end
      if n >= #room.players or player.dead or target.dead then
        break
      end
    end
    room:shuffleDrawPile()
  end,
}
Fk:addSkill(wengua_active)
wengua:addRelatedSkill(wengua_trigger)
xushi:addSkill(wengua)
xushi:addSkill(fuzhu)
Fk:loadTranslationTable{
  ["xushi"] = "徐氏",
  ["wengua"] = "问卦",
  [":wengua"] = "每名角色出牌阶段限一次，其可以交给你一张牌，然后你可以将此牌置于牌堆顶或牌堆底，你与其从另一端摸一张牌。",
  ["fuzhu"] = "伏诛",
  [":fuzhu"] = "一名男性角色结束阶段，若牌堆剩余牌数不大于你体力值的十倍，你可以依次对其使用牌堆中所有的【杀】（不能超过游戏人数），然后洗牌。",
  ["#wengua"] = "问卦：你可以将一张牌置于牌堆顶或牌堆底，从另一端摸两张牌",
  ["#wengua-choice"] = "问卦：你可以将 %arg 置于牌堆顶或牌堆底，然后你与 %dest 从另一端摸一张牌",
  ["wengua&"] = "问卦",
  [":wengua&"] = "出牌阶段限一次，你可以交给徐氏一张牌，然后其可以将此牌置于牌堆顶或牌堆底，其与你从另一端摸一张牌。",
  ["#wengua&"] = "问卦：你可以交给徐氏一张牌，然后其可以将此牌置于牌堆顶或牌堆底，从另一端各摸一张牌",
  ["#fuzhu-invoke"] = "伏诛：你可以对 %dest 使用牌堆中所有【杀】！",

  ["$wengua1"] = "阴阳相生相克，万事周而复始。",
  ["$wengua2"] = "卦不能佳，可须异日。",
  ["$fuzhu1"] = "我连做梦都在等这一天呢。",
  ["$fuzhu2"] = "既然来了，就别想走了。",
  ["~xushi"] = "莫问前程凶吉，但求落幕无悔。",
}

local caojie = General(extension, "caojie", "qun", 3, 3, General.Female)
local shouxi = fk.CreateTriggerSkill{
  name = "shouxi",
  events = {fk.TargetConfirmed},
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.card.trueName == "slash"
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local mark = type(player:getMark("@$shouxi")) == "table" and player:getMark("@$shouxi") or {}
    local names = {}
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id)
      if card.type ~= Card.TypeEquip and not card.is_derived and not table.contains(mark, card.trueName) then
        table.insertIfNeed(names, card.trueName)
      end
    end
    if #names > 0 then
      if room:askForSkillInvoke(player, self.name) then
        local choice = room:askForChoice(player, names, self.name)
        self.cost_data = choice
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local name = self.cost_data
    local mark = type(player:getMark("@$shouxi")) == "table" and player:getMark("@$shouxi") or {}
    table.insert(mark, name)
    room:setPlayerMark(player, "@$shouxi", mark)
    local from = room:getPlayerById(data.from)
    if #room:askForDiscard(from, 1, 1, false, self.name, true, name, "#shouxi-discard::"..player.id..":"..name) == 0 then
      table.insertIfNeed(data.nullifiedTargets, player.id)
    elseif not player:isNude() then
      local card = room:askForCardChosen(from, player, "he", self.name)
      room:obtainCard(from, card, false, fk.ReasonPrey)
    end
  end,
}
caojie:addSkill(shouxi)
local huimin = fk.CreateTriggerSkill{
  name = "huimin",
  events = {fk.EventPhaseStart},
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Finish and
    table.find(player.room.alive_players, function(p) return p:getHandcardNum() < p.hp end)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local n = #table.filter(room.alive_players, function(p) return p:getHandcardNum() < p.hp end)
    return room:askForSkillInvoke(player, self.name, nil, "#huimin-invoke:::"..n)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local players = table.filter(room.alive_players, function(p) return p:getHandcardNum() < p.hp end)
    player:drawCards(#players, self.name)
    if player:isKongcheng() then return false end
    local cards = room:askForCard(player, #players, #players, false, self.name, false, ".", "#huimin-show:::"..#players)
    player:showCards(cards)
    local tos = room:askForChoosePlayers(player, table.map(players, Util.IdMapper), 1, 1, "#huimin-choose", self.name, false)
    local temp = room:getPlayerById(tos[1])
    table.forEach(room.players, function(p) room:fillAG(p, cards) end)
    while #cards > 0 and #players > 0 do
      if table.contains(players, temp) then
        table.removeOne(players, temp)
        local chosen = room:askForAG(temp, cards, false, self.name)
        room:takeAG(temp, chosen, room.players)
        room:obtainCard(temp, chosen, true, fk.ReasonPrey)
        table.removeOne(cards, chosen)
        cards = table.filter(cards, function(id) return room:getCardOwner(id) == player and room:getCardArea(id) == Card.PlayerHand end)
      end
      temp = temp.next
    end
    table.forEach(room.players, function(p) room:closeAG(p) end)
  end,
}
caojie:addSkill(huimin)
Fk:loadTranslationTable{
  ["caojie"] = "曹节",
  ["shouxi"] = "守玺",
  [":shouxi"] = "当你成为【杀】的目标后，你可声明一种未以此法声明过的基本牌或锦囊牌的牌名，然后使用者选择一项：弃置一张你声明的牌，然后获得你的一张牌；或令此【杀】对你无效。",
  ["@$shouxi"] = "守玺",
  ["#shouxi-discard"] = "守玺：1.弃置一张%arg并获得%dest一张牌2.此【杀】对%dest无效",

  ["huimin"] = "惠民",
  [":huimin"] = "结束阶段开始时，你可以摸X张牌（X为手牌数小于体力值的角色数），然后展示等量的手牌，从你指定的一名角色开始，这些角色依次获得其中一张。",
  ["#huimin-invoke"] = "惠民：摸%arg张牌，再展示等量手牌，令手牌数小于体力值的角色获得",
  ["#huimin-choose"] = "惠民：指定第一个选牌的角色",
  ["#huimin-show"] = "惠民：请展示%arg张手牌，从你指定的角色开始，手牌数小于体力值的角色依次获得其中一张",

  ["$shouxi1"] = "天子之位，乃归刘汉！",
  ["$shouxi2"] = "吾父功盖寰区，然且不敢篡窃神器。",
  ["$huimin1"] = "悬壶济世，施医救民。",
  ["$huimin2"] = "心系百姓，惠布山阳。",
  ["~caojie"] = "皇天必不祚尔。",
}
local caiyong = General(extension, "caiyong", "qun", 3, 3)
local pizhuan = fk.CreateTriggerSkill{
  name = "pizhuan",
  anim_type = "special",
  events = {fk.CardUsing, fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self.name) and data.card.suit == Card.Spade and #player:getPile("pzbook") < 4 then
      return event == fk.CardUsing or data.from ~= player.id
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:addToPile("pzbook", room:getNCards(1)[1], true, self.name)
  end,
}
local pizhuan_maxcards = fk.CreateMaxCardsSkill{
  name = "#pizhuan_maxcards",
  correct_func = function(self, player)
    if player:hasSkill(self.name) then
      return #player:getPile("pzbook")
    end
  end,
}
pizhuan:addRelatedSkill(pizhuan_maxcards)
caiyong:addSkill(pizhuan)
local tongbo = fk.CreateTriggerSkill{
  name = "tongbo",
  anim_type = "special",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Draw and #player:getPile("pzbook") > 0 and not player:isNude()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local piles = room:askForExchange(player, {player:getPile("pzbook"), player:getCardIds("he")}, {"pzbook", player.general}, self.name)
    local cards1, cards2 = {}, {}
    for _, id in ipairs(piles[1]) do
      if room:getCardArea(id) == Player.Hand or room:getCardArea(id) == Player.Equip then
        table.insert(cards1, id)
      end
    end
    for _, id in ipairs(piles[2]) do
      if room:getCardArea(id) == Card.PlayerSpecial then
        table.insert(cards2, id)
      end
    end
    room:moveCards(
      {
        ids = cards2,
        from = player.id,
        to = player.id,
        fromArea = Card.PlayerSpecial,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonExchange,
        proposer = player.id,
        specialName = "pzbook",
        skillName = self.name,
      },
      {
        ids = cards1,
        from = player.id,
        to = player.id,
        fromArea = Card.PlayerHand,
        toArea = Card.PlayerSpecial,
        moveReason = fk.ReasonExchange,
        proposer = player.id,
        specialName = "pzbook",
        skillName = self.name,
      }
    )
    local suits = {}
    for _, id in ipairs(player:getPile("pzbook")) do
      table.insertIfNeed(suits, Fk:getCardById(id).suit)
    end
    if #suits ~= 4 then return false end
    local moveInfos = {}
    local cards = table.simpleClone(player:getPile("pzbook"))
    for _, id in ipairs(cards) do room:setCardMark(Fk:getCardById(id), self.name, 1) end
    while #cards > 0 do
      local _, ret = room:askForUseActiveSkill(player, "tongbo_active", "#tongbo-give", false, data, true)
      local to, give_cards
      if ret then
        give_cards = ret.cards
        to =  ret.targets[1]
      else
        give_cards = cards
        to = table.random(table.map(room:getOtherPlayers(player), Util.IdMapper))
      end
      room:getCardArea(give_cards[1])
      for _, id in ipairs(give_cards) do
        table.removeOne(cards, id)
        room:setCardMark(Fk:getCardById(id), self.name, 0)
      end
      table.insert(moveInfos, {
        ids = give_cards,
        from = player.id,
        fromArea = Card.PlayerSpecial,
        to = to,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonJustMove,
        proposer = player.id,
        specialName = "pzbook",
        skillName = self.name,
      })
    end
    room:moveCards(table.unpack(moveInfos))
  end,
}
caiyong:addSkill(tongbo)
local tongbo_active = fk.CreateActiveSkill{
  name = "tongbo_active",
  mute = true,
  min_card_num = 1,
  target_num = 1,
  expand_pile = "pzbook",
  card_filter = function(self, to_select)
    return Self:getPileNameOfId(to_select) == "pzbook" and Fk:getCardById(to_select):getMark("tongbo") > 0
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
}
Fk:addSkill(tongbo_active)
Fk:loadTranslationTable{
  ["caiyong"] = "蔡邕",

  ["pizhuan"] = "辟撰",
  [":pizhuan"] = "当你使用♠牌时，或你成为其他角色使用♠牌的目标后，你可以将牌堆顶的一张牌置于武将牌上，称为“书”；你至多拥有四张“书”，你的手牌上限+X（X为“书”的数量）。",
  ["pzbook"] = "书",

  ["tongbo"] = "通博",
  [":tongbo"] = "摸牌阶段结束时，你可以用任意张牌替换等量的“书”，然后若你的“书”包含四种花色，你须将所有“书”分配给任意名其他角色。 ",
  ["#tongbo-exchange"] = "通博：你可以用任意张牌替换等量的“书”",
  ["#tongbo-give"] = "通博：你须将所有“书”分配给任意名其他角色",
  ["tongbo_active"] = "通博",

  ["$pizhuan1"] = "无墨不成书，无识不成才。",
  ["$pizhuan2"] = "笔可抒情，亦可诛心。",
  ["$tongbo1"] = "读万卷书，行万里路。",
  ["$tongbo2"] = "博学而不穷，笃行而不倦。",
  ["~caiyong"] = "感叹世事，何罪之有？",
}




return extension

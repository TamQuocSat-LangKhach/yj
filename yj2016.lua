local extension = Package("yczh2016")
extension.extensionName = "yj"

local U = require "packages/utility/utility"

Fk:loadTranslationTable{
  ["yczh2016"] = "原创之魂2016",
}

local guohuanghou = General(extension, "guohuanghou", "wei", 3, 3, General.Female)
local jiaozhaoSkills = {"jiaozhao", "jiaozhaoEx1", "jiaozhaoEx2"}
local jiaozhao = fk.CreateActiveSkill{
  name = "jiaozhao",
  anim_type = "special",
  card_num = 1,
  target_num = 1,
  prompt = "#jiaozhao",
  can_use = function(self, player)
    return not player:isKongcheng() and
      table.every(jiaozhaoSkills, function(s) return player:usedSkillTimes(s, Player.HistoryPhase) == 0 end)
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  target_filter = function(self, to_select, selected)
    if #selected == 0 then
      local n = 999
      for _, p in ipairs(Fk:currentRoom().alive_players) do
        if p ~= Self and Self:distanceTo(p) < n then
          n = Self:distanceTo(p)
        end
      end
      return Self:distanceTo(Fk:currentRoom():getPlayerById(to_select)) == n
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    player:showCards(effect.cards)
    if player.dead then return end
    local c = Fk:getCardById(effect.cards[1])
    local names = {}
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id)
      if card.type == Card.TypeBasic and not card.is_derived then
        table.insertIfNeed(names, card.name)
      end
    end
    local choice = room:askForChoice(target, names, self.name, "#jiaozhao-choice:"..player.id.."::"..c:toLogString())
    room:doBroadcastNotify("ShowToast", Fk:translate("jiaozhao_choice")..Fk:translate(choice))
    if room:getCardOwner(c) == player and room:getCardArea(c) == Card.PlayerHand then
      room:setCardMark(c, "jiaozhao-inhand", choice)
      room:setCardMark(c, "@jiaozhao-inhand", Fk:translate(choice))
      room:handleAddLoseSkills(player, "-jiaozhao|jiaozhaoVS", nil, false, true)
    end
  end,
}
local jiaozhaoVS = fk.CreateViewAsSkill{
  name = "jiaozhaoVS",
  pattern = ".",
  mute = true,
  prompt = "#jiaozhaoVS",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select):getMark("jiaozhao-inhand") ~= 0
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return end
    local card = Fk:cloneCard(Fk:getCardById(cards[1]):getMark("jiaozhao-inhand"))
    card.skillName = "jiaozhao"
    card:addSubcard(cards[1])
    return card
  end,
  before_use = function(self, player, use)
    local room = player.room
    player:broadcastSkillInvoke("jiaozhao")
    room:notifySkillInvoked(player, "jiaozhao", "special")
    room:handleAddLoseSkills(player, jiaozhaoSkills[player:getMark("jiaozhao_status")].."|-jiaozhaoVS", nil, false, true)
  end,
  enabled_at_play = function(self, player)
    return table.find(player:getCardIds("h"), function(id) return Fk:getCardById(id):getMark("jiaozhao-inhand") ~= 0 end)
  end,
  enabled_at_response = function(self, player, response)
    return not response and player.phase ~= Player.NotActive and
      table.find(player:getCardIds("h"), function(id) return Fk:getCardById(id):getMark("jiaozhao-inhand") ~= 0 end)
  end,
}
local jiaozhao_prohibit = fk.CreateProhibitSkill{
  name = "#jiaozhao_prohibit",
  is_prohibited = function(self, from, to, card)
    return card and from == to and table.contains(card.skillNames, "jiaozhao")
  end,
}
local jiaozhao_change = fk.CreateTriggerSkill{
  name = "#jiaozhao_change",

  refresh_events = {fk.GameStart, fk.EventAcquireSkill, fk.TurnStart, fk.TurnEnd},
  can_refresh = function(self, event, target, player, data)
    if event == fk.GameStart then
      return player:hasSkill("jiaozhao")
    elseif target == player then
      if event == fk.EventAcquireSkill then
        return data.name == "jiaozhao"
      elseif event == fk.TurnStart or event == fk.TurnEnd then
        return player:hasSkill("jiaozhaoVS", true)
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.GameStart then
      room:setPlayerMark(player, "jiaozhao_status", 1)
    else
      if player:getMark("jiaozhao_status") == 0 then
        room:setPlayerMark(player, "jiaozhao_status", 1)
      end
      if event == fk.TurnStart or event == fk.TurnEnd then
        for _, id in ipairs(player:getCardIds("h")) do
          room:setCardMark(Fk:getCardById(id), "jiaozhao-inhand", 0)
          room:setCardMark(Fk:getCardById(id), "@jiaozhao-inhand", 0)
        end
      end
      room:handleAddLoseSkills(player, jiaozhaoSkills[player:getMark("jiaozhao_status")].."|-jiaozhaoVS", nil, false, true)
    end
  end,
}
local jiaozhaoEx1 = fk.CreateActiveSkill{
  name = "jiaozhaoEx1",
  mute = true,
  card_num = 1,
  target_num = 1,
  prompt = "#jiaozhaoEx1",
  can_use = function(self, player)
    return not player:isKongcheng() and
      table.every(jiaozhaoSkills, function(s) return player:usedSkillTimes(s, Player.HistoryPhase) == 0 end)
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  target_filter = function(self, to_select, selected)
    if #selected == 0 then
      local n = 999
      for _, p in ipairs(Fk:currentRoom().alive_players) do
        if p ~= Self and Self:distanceTo(p) < n then
          n = Self:distanceTo(p)
        end
      end
      return Self:distanceTo(Fk:currentRoom():getPlayerById(to_select)) == n
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    player:broadcastSkillInvoke("jiaozhao")
    room:notifySkillInvoked(player, "jiaozhao", "special")
    player:showCards(effect.cards)
    if player.dead then return end
    local c = Fk:getCardById(effect.cards[1])
    local names = {}
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id)
      if (card.type == Card.TypeBasic or card:isCommonTrick()) and not card.is_derived then
        table.insertIfNeed(names, card.name)
      end
    end
    local choice = room:askForChoice(target, names, "jiaozhao", "#jiaozhao-choice:"..player.id.."::"..c:toLogString())
    room:doBroadcastNotify("ShowToast", Fk:translate("jiaozhao_choice")..Fk:translate(choice))
    if room:getCardOwner(c) == player and room:getCardArea(c) == Card.PlayerHand then
      room:setCardMark(c, "jiaozhao-inhand", choice)
      room:setCardMark(c, "@jiaozhao-inhand", Fk:translate(choice))
      room:handleAddLoseSkills(player, "-jiaozhaoEx1|jiaozhaoVS", nil, false, true)
    end
  end,
}
local jiaozhaoEx2 = fk.CreateActiveSkill{
  name = "jiaozhaoEx2",
  mute = true,
  card_num = 1,
  target_num = 0,
  prompt = "#jiaozhaoEx2",
  can_use = function(self, player)
    return not player:isKongcheng() and
      table.every(jiaozhaoSkills, function(s) return player:usedSkillTimes(s, Player.HistoryPhase) == 0 end)
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  target_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    player:broadcastSkillInvoke("jiaozhao")
    room:notifySkillInvoked(player, "jiaozhao", "special")
    player:showCards(effect.cards)
    if player.dead then return end
    local c = Fk:getCardById(effect.cards[1])
    local names = {}
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id)
      if (card.type == Card.TypeBasic or card:isCommonTrick()) and not card.is_derived then
        table.insertIfNeed(names, card.name)
      end
    end
    local choice = room:askForChoice(player, names, "jiaozhao", "#jiaozhao-choice:"..player.id.."::"..c:toLogString())
    room:doBroadcastNotify("ShowToast", Fk:translate("jiaozhao_choice")..Fk:translate(choice))
    if room:getCardOwner(c) == player and room:getCardArea(c) == Card.PlayerHand then
      room:setCardMark(c, "jiaozhao-inhand", choice)
      room:setCardMark(c, "@jiaozhao-inhand", Fk:translate(choice))
      room:handleAddLoseSkills(player, "-jiaozhaoEx2|jiaozhaoVS", nil, false, true)
    end
  end,
}
local danxin = fk.CreateTriggerSkill{
  name = "danxin",
  anim_type = "masochism",
  events = {fk.Damaged},
  on_cost = function(self, event, target, player, data)
    local choices = {"Cancel", "draw1"}
    if player:getMark("jiaozhao_status") > 0 and player:getMark("jiaozhao_status") < 3 then
      table.insert(choices, "updateJiaozhao")
    end
    local choice = player.room:askForChoice(player, choices, self.name)
    if choice ~= "Cancel" then
      self.cost_data = choice
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    if self.cost_data == "draw1" then
      player:drawCards(1, self.name)
    else
      local room = player.room
      local n = player:getMark("jiaozhao_status")
      room:addPlayerMark(player, "jiaozhao_status", 1)
      if not player:hasSkill("jiaozhaoVS", true) then
        room:handleAddLoseSkills(player, jiaozhaoSkills[n + 1].."|-"..jiaozhaoSkills[n], nil, false, true)
      end
    end
  end,
}
jiaozhaoVS:addRelatedSkill(jiaozhao_prohibit)
Fk:addSkill(jiaozhaoVS)
Fk:addSkill(jiaozhaoEx1)
Fk:addSkill(jiaozhaoEx2)
jiaozhao:addRelatedSkill(jiaozhao_change)
guohuanghou:addSkill(danxin)
guohuanghou:addSkill(jiaozhao)
Fk:loadTranslationTable{
  ["guohuanghou"] = "郭皇后",
  ["#guohuanghou"] = "月华驱霾",
  ["designer:guohuanghou"] = "杰米Y",
  ["illustrator:guohuanghou"] = "樱花闪乱",

  ["jiaozhao"] = "矫诏",
  [":jiaozhao"] = "出牌阶段限一次，你可以展示一张手牌并选择一名距离最近的其他角色，该角色声明一种基本牌的牌名，本回合你可以将此牌当声明的牌使用"..
  "（不能指定自己为目标）。",
  ["danxin"] = "殚心",
  [":danxin"] = "当你受到伤害后，你可以摸一张牌，或修改〖矫诏〗。",
  ["jiaozhaoEx1"] = "矫诏",
  [":jiaozhaoEx1"] = "出牌阶段限一次，你可以展示一张手牌，然后选择一名距离最近的其他角色，该角色声明一种基本牌或普通锦囊牌的牌名，"..
  "本回合你可以将此牌当声明的牌使用（不能指定自己为目标）。",
  ["jiaozhaoEx2"] = "矫诏",
  [":jiaozhaoEx2"] = "出牌阶段限一次，你可以展示一张手牌，然后声明一种基本牌或普通锦囊牌的牌名，本回合你可以将此牌当声明的牌使用（不能指定自己为目标）。",
  ["jiaozhaoVS"] = "矫诏",
  [":jiaozhaoVS"] = "你可以将“矫诏”牌当本回合被声明的牌使用（不能指定自己为目标）。",
  ["#jiaozhao"] = "矫诏：展示一张手牌令一名角色声明一种基本牌，你本回合可以将此牌当声明的牌使用",
  ["#jiaozhaoEx1"] = "矫诏：展示一张手牌令一名角色声明一种基本牌或普通锦囊牌，你本回合可以将此牌当声明的牌使用",
  ["#jiaozhaoEx2"] = "矫诏：展示一张手牌并声明一种基本牌或普通锦囊牌，你本回合可以将此牌当声明的牌使用",
  ["#jiaozhaoVS"] = "矫诏：你可以将“矫诏”牌当本回合被声明的牌使用（不能指定自己为目标）",
  ["#jiaozhao-choice"] = "矫诏：声明一种牌名，%src 本回合可以将%arg当此牌使用",
  ["jiaozhao_choice"] = "矫诏声明牌名：",
  ["@jiaozhao-inhand"] = "矫诏",
  ["updateJiaozhao"] = "修改矫诏",

  ["$jiaozhao1"] = "诏书在此，不得放肆！",
  ["$jiaozhao2"] = "妾身也是逼不得已，方才出此下策。",
  ["$danxin1"] = "司马一族，其心可诛。",
  ["$danxin2"] = "妾身定为我大魏鞠躬尽瘁，死而后已。",
  ["~guohuanghou"] = "陛下，臣妾这就来见你。",
}

local sunziliufang = General(extension, "sunziliufang", "wei", 3)
local guizao = fk.CreateTriggerSkill{
  name = "guizao",
  anim_type = "defensive",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and player.phase == Player.Discard then
      local yes, suits = true, {}
      player.room.logic:getEventsOfScope(GameEvent.MoveCards, 999, function(e)
        for _, move in ipairs(e.data) do
          if move.from == player.id and move.moveReason == fk.ReasonDiscard then
            for _, info in ipairs(move.moveInfo) do
              local card = Fk:getCardById(info.cardId)
              if not table.contains(suits, card.suit) then
                table.insertIfNeed(suits, card.suit)
              elseif card.suit ~= Card.NoSuit then
                yes = false
                return
              end
            end
          end
        end
      end, Player.HistoryPhase)
      return yes and #suits > 1
    end
  end,
  on_cost = function(self, event, target, player, data)
    local choices = {"Cancel", "draw1"}
    if player:isWounded() then
      table.insert(choices, "recover")
    end
    local choice = player.room:askForChoice(player, choices, self.name)
    if choice ~= "Cancel" then
      self.cost_data = choice
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    if self.cost_data == "draw1" then
      player:drawCards(1, self.name)
    else
      player.room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name
      })
    end
  end,
}
local jiyu = fk.CreateActiveSkill{
  name = "jiyu",
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  prompt = "#jiyu",
  can_use = function(self, player)
    return table.find(player:getCardIds("h"), function(id)
      local card = Fk:getCardById(id)
      return player:canUse(card) and not player:prohibitUse(card)
    end)
  end,
  card_filter = function(self, to_select, selected)
    return false
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and (Self:getMark("jiyu-phase") == 0 or not table.contains(Self:getMark("jiyu-phase"), to_select)) and
      not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local mark = player:getMark("jiyu-phase")
    if mark == 0 then mark = {} end
    table.insert(mark, target.id)
    room:setPlayerMark(player, "jiyu-phase", mark)
    local card = room:askForDiscard(target, 1, 1, false, self.name, false, ".", "#jiyu-discard:"..player.id)
    if Fk:getCardById(card[1]).suit == Card.NoSuit then return end
    mark = player:getMark("@jiyu-turn")
    if mark == 0 then mark = {} end
    table.insertIfNeed(mark, Fk:getCardById(card[1]):getSuitString(true))
    room:setPlayerMark(player, "@jiyu-turn", mark)
    if Fk:getCardById(card[1]).suit == Card.Spade then
      if not target.dead then
        room:loseHp(target, 1, self.name)
      end
      if not player.dead then
        player:turnOver()
      end
    end
  end,
}
local jiyu_prohibit = fk.CreateProhibitSkill{
  name = "#jiyu_prohibit",
  prohibit_use = function(self, player, card)
    return player:getMark("@jiyu-turn") ~= 0 and table.contains(player:getMark("@jiyu-turn"), card:getSuitString(true))
  end,
}
jiyu:addRelatedSkill(jiyu_prohibit)
sunziliufang:addSkill(guizao)
sunziliufang:addSkill(jiyu)
Fk:loadTranslationTable{
  ["sunziliufang"] = "孙资刘放",
  ["#sunziliufang"] = "服谗搜慝",
  ["designer:sunziliufang"] = "Rivers",
  ["illustrator:sunziliufang"] = "sinno",

  ["guizao"] = "瑰藻",
  [":guizao"] = "弃牌阶段结束时，若你本阶段弃置过至少两张牌且花色均不相同，你可以回复1点体力或摸一张牌。",
  ["jiyu"] = "讥谀",
  [":jiyu"] = "出牌阶段每名角色限一次，若你有可以使用的手牌，你可以令一名角色弃置一张手牌，然后本回合你不能使用与之相同花色的牌。"..
  "若其以此法弃置的牌为♠，其失去1点体力，你翻面。",
  ["#jiyu"] = "讥谀：令一名角色弃置一张手牌，若为♠，其失去1点体力，你翻面",
  ["#jiyu-discard"] = "讥谀：请弃置一张手牌，若为♠，%src 失去1点体力，你翻面",
  ["@jiyu-turn"] = "讥谀",

  ["$guizao1"] = "这都是陛下的恩泽呀。",
  ["$guizao2"] = "陛下盛宠，臣万莫敢忘。",
  ["$jiyu1"] = "陛下，此人不堪大用。",
  ["$jiyu2"] = "尔等玩忽职守，依诏降职处置。",
  ["~sunziliufang"] = "唉，树倒猢狲散，鼓破众人捶呀。",
}

local liyans = General(extension, "liyans", "shu", 3)
local duliang = fk.CreateActiveSkill{
  name = "duliang",
  anim_type = "support",
  card_num = 0,
  target_num = 1,
  prompt = "#duliang",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected)
    return false
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id and not Fk:currentRoom():getPlayerById(to_select):isNude()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local card = room:askForCardChosen(player, target, "he", self.name)
    room:obtainCard(player.id, card, false, fk.ReasonPrey)
    if player.dead or target.dead then return end
    local choice = room:askForChoice(player, {"duliang_view", "duliang_draw"}, self.name, "#duliang-choice::"..target.id)
    if choice == "duliang_view" then
      local cards = room:getNCards(2)
      U.viewCards(target, cards, self.name)
      for i = #cards, 1, -1 do
        local id = cards[i]
        if Fk:getCardById(id).type ~= Card.TypeBasic then
          table.insert(room.draw_pile, 1, id)
          table.remove(cards, i)
        end
      end
      if #cards > 0 then
        room:moveCardTo(cards, Card.PlayerHand, target, fk.ReasonPrey, self.name, "", false)
      end
    else
      room:addPlayerMark(target, "@duliang", 1)
    end
  end,
}
local duliang_trigger = fk.CreateTriggerSkill{
  name = "#duliang_trigger",
  mute = true,
  events = {fk.DrawNCards},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@duliang") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.n = data.n + player:getMark("@duliang")
    player.room:setPlayerMark(player, "@duliang", 0)
  end,
}
local fulin = fk.CreateMaxCardsSkill{
  name = "fulin",
  frequency = Skill.Compulsory,
  exclude_from = function(self, player, card)
    return player:hasSkill(self) and card:getMark("@@fulin-inhand") > 0
  end,
}
local fulin_record = fk.CreateTriggerSkill{
  name = "#fulin_record",
  refresh_events = {fk.AfterCardsMove, fk.TurnEnd},
  can_refresh = function(self, event, target, player, data)
    if player:hasShownSkill(fulin, true) then
      if event == fk.AfterCardsMove and player.phase ~= Player.NotActive then
        for _, move in ipairs(data) do
          if move.to == player.id and move.toArea == Card.PlayerHand then
            return true
          end
        end
      elseif event == fk.TurnEnd then
        return target == player
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.AfterCardsMove then
      for _, move in ipairs(data) do
        if move.to == player.id and move.toArea == Card.PlayerHand then
          for _, info in ipairs(move.moveInfo) do
            room:setCardMark(Fk:getCardById(info.cardId), "@@fulin-inhand", 1)
          end
        end
      end
    else
      for _, id in ipairs(player:getCardIds("h")) do
        room:setCardMark(Fk:getCardById(id), "@@fulin-inhand", 0)
      end
    end
  end,
}
local fulin_audio = fk.CreateTriggerSkill{
  name = "#fulin_audio",
  refresh_events = {fk.EventPhaseStart},
  can_refresh = function(self, event, target, player, data)
    return player == target and player:hasSkill(self) and player.phase == Player.Discard and not player:isFakeSkill(fulin)
    and player:getMaxCards() < player:getHandcardNum() and table.find(player:getCardIds("h"), function (id)
      return Fk:getCardById(id):getMark("@@fulin-inhand") > 0
    end)
  end,
  on_refresh = function(self, event, target, player, data)
    player:broadcastSkillInvoke("fulin")
  end,
}
duliang:addRelatedSkill(duliang_trigger)
fulin:addRelatedSkill(fulin_record)
fulin:addRelatedSkill(fulin_audio)
liyans:addSkill(duliang)
liyans:addSkill(fulin)
Fk:loadTranslationTable{
  ["liyans"] = "李严",
  ["#liyans"] = "矜风流务",
  ["designer:liyans"] = "RP集散中心",
  ["illustrator:liyans"] = "米SIR",

  ["duliang"] = "督粮",
  [":duliang"] = "出牌阶段限一次，你可以获得一名其他角色一张牌，然后选择一项：1.其观看牌堆顶的两张牌，获得其中的基本牌；2.其下个摸牌阶段额外摸一张牌。",
  ["fulin"] = "腹鳞",
  [":fulin"] = "锁定技，你于回合内获得的牌不计入手牌上限。",
  ["#duliang"] = "督粮：获得一名其他角色一张牌，然后令其获得基本牌或其下个摸牌阶段多摸一张牌",
  ["duliang_view"] = "其观看牌堆顶的两张牌，获得其中的基本牌",
  ["duliang_draw"] = "其下个摸牌阶段额外摸一张牌",
  ["#duliang-choice"] = "督粮：选择令 %dest 执行的一项",
  ["@duliang"] = "督粮",
  ["#duliang_trigger"] = "督粮",
  ["@@fulin-inhand"] = "腹鳞",

  ["$duliang1"] = "粮草已到，请将军验看。",
  ["$duliang2"] = "告诉丞相，山路难走！请宽限几天。",
  ["$fulin1"] = "丞相，丞相！你们没看见我吗？",
  ["$fulin2"] = "我乃托孤重臣，却在这儿搞什么粮草！",
  ["~liyans"] = "孔明这一走，我算是没指望了。",
}

local huanghao = General(extension, "huanghao", "shu", 3)
local qinqing = fk.CreateTriggerSkill{
  name = "qinqing",
  events = {fk.EventPhaseStart},
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if target == player and player.phase == Player.Finish and player:hasSkill(self) then
      local lord = player.room:getLord()  --暂不考虑主公身份被变掉且没有主公的情况，以及多个主公的情况（3v3）
      if not lord then
        lord = table.filter(player.room.players, function(p) return p.seat == 1 end)
      end
      return lord and not lord.dead and table.find(player.room.alive_players, function(p) return p:inMyAttackRange(lord) end)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local lord = room:getLord()
    if not lord then
      lord = table.filter(room.players, function(p) return p.seat == 1 end)[1]
    end
    local targets = table.filter(room.alive_players, function(p) return p:inMyAttackRange(lord) end)
    local tos = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 999, "#qinqing-choose", self.name, true)
    if #tos > 0 then
      self.cost_data = tos
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local tos = table.map(self.cost_data, Util.Id2PlayerMapper)
    for _, p in ipairs(tos) do
      if not p:isNude() then
        local cid = room:askForCardChosen(player, p, "he", self.name)
        room:throwCard({cid}, self.name, p, player)
      end
      if not p.dead then
        p:drawCards(1, self.name)
      end
    end
    local lord = room:getLord()
    if not lord then
      lord = table.filter(room.players, function(p) return p.seat == 1 end)[1]
    end
    if lord.dead then return end
    local n = #table.filter(tos, function(p) return p:getHandcardNum() > lord:getHandcardNum() end)
    if not player.dead and n > 0 then
      player:drawCards(n, self.name)
    end
  end,
}
local huisheng = fk.CreateTriggerSkill{
  name = "huisheng",
  events = {fk.DamageInflicted},
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and not player:isNude() and data.from and data.from ~= player
      and not data.from.dead and (player:getMark(self.name) == 0 or not table.contains(player:getMark(self.name), data.from.id))
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askForCard(player, 1, 999, true, self.name, true, ".", "#huisheng-invoke:"..data.from.id)
    if #cards > 0 then
      self.cost_data = cards
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = self.cost_data
    local n = #cards
    local get = room:askForCardChosen(data.from, player, {card_data = {{player.general, cards}}}, self.name)
    if #room:askForDiscard(data.from, n, n, true, self.name, true, ".",
      "#huisheng-discard::"..player.id..":"..n..":"..Fk:getCardById(get,true):toLogString()) ~= n then
      local mark = player:getMark(self.name)
      if mark == 0 then mark = {} end
      table.insert(mark, data.from.id)
      room:setPlayerMark(player, self.name, mark)
      room:obtainCard(data.from, get, false, fk.ReasonPrey)
      return true
    end
  end,
}
huanghao:addSkill(qinqing)
huanghao:addSkill(huisheng)
Fk:loadTranslationTable{
  ["huanghao"] = "黄皓",
  ["#huanghao"] = "便辟佞慧",
  ["designer:huanghao"] = "凌天翼",
  ["illustrator:huanghao"] = "2B铅笔",

  ["qinqing"] = "寝情",
  [":qinqing"] = "结束阶段，你可以选择任意名攻击范围内含有主公的角色，然后你弃置这些角色的一张牌（无牌则不弃），并令这些角色依次摸一张牌。"..
  "若如此做，你摸X张牌（X为这些角色中手牌数大于主公的角色数）。",
  ["#qinqing-choose"] = "寝情：选择任意名攻击范围内含有主公的角色",
  ["huisheng"] = "贿生",
  [":huisheng"] = "当你受到其他角色造成的伤害时，你可以选择至少一张牌，令其观看之并选择一项：1.获得其中一张，防止此伤害，然后你不能再对其发动此技能；"..
  "2.弃置等量的牌。",
  ["#huisheng-invoke"] = "贿生：你可选择至少一张牌令 %src 观看之",
  ["#huisheng-discard"] = "贿生：弃置%arg张牌，否则你获得%arg2并防止对%dest造成的伤害",

  ["$qinqing1"] = "陛下勿忧，大将军危言耸听。",
  ["$qinqing2"] = "陛下，莫让他人知晓此事！",
  ["$huisheng1"] = "大人，这些钱够吗？",
  ["$huisheng2"] = "劳烦大人美言几句~",
  ["~huanghao"] = "魏军竟然真杀来了！",
}

local sundeng = General(extension, "sundeng", "wu", 4)
local kuangbi = fk.CreateActiveSkill{
  name = "kuangbi",
  anim_type = "support",
  card_num = 0,
  target_num = 1,
  prompt = "#kuangbi",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id and not Fk:currentRoom():getPlayerById(to_select):isNude()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local cards = room:askForCard(target, 1, 3, true, self.name, false, ".", "#kuangbi-card:"..player.id)
    room:setPlayerMark(player, self.name, target.id)
    player:addToPile(self.name, cards, false, self.name, target.id, {})
  end,
}
local kuangbi_trigger = fk.CreateTriggerSkill {
  name = "#kuangbi_trigger",
  mute = true,
  events = {fk.TurnStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("kuangbi") ~= 0 and #player:getPile("kuangbi") ~= 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(player:getMark("kuangbi"))
    room:setPlayerMark(player, "kuangbi", 0)
    local dummy = Fk:cloneCard("dilu")
    dummy:addSubcards(player:getPile("kuangbi"))
    room:obtainCard(player, dummy, false, fk.ReasonJustMove)
    if not to.dead then
      room:doIndicate(player.id, {to.id})
      to:drawCards(#dummy.subcards, "kuangbi")
    end
  end,
}
kuangbi:addRelatedSkill(kuangbi_trigger)
sundeng:addSkill(kuangbi)
Fk:loadTranslationTable{
  ["sundeng"] = "孙登",
  ["#sundeng"] = "才高德茂",
  ["designer:sundeng"] = "过客",
  ["illustrator:sundeng"] = "DH",

  ["kuangbi"] = "匡弼",
  [":kuangbi"] = "出牌阶段限一次，你可以令一名其他角色将一至三张牌扣置于你的武将牌上。若如此做，你的下回合开始时，你获得武将牌上所有牌，其摸等量的牌。",
  ["#kuangbi"] = "匡弼：令一名角色将至多三张牌置为“匡弼”牌，你下回合开始时获得“匡弼”牌，其摸等量牌",
  ["#kuangbi-card"] = "匡弼：将至多三张牌置为 %src 的“匡弼”牌",

  ["$kuangbi1"] = "匡人助己，辅政弼贤。",
  ["$kuangbi2"] = "兴隆大化，佐理时务。",
  ["~sundeng"] = "愿陛下留意听采，儿臣虽死犹生。",
}

local cenhun = General(extension, "cenhun", "wu", 3)
local jishe = fk.CreateActiveSkill{
  name = "jishe",
  anim_type = "drawcard",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:getMaxCards() > 0
  end,
  card_filter = function(self, to_select, selected)
    return false
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    player:drawCards(1, self.name)
    room:addPlayerMark(player, "@jishe-turn", 1)
    room:broadcastProperty(player, "MaxCards")
  end,
}
local jishe_maxcards = fk.CreateMaxCardsSkill{
  name = "#jishe_maxcards",
  correct_func = function(self, player)
    return -player:getMark("@jishe-turn")
  end,
}
local jishe_trigger = fk.CreateTriggerSkill{
  name = "#jishe_trigger",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill("jishe") and player.phase == Player.Finish and player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room:getAlivePlayers(), function(p)
      return not p.chained end), Util.IdMapper)
    if #targets == 0 then return end
    local n = player.hp
    local tos = room:askForChoosePlayers(player, targets, 1, n, "#jishe-choose:::"..tostring(n), self.name, true)
    if #tos > 0 then
      self.cost_data = tos
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, id in ipairs(self.cost_data) do
      local to = room:getPlayerById(id)
      to:setChainState(true)
    end
  end,
}
local lianhuo = fk.CreateTriggerSkill{
  name = "lianhuo",
  anim_type = "negative",
  frequency = Skill.Compulsory,
  events = {fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.damageType == fk.FireDamage and player.chained and not data.chain
  end,
  on_use = function(self, event, target, player, data)
    player.room:setEmotion(player, "./packages/maneuvering/image/anim/vineburn")
    data.damage = data.damage + 1
  end,
}
jishe:addRelatedSkill(jishe_maxcards)
jishe:addRelatedSkill(jishe_trigger)
cenhun:addSkill(jishe)
cenhun:addSkill(lianhuo)
Fk:loadTranslationTable{
  ["cenhun"] = "岑昏",
  ["#cenhun"] = "岑昏",
  ["designer:cenhun"] = "韩旭",
  ["illustrator:cenhun"] = "心中一凛",

  ["jishe"] = "极奢",
  [":jishe"] = "出牌阶段，若你的手牌上限大于0，你可以摸一张牌，然后本回合你的手牌上限-1；结束阶段，若你没有手牌，你可以横置至多X名角色（X为你的体力值）。",
  ["lianhuo"] = "链祸",
  [":lianhuo"] = "锁定技，当你受到火焰伤害时，若你处于连环状态且你是传导伤害的起点，则此伤害+1。",
  ["@jishe-turn"] = "极奢",
  ["#jishe_trigger"] = "极奢",
  ["#jishe-choose"] = "极奢：你可以横置至多%arg名角色",

  ["$jishe1"] = "孙吴正当盛世，兴些土木又何妨？",
  ["$jishe2"] = "当再建新殿，扬我国威！",
  ["$lianhuo1"] = "用那剩下的铁石，正好做些工事。",
  ["$lianhuo2"] = "筑下这铁链，江东天险牢不可破！",
  ["~cenhun"] = "我为主上出过力！！！呃啊！",
}

local liuyu = General(extension, "liuyu", "qun", 2)
local zhige = fk.CreateActiveSkill{
  name = "zhige",
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) == 0 and #player.player_cards[Player.Hand] > player.hp
  end,
  card_filter = function(self, to_select, selected)
    return false
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getPlayerById(to_select):inMyAttackRange(Self)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local use = room:askForUseCard(target, "slash", "slash", "#zhige-use:"..player.id, true)
    if use then
      room:useCard(use)
    else
      if #target.player_cards[Player.Equip] > 0 then
        local card = room:askForCard(target, 1, 1, true, self.name, false, ".|.|.|equip", "#zhige-card:"..player.id)
        room:obtainCard(player, card[1], true, fk.ReasonGive)
      end
    end
  end
}
local zongzuo = fk.CreateTriggerSkill{
  name = "zongzuo",
  mute = true,
  events = {fk.GameStart, fk.Deathed},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and (event == fk.GameStart or
      (event == fk.Deathed and table.every(player.room:getAlivePlayers(), function(p) return p.kingdom ~= target.kingdom end)))
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.GameStart then
      player:broadcastSkillInvoke(self.name)
      room:notifySkillInvoked(player, self.name, "defensive")
      local kingdoms = {}
      for _, p in ipairs(player.room:getAlivePlayers()) do
        table.insertIfNeed(kingdoms, p.kingdom)
      end
      room:changeMaxHp(player, #kingdoms)
      room:recover{
        who = player,
        num = player.maxHp - player.hp,
        recoverBy = player,
        skillName = self.name,
      }
    else
      room:notifySkillInvoked(player, self.name, "negative")
      room:changeMaxHp(player, -1)
    end
  end,
}
liuyu:addSkill(zhige)
liuyu:addSkill(zongzuo)
Fk:loadTranslationTable{
  ["liuyu"] = "刘虞",
  ["#liuyu"] = "甘棠永固",
  ["designer:liuyu"] = "冰眼",
  ["illustrator:liuyu"] = "尼乐小丑",

  ["zhige"] = "止戈",
  [":zhige"] = "出牌阶段限一次，若你的手牌数大于体力值，你可以令一名攻击范围包含你的其他角色选择一项：1.使用一张【杀】；2.将装备区里的一张牌交给你。",
  ["zongzuo"] = "宗祚",
  [":zongzuo"] = "锁定技，游戏开始时，你加X点体力上限和体力（X为全场势力数）；当每个势力的最后一名角色死亡后，你减1点体力上限。",
  ["#zhige-use"] = "止戈：使用一张【杀】，否则将装备区内一张牌交给 %src",
  ["#zhige-card"] = "止戈：将装备区内一张牌交给 %src",

  ["$zhige1"] = "天下和而平乱，神器宁而止戈。",
  ["$zhige2"] = "刀兵纷争既止，国运福祚绵长。",
  ["$zongzuo1"] = "尽死生之力，保大厦不倾。",
  ["$zongzuo2"] = "乾坤倒，黎民苦，高祖后，岂任之？",
  ["~liuyu"] = "怀柔之计，终非良策。",
}

local zhangrang = General(extension, "zhangrang", "qun", 3)
local taoluan = fk.CreateViewAsSkill{
  name = "taoluan",
  pattern = ".",
  interaction = function()
    local names = {}
    local mark = U.getMark(Self, "@$taoluan")
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id)
      if (card.type == Card.TypeBasic or card:isCommonTrick()) and not card.is_derived and
        ((Fk.currentResponsePattern == nil and Self:canUse(card)) or
        (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(card))) then
        if not table.contains(mark, card.trueName) then
          table.insertIfNeed(names, card.name)
        end
      end
    end
    if #names == 0 then return end
    return UI.ComboBox {choices = names}
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  view_as = function(self, cards)
    if #cards ~= 1 or not self.interaction.data then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcard(cards[1])
    card.skillName = self.name
    return card
  end,
  before_use = function(self, player, use)
    local mark = player:getMark("@$taoluan")
    if mark == 0 then mark = {} end
    table.insert(mark, use.card.trueName)
    player.room:setPlayerMark(player, "@$taoluan", mark)
  end,
  enabled_at_play = function(self, player)
    return not player:isNude() and player:getMark("@@taoluan-turn") == 0 and
      table.every(Fk:currentRoom().alive_players, function(p) return not p.dying end)
  end,
  enabled_at_response = function(self, player, response)
    if not response and not player:isNude() and player:getMark("@@taoluan-turn") == 0 and Fk.currentResponsePattern
    and table.every(Fk:currentRoom().alive_players, function(p) return not p.dying end) then
      local mark = U.getMark(Self, "@$taoluan")
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
}
local taoluan_trigger = fk.CreateTriggerSkill{
  name = "#taoluan_trigger",
  mute = true,
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    return target == player and table.contains(data.card.skillNames, "taoluan")
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(room:getOtherPlayers(player), Util.IdMapper)
    local type = data.card:getTypeString()
    local tos = room:askForChoosePlayers(player, targets, 1, 1, "#taoluan-choose:::"..type, "taoluan", false)
    local to = room:getPlayerById(tos[1])
    local card = room:askForCard(to, 1, 1, true, "taoluan", true, ".|.|.|.|.|^"..type, "#taoluan-card:"..player.id.."::"..type)
    if #card > 0 then
      room:obtainCard(player, card[1], false, fk.ReasonGive)
    else
      room:setPlayerMark(player, "@@taoluan-turn", 1)
      room:loseHp(player, 1, "taoluan")
    end
  end,
}
taoluan:addRelatedSkill(taoluan_trigger)
zhangrang:addSkill(taoluan)
Fk:loadTranslationTable{
  ["zhangrang"] = "张让",
  ["#zhangrang"] = "窃幸绝禋",
  ["designer:zhangrang"] = "千幻",
  ["illustrator:zhangrang"] = "蚂蚁君",

  ["taoluan"] = "滔乱",
  [":taoluan"] = "当你需要使用一张基本牌或普通锦囊牌时，若没有角色处于濒死状态，你可以将一张牌当任意一张基本牌或普通锦囊牌使用（每种牌名每局游戏限一次），"..
  "然后你令一名其他角色选择一项：1.交给你一张与你以此法使用的牌类别不同的牌；2.令你失去1点体力，且你本回合〖滔乱〗失效。",
  ["@$taoluan"] = "滔乱",
  ["#taoluan-choose"] = "滔乱：令一名其他角色交给你一张非%arg，或你失去1点体力且本回合〖滔乱〗失效",
  ["#taoluan-card"] = "滔乱：你需交给 %src 一张非%arg，否则其失去1点体力且本回合〖滔乱〗失效",
  ["@@taoluan-turn"] = "滔乱失效",

  ["$taoluan1"] = "国家承平，神器稳固，陛下勿忧。",
  ["$taoluan2"] = "睁开你的眼睛看看，现在是谁说了算？",
  ["~zhangrang"] = "臣等殄灭，唯陛下自爱……（跳水声）",
}

return extension

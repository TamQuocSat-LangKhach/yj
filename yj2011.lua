local extension = Package("yjcm2011")
extension.extensionName = "yj"

Fk:loadTranslationTable{
  ["yjcm2011"] = "一将成名2011",
  ["nos"] = "旧",
}

local caozhi = General(extension, "caozhi", "wei", 3)
local luoying = fk.CreateTriggerSkill{
  name = "luoying",
  anim_type = "drawcard",
  events = {fk.AfterCardsMove, fk.FinishJudge},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) then
      if event == fk.AfterCardsMove then
        for _, move in ipairs(data) do
          if move.toArea == Card.DiscardPile then
            if move.moveReason == fk.ReasonDiscard and move.from ~= player.id then
              for _, info in ipairs(move.moveInfo) do
                if Fk:getCardById(info.cardId).suit == Card.Club then
                  return true
                end
              end
            end
            --[[if move.moveReason == fk.ReasonPutIntoDiscardPile then
              for _, info in ipairs(move.moveInfo) do
                return player.room:getCardArea(info.cardId) == Card.Processing
              end
            end]]  --TODO: need judge_reason
          end
        end
      elseif event == fk.FinishJudge then
        return data.who ~= player and player.room:getCardArea(data.card.id) == Card.Processing and data.card.suit == Card.Club
      else
        return player.tag["luoying"] ~= nil and #player.tag["luoying"] > 0
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = {}
    if event == fk.AfterCardsMove then
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile then
          if move.moveReason == fk.ReasonDiscard and move.from ~= player.id then
            for _, info in ipairs(move.moveInfo) do
              if Fk:getCardById(info.cardId).suit == Card.Club then
                table.insertIfNeed(cards, info.cardId)
              end
            end
          end
        end
      end
    elseif event == fk.FinishJudge then
      if data.card.suit == Card.Club then
        table.insertIfNeed(cards, data.card.id)
      end
    end
    local get = {}
    while #cards > 0 do
      room:fillAG(player, cards)
      local id = room:askForAG(player, cards, true, self.name)  --TODO: temporarily use AG. AG function need cancelable!
      if id ~= nil then
        table.removeOne(cards, id)
        table.insert(get, id)
        room:closeAG(player)
      else
        room:closeAG(player)
        break
      end
    end
    if #get > 0 then
      local dummy = Fk:cloneCard("dilu")
      dummy:addSubcards(get)
      room:obtainCard(player.id, dummy, true, fk.ReasonPrey)
    end
  end,
}
local jiushi = fk.CreateViewAsSkill{
  name = "jiushi",
  anim_type = "support",
  pattern = "analeptic",
  card_filter = function(self, to_select, selected)
    return false
  end,
  view_as = function(self, cards)
    if not Self.faceup then return end
    local c = Fk:cloneCard("analeptic")
    c.skillName = self.name
    return c
  end,
}
local jiushi_ex = fk.CreateTriggerSkill{
  name = "#jiushi_ex",
  anim_type = "support",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player:getMark(self.name) > 0
  end,
  on_cost = function(self, event, target, player, data)
    player.room:setPlayerMark(player, self.name, 0)
    return player.room:askForSkillInvoke(player, self.name)
  end,
  on_use = function(self, event, target, player, data)
   player:turnOver()
  end,

  refresh_events = {fk.AfterCardUseDeclared, fk.DamageInflicted},
  can_refresh = function(self, event, target, player, data)
    if target == player and player:hasSkill(self.name) then
      if event == fk.AfterCardUseDeclared then
        return data.card.skillName == "jiushi"
      else
        return not player.faceup
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    if event == fk.AfterCardUseDeclared then
      player:turnOver()
    else
      player.room:addPlayerMark(player, self.name, 1)
    end
  end,
}
jiushi:addRelatedSkill(jiushi_ex)
caozhi:addSkill(luoying)
caozhi:addSkill(jiushi)
Fk:loadTranslationTable{
  ["caozhi"] = "曹植",
  ["luoying"] = "落英",
  [":luoying"] = "当其他角色的♣牌，因弃牌或判定而进入弃牌堆时，你可以获得之。",
  ["jiushi"] = "酒诗",
  [":jiushi"] = "若你的武将牌正面朝上，你可以（在合理的时机）将你的武将牌翻面来视为使用一张【酒】。当你的武将牌背面朝上时你受到伤害，你可在伤害结算后将之翻回正面。",
  ["#jiushi_ex"] = "酒诗",
}

local yujin = General(extension, "yujin", "wei", 4)
local yizhong = fk.CreateTriggerSkill{
  name = "yizhong",
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  events = {fk.PreCardEffect},
  can_trigger = function(self, event, target, player, data)
    return player.id == data.to and player:hasSkill(self.name) and data.card.trueName == "slash" and data.card.color == Card.Black and player:getEquipment(Card.SubtypeArmor) == nil
  end,
  on_use = function()
    return true
  end,
}
yujin:addSkill(yizhong)
Fk:loadTranslationTable{
  ["yujin"] = "于禁",
  ["yizhong"] = "毅重",
  [":yizhong"] = "锁定技，当你没有装备防具时，黑色的【杀】对你无效。",
}

local zhangchunhua = General(extension, "zhangchunhua", "wei", 3, 3, General.Female)
local jueqing = fk.CreateTriggerSkill{
  name = "jueqing",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.PreDamage},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
  end,
  on_use = function(self, event, target, player, data)
    player.room:loseHp(data.to, data.damage, self.name)
    return true
  end,
}
local shangshi = fk.CreateTriggerSkill{
  name = "shangshi",
  anim_type = "drawcard",
  events = {fk.HpChanged, fk.MaxHpChanged, fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) and #player.player_cards[Player.Hand] < player:getLostHp() then
      if event == fk.AfterCardsMove then
        for _, move in ipairs(data) do
          return move.from == player.id
        end
      else
        return target == player
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(player:getLostHp() - #player.player_cards[Player.Hand], self.name)
  end,
}
zhangchunhua:addSkill(jueqing)
zhangchunhua:addSkill(shangshi)
Fk:loadTranslationTable{
  ["zhangchunhua"] = "张春华",
  ["jueqing"] = "绝情",
  [":jueqing"] = "锁定技，你造成的伤害均视为体力流失。",
  ["shangshi"] = "伤逝",
  [":shangshi"] = "除弃牌阶段外，每当你的手牌数小于你已损失的体力值时，可立即将手牌数补至等同于你已损失的体力值。",
}

local nos__fazheng = General(extension, "nos__fazheng", "shu", 3)
local nos__enyuan = fk.CreateTriggerSkill{
  name = "nos__enyuan",
  mute = true,
  anim_type = "masochism",
  frequency = Skill.Compulsory,
  events = {fk.HpRecover ,fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self.name) then
      if event ==  fk.HpRecover then
        return data.recoverBy and data.recoverBy ~= player and not data.recoverBy.dead
      else
        return data.from ~= nil and data.from ~= player and not data.from.dead
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event ==  fk.HpRecover then
      data.recoverBy:drawCards(data.num)
    else
      if data.from:isKongcheng() then
        room:loseHp(data.from, 1, self.name)
      else
        local card = room:askForCard(data.from, 1, 1, false, self.name, true, ".|.|heart|hand|.|.", "#nos__enyuan-give")
        if #card > 0 then
          room:obtainCard(player, Fk:getCardById(card[1]), true, fk.ReasonGive)
        else
          room:loseHp(data.from, 1, self.name)
        end
      end
    end
  end,
}
local nos__xuanhuo = fk.CreateActiveSkill{
  name = "nos__xuanhuo",
  anim_type = "control",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) == 0 and not player:isKongcheng()
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).suit == Card.Heart and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:obtainCard(target, effect.cards[1], false, fk.ReasonGive)
    local card = room:askForCardChosen(player, target, "he", self.name)
    room:obtainCard(player.id, card, false, fk.ReasonPrey)
    local to
    local tos = room:askForChoosePlayers(player, table.map(room:getOtherPlayers(target), function(p) return p.id end), 1, 1, "#nos__xuanhuo-choose", self.name)
    if #tos > 0 then
      to = tos[1]
    else
      to = player.id
    end
    if to ~= player.id then
      room:obtainCard(to, card, false, fk.ReasonGive)
    end
  end,
}
nos__fazheng:addSkill(nos__enyuan)
nos__fazheng:addSkill(nos__xuanhuo)
Fk:loadTranslationTable{
  ["nos__fazheng"] = "法正",
  ["nos__enyuan"] = "恩怨",
  [":nos__enyuan"] = "锁定技，其他角色每令你回复1点体力，该角色摸一张牌；其他角色每对你造成一次伤害，须给你一张♥手牌，否则该角色失去1点体力。",
  ["nos__xuanhuo"] = "眩惑",
  [":nos__xuanhuo"] = "出牌阶段，你可将一张♥手牌交给一名其他角色，然后，你获得该角色的一张牌并立即交给除该角色外的其他角色。每回合限一次。",
  ["#nos__enyuan-give"] = "恩怨：你需交出一张♥手牌，否则失去1点体力",
  ["#nos__xuanhuo-choose"] = "眩惑：选择获得这张牌的角色",
}

local fazheng = General(extension, "fazheng", "shu", 3)
local enyuan = fk.CreateTriggerSkill{
  name = "enyuan",
  mute = true,
  anim_type = "masochism",
  events = {fk.AfterCardsMove ,fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) then
      if event == fk.AfterCardsMove then
        self.enyuan_to = nil
        for _, move in ipairs(data) do
          if move.from ~= nil and move.from ~= player.id and move.to == player.id and move.toArea == Card.PlayerHand and #move.moveInfo > 1 then
            self.enyuan_to = move.from
            return true
          end
        end
      else
        return target == player and data.from ~= nil and data.from ~= player and not data.from.dead
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event ==  fk.AfterCardsMove then
      room:broadcastSkillInvoke(self.name, 1)
      room:notifySkillInvoked(player, self.name, "support")
      room:getPlayerById(self.enyuan_to):drawCards(1, self.name)
    else
      room:broadcastSkillInvoke(self.name, 2)
      room:notifySkillInvoked(player, self.name)
      if data.from:isKongcheng() then
        room:loseHp(data.from, 1, self.name)
      else
        local card = room:askForCard(data.from, 1, 1, false, self.name, true, ".|.|.|hand|.|.", "#enyuan-give")
        if #card > 0 then
          room:obtainCard(player, Fk:getCardById(card[1]), true, fk.ReasonGive)
        else
          room:loseHp(data.from, 1, self.name)
        end
      end
    end
  end,
}
local xuanhuo = fk.CreateTriggerSkill{
  name = "xuanhuo",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Draw
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askForChoosePlayers(player, table.map(player.room:getOtherPlayers(player), function(p) return p.id end), 1, 1, "#xuanhuo-target", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    to:drawCards(2, self.name)
    local targets = {}
    for _, p in ipairs(room:getOtherPlayers(to)) do
      if to:inMyAttackRange(p) then
        table.insert(targets, p.id)
      end
    end
    if #targets == 0 then
      local cards = room:askForCardsChosen(player, to, 2, 2, "he", self.name)
      local dummy = Fk:cloneCard("dilu")
      dummy:addSubcards(cards)
      room:obtainCard(player, dummy, false, fk.ReasonPrey)
    else
      local tos = room:askForChoosePlayers(player, targets, 1, 1, "#xuanhuo-choose", self.name)
      local victim
      if #tos > 0 then
        victim = tos[1]
      else
        victim = targets[math.random(1, #targets)]
      end
      room:doIndicate(to.id, {victim})
      local use = room:askForUseCard(to, "slash", "slash", "#xuanhuo-slash", true, {must_targets = {victim}})
      if use then
        room:useCard(use)
      else
        local cards = room:askForCardsChosen(player, to, 2, 2, "he", self.name)
        local dummy = Fk:cloneCard("dilu")
        dummy:addSubcards(cards)
        room:obtainCard(player, dummy, false, fk.ReasonPrey)
      end
    end
    return true
  end,
}
fazheng:addSkill(enyuan)
fazheng:addSkill(xuanhuo)
Fk:loadTranslationTable{
  ["fazheng"] = "法正",
  ["enyuan"] = "恩怨",
  [":enyuan"] = "你每次获得一名其他角色两张或更多的牌时，可令其摸一张牌；每当你受到1点伤害后，你可以令伤害来源选择一项：交给你一张手牌，或失去1点体力。",
  ["xuanhuo"] = "眩惑",
  [":xuanhuo"] = "摸牌阶段，你可以放弃摸牌，改为令另一名角色摸两张牌，然后令其对其攻击范围内你指定的一名角色使用一张【杀】，若该角色未如此做，你获得其两张牌。",
  ["#enyuan-give"] = "恩怨：你需交出一张手牌，否则失去1点体力",
  ["#xuanhuo-target"] = "眩惑：你可以放弃摸牌，令另一名角色摸两张牌并使用【杀】",
  ["#xuanhuo-choose"] = "眩惑：选择令其使用【杀】的目标",
  ["#xuanhuo-slash"] = "眩惑：你需对目标使用【杀】，否则来源获得你两张牌",
}

local masu = General(extension, "masu", "shu", 3)
local xinzhan = fk.CreateActiveSkill{
  name = "xinzhan",
  anim_type = "drawcard",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) == 0 and #player.player_cards[Player.Hand] > player.maxHp
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local cards = room:getNCards(3)
    local others = {}
    for _, id in ipairs(cards) do
      if Fk:getCardById(id).suit ~= Card.Heart then
        table.insert(others, id)
      end
    end
    if #others < 3 then
      local get = {}
      room:fillAG(player, cards, others)
      while #cards > #others do
        local id = room:askForAG(player, cards, false, self.name)
        --if id == nil then break end
        room:takeAG(player, id, room.players)
        table.insert(get, id)
        table.removeOne(cards, id)
      end
      room:closeAG(player)
      if #get > 0 then
        local dummy = Fk:cloneCard("dilu")
        dummy:addSubcards(get)
        room:obtainCard(player.id, dummy, true, fk.ReasonPrey)
      end
    end
    if #cards > 0 then
      room:askForGuanxing(player, cards)  --TODO: up only
    end
  end
}
local huilei = fk.CreateTriggerSkill{
  name = "huilei",
  anim_type = "control",
  frequency = Skill.Compulsory,
  events = {fk.Death},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name, false, true) and data.damage and data.damage.from
  end,
  on_use = function(self, event, target, player, data)
    local killer = data.damage.from
    if not killer:isNude() then
      killer:throwAllCards("he")
    end
  end,
}
masu:addSkill(xinzhan)
masu:addSkill(huilei)
Fk:loadTranslationTable{
  ["masu"] = "马谡",
  ["xinzhan"] = "心战",
  [":xinzhan"] = "出牌阶段，若你的手牌数大于你的体力上限，你可以观看牌堆顶的三张牌，然后展示其中任意数量的♥牌并获得之，其余以任意顺序置于牌堆顶。每回合限一次。",
  ["huilei"] = "挥泪",
  [":huilei"] = "锁定技，杀死你的角色立即弃置所有牌。",
}

local nos__xushu = General(extension, "nos__xushu", "shu", 3)
local nos__wuyan = fk.CreateTriggerSkill{
  name = "nos__wuyan",
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  events = {fk.PreCardEffect},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) and data.card.type == Card.TypeTrick and data.card.sub_type ~= Card.SubtypeDelayedTrick and data.card.name ~= "nullification" then
      if player.id == data.from then
        return player.id ~= data.to
      end
      if player.id == data.to then
        return player.id ~= data.from
      end
    end
  end,
  on_use = function()
    return true
  end,
}
local nos__jujian = fk.CreateActiveSkill{
  name = "nos__jujian",
  anim_type = "support",
  min_card_num = 1,
  max_card_num = 3,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) == 0 and not player:isNude()
  end,
  card_filter = function(self, to_select, selected)
    return #selected < 3
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:throwCard(effect.cards, self.name, player, player)
    room:drawCards(target, #effect.cards, self.name)
    if player:isWounded() and #effect.cards == 3 then
      for _, id in ipairs(effect.cards) do
        if Fk:getCardById(id).type ~= Fk:getCardById(effect.cards[1]).type then
          return
        end
      end
      room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name
      })
    end
  end
}
nos__xushu:addSkill(nos__wuyan)
nos__xushu:addSkill(nos__jujian)
Fk:loadTranslationTable{
  ["nos__xushu"] = "徐庶",
  ["nos__wuyan"] = "无言",
  [":nos__wuyan"] = "锁定技，你使用的非延时类锦囊对其他角色无效；其他角色使用的非延时类锦囊对你无效。",
  ["nos__jujian"] = "举荐",
  [":nos__jujian"] = "出牌阶段，你可以弃至多三张牌，然后让一名其他角色摸等量的牌，若你以此法弃牌不少于三张且均为同一类别，你回复1点体力。每回合限一次。",
}

local xushu = General(extension, "xushu", "shu", 3)
local wuyan = fk.CreateTriggerSkill{
  name = "wuyan",
  anim_type = "defensive",
  events = {fk.DamageCaused, fk.DamageInflicted},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.card ~= nil and data.card.type == Card.TypeTrick
  end,
  on_use = function(self, event, target, player, data)
    return true
  end,
}
local jujian = fk.CreateTriggerSkill{
  name = "jujian",
  anim_type = "support",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Finish and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local tos, id = player.room:askForChooseCardAndPlayers(player, table.map(player.room:getOtherPlayers(player), function(p) return p.id end), 1, 1, ".|.|.|.|.|trick,equip", "#jujian-choose", self.name, true)
    if #tos > 0 then
      self.cost_data = {tos[1], id}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data[1])
    room:throwCard({self.cost_data[2]}, self.name, player, player)
    local choices = {"draw2"}
    if to:isWounded() then
      table.insert(choices, "recover")
    end
    if not to.faceup or to.chained then
      table.insert(choices, "jujian_reset")
    end
    local choice = room:askForChoice(to, choices, self.name)
    if choice == "draw2" then
      to:drawCards(2, self.name)
    elseif choice == "recover" then
      room:recover({
        who = to,
        num = 1,
        recoverBy = player,
        skillName = self.name
      })
    else
      if not to.faceup then
        to:turnOver()
      end
      if to.chained then
        to:setChainState(false)
      end
    end
  end,
}
xushu:addSkill(wuyan)
xushu:addSkill(jujian)
Fk:loadTranslationTable{
  ["xushu"] = "徐庶",
  ["wuyan"] = "无言",
  [":wuyan"] = "锁定技，你防止你造成或受到的任何锦囊牌的伤害。",
  ["jujian"] = "举荐",
  [":jujian"] = "回合结束阶段开始时，你可以弃置一张非基本牌，若如此做，你令一名其他角色选择一项执行：摸两张牌；或回复1点体力；或将其武将牌翻至正面向上并重置。",
  ["#jujian-choose"] = "举荐：你可以弃置一张非基本牌，令一名其他角色摸牌/回复体力/重置武将牌",
  ["jujian_reset"] = "武将牌翻至正面向上并重置",
}

local nos__lingtong = General(extension, "nos__lingtong", "wu", 4)
local nos__xuanfeng = fk.CreateTriggerSkill{
  name = "nos__xuanfeng",
  anim_type = "offensive",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) then
      for _, move in ipairs(data) do
        if move.from == player.id then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerEquip then
              return true
            end
          end
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if true or player:distanceTo(p) == 1 then
        table.insert(targets, p.id)
      end
    end
    local to = room:askForChoosePlayers(player, targets, 1, 1, "#nos__xuanfeng-choose", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    local choices = {"nos__xuanfeng_slash"}  --TODO: target filter
    if player:distanceTo(to) == 1 then
      table.insert(choices, "nos__xuanfeng_damage")
    end
    local choice = room:askForChoice(player, choices, self.name)
    if choice == "nos__xuanfeng_slash" then
      local slash = Fk:cloneCard("slash")
      room:useCard({
        card = slash,
        from = player.id,
        tos = {{to.id}},
        extraUse = true,
      })
    else
      room:damage{
        from = player,
        to = to,
        damage = 1,
        skillName = self.name,
      }
    end
  end,
}
nos__lingtong:addSkill(nos__xuanfeng)
Fk:loadTranslationTable{
  ["nos__lingtong"] = "凌统",
  ["nos__xuanfeng"] = "旋风",
  [":nos__xuanfeng"] = "每当你失去一次装备区里的牌时，你可以执行下列两项中的一下：1.视为对任意一名其他角色使用一张【杀】（此【杀】不计入每回合的使用限制）；2.对与你距离1以内的一名其他角色造成1点伤害。",
  ["#nos__xuanfeng-choose"] = "旋风：你可以视为使用一张【杀】，或对距离1的一名其他角色造成1点伤害",
  ["nos__xuanfeng_slash"] = "视为对其使用【杀】",
  ["nos__xuanfeng_damage"] = "对其造成1点伤害",
}

local lingtong = General(extension, "lingtong", "wu", 4)
local xuanfeng = fk.CreateTriggerSkill{
  name = "xuanfeng",
  anim_type = "control",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) then
      for _, move in ipairs(data) do
        if move.from == player.id then
          if player.phase == Player.Discard then
            player.room:addPlayerMark(player, self.name, #move.moveInfo)
            if player:getMark(self.name) > 1 then
              return true
            end
          end
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerEquip then
              return true
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for i = 1, 2, 1 do
      local targets = {}
      for _, p in ipairs(room:getOtherPlayers(player)) do
        if not p:isNude() then
          table.insert(targets, p.id)
        end
      end
      if #targets == 0 then return end
      local to = room:askForChoosePlayers(player, targets, 1, 1, "#xuanfeng-choose", self.name)
      if #to == 0 then
        to = targets[math.random(1, #targets)]
      end
      local card = room:askForCardChosen(player, room:getPlayerById(to[1]), "he", self.name)
      room:throwCard({card}, self.name, room:getPlayerById(to[1]), player)
    end
  end,

  refresh_events = {fk.EventPhaseStart},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Discard
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, self.name, 0)
  end,
}
lingtong:addSkill(xuanfeng)
Fk:loadTranslationTable{
  ["lingtong"] = "凌统",
  ["xuanfeng"] = "旋风",
  [":xuanfeng"] = "当你失去装备区里的牌，或于弃牌阶段弃掉两张或更多的牌时，你可以依次弃置一至两名角色的共计两张牌。",
  ["#xuanfeng-choose"] = "旋风：你可以依次弃置一至两名角色的共计两张牌",
}

local wuguotai = General(extension, "wuguotai", "wu", 3, 3, General.Female)
local ganlu = fk.CreateActiveSkill{
  name = "ganlu",
  anim_type = "control",
  target_num = 2,
  card_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) == 0
  end,
  card_filter = function(self, to_select, selected)
    return false
  end,
  target_filter = function(self, to_select, selected)
    if #selected == 0 then
      return true
    elseif #selected == 1 then
      local target1 = Fk:currentRoom():getPlayerById(to_select)
      local target2 = Fk:currentRoom():getPlayerById(selected[1])
      if #target1.player_cards[Player.Equip] == 0 and #target2.player_cards[Player.Equip] == 0 then
        return false
      end
      return math.abs(#target1.player_cards[Player.Equip] - #target2.player_cards[Player.Equip]) <= Self:getLostHp()
    else
      return false
    end
  end,
  on_use = function(self, room, use)
    local move1 = {
      from = use.tos[1],
      ids = room:getPlayerById(use.tos[1]).player_cards[Player.Equip],
      to = use.tos[2],
      toArea = Card.PlayerEquip,
      moveReason = fk.ReasonJustMove,
      proposer = use.from,
      skillName = self.name,
    }
    local move2 = {
      from = use.tos[2],
      ids = room:getPlayerById(use.tos[2]).player_cards[Player.Equip],
      to = use.tos[1],
      toArea = Card.PlayerEquip,
      moveReason = fk.ReasonJustMove,
      proposer = use.from,
      skillName = self.name,
    }
    room:moveCards(move1, move2)
  end,
}
local buyi = fk.CreateTriggerSkill{
  name = "buyi",
  anim_type = "support",
  events = {fk.EnterDying},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and not target:isKongcheng()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local id = room:askForCardChosen(player, target, "h", self.name)
    target:showCards({id})
    if Fk:getCardById(id).type ~= Card.TypeBasic then
      room:throwCard({id}, self.name, target, target)
      room:recover{
        who = target,
        num = 1,
        recoverBy = player,
        skillName = self.name
      }
    end
  end,
}
wuguotai:addSkill(ganlu)
wuguotai:addSkill(buyi)
Fk:loadTranslationTable{
  ["wuguotai"] = "吴国太",
  ["ganlu"] = "甘露",
  [":ganlu"] = "出牌阶段，你可以选择两名角色，交换他们装备区里的所有牌，以此法交换的装备牌数量不能超过X（X为你已损失体力值）。每回合限一次。",
  ["buyi"] = "补益",
  [":buyi"] = "当有角色进入濒死状态时，你可以展示该角色的一张手牌：若此牌不为基本牌，则该角色弃掉这张牌并回复1点体力。",
}

local xusheng = General(extension, "xusheng", "wu", 4)
local pojun = fk.CreateTriggerSkill{
  name = "pojun",
  anim_type = "control",
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.card ~= nil and data.card.trueName == "slash" and not data.to.dead
  end,
  on_use = function(self, event, target, player, data)
    data.to:drawCards(math.min(data.to.hp, 5))
    data.to:turnOver()
  end
}
xusheng:addSkill(pojun)
Fk:loadTranslationTable{
  ["xusheng"] = "徐盛",
  ["pojun"] = "破军",
  [":pojun"] = "你每使用【杀】造成一次伤害，可令受到该伤害的角色摸X张牌，X为该角色当前的体力值（X最多为5），然后该角色将其武将牌翻面。",
}

--local gaoshun = General(extension, "gaoshun", "qun", 4)
local jinjiu = fk.CreateFilterSkill{
  name = "jinjiu",
  card_filter = function(self, to_select, player)
    return player:hasSkill(self.name) and to_select.name == "analeptic"
  end,
  view_as = function(self, to_select)
    return Fk:cloneCard("slash", to_select.suit, to_select.number)
  end,
}
--gaoshun:addSkill(jinjiu)
Fk:loadTranslationTable{
  ["gaoshun"] = "高顺",
  ["xianzhen"] = "陷阵",
  [":xianzhen"] = "出牌阶段，你可以与一名角色拼点，若你赢，你获得以下技能直到回合结束：无视与该角色的距离及其防具牌；可对该角色使用任意数量的【杀】。若你没赢，你不能使用【杀】直到回合结束。每回合限一次。",
  ["jinjiu"] = "禁酒",
  [":jinjiu"] = "锁定技，你的【酒】均视为【杀】。",
}

local chengong = General(extension, "chengong", "qun", 3)
local mingce = fk.CreateActiveSkill{
  name = "mingce",
  anim_type = "support",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) == 0 and not player:isKongcheng()
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and (Fk:getCardById(to_select).trueName == "slash" or Fk:getCardById(to_select).type == Card.TypeEquip)
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:obtainCard(target, Fk:getCardById(effect.cards[1]), false, fk.ReasonGive)
    local targets = {}
    for _, p in ipairs(room:getOtherPlayers(target)) do
      if target:inMyAttackRange(p) then  --TODO: target filter
        table.insert(targets, p.id)
      end
    end
    if #targets == 0 then
      target:drawCards(1, self.name)
    else
      local tos = room:askForChoosePlayers(player, targets, 1, 1, "#mingce-choose", self.name)
      local to
      if #tos > 0 then
        to = tos[1]
      else
        to = targets[math.random(1, #targets)]
      end
      room:doIndicate(target.id, {to})
      local choice = room:askForChoice(target, {"mingce_slash", "draw1"}, self.name)
      if choice == "mingce_slash" then
        local slash = Fk:cloneCard("slash")
        room:useCard({
          card = slash,
          from = target.id,
          tos = {{to}},
        })
      else
        target:drawCards(1, self.name)
      end
    end
  end,
}
local zhichi = fk.CreateTriggerSkill{
  name = "zhichi",
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  events = {fk.Damaged, fk.PreCardEffect},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) and player.phase == Player.NotActive then
      if event == fk.Damaged then
        return target == player
      else
        return player.id == data.to and player:getMark("@zhichi-turn") > 0 and (data.card.trueName == "slash" or (data.card.type == Card.TypeTrick and data.card.sub_type ~= Card.SubtypeDelayedTrick))
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.Damaged then
      player.room:setPlayerMark(player, "@zhichi-turn", 1)
    else
      return true
    end
  end,
}
chengong:addSkill(mingce)
chengong:addSkill(zhichi)
Fk:loadTranslationTable{
  ["chengong"] = "陈宫",
  ["mingce"] = "明策",
  [":mingce"] = "出牌阶段，你可以给其他任一角色一张装备牌或【杀】，该角色进行二选一：1.视为对其攻击范围内的另一名由你指定的角色使用一张【杀】；2.摸一张牌。每回合限一次。",
  ["zhichi"] = "智迟",
  [":zhichi"] = "锁定技，你的回合外，你每受到一次伤害，任何【杀】或非延时类锦囊对你无效，直到该回合结束。",
  ["#mingce-choose"] = "明策：选择视为使用【杀】的目标",
  ["mingce_slash"] = "视为使用【杀】",
  ["@zhichi-turn"] = "智迟",
}

return extension

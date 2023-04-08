local extension = Package("yjcm2014")
extension.extensionName = "yj"

Fk:loadTranslationTable{
  ["yjcm2014"] = "一将成名2014",
}

local caozhen = General(extension, "caozhen", "wei", 4)
local sidi = fk.CreateTriggerSkill{
  name = "sidi",
  anim_type = "control",
  expand_pile = "sidi",
  events = {fk.CardUseFinished, fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) then
      if event == fk.CardUseFinished then
        return data.card.name == "jink" and (target == player or player.phase ~= Player.NotActive)
      else
        return target ~= player and target.phase == Player.Play and #player:getPile(self.name) > 0
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if event == fk.CardUseFinished then
      return room:askForSkillInvoke(player, self.name)
    else
      local card = room:askForCard(player, 1, 1, false, self.name, true, ".|.|.|sidi|.|.", "#sidi-invoke", "sidi")
      if #card > 0 then
        self.cost_data = card
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.CardUseFinished then
      player:addToPile(self.name, room:getNCards(1), false, self.name)
    else
      room:moveCards({
        from = player.id,
        ids = self.cost_data,
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonPutIntoDiscardPile,
        skillName = self.name,
        specialName = self.name,
      })
      target:addCardUseHistory("slash", 1)
    end
  end,
}
caozhen:addSkill(sidi)
Fk:loadTranslationTable{
  ["caozhen"] = "曹真",
  ["sidi"] = "司敌",
  [":sidi"] = "每当你使用或其他角色在你的回合内使用【闪】时，你可以将牌堆顶的一张牌正面向上置于你的武将牌上；一名其他角色的出牌阶段开始时，你可以将你武将牌上的一张牌置入弃牌堆，然后该角色本阶段可使用【杀】的次数上限-1。",
  ["#sidi-invoke"] = "司敌：你可以将一张“司敌”牌置入弃牌堆，令该角色本阶段使用【杀】次数上限-1",
}

local chenqun = General(extension, "chenqun", "wei", 3)
local dingpin = fk.CreateActiveSkill{
  name = "dingpin",
  anim_type = "support",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return not player:isKongcheng()
  end,
  card_filter = function(self, to_select, selected)
    if #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip then
      local types = Self:getMark(self.name)
      if type(types) == "table" then
        return not table.contains(types, Fk:getCardById(to_select):getTypeString())
      else
        return true
      end
    end
  end,
  target_filter = function(self, to_select, selected)
    local target = Fk:currentRoom():getPlayerById(to_select)
    return #selected == 0 and target:isWounded() and target:getMark("dingpin_target") == 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:throwCard(effect.cards, self.name, player)
    local judge = {
      who = target,
      reason = self.name,
      pattern = ".|.|spade,club",
    }
    room:judge(judge)
    if judge.card.color == Card.Black then
      target:drawCards(target:getLostHp())
      room:addPlayerMark(target, "dingpin_target", 1)
    elseif judge.card.color == Card.Red then
      player:turnOver()
    end
   end
}
local dingpin_record = fk.CreateTriggerSkill{
  name = "#dingpin_record",

  refresh_events = {fk.CardUsing, fk.AfterCardsMove, fk.EventPhaseStart},
  can_refresh = function(self, event, target, player, data)
    if player:hasSkill(self.name) then
      if event == fk.CardUsing then
        return target == player and player.phase ~= Player.NotActive
      elseif event == fk.AfterCardsMove then
        if player:hasSkill(self.name) and player.phase ~= Player.NotActive then
          for _, move in ipairs(data) do
            if move.from == player.id and move.toArea == Card.DiscardPile and move.moveReason == fk.ReasonDiscard then
              return true
            end
          end
        end
      else
        return target == player and player.phase == Player.NotActive
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.CardUsing then
      local types = player:getMark("dingpin")
      if type(types) ~= "table" then
        types = {}
      end
      table.insertIfNeed(types, data.card:getTypeString())
      room:setPlayerMark(player, "dingpin", types)
    elseif event == fk.AfterCardsMove then
      local types = player:getMark("dingpin")
      if type(types) ~= "table" then
        types = {}
      end
      for _, move in ipairs(data) do
        if move.from == player.id and move.toArea == Card.DiscardPile and move.moveReason == fk.ReasonDiscard then  --ATTENTION: recast iron_chain may trigger this!
          for _, info in ipairs(move.moveInfo) do
            table.insertIfNeed(types, Fk:getCardById(info.cardId):getTypeString())
          end
        end
      end
      room:setPlayerMark(player, "dingpin", types)
    else
      for _, p in ipairs(room:getAlivePlayers()) do
        room:setPlayerMark(p, "dingpin_target", 0)
        room:setPlayerMark(p, "dingpin", 0)
      end
    end
  end,
}
local faen = fk.CreateTriggerSkill{
  name = "faen",
  anim_type = "drawcard",
  events = {fk.TurnedOver, fk.ChainStateChanged},  --ChainStateChanged can't trigger yet!
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) then
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    target:drawCards(1)
  end,
}
dingpin:addRelatedSkill(dingpin_record)
chenqun:addSkill(dingpin)
chenqun:addSkill(faen)
Fk:loadTranslationTable{
  ["chenqun"] = "陈群",
  ["dingpin"] = "定品",
  [":dingpin"] = "出牌阶段，你可以弃置一张与你本回合已使用或弃置的牌类别均不同的手牌，然后令一名已受伤的角色进行一次判定，若结果为黑色，该角色摸X张牌（X为该角色已损失的体力值），然后你本回合不能再对其发动“定品”；若结果为红色，将你的武将牌翻面。",
  ["faen"] = "法恩",
  [":faen"] = "每当一名角色的武将牌翻面或横置时，你可以令其摸一张牌。",
}

--local hanhaoshihuan = General(extension, "hanhaoshihuan", "wei", 3)
Fk:loadTranslationTable{
  ["hanhaoshihuan"] = "韩浩史涣",
  ["shenduan"] = "慎断",
  [":shenduan"] = "当你的黑色基本牌因弃置进入弃牌堆时，你可以将之当作【兵粮寸断】置于一名其他角色的判定区里。",
  ["yonglve"] = "勇略",
  [":yonglve"] = "你攻击范围内的一名其他角色的判定阶段开始时，你可以弃置其判定区里的一张牌，视为对该角色使用一张【杀】，若此【杀】未造成伤害，你摸一张牌。",
}

--local zhoucang = General(extension, "zhoucang", "shu", 4)
local zhongyong = fk.CreateTriggerSkill{
  name = "zhongyong",
  anim_type = "offensive",
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) and player.phase == Player.Play and data.card.name == "jink" and data.toCard and data.toCard.trueName == "slash" then
      return true--data.from == player-- and room:getCardArea(data.card) == Card.Processing
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askForChoosePlayers(player, room:getOtherPlayers(target), 1, 1, "#zhongyong-choose", self.name)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = data.card
    pt(data.toCard)
  end,
}
--zhoucang:addSkill(zhongyong)
Fk:loadTranslationTable{
  ["zhoucang"] = "周仓",
  ["zhongyong"] = "忠勇",
  [":zhongyong"] = "当你于出牌阶段内使用的【杀】被目标角色使用的【闪】抵消时，你可以将此【闪】交给除该角色外的一名角色，若获得此【闪】的角色不是你，你可以对相同的目标再使用一张【杀】。",
  ["#zhongyong-choose"] = "忠勇：将此【闪】交给除其以外的一名角色，若不是你，你可以对相同的目标再使用一张【杀】",
}

--local wuyi = General(extension, "wuyi", "shu", 4)
Fk:loadTranslationTable{
  ["wuyi"] = "吴懿",
  ["benxi"] = "奔袭",
  [":benxi"] = "锁定技，你每于回合内使用一次牌后，你计算与其他角色的距离减少1直到回合结束；你的回合内，若你与所有其他角色的距离均为1，你无视其他角色的防具，且你使用的下一张【杀】不计入出牌阶段使用次数并可以额外指定一个目标。",
}

local zhangsong = General(extension, "zhangsong", "shu", 3)
local qiangzhi = fk.CreateTriggerSkill{
  name = "qiangzhi",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart, fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self.name) and player.phase == Player.Play then
      if event == fk.EventPhaseStart then
        for _, p in ipairs(player.room:getOtherPlayers(player)) do
          if not p:isKongcheng() then
            return true
          end
        end
      else
        return data.card:getTypeString() == player:getMark("@qiangzhi")
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      local targets = {}
      for _, p in ipairs(player.room:getOtherPlayers(player)) do
        if not p:isKongcheng() then
          table.insert(targets, p.id)
        end
      end
      if #targets == 0 then return end
      local to = room:askForChoosePlayers(player, targets, 1, 1, "#qiangzhi-choose", self.name)
      if #to > 0 then
        self.cost_data = to[1]
        return true
      end
    else
      if room:askForSkillInvoke(player, self.name, data) then
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      local to = room:getPlayerById(self.cost_data)
      local card = Fk:getCardById(room:askForCardChosen(player, to, "h", self.name))
      to:showCards(card)
      room:setPlayerMark(player, "@qiangzhi", card:getTypeString())  --TODO: Fk:translate
    else
      player:drawCards(1)
    end
  end,

  refresh_events = {fk.EventPhaseEnd},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name, true) and player.phase == Player.Play
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@qiangzhi", 0)
  end,
}
local xiantu = fk.CreateTriggerSkill{
  name = "xiantu",
  anim_type = "support",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(self.name) and target.phase == Player.Play
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(2)
    local cards = room:askForCard(player, 2, 2, true, self.name, false)
    local dummy = Fk:cloneCard("dilu")
    dummy:addSubcards(cards)
    room:obtainCard(target, dummy, false, fk.ReasonGive)
  end,

  refresh_events = {fk.EventPhaseEnd, fk.Death},
  can_refresh = function(self, event, target, player, data)
    if player:hasSkill(self.name, true) and player:usedSkillTimes(self.name) > 0 and not player.dead then
      if event == fk.EventPhaseEnd then
        return target.phase == Player.Play
      else
        return true
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.Death then
      if data.damage and room.current.id == data.damage.from.id then
        room:setPlayerMark(player, self.name, 1)
      end
    else
      if player:getMark(self.name) == 0 then
        room:loseHp(player, 1, self.name)
      else
        room:setPlayerMark(player, self.name, 0)
      end
    end
  end,
}
zhangsong:addSkill(qiangzhi)
zhangsong:addSkill(xiantu)
Fk:loadTranslationTable{
  ["zhangsong"] = "张松",
  ["qiangzhi"] = "强识",
  [":qiangzhi"] = "出牌阶段开始时，你可以展示一名其他角色的一张手牌，若如此做，每当你于此阶段内使用与此牌类别相同的牌时，你可以摸一张牌。",
  ["xiantu"] = "献图",
  [":xiantu"] = "一名其他角色的出牌阶段开始时，你可以摸两张牌，然后交给其两张牌，若如此做，此阶段结束时，若该角色未于此回合内杀死过一名角色，则你失去1点体力。",
  ["#qiangzhi-choose"] = "强识：展示一名其他角色的一张手牌，此阶段内你使用类别相同的牌时，你可以摸一张牌",
  ["@qiangzhi"] = "强识",
}

local guyong = General(extension, "guyong", "wu", 3)
local shenxing = fk.CreateActiveSkill{
  name = "shenxing",
  anim_type = "drawcard",
  can_use = function(self, player)
    return not player:isNude()
  end,
  card_filter = function(self, to_select, selected)
    return #selected < 2
  end,
  target_num = 0,
  card_num = 2,
  on_use = function(self, room, effect)
    local from = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, self.name, from)
    room:drawCards(from, 1, self.name)
  end
}
local bingyi = fk.CreateTriggerSkill{
  name = "bingyi",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Finish and not player:isKongcheng()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = player.player_cards[Player.Hand]
    player:showCards(cards)
    for _, id in ipairs(cards) do
      if Fk:getCardById(id).color ~= Fk:getCardById(cards[1]).color then
        return
      end
    end
    local tos = room:askForChoosePlayers(player, table.map(room:getAlivePlayers(), function(p) return p.id end), 1, #cards, "#bingyi-target", self.name)
    if #tos > 0 then
      for _, p in ipairs(tos) do
        room:getPlayerById(p):drawCards(1)
      end
    end
  end,
}
guyong:addSkill(shenxing)
guyong:addSkill(bingyi)
Fk:loadTranslationTable{
  ["guyong"] = "顾雍",
  ["shenxing"] = "慎行",
  [":shenxing"] = "出牌阶段，你可以弃置两张牌，然后摸一张牌。",
  ["bingyi"] = "秉壹",
  [":bingyi"] = "结束阶段开始时，你可以展示所有手牌，若均为同一颜色，则你令至多X名角色各摸一张牌（X为你的手牌数）。",
  ["#bingyi-target"] = "秉壹：你令至多X名角色各摸一张牌（X为你的手牌数）",
}

local sunluban = General(extension, "sunluban", "wu", 3, 3, General.Female)
local zenhui = fk.CreateTriggerSkill{
  name = "zenhui",
  anim_type = "offensive",
  events = {fk.AfterCardTargetDeclared},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player:usedSkillTimes(self.name) == 0 and
      data.tos ~= nil and #data.tos == 1 and
      (data.card.trueName == "slash" or
      (data.card.color == Card.Black and data.card.type == Card.TypeTrick and data.card.sub_type ~= Card.SubtypeDelayedTrick))
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if not table.contains(data.tos[1], p.id) then  --TODO: target filter
        table.insertIfNeed(targets, p.id)
      end
    end
    local to = room:askForChoosePlayers(player, targets, 1, 1, "#zenhui-choose", self.name)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    if to:isNude() then
      table.insert(data.tos, {self.cost_data})  --TODO: sort by action order
      return
    end
    local card = room:askForCard(to, 1, 1, true, self.name, true)
    if #card > 0 then
      room:obtainCard(player, Fk:getCardById(card[1]), false, fk.ReasonGive)
      data.from = to.id
      --room.logic:trigger(fk.PreCardUse, to, data)
    else
      table.insert(data.tos, {self.cost_data})  --TODO: sort by action order
    end
  end,
}
local jiaojin = fk.CreateTriggerSkill{
  name = "jiaojin",
  anim_type = "defensive",
  events = {fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and not player:isNude() and data.from and data.from.gender == General.Male
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local _, discard = room:askForUseActiveSkill(player, "discard_skill", "#jiaojin-discard", true, {
      num = 1,
      min_num = 1,
      include_equip = true,
      reason = self.name,
      pattern = ".|.|.|.|.|equip",
    })
    if discard then
      room:throwCard(discard.cards, self.name, player, player)
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage - 1
  end,
}
sunluban:addSkill(zenhui)
sunluban:addSkill(jiaojin)
Fk:loadTranslationTable{
  ["sunluban"] = "孙鲁班",
  ["zenhui"] = "谮毁",
  [":zenhui"] = "出牌阶段限一次，当你使用【杀】或黑色非延时类锦囊牌指定唯一目标时，你令可以成为此牌目标的另一名其他角色选择一项：交给你一张牌并成为此牌的使用者；或成为此牌的额外目标。",
  ["jiaojin"] = "骄矜",
  [":jiaojin"] = "每当你受到一名男性角色造成的伤害时，你可以弃置一张装备牌，令此伤害-1。",
  ["#zenhui-choose"] = "谮毁：你令可以令一名角色选择一项：交给你一张牌并成为此牌的使用者；或成为此牌的额外目标",
  ["#jiaojin-discard"] = "骄矜：你可以弃置一张装备牌，令此伤害-1",
}

local zhuhuan = General(extension, "zhuhuan", "wu", 4)
local youdi = fk.CreateTriggerSkill{
  name = "youdi",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Finish and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askForChoosePlayers(player, table.map(player.room:getOtherPlayers(player), function(p) return p.id end), 1, 1, "#youdi-choose", self.name)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    local card = room:askForCardChosen(to, player, "he", self.name)
    room:throwCard({card}, self.name, player, to)
    if Fk:getCardById(card).trueName ~= "slash" and not to:isNude() then
      local card2 = room:askForCardChosen(player, to, "he", self.name)
      room:obtainCard(player.id, card2, false)
    end
  end,
}
zhuhuan:addSkill(youdi)
Fk:loadTranslationTable{
  ["zhuhuan"] = "朱桓",
  ["youdi"] = "诱敌",
  [":youdi"] = "结束阶段开始时，你可以令一名其他角色弃置你的一张牌，若此牌不为【杀】，你获得该角色的一张牌。",
  ["#youdi-choose"] = "诱敌：令一名其他角色弃置你的一张牌，若不为【杀】，你获得其一张牌",
}

local caifuren = General(extension, "caifuren", "qun", 3, 3, General.Female)
local qieting = fk.CreateTriggerSkill{
  name = "qieting",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(self.name) and target.phase == Player.Finish and player:getMark(self.name) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choices = {"draw1"}
    local ids = {}
    if #target.player_cards[Player.Equip] > 0 then
      for _, e in ipairs(target.player_cards[Player.Equip]) do
        if player:getEquipment(Fk:getCardById(e).sub_type) == nil then
          table.insert(ids, e)
        end
      end
      if #ids > 0 then
        table.insert(choices, 1, "qieting_move")
      end
    end
    local choice = room:askForChoice(player, choices, self.name)
    if choice == "qieting_move" then
      room:fillAG(player, ids)
      local id = room:askForAG(player, ids, true, self.name)
      room:closeAG(player)
      target:removeCards(Player.Equip, {id})  --FIXME: it's fake move! orginal card didn't move actually!
      room:moveCards({
        from = target.id,
        ids = {id},
        to = player.id,
        toArea = Card.PlayerEquip,
        moveReason = fk.ReasonJustMove,
        proposer = player.id,
        skillName = self.name,
      })
    else
      player:drawCards(1, self.name)
    end
  end,

  refresh_events = {fk.CardUsing, fk.EventPhaseStart},
  can_refresh = function(self, event, target, player, data)
    if player:hasSkill(self.name, true) and target.phase ~= Player.NotActive then
      if event == fk.CardUsing then
        return target ~= player and data.tos ~= nil
      else
        return target.phase == Player.Start
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.CardUsing then
      for _, info in ipairs(data.tos) do
        for _, p in ipairs(info) do
          if p ~= data.from then
            room:addPlayerMark(player, self.name, 1)
            return
          end
        end
      end
    else
      room:setPlayerMark(player, self.name, 0)
    end
  end,
}
local xianzhou = fk.CreateActiveSkill{
  name = "xianzhou",
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  frequency = Skill.Limited,
  can_use = function(self, player)
    return player:getMark(self.name) == 0 and #player.player_cards[Player.Equip] > 0
  end,
  card_filter = function(self, to_select, selected)
    return false
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local n = #player.player_cards[Player.Equip]
    room:addPlayerMark(player, self.name)
    local dummy = Fk:cloneCard("dilu")
    dummy:addSubcards(player.player_cards[Player.Equip])
    room:obtainCard(target, dummy, false, fk.ReasonGive)
    local targets = {}
    for _, p in ipairs(room:getOtherPlayers(target)) do
      if target:inMyAttackRange(p) then
        table.insert(targets, p.id)
      end
    end
    if #targets > 0 then
      local tos = room:askForChoosePlayers(target, targets, 1, n, "#xianzhou-choose", self.name)
      if #tos > 0 then
        for _, p in ipairs(tos) do
          room:damage{
            from = target,
            to = room:getPlayerById(p),
            damage = 1,
            skillName = self.name,
          }
        end
      else
        if player:isWounded() then
          room:recover({
            who = player,
            num = math.min(n, player:getLostHp()),
            recoverBy = target,
            skillName = self.name
          })
        end
      end
    end
  end,
}
caifuren:addSkill(qieting)
caifuren:addSkill(xianzhou)
Fk:loadTranslationTable{
  ["caifuren"] = "蔡夫人",
  ["qieting"] = "窃听",
  [":qieting"] = "一名其他角色的回合结束时，若其未于此回合内使用过指定另一名角色为目标的牌，你可以选择一项：将其装备区里的一张牌移动至你装备区里的相应位置；或摸一张牌。",
  ["xianzhou"] = "献州",
  [":xianzhou"] = "限定技，出牌阶段，你可以将装备区里的所有牌交给一名其他角色，然后该角色选择一项：令你回复X点体力，或对其攻击范围内的至多X名角色各造成1点伤害（X为你以此法交给该角色的牌的数量）。",
  ["qieting_move"] = "将其一张装备移动给你",
  ["#xianzhou-choose"] = "献州：对你攻击范围内的至多X名角色各造成1点伤害，或点“取消”令其回复X点体力",
}

local jvshou = General(extension, "jvshou", "qun", 3)
local jianying = fk.CreateTriggerSkill{
  name = "jianying",
  anim_type = "drawcard",
  events = {fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Play and self.can_jianying
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1)
  end,

  refresh_events = {fk.AfterCardUseDeclared, fk.EventPhaseEnd},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Play
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.AfterCardUseDeclared then
      if data.card.suit == Card.NoSuit then
        room:setPlayerMark(player, "@jianying", 0)
        room:setPlayerMark(player, "jianying_suit", 0)
        room:setPlayerMark(player, "jianying_num", 0)
        self.can_jianying = false
      else
        if data.card:getSuitString() == player:getMark("jianying_suit") or data.card.number == player:getMark("jianying_num") then
          self.can_jianying = true
        else
          self.can_jianying = false
        end
        room:setPlayerMark(player, "@jianying", string.format("%s-%d", Fk:translate(data.card:getSuitString()), data.card.number))
        room:setPlayerMark(player, "jianying_suit", data.card:getSuitString())
        room:setPlayerMark(player, "jianying_num", data.card.number)
      end
    else
      room:setPlayerMark(player, "@jianying", 0)
      room:setPlayerMark(player, "jianying_suit", 0)
      room:setPlayerMark(player, "jianying_num", 0)
      self.can_jianying = false
    end
  end,
}
local shibei = fk.CreateTriggerSkill{
  name = "shibei",
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if player:getMark(self.name) == 0 then
      room:recover{
        who = player,
        num = 1,
        skillName = self.name
      }
    else
      room:loseHp(player, 1, self.name)
    end
    room:addPlayerMark(player, self.name, 1)
  end,

  refresh_events = {fk.EventPhaseStart},
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(self.name, true) and target.phase == Player.NotActive
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, self.name, 0)
  end,
}
jvshou:addSkill(jianying)
jvshou:addSkill(shibei)
Fk:loadTranslationTable{
  ["jvshou"] = "沮授",
  ["jianying"] = "渐营",
  [":jianying"] = "每当你于出牌阶段内使用的牌与此阶段你使用的上一张牌点数或花色相同时，你可以摸一张牌。",
  ["shibei"] = "矢北",
  [":shibei"] = "锁定技，每当你受到伤害后，若此伤害是你本回合第一次受到的伤害，你回复1点体力；否则你失去1点体力。",
  ["@jianying"] = "渐营",
}

return extension

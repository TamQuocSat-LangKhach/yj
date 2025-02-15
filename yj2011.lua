local extension = Package("yjcm2011")
extension.extensionName = "yj"

Fk:loadTranslationTable{
  ["yjcm2011"] = "一将成名2011",
  ["nos"] = "旧",
}
local U = require "packages/utility/utility"
local caozhi = General(extension, "caozhi", "wei", 3)
local luoying = fk.CreateTriggerSkill{
  name = "luoying",
  anim_type = "drawcard",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      local ids = {}
      local room = player.room
      for _, move in ipairs(data) do
        if move.toArea == Card.DiscardPile then
          if move.moveReason == fk.ReasonDiscard and move.from and move.from ~= player.id then
            for _, info in ipairs(move.moveInfo) do
              if (info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip) and
              Fk:getCardById(info.cardId).suit == Card.Club and
              room:getCardArea(info.cardId) == Card.DiscardPile then
                table.insertIfNeed(ids, info.cardId)
              end
            end
          elseif move.moveReason == fk.ReasonJudge then
            local judge_event = room.logic:getCurrentEvent():findParent(GameEvent.Judge)
            if judge_event and judge_event.data[1].who ~= player then
              for _, info in ipairs(move.moveInfo) do
                if info.fromArea == Card.Processing and Fk:getCardById(info.cardId).suit == Card.Club and
                room:getCardArea(info.cardId) == Card.DiscardPile then
                  table.insertIfNeed(ids, info.cardId)
                end
              end
            end
          end
        end
      end
      ids = U.moveCardsHoldingAreaCheck(room, ids)
      if #ids > 0 then
        self.cost_data = ids
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local ids = table.simpleClone(self.cost_data)
    if #ids > 1 then
      local cards, _ = U.askforChooseCardsAndChoice(player, ids, {"OK"}, self.name,
      "#luoying-choose", {"get_all"}, 1, #ids)
      if #cards > 0 then
        ids = cards
      end
    end
    room:moveCardTo(ids, Card.PlayerHand, player, fk.ReasonJustMove, self.name, nil, true, player.id, "@@luoying-inhand")
  end,
}
local jiushi = fk.CreateViewAsSkill{
  name = "jiushi",
  anim_type = "support",
  pattern = "analeptic",
  card_filter = Util.FalseFunc,
  before_use = function(self, player)
    player:turnOver()
  end,
  view_as = function(self)
    local c = Fk:cloneCard("analeptic")
    c.skillName = self.name
    return c
  end,
  enabled_at_play = function (self, player)
    return player.faceup
  end,
  enabled_at_response = function (self, player, response)
    return player.faceup and not response
  end,
}
local jiushi_trigger = fk.CreateTriggerSkill{
  name = "#jiushi_trigger",
  mute = true,
  main_skill = jiushi,
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jiushi) and (data.extra_data or {}).jiushi_check and not player.faceup
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, "jiushi")
  end,
  on_use = function(self, event, target, player, data)
    player:broadcastSkillInvoke("jiushi")
    player.room:notifySkillInvoked(player, "jiushi", "defensive")
    player:turnOver()
  end,

  refresh_events = {fk.DamageInflicted},
  can_refresh = function(self, event, target, player, data)
    return target == player and not player.faceup
  end,
  on_refresh = function(self, event, target, player, data)
    data.extra_data = data.extra_data or {}
    data.extra_data.jiushi_check = true
  end,
}
jiushi:addRelatedSkill(jiushi_trigger)
caozhi:addSkill(luoying)
caozhi:addSkill(jiushi)
Fk:loadTranslationTable{
  ["caozhi"] = "曹植",
  ["#caozhi"] = "八斗之才",
  ["designer:caozhi"] = "Foxear",
  ["illustrator:caozhi"] = "木美人",
  ["luoying"] = "落英",
  [":luoying"] = "当其他角色的♣牌因弃置或判定进入弃牌堆后，你可以获得之。",
  ["jiushi"] = "酒诗",
  [":jiushi"] = "若你的武将牌正面朝上，你可以翻面视为使用一张【酒】；当你受到伤害时，若你的武将牌背面朝上，你可以在受到伤害后翻至正面。",

  ["#luoying-choose"] = "落英：选择要获得的牌",
  ["get_all"] = "全部获得",
  ["@@luoying-inhand"] = "落英",

  ["$luoying1"] = "这些都是我的。",
  ["$luoying2"] = "别着急扔，给我就好。",
  ["$jiushi1"] = "置酒高殿上，亲友从我游。",
  ["$jiushi2"] = "走马行酒醴，驱车布鱼肉。",
  ["~caozhi"] = "本是同根生，相煎何太急。",
}

local yujin = General(extension, "yujin", "wei", 4)
local yizhong = fk.CreateTriggerSkill{
  name = "yizhong",
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  events = {fk.PreCardEffect},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.card.trueName == "slash" and player.id == data.to and
      data.card.color == Card.Black and player:getEquipment(Card.SubtypeArmor) == nil
  end,
  on_use = Util.TrueFunc,
}
yujin:addSkill(yizhong)
Fk:loadTranslationTable{
  ["yujin"] = "于禁",
  ["#yujin"] = "魏武之刚",
  ["designer:yujin"] = "许坦",
  ["illustrator:yujin"] = "Yi章",

  ["yizhong"] = "毅重",
  [":yizhong"] = "锁定技，当你没有装备防具时，黑色的【杀】对你无效。",

  ["$yizhong1"] = "不先为备，何以待敌？",
  ["$yizhong2"] = "稳重行军，百战不殆！",
  ["~yujin"] = "我，无颜面对丞相了……",
}

local zhangchunhua = General(extension, "zhangchunhua", "wei", 3, 3, General.Female)
local jueqing = fk.CreateTriggerSkill{
  name = "jueqing",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.PreDamage},
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
    if player:hasSkill(self) and player:getHandcardNum() < player:getLostHp() then
      if event == fk.AfterCardsMove then
        for _, move in ipairs(data) do
          if move.from == player.id then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand then
                return true
              end
            end
          end
        end
      else
        return target == player
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(player:getLostHp() - player:getHandcardNum(), self.name)
  end,
}
zhangchunhua:addSkill(jueqing)
zhangchunhua:addSkill(shangshi)
Fk:loadTranslationTable{
  ["zhangchunhua"] = "张春华",
  ["#zhangchunhua"] = "冷血皇后",
  ["designer:zhangchunhua"] = "JZHIEI",
  ["illustrator:zhangchunhua"] = "樱花闪乱",
  ["jueqing"] = "绝情",
  [":jueqing"] = "锁定技，你造成的伤害均视为体力流失。",
  ["shangshi"] = "伤逝",
  [":shangshi"] = "当你的手牌数小于你已损失的体力值时，你可以将手牌补至已损失体力值。",

  ["$jueqing1"] = "你的死活，与我何干？",
  ["$jueqing2"] = "无来无去，不悔不怨。",
  ["$shangshi1"] = "无情者伤人，有情者自伤。",
  ["$shangshi2"] = "自损八百，可伤敌一千。",
  ["~zhangchunhua"] = "怎能如此对我！",
}

local nos__fazheng = General(extension, "nos__fazheng", "shu", 3)
local nos__enyuan = fk.CreateTriggerSkill{
  name = "nos__enyuan",
  mute = true,
  anim_type = "masochism",
  frequency = Skill.Compulsory,
  events = {fk.HpRecover ,fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) then
      if event ==  fk.HpRecover then
        return data.recoverBy and data.recoverBy ~= player and not data.recoverBy.dead
      else
        return data.from and data.from ~= player and not data.from.dead
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event ==  fk.HpRecover then
      player:broadcastSkillInvoke(self.name, math.random(1,2))
      room:notifySkillInvoked(player, self.name, "support")
      data.recoverBy:drawCards(data.num, self.name)
    else
      player:broadcastSkillInvoke(self.name, math.random(3,4))
      room:notifySkillInvoked(player, self.name)
      room:doIndicate(player.id, {data.from.id})
      if data.from:isKongcheng() then
        room:loseHp(data.from, 1, self.name)
      else
        local card = room:askForCard(data.from, 1, 1, false, self.name, true, ".|.|heart|hand|.|.", "#nos__enyuan-give:"..player.id)
        if #card > 0 then
          room:obtainCard(player, card[1], true, fk.ReasonGive, data.from.id, self.name)
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
  prompt = "#nos__xuanhuo",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
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
    room:obtainCard(target.id, effect.cards[1], false, fk.ReasonGive, player.id, self.name)
    if target:isNude() or player.dead or target.dead then return end
    local id = room:askForCardChosen(player, target, "he", self.name)
    room:obtainCard(player.id, id, false, fk.ReasonPrey, player.id, self.name)
    if player.dead then return end
    local targets = table.map(room:getOtherPlayers(target), Util.IdMapper)
    if #targets == 0 or room:getCardOwner(id) ~= player or room:getCardArea(id) ~= Card.PlayerHand then return end
    local to = room:askForChoosePlayers(player, targets, 1, 1,
      "#nos__xuanhuo-choose:::"..Fk:getCardById(id):toLogString(), self.name, false)
    if #to > 0 then
      to = to[1]
    else
      to = player.id
    end
    if to ~= player.id then
      room:obtainCard(to, id, false, fk.ReasonGive, player.id)
    end
  end,
}
nos__fazheng:addSkill(nos__enyuan)
nos__fazheng:addSkill(nos__xuanhuo)
Fk:loadTranslationTable{
  ["nos__fazheng"] = "法正",
  ["#nos__fazheng"] = "蜀汉的辅翼",
  ["designer:nos__fazheng"] = "Michael_Lee",
  ["illustrator:nos__fazheng"] = "雷没才",
  ["nos__enyuan"] = "恩怨",
  [":nos__enyuan"] = "锁定技，其他角色每令你回复1点体力，该角色摸一张牌；其他角色每对你造成一次伤害，须给你一张<font color='red'>♥</font>手牌，"..
  "否则该角色失去1点体力。",
  ["nos__xuanhuo"] = "眩惑",
  [":nos__xuanhuo"] = "出牌阶段限一次，你可将一张<font color='red'>♥</font>手牌交给一名其他角色，然后你获得该角色的一张牌并交给除该角色外的其他角色。",
  ["#nos__enyuan-give"] = "恩怨：你需交给 %src 一张<font color='red'>♥</font>手牌，否则失去1点体力",
  ["#nos__xuanhuo"] = "眩惑：你可以将一张<font color='red'>♥</font>手牌交给一名其他角色，获得其一张牌，然后交给任一角色",
  ["#nos__xuanhuo-choose"] = "眩惑：选择获得%arg的角色",

  ["$nos__enyuan1"] = "得人恩果千年记。",
  ["$nos__enyuan2"] = "滴水之恩，涌泉相报。",
  ["$nos__enyuan3"] = "谁敢得罪我？",
  ["$nos__enyuan4"] = "睚眦之怨，无不报复。",
  ["$nos__xuanhuo1"] = "重用许靖，以眩远近。",
  ["$nos__xuanhuo2"] = "给你的，十倍奉还给我。",
  ["~nos__fazheng"] = "辅翼既折，蜀汉衰矣……",
}

local fazheng = General(extension, "fazheng", "shu", 3)
local enyuan = fk.CreateTriggerSkill{
  name = "enyuan",
  mute = true,
  anim_type = "masochism",
  events = {fk.AfterCardsMove ,fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.AfterCardsMove then
        self.cost_data = nil
        for _, move in ipairs(data) do
          if move.from and move.from ~= player.id and move.to == player.id and move.toArea == Card.PlayerHand and
            #move.moveInfo > 1 and not player.room:getPlayerById(move.from).dead then
            return true
          end
        end
      else
        return target == player and data.from and data.from ~= player and not data.from.dead
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    if event == fk.AfterCardsMove then
      for _, move in ipairs(data) do
        if player.dead or not player:hasSkill(self) then return end
        if move.from and move.from ~= player.id and move.to == player.id and move.toArea == Card.PlayerHand and #move.moveInfo > 1 and
          #move.moveInfo > 1 and not player.room:getPlayerById(move.from).dead then
          self:doCost(event, target, player, move.from)
        end
      end
    else
      self:doCost(event, target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local prompt
    if event == fk.AfterCardsMove then
      prompt = "#enyuan1-invoke::"..data
    else
      prompt = "#enyuan2-invoke::"..data.from.id
    end
    return player.room:askForSkillInvoke(player, self.name, nil, prompt)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event ==  fk.AfterCardsMove then
      player:broadcastSkillInvoke(self.name, 1)
      room:notifySkillInvoked(player, self.name, "support")
      room:doIndicate(player.id, {data})
      room:getPlayerById(data):drawCards(1, self.name)
    else
      player:broadcastSkillInvoke(self.name, 2)
      room:notifySkillInvoked(player, self.name)
      room:doIndicate(player.id, {data.from.id})
      if data.from:isKongcheng() then
        room:loseHp(data.from, 1, self.name)
      else
        local card = room:askForCard(data.from, 1, 1, false, self.name, true, ".|.|.|hand|.|.", "#enyuan-give:"..player.id)
        if #card > 0 then
          room:obtainCard(player, Fk:getCardById(card[1]), true, fk.ReasonGive, data.from.id)
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
    return target == player and player:hasSkill(self) and player.phase == Player.Draw
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askForChoosePlayers(player, table.map(player.room:getOtherPlayers(player, false), Util.IdMapper), 1, 1, "#xuanhuo-target", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    to:drawCards(2, self.name)
    if player.dead or to.dead then return end
    local targets = table.map(table.filter(room:getOtherPlayers(target), function(p)
      return target:inMyAttackRange(p) end), Util.IdMapper)
    if #targets == 0 then
      if to:isNude() then return end
      local cards = room:askForCardsChosen(player, to, math.min(2, #to:getCardIds("he")), 2, "he", self.name)
      room:obtainCard(player, cards, false, fk.ReasonPrey)
    else
      local tos = room:askForChoosePlayers(player, targets, 1, 1, "#xuanhuo-choose::"..to.id, self.name, false, true)
      local victim
      if #tos > 0 then
        victim = tos[1]
      else
        victim = table.random(targets)
      end
      room:doIndicate(to.id, {victim})
      local use = room:askForUseCard(to, "slash", "slash", "#xuanhuo-slash:"..player.id..":"..victim, true, {must_targets = {victim}})
      if use then
        room:useCard(use)
      else
        if to:isNude() then return end
        local cards = room:askForCardsChosen(player, to, math.min(2, #to:getCardIds("he")), 2, "he", self.name)
        room:obtainCard(player, cards, false, fk.ReasonPrey)
      end
    end
    return true
  end,
}
fazheng:addSkill(enyuan)
fazheng:addSkill(xuanhuo)
Fk:loadTranslationTable{
  ["fazheng"] = "法正",
  ["#fazheng"] = "蜀汉的辅翼",
  ["designer:fazheng"] = "韩旭",

  ["enyuan"] = "恩怨",
  [":enyuan"] = "当你获得一名其他角色两张或更多的牌时，可令其摸一张牌；当你受到1点伤害后，你可以令伤害来源选择一项：交给你一张手牌，或失去1点体力。",
  ["xuanhuo"] = "眩惑",
  [":xuanhuo"] = "摸牌阶段，你可以放弃摸牌，改为令另一名角色摸两张牌，然后令其对其攻击范围内你指定的一名角色使用一张【杀】，若该角色未如此做，你获得其两张牌。",
  ["#enyuan1-invoke"] = "恩怨：是否令 %dest 摸一张牌？",
  ["#enyuan2-invoke"] = "恩怨：你可以令 %dest 选择交给你一张手牌或失去1点体力",
  ["#enyuan-give"] = "恩怨：你需交给 %src 一张手牌，否则失去1点体力",
  ["#xuanhuo-target"] = "眩惑：你可以放弃摸牌，令另一名角色摸两张牌并使用【杀】",
  ["#xuanhuo-choose"] = "眩惑：选择令 %dest 使用【杀】的目标",
  ["#xuanhuo-slash"] = "眩惑：你需对 %dest 使用【杀】，否则 %src 获得你两张牌",

  ["$enyuan1"] = "报之以李，还之以桃。",
  ["$enyuan2"] = "伤了我，休想全身而退！",
  ["$xuanhuo1"] = "收人钱财，替人消灾。",
  ["$xuanhuo2"] = "哼，叫你十倍奉还！",
  ["~fazheng"] = "汉室复兴，我，是看不到了……",
}

local masu = General(extension, "masu", "shu", 3)
local xinzhan = fk.CreateActiveSkill{
  name = "xinzhan",
  anim_type = "drawcard",
  card_num = 0,
  target_num = 0,
  prompt = "#xinzhan",
  card_filter = Util.FalseFunc,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and player:getHandcardNum() > player.maxHp
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local cards = room:getNCards(3)
    local cardmap = room:askForArrangeCards(player, self.name, {cards, "Top", "toObtain"}, "#xinzhan-choose", true, 0,
    {3, 3}, {0, 0}, ".|.|heart")
    if #cardmap[2] > 0 then
      room:moveCardTo(cardmap[2], Player.Hand, player, fk.ReasonPrey, self.name)
    end
  end
}
local huilei = fk.CreateTriggerSkill{
  name = "huilei",
  anim_type = "control",
  frequency = Skill.Compulsory,
  events = {fk.Death},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self, false, true) and data.damage and data.damage.from and not data.damage.from:isNude()
  end,
  on_use = function(self, event, target, player, data)
    data.damage.from:throwAllCards("he")
  end,
}
masu:addSkill(xinzhan)
masu:addSkill(huilei)
Fk:loadTranslationTable{
  ["masu"] = "马谡",
  ["#masu"] = "怀才自负",
  ["designer:masu"] = "点点",
  ["illustrator:masu"] = "张帅",

  ["xinzhan"] = "心战",
  [":xinzhan"] = "出牌阶段限一次，若你的手牌数大于你的体力上限，你可以观看牌堆顶的三张牌，然后展示其中任意数量的<font color='red'>♥</font>牌并获得之，最后将其余的牌以任意顺序置于牌堆顶。",
  ["huilei"] = "挥泪",
  [":huilei"] = "锁定技，杀死你的角色弃置所有牌。",
  ["#xinzhan"] = "心战：观看牌堆顶的三张牌，获得其中任意张<font color='red'>♥</font>牌，其余牌以任意顺序置于牌堆顶",
  ["#xinzhan-choose"] = "获得任意<font color='red'>♥</font>牌，调整其余牌顺序",

  ["$xinzhan1"] = "吾通晓兵法，世人皆知。",
  ["$xinzhan2"] = "用兵之道，攻心为上。",
  ["$huilei1"] = "丞相视某如子，某以丞相为父。",
  ["$huilei2"] = "谡愿以死安大局。",
}

local nos__xushu = General(extension, "nos__xushu", "shu", 3)
local nos__wuyan = fk.CreateTriggerSkill{
  name = "nos__wuyan",
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  events = {fk.PreCardEffect},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and data.card:isCommonTrick() and data.card.name ~= "nullification" then
      if player.id == data.from then
        return player.id ~= data.to
      end
      if player.id == data.to then
        return player.id ~= data.from
      end
    end
  end,
  on_use = Util.TrueFunc,
}
local nos__jujian = fk.CreateActiveSkill{
  name = "nos__jujian",
  anim_type = "support",
  min_card_num = 1,
  max_card_num = 3,
  target_num = 1,
  prompt = "#nos__jujian",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isNude()
  end,
  card_filter = function(self, to_select, selected)
    return #selected < 3 and not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:throwCard(effect.cards, self.name, player, player)
    if not target.dead then
      room:drawCards(target, #effect.cards, self.name)
    end
    if #effect.cards == 3 and player:isWounded() and not player.dead and
      table.every(effect.cards, function (id) return Fk:getCardById(id).type == Fk:getCardById(effect.cards[1]).type end) then
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
  ["#nos__xushu"] = "忠孝的侠士",
  ["designer:nos__xushu"] = "双叶松",
  ["illustrator:nos__xushu"] = "XINA",

  ["nos__wuyan"] = "无言",
  [":nos__wuyan"] = "锁定技，你使用的非延时类锦囊对其他角色无效；其他角色使用的非延时类锦囊对你无效。",
  ["nos__jujian"] = "举荐",
  [":nos__jujian"] = "出牌阶段限一次，你可以弃置至多三张牌，令一名其他角色摸等量的牌；若你以此法弃置了三张相同类别的牌，你回复1点体力。",
  ["#nos__jujian"] = "举荐：你可以弃置至多三张牌，令一名角色摸等量牌，若你弃置了三张相同类别牌，你回复1点体力",

  ["$nos__wuyan1"] = "嘘，言多必失啊。",
  ["$nos__wuyan2"] = "唉，一切尽在不言中。",
  ["$nos__jujian1"] = "我看好你！",
  ["$nos__jujian2"] = "将军岂愿抓牌乎？",
  ["~nos__xushu"] = "娘……孩儿不孝……向您……请罪……",
}

local xushu = General(extension, "xushu", "shu", 3)
local wuyan = fk.CreateTriggerSkill{
  name = "wuyan",
  anim_type = "defensive",
  events = {fk.DamageCaused, fk.DamageInflicted},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card and data.card.type == Card.TypeTrick
  end,
  on_use = Util.TrueFunc,
}
local jujian = fk.CreateTriggerSkill{
  name = "jujian",
  anim_type = "support",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local tos, id = player.room:askForChooseCardAndPlayers(player, table.map(player.room:getOtherPlayers(player, false), Util.IdMapper), 1, 1, ".|.|.|.|.|^basic", "#jujian-choose", self.name, true)
    if #tos > 0 then
      self.cost_data = {tos = tos, cards = {id}}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data.tos[1])
    room:throwCard(self.cost_data.cards, self.name, player, player)
    local choices = {"draw2"}
    if to:isWounded() then
      table.insert(choices, "recover")
    end
    if not to.faceup or to.chained then
      table.insert(choices, "jujian_reset")
    end
    local choice = room:askForChoice(to, choices, self.name, nil, false, {"draw2", "recover", "jujian_reset"})
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
      to:reset()
    end
  end,
}
xushu:addSkill(wuyan)
xushu:addSkill(jujian)
Fk:loadTranslationTable{
  ["xushu"] = "徐庶",
  ["#xushu"] = "忠孝的侠士",
  ["illustrator:xushu"] = "L",

  ["wuyan"] = "无言",
  [":wuyan"] = "锁定技，你防止你造成或受到的任何锦囊牌的伤害。",
  ["jujian"] = "举荐",
  [":jujian"] = "结束阶段，你可以弃置一张非基本牌，令一名其他角色选择一项：摸两张牌；回复1点体力；复原武将牌。",
  ["#jujian-choose"] = "举荐：你可以弃置一张非基本牌，令一名其他角色摸牌/回复体力/复原武将牌",
  ["jujian_reset"] = "复原武将牌",

  ["$wuyan1"] = "吾，誓不为汉贼献一策！",
  ["$wuyan2"] = "汝有良策，何必问我！",
  ["$jujian1"] = "天下大任，望君莫辞！",
  ["$jujian2"] = "卧龙之才，远胜于我。",
  ["~xushu"] = "忠孝不能两全，孩儿……",
}

local nos__lingtong = General(extension, "nos__lingtong", "wu", 4)
local nos__xuanfeng = fk.CreateTriggerSkill{
  name = "nos__xuanfeng",
  anim_type = "offensive",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return end
    for _, move in ipairs(data) do
      if move.from == player.id then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerEquip then
            return true
          end
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room:getOtherPlayers(player), function(p)
      return (not player:isProhibited(p, Fk:cloneCard("slash")) or player:distanceTo(p) == 1) end), Util.IdMapper)
    if #targets == 0 then return end
    local to = room:askForChoosePlayers(player, targets, 1, 1, "#nos__xuanfeng-choose", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    local choices = {}
    if not player:isProhibited(to, Fk:cloneCard("slash")) then
      table.insert(choices, "nos__xuanfeng_slash")
    end
    if player:distanceTo(to) == 1 then
      table.insert(choices, "nos__xuanfeng_damage")
    end
    local choice = room:askForChoice(player, choices, self.name)
    if choice == "nos__xuanfeng_slash" then
      room:useVirtualCard("slash", nil, player, to, self.name, true)
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
  ["#nos__lingtong"] = "豪情烈胆",
  ["cv:nos__lingtong"] = "冷泉月夜",
  ["designer:nos__lingtong"] = "ShadowLee",
  ["illustrator:nos__lingtong"] = "绵Myan",

  ["nos__xuanfeng"] = "旋风",
  [":nos__xuanfeng"] = "当你失去装备区内的牌后，你可以选择一项：1.视为使用一张【杀】（无距离次数限制）；2.对距离1的一名其他角色造成1点伤害。",
  ["#nos__xuanfeng-choose"] = "旋风：你可以视为使用一张【杀】，或对距离1的一名其他角色造成1点伤害",
  ["nos__xuanfeng_slash"] = "视为对其使用【杀】",
  ["nos__xuanfeng_damage"] = "对其造成1点伤害",

  ["$nos__xuanfeng1"] = "伤敌于千里之外！",
  ["$nos__xuanfeng2"] = "索命于须臾之间！",
  ["~nos__lingtong"] = "大丈夫不惧死亡……",
}

local lingtong = General(extension, "lingtong", "wu", 4)
local xuanfeng = fk.CreateTriggerSkill{
  name = "xuanfeng",
  anim_type = "control",
  events = {fk.AfterCardsMove, fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.AfterCardsMove then
        for _, move in ipairs(data) do
          if move.from == player.id then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerEquip then
                return not table.every(player.room.alive_players, function (p)
                  return p == player or p:isNude()
                end)
              end
            end
          end
        end
      elseif event == fk.EventPhaseEnd then
        if target == player and player.phase == Player.Discard and not table.every(player.room.alive_players, function (p)
          return p == player or p:isNude()
        end) then
          local x = 0
          local logic = player.room.logic
          logic:getEventsOfScope(GameEvent.MoveCards, 1, function (e)
            for _, move in ipairs(e.data) do
              if move.from == player.id and move.moveReason == fk.ReasonDiscard and move.skillName == "phase_discard" then
                x = x + #move.moveInfo
                if x > 1 then return true end
              end
            end
            return false
          end, Player.HistoryTurn)
          return x > 1
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function(p) return not p:isNude() and p ~= player end)
    if #targets == 0 then return false end
    local tos = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1, "#xuanfeng-choose", self.name, true, true)
    if #tos > 0 then
      self.cost_data = { tos = tos }
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data.tos[1])
    local card = room:askForCardChosen(player, to, "he", self.name)
    room:throwCard({card}, self.name, to, player)
    if player.dead then return false end
    local targets = table.filter(room.alive_players, function(p) return not p:isNude() and p ~= player end)
    if #targets > 0 then
      local tos = room:askForChoosePlayers(player, table.map(targets, Util.IdMapper), 1, 1, "#xuanfeng-choose", self.name, true)
      if #tos > 0 then
        to = room:getPlayerById(tos[1])
        card = room:askForCardChosen(player, to, "he", self.name)
        room:throwCard({card}, self.name, to, player)
      end
    end
  end,
}

lingtong:addSkill(xuanfeng)
Fk:loadTranslationTable{
  ["lingtong"] = "凌统",
  ["#lingtong"] = "豪情烈胆",
  ["cv:lingtong"] = "冷泉月夜",
  ["illustrator:lingtong"] = "DH", -- 精良皮 豪情烈胆

  ["xuanfeng"] = "旋风",
  [":xuanfeng"] = "当你失去装备区里的牌后，或弃牌阶段结束时，若你于此阶段内弃置过你的至少两张手牌，你可以依次弃置至多两名其他角色共计两张牌。",
  ["#xuanfeng-choose"] = "旋风：你可以依次弃置一至两名角色的共计两张牌",

  ["$xuanfeng1"] = "伤敌于千里之外！",
  ["$xuanfeng2"] = "索命于须臾之间！",
  ["~lingtong"] = "大丈夫不惧死亡……",
}

local wuguotai = General(extension, "wuguotai", "wu", 3, 3, General.Female)
local ganlu = fk.CreateActiveSkill{
  name = "ganlu",
  anim_type = "control",
  target_num = 2,
  card_num = 0,
  prompt = function()
    return "#ganlu:::"..Self:getLostHp()
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    if #selected == 0 then
      return #Fk:currentRoom():getPlayerById(to_select).player_cards[Player.Equip] > 0
    elseif #selected == 1 then
      local target1 = Fk:currentRoom():getPlayerById(to_select)
      local target2 = Fk:currentRoom():getPlayerById(selected[1])
      return math.abs(#target1:getCardIds("e") - #target2:getCardIds("e")) <= Self:getLostHp()
    else
      return false
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target1 = room:getPlayerById(effect.tos[1])
    local target2 = room:getPlayerById(effect.tos[2])
    U.swapCards(room, player, target1, target2, target1:getCardIds("e"), target2:getCardIds("e"), self.name, Card.PlayerEquip)
  end,
}
local buyi = fk.CreateTriggerSkill{
  name = "buyi",
  anim_type = "support",
  events = {fk.EnterDying},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and not target:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, data, "#buyi-invoke::"..target.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local id = room:askForCardChosen(player, target, "h", self.name)
    target:showCards({id})
    if target.dead then return end
    if Fk:getCardById(id).type ~= Card.TypeBasic then
      room:throwCard({id}, self.name, target, target)
      if target.dead or not target:isWounded() then return end
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
  ["#wuguotai"] = "武烈皇后",
  ["designer:wuguotai"] = "章鱼",
  ["illustrator:wuguotai"] = "zoo",

  ["ganlu"] = "甘露",
  [":ganlu"] = "出牌阶段限一次，你可以选择装备区内牌数之差不大于X的两名角色，交换其装备区内的牌（X为你已损失体力值）。",
  ["buyi"] = "补益",
  [":buyi"] = "当一名角色进入濒死状态时，你可以展示该角色一张手牌，若不为基本牌，则其弃置此牌并回复1点体力。",
  ["#ganlu"] = "甘露：选择装备区内牌数之差不大于%arg的两名角色，交换其装备区内的牌",
  ["#buyi-invoke"] = "补益：你可以展示%dest的一张手牌，若为非基本牌则其弃掉并回复1点体力",

  ["$ganlu1"] = "男婚女嫁，须当交换文定之物。",
  ["$ganlu2"] = "此真乃吾之佳婿也。",
  ["$buyi1"] = "吾乃吴国之母，何人敢放肆？",
  ["$buyi2"] = "有老身在，汝等尽可放心。",
  ["~wuguotai"] = "卿等，务必用心辅佐仲谋……",
}

local xusheng = General(extension, "xusheng", "wu", 4)
local pojun = fk.CreateTriggerSkill{
  name = "pojun",
  anim_type = "control",
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card and data.card.trueName == "slash"
    and not data.to.dead and player.room.logic:damageByCardEffect()
  end,
  on_use = function(self, event, target, player, data)
    local to = data.to
    to:drawCards(math.min(data.to.hp, 5))
    if to.dead then return end
    to:turnOver()
  end
}
xusheng:addSkill(pojun)
Fk:loadTranslationTable{
  ["xusheng"] = "徐盛",
  ["#xusheng"] = "江东的铁壁",
  ["designer:xusheng"] = "阿江",
  ["illustrator:xusheng"] = "刘周",

  ["pojun"] = "破军",
  [":pojun"] = "当你使用【杀】对目标角色造成伤害后，你可以令其摸X张牌（X为其体力值，至多为5），然后其翻面。",

  ["$pojun1"] = "大军在此！汝等休想前进一步！",
  ["$pojun2"] = "敬请，养精蓄锐！",
  ["~xusheng"] = "盛，不能奋身出命，不亦辱乎……",
}

local gaoshun = General(extension, "gaoshun", "qun", 4)
local xianzhen = fk.CreateActiveSkill{
  name = "xianzhen",
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  prompt = "#xianzhen",
  can_use = function(self, player)
    return not player:isKongcheng() and player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id and Self:canPindian(Fk:currentRoom():getPlayerById(to_select))
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local pindian = player:pindian({target}, self.name)
    if pindian.results[target.id].winner == player then
      room:addPlayerMark(target, "@@xianzhen-turn")
      room:addTableMark(player, "xianzhen_target-turn", target.id)
      room:addTableMark(player, fk.MarkArmorInvalidTo .. "-turn", target.id)
    else
      room:setPlayerMark(player, "xianzhen_lose-turn", 1)
    end
  end,
}
local xianzhen_targetmod = fk.CreateTargetModSkill{
  name = "#xianzhen_targetmod",
  bypass_times = function(self, player, skill, scope, card, to)
    return card and to and table.contains(player:getTableMark("xianzhen_target-turn"), to.id)
  end,
  bypass_distances = function(self, player, skill, card, to)
    return card and to and table.contains(player:getTableMark("xianzhen_target-turn"), to.id)
  end,
}
local xianzhen_prohibit = fk.CreateProhibitSkill{
  name = "#xianzhen_prohibit",
  prohibit_use = function(self, player, card)
    return player:getMark("xianzhen_lose-turn") > 0 and card.trueName == "slash"
  end,
}
local jinjiu = fk.CreateFilterSkill{
  name = "jinjiu",
  card_filter = function(self, card, player, isJudgeEvent)
    return player:hasSkill(self) and card.name == "analeptic" and
    (table.contains(player.player_cards[Player.Hand], card.id) or isJudgeEvent)
  end,
  view_as = function(self, card)
    return Fk:cloneCard("slash", card.suit, card.number)
  end,
}
xianzhen:addRelatedSkill(xianzhen_targetmod)
xianzhen:addRelatedSkill(xianzhen_prohibit)
gaoshun:addSkill(xianzhen)
gaoshun:addSkill(jinjiu)
Fk:loadTranslationTable{
  ["gaoshun"] = "高顺",
  ["#gaoshun"] = "攻无不克",
  ["designer:gaoshun"] = "羽柴文理",
  ["illustrator:gaoshun"] = "鄧Sir",

  ["xianzhen"] = "陷阵",
  [":xianzhen"] = "出牌阶段限一次，你可以与一名角色拼点：若你赢，直到回合结束，你对该角色使用牌无距离限制且无视其防具牌，使用【杀】无次数限制；"..
  "若你没赢，你不能使用【杀】直到回合结束。",
  ["jinjiu"] = "禁酒",
  [":jinjiu"] = "锁定技，你的【酒】及作为你的判定牌的【酒】的牌名视为【杀】且此【杀】为普【杀】。",

  ["#xianzhen"] = "陷阵：与一名角色拼点，若赢，你对其使用牌无距离限制且无视防具，对其使用【杀】无次数限制",
  ["@@xianzhen-turn"] = "陷阵",

  ["$xianzhen1"] = "攻无不克，战无不胜！",
  ["$xianzhen2"] = "破阵斩将，易如反掌！",
  ["$jinjiu1"] = "贬酒阙色，所以无污。",
  ["$jinjiu2"] = "避嫌远疑，所以无误。",
  ["~gaoshun"] = "生死有命……",
}

local chengong = General(extension, "chengong", "qun", 3)
local mingce = fk.CreateActiveSkill{
  name = "mingce",
  anim_type = "support",
  card_num = 1,
  target_num = 1,
  prompt = "#mingce",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
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
    room:obtainCard(target.id, Fk:getCardById(effect.cards[1]), false, fk.ReasonGive, player.id)
    if player.dead or target.dead then return end
    local targets = table.map(table.filter(room:getOtherPlayers(target), function(p)
      return target:inMyAttackRange(p) end), Util.IdMapper)
    if #targets == 0 then
      target:drawCards(1, self.name)
    else
      local to = room:askForChoosePlayers(player, targets, 1, 1, "#mingce-choose::"..target.id, self.name, false, true)
      to = room:getPlayerById(to[1])
      room:doIndicate(target.id, {to.id})
      local choice = room:askForChoice(target, {"mingce_slash::"..to.id, "draw1"}, self.name)
      if choice == "draw1" then
        target:drawCards(1, self.name)
      else
        room:useVirtualCard("slash", nil, target, to, self.name, true)
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
    if player.phase == Player.NotActive then
      if event == fk.Damaged then
        return target == player and player:hasSkill(self)
      else
        return player.id == data.to and player:usedSkillTimes(self.name, Player.HistoryTurn) > 0 and
          (data.card.trueName == "slash" or data.card:isCommonTrick())
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.Damaged then
      player.room:setPlayerMark(player, "@@zhichi-turn", 1)
    else
      return true
    end
  end,
}
chengong:addSkill(mingce)
chengong:addSkill(zhichi)
Fk:loadTranslationTable{
  ["chengong"] = "陈宫",
  ["#chengong"] = "刚直壮烈",
  ["designer:chengong"] = "Kaycent",
  ["cv:chengong"] = "金垚",
  ["illustrator:chengong"] = "黑月乱",

  ["mingce"] = "明策",
  [":mingce"] = "出牌阶段限一次，你可以交给一名其他角色一张装备牌或【杀】，其选择一项：1.视为对其攻击范围内一名你指定的角色使用一张【杀】；2.摸一张牌。",
  ["zhichi"] = "智迟",
  [":zhichi"] = "锁定技，你的回合外，当你受到伤害后，此回合【杀】和普通锦囊牌对你无效。",
  ["#mingce"] = "明策：交给一名角色一张装备牌或【杀】，其选择视为对你指定的角色使用【杀】或摸一张牌",
  ["#mingce-choose"] = "明策：选择 %dest 视为使用【杀】的目标",
  ["mingce_slash"] = "视为对%dest使用【杀】",
  ["@@zhichi-turn"] = "智迟",

  ["$mingce1"] = "如此，霸业可图也。",
  ["$mingce2"] = "如此，一击可擒也。",
  ["$zhichi1"] = "如今之计，唯有退守，再做决断。",
  ["$zhichi2"] = "若吾，早知如此……",
  ["~chengong"] = "请出就戮！",
}

return extension

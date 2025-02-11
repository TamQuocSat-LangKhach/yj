local extension = Package("yjcm2014")
extension.extensionName = "yj"

local U = require "packages/utility/utility"

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
    if player:hasSkill(self) then
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
      local card = room:askForCard(player, 1, 1, false, self.name, true, ".|.|.|sidi|.|.", "#sidi-invoke::"..target.id, "sidi")
      if #card > 0 then
        self.cost_data = card
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.CardUseFinished then
      player:addToPile(self.name, room:getNCards(1), true, self.name)
    else
      room:doIndicate(player.id, {target.id})
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
  ["#caozhen"] = "荷国天督",
  ["designer:caozhen"] = "世外高v狼",
  ["illustrator:caozhen"] = "Thinking",
  ["sidi"] = "司敌",
  [":sidi"] = "每当你使用或其他角色在你的回合内使用【闪】时，你可以将牌堆顶的一张牌正面向上置于你的武将牌上；一名其他角色的出牌阶段开始时，"..
  "你可以将你武将牌上的一张牌置入弃牌堆，然后该角色本阶段可使用【杀】的次数上限-1。",
  ["#sidi-invoke"] = "司敌：你可以将一张“司敌”牌置入弃牌堆，令 %dest 本阶段使用【杀】次数上限-1",

  ["$sidi1"] = "筑城固守，司敌备战。",
  ["$sidi2"] = "徒手制敌，能奈我何？",
  ["~caozhen"] = "秋雨凄迷，军心已乱……",
}

local chenqun = General(extension, "chenqun", "wei", 3)
local pindi = fk.CreateActiveSkill{
  name = "pindi",
  anim_type = "control",
  card_num = 1,
  target_num = 1,
  prompt = function(self)
    return "#pindi-active:::"..(Self:usedSkillTimes(self.name, Player.HistoryTurn) + 1)
  end,
  card_filter = function(self, to_select, selected)
    if #selected == 0 and not Self:prohibitDiscard(Fk:getCardById(to_select)) then
      local mark = Self:getTableMark("pindi_types-turn")
      return not table.contains(mark, Fk:getCardById(to_select):getTypeString())
    end
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id and not table.contains(Self:getTableMark("pindi_targets-turn"), to_select)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])

    room:addTableMark(player, "pindi_types-turn", Fk:getCardById(effect.cards[1]):getTypeString())
    room:addTableMark(player, "pindi_targets-turn", target.id)

    room:throwCard(effect.cards, self.name, player)
    if player.dead or target.dead then return end
    local n = player:usedSkillTimes(self.name, Player.HistoryTurn)
    if target:isNude() or room:askForChoice(player, {"#pindi-draw::".. target.id .. ":" .. n,
    "#pindi-discard::".. target.id .. ":" .. n}, self.name):startsWith("#pindi-draw") then
      target:drawCards(n, self.name)
    else
      room:askForDiscard(target, n, n, true, self.name, false)
    end
    if not target.dead and target:isWounded() and not player.dead and not player.chained then
      player:setChainState(true)
    end
  end,
}
local faen = fk.CreateTriggerSkill{
  name = "faen",
  anim_type = "support",
  events = {fk.TurnedOver, fk.ChainStateChanged},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and not target.dead then
      return (event == fk.TurnedOver and target.faceup) or (event == fk.ChainStateChanged and target.chained)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askForSkillInvoke(player, self.name, nil, "#faen-invoke::"..target.id) then
      self.cost_data = {tos = {target.id}}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    target:drawCards(1, self.name)
  end,
}
chenqun:addSkill(pindi)
chenqun:addSkill(faen)
Fk:loadTranslationTable{
  ["chenqun"] = "陈群",
  ["#chenqun"] = "万世臣表",
  ["designer:chenqun"] = "Michael_Lee",
  ["illustrator:chenqun"] = "NOVART",
  ["pindi"] = "品第",
  [":pindi"] = "出牌阶段，你可以弃置一张于此回合内未以此法弃置过的类别的牌并选择此回合内未以此法选择过的一名其他角色，"..
  "你选择：1.令其摸X张牌；2.令其弃置X张牌。若其已受伤，你横置。（X为你于此回合内发动过此技能的次数）",
  ["faen"] = "法恩",
  [":faen"] = "当一名角色的武将牌翻至正面朝上或横置后，你可以令其摸一张牌。",
  ["#pindi-active"] = "品第：弃置一张未弃置过类别的牌，令一名其他角色摸牌或弃牌（%arg张）",
  ["#faen-invoke"] = "法恩：你可以令 %dest 摸一张牌",
  ["#pindi-draw"] = "令%dest摸%arg张牌",
  ["#pindi-discard"] = "令%dest弃置%arg张牌",

  ["$pindi1"] = "观其风气，查其品行。",
  ["$pindi2"] = "推举贤才，兴盛大魏。",
  ["$faen1"] = "王法威仪，恩泽天下。",
  ["$faen2"] = "法外有情，恩威并举。",
  ["~chenqun"] = "三朝如一日，弹指一挥间……",
}

local nos__chenqun = General(extension, "nos__chenqun", "wei", 3)
local dingpin = fk.CreateActiveSkill{
  name = "dingpin",
  anim_type = "support",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return not player:isKongcheng()
  end,
  card_filter = function(self, to_select, selected)
    if #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip and not Self:prohibitDiscard(Fk:getCardById(to_select)) then
      local types = Self:getMark("dingpin-turn")
      if type(types) == "table" then
        return not table.contains(types, Fk:getCardById(to_select):getTypeString())
      else
        return true
      end
    end
  end,
  target_filter = function(self, to_select, selected)
    local target = Fk:currentRoom():getPlayerById(to_select)
    return #selected == 0 and target:isWounded() and target:getMark("dingpin_target-turn") == 0
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
      target:drawCards(target:getLostHp(), self.name)
      room:setPlayerMark(target, "dingpin_target-turn", 1)
    elseif judge.card.color == Card.Red then
      player:turnOver()
    end
   end
}
local dingpin_record = fk.CreateTriggerSkill{
  name = "#dingpin_record",

  refresh_events = {fk.CardUsing, fk.AfterCardsMove},
  can_refresh = function(self, event, target, player, data)
    if player:hasSkill(self) and player.phase ~= Player.NotActive then
      if event == fk.CardUsing then
        return target == player
      elseif event == fk.AfterCardsMove then
        for _, move in ipairs(data) do
          if move.from == player.id and move.toArea == Card.DiscardPile and move.moveReason == fk.ReasonDiscard then
            return true
          end
        end
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.CardUsing then
      local types = player:getMark("dingpin-turn")
      if types == 0 then types = {} end
      table.insertIfNeed(types, data.card:getTypeString())
      room:setPlayerMark(player, "dingpin-turn", types)
    elseif event == fk.AfterCardsMove then
      local types = player:getMark("dingpin-turn")
      if types == 0 then types = {} end
      for _, move in ipairs(data) do
        if move.from == player.id and move.toArea == Card.DiscardPile and move.moveReason == fk.ReasonDiscard then
          for _, info in ipairs(move.moveInfo) do
            table.insertIfNeed(types, Fk:getCardById(info.cardId):getTypeString())
          end
        end
      end
      room:setPlayerMark(player, "dingpin-turn", types)
    end
  end,
}
local nos__faen = fk.CreateTriggerSkill{
  name = "nos__faen",
  anim_type = "drawcard",
  events = {fk.TurnedOver, fk.ChainStateChanged},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and not target.dead then
      return event == fk.TurnedOver or (event == fk.ChainStateChanged and target.chained)
    end
  end,
  on_cost = function(self, event, target, player, data)
    self.cost_data = {tos = {target.id}}
    return player.room:askForSkillInvoke(player, self.name, nil, "#nos__faen-invoke::"..target.id)
  end,
  on_use = function(self, event, target, player, data)
    target:drawCards(1, self.name)
  end,
}
dingpin:addRelatedSkill(dingpin_record)
nos__chenqun:addSkill(dingpin)
nos__chenqun:addSkill(nos__faen)
Fk:loadTranslationTable{
  ["nos__chenqun"] = "陈群",
  ["#nos__chenqun"] = "万世臣表",
  ["designer:nos__chenqun"] = "Michael_Lee",
  ["illustrator:nos__chenqun"] = "DH",
  ["dingpin"] = "定品",
  [":dingpin"] = "出牌阶段，你可以弃置一张与你本回合已使用或弃置的牌类别均不同的手牌，然后令一名已受伤的角色进行一次判定，若结果为黑色，"..
  "该角色摸X张牌（X为该角色已损失的体力值），然后你本回合不能再对其发动〖定品〗；若结果为红色，将你的武将牌翻面。",
  ["nos__faen"] = "法恩",
  [":nos__faen"] = "每当一名角色的武将牌翻面或横置时，你可以令其摸一张牌。",
  ["#nos__faen-invoke"] = "法恩：你可以令 %dest 摸一张牌",

  ["$dingpin1"] = "取才赋职，论能行赏。",
  ["$dingpin2"] = "定品寻良骥，中正探人杰。",
  ["$nos__faen1"] = "礼法容情，皇恩浩荡。",
  ["$nos__faen2"] = "法理有度，恩威并施。",
  ["~nos__chenqun"] = "吾身虽陨，典律昭昭。",
}

local hanhaoshihuan = General(extension, "hanhaoshihuan", "wei", 4)
local shenduan = fk.CreateTriggerSkill{
  name = "shenduan",
  anim_type = "control",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      for _, move in ipairs(data) do
        if move.from == player.id and move.moveReason == fk.ReasonDiscard then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand and player.room:getCardArea(info.cardId) == Card.DiscardPile then
              local card = Fk:getCardById(info.cardId)
              if card.type == Card.TypeBasic and card.color == Card.Black then
                return true
              end
            end
          end
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local ids = {}
    for _, move in ipairs(data) do
      if move.from == player.id and move.moveReason == fk.ReasonDiscard then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand and player.room:getCardArea(info.cardId) == Card.DiscardPile then
            local card = Fk:getCardById(info.cardId)
            if card.type == Card.TypeBasic and card.color == Card.Black then
              table.insertIfNeed(ids, info.cardId)
            end
          end
        end
      end
    end
    for i = 1, #ids, 1 do
      if not player:hasSkill(self) then break end
      local cards = table.filter(ids, function(id) return player.room:getCardArea(id) == Card.DiscardPile end)
      if #cards == 0 then break end
      self.cancel_cost = false
      self:doCost(event, nil, player, cards)
      if self.cancel_cost then
        self.cancel_cost = false
        break
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, self.name, data)
    local _, dat = room:askForUseViewAsSkill(player, "shenduan_active", "#shenduan-use", true,
    {expand_pile = data, bypass_distances = true})
    if dat then
      self.cost_data = dat
      return true
    else
      self.cancel_cost = true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:useVirtualCard("supply_shortage", self.cost_data.cards, player, room:getPlayerById(self.cost_data.targets[1]), self.name)
  end,
}
local shenduan_active = fk.CreateViewAsSkill{
  name = "shenduan_active",
  expand_pile = function () return Self:getTableMark("shenduan") end,
  card_filter = function(self, to_select, selected)
    if #selected == 0 then
      local ids = Self:getMark("shenduan")
      return type(ids) == "table" and table.contains(ids, to_select)
    end
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return nil end
    local c = Fk:cloneCard("supply_shortage")
    c.skillName = "shenduan"
    c:addSubcard(cards[1])
    return c
  end,
}
local yonglue = fk.CreateTriggerSkill{
  name = "yonglue",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target.phase == Player.Judge and #target:getCardIds("j") > 0 and player:inMyAttackRange(target)
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#yonglue-invoke::"..target.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    local card = room:askForCardChosen(player, target, "j", self.name)
    room:throwCard({card}, self.name, target, player)
    if player.dead or target.dead then return end
    local use = {
      from = player.id,
      tos = {{target.id}},
      card = Fk:cloneCard("slash"),
      extraUse = true,
    }
    use.card.skillName = self.name
    room:useCard(use)
    if not player.dead and not use.damageDealt then
      player:drawCards(1, self.name)
    end
  end,
}
Fk:addSkill(shenduan_active)
hanhaoshihuan:addSkill(shenduan)
hanhaoshihuan:addSkill(yonglue)
Fk:loadTranslationTable{
  ["hanhaoshihuan"] = "韩浩史涣",
  ["#hanhaoshihuan"] = "中军之主",
  ["designer:hanhaoshihuan"] = "浪人兵法家",
  ["illustrator:hanhaoshihuan"] = "lylylyang",
  ["shenduan"] = "慎断",
  [":shenduan"] = "当你的黑色基本牌因弃置进入弃牌堆时，你可以将此牌当无距离限制的【兵粮寸断】使用。",
  ["yonglue"] = "勇略",
  [":yonglue"] = "你攻击范围内的一名其他角色的判定阶段开始时，你可以弃置其判定区里的一张牌，视为对该角色使用【杀】，若此【杀】未造成伤害，你摸一张牌。",
  ["#shenduan-use"] = "慎断：你可以将这些牌当【兵粮寸断】使用",
  ["shenduan_active"] = "慎断",
  ["#yonglue-invoke"] = "勇略：你可以弃置 %dest 判定区一张牌，视为对其使用【杀】",

  ["$shenduan1"] = "良机虽去，尚可截资断源！",
  ["$shenduan2"] = "行军须慎，谋断当绝！",
  ["$yonglue1"] = "不必从言，自有主断！",
  ["$yonglue2"] = "非常之机，当行非常之计！",
  ["~hanhaoshihuan"] = "那拈弓搭箭的将军，是何人？",
}

local zhoucang = General(extension, "zhoucang", "shu", 4)
local zhongyong = fk.CreateTriggerSkill{
  name = "zhongyong",
  anim_type = "offensive",
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and player.phase == Player.Play and data.card.name == "jink" and
      data.toCard and data.toCard.trueName == "slash" and data.responseToEvent.from == player.id and
      player.room:getCardArea(data.card) == Card.Processing
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askForChoosePlayers(player, table.map(room:getOtherPlayers(target), Util.IdMapper), 1, 1,
      "#zhongyong-choose::"..target.id, self.name, true)
    if #to > 0 then
      self.cost_data = {tos = to}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = self.cost_data.tos[1]
    room:obtainCard(to, data.card, true, fk.ReasonGive, player.id)
    if to ~= player.id then
      local use = room:askForUseCard(player, "slash", "slash", "#zhongyong-slash::"..target.id, true, {must_targets = {target.id}})
      if use then
        use.extraUse = true
        room:useCard(use)
      end
    end
  end,
}
zhoucang:addSkill(zhongyong)
Fk:loadTranslationTable{
  ["zhoucang"] = "周仓",
  ["#zhoucang"] = "披肝沥胆",
  ["designer:zhoucang"] = "WOLVES29",
  ["illustrator:zhoucang"] = "ocsky",
  ["zhongyong"] = "忠勇",
  [":zhongyong"] = "当你于出牌阶段内使用的【杀】被目标角色使用的【闪】抵消时，你可以将此【闪】交给除该角色外的一名角色，若获得此【闪】的角色不是你，"..
  "你可以对相同的目标再使用一张【杀】。",
  ["#zhongyong-choose"] = "忠勇：将此【闪】交给除 %dest 以外的一名角色，若不是你，你可以对其再使用一张【杀】",
  ["#zhongyong-slash"] = "忠勇：你可以对 %dest 再使用一张【杀】",

  ["$zhongyong1"] = "驱刀飞血，直取寇首！",
  ["$zhongyong2"] = "为将军提刀携马，万死不辞！",
  ["~zhoucang"] = "为将军操刀牵马，此生无憾。",
}

local wuyi = General(extension, "wuyi", "shu", 4)
local benxi = fk.CreateTriggerSkill{
  name = "benxi",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.CardUsing, fk.AfterCardTargetDeclared},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.room.current == player and
    (event == fk.CardUsing or (data.card and data.card.trueName == "slash" and
    table.every(player.room.alive_players, function (p) return player:distanceTo(p) < 2 end) and
    #player.room:getUseExtraTargets(data, false) > 0))
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.CardUsing then
      player.room:addPlayerMark(player, "@benxi-turn", 1)
    else
      local room = player.room
      local targets = room:getUseExtraTargets(data, false)
      if #targets == 0 then return false end
      targets = room:askForChoosePlayers(player, targets, 1, 1, "#benxi-choose", self.name, true)
      if #targets > 0 then
        table.insert(data.tos, targets)
      end
    end
  end,
}
local benxi_armorInvalidity = fk.CreateInvaliditySkill {
  name = "#benxi_invalidity",
  invalidity_func = function(self, player, skill)
    if skill.attached_equip and Fk:cloneCard(skill.attached_equip).sub_type == Card.SubtypeArmor then

      --无视防具（规则集版）！
      if RoomInstance then
        local skill_owner = RoomInstance.current
        if not (skill_owner:hasSkill(benxi) and table.every(RoomInstance.alive_players, function (p)
          return skill_owner:distanceTo(p) < 2
        end)) then return false end

        local logic = RoomInstance.logic
        local event = logic:getCurrentEvent()
        repeat
          if event.event == GameEvent.SkillEffect then
            if not event.data[3].cardSkill then
              return event.data[2] == skill_owner
            end
          elseif event.event == GameEvent.Damage then
            local damage = event.data[1]
            return damage.to == player and damage.from == skill_owner
          elseif event.event == GameEvent.UseCard then
            local use = event.data[1]
            return use.from == skill_owner.id and table.contains(TargetGroup:getRealTargets(use.tos), player.id)
          end
          event = event.parent
        until event == nil
      end
    end
  end
}
local benxi_distance = fk.CreateDistanceSkill{
  name = "#benxi_distance",
  correct_func = function(self, from, to)
    return -from:getMark("@benxi-turn")
  end,
}
benxi:addRelatedSkill(benxi_armorInvalidity)
benxi:addRelatedSkill(benxi_distance)
wuyi:addSkill(benxi)
Fk:loadTranslationTable{
  ["wuyi"] = "吴懿",
  ["#wuyi"] = "建兴鞍辔",
  ["designer:wuyi"] = "沸治克里夫",
  ["illustrator:wuyi"] = "蚂蚁君",
  ["benxi"] = "奔袭",
  [":benxi"] = "锁定技，当你于回合内使用牌时，本回合你计算与其他角色的距离-1；你的回合内，若你与所有其他角色的距离均为1，"..
  "则你无视其他角色的防具且你使用【杀】可以多指定一个目标。",
  ["@benxi-turn"] = "奔袭",
  ["#benxi-choose"] = "奔袭：你可以多指定一个目标",

  ["$benxi1"] = "奔战万里，袭关斩将。",
  ["$benxi2"] = "袭敌千里，溃敌百步！",
  ["~wuyi"] = "奔波已疲，难以，再战。",
}

local zhangsong = General(extension, "zhangsong", "shu", 3)
local qiangzhi = fk.CreateTriggerSkill{
  name = "qiangzhi",
  mute = true,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Play and
      table.find(player.room:getOtherPlayers(player), function(p) return p:getHandcardNum() > 0 end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room:getOtherPlayers(player), function(p)
      return not p:isKongcheng() end), Util.IdMapper)
    local to = room:askForChoosePlayers(player, targets, 1, 1, "#qiangzhi-choose", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name, 1)
    room:notifySkillInvoked(player, self.name, "control")
    local to = room:getPlayerById(self.cost_data)
    room:doIndicate(player.id, {self.cost_data})
    local card = Fk:getCardById(room:askForCardChosen(player, to, "h", self.name))
    to:showCards(card)
    local cardType = card:getTypeString()
    if cardType ~= "notype" then room:setPlayerMark(player, "@qiangzhi-phase", cardType) end
  end,
}
local qiangzhi_trigger = fk.CreateTriggerSkill{
  name = "#qiangzhi_trigger",
  mute = true,
  events = {fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Play and player:getMark("@qiangzhi-phase") ~= 0 and
      data.card:getTypeString() == player:getMark("@qiangzhi-phase")
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, "qiangzhi", nil, "#qiangzhi-invoke")
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("qiangzhi", 2)
    room:notifySkillInvoked(player, "qiangzhi", "drawcard")
    player:drawCards(1, "qiangzhi")
  end,
}
local xiantu = fk.CreateTriggerSkill{
  name = "xiantu",
  mute = true,
  anim_type = "support",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(self) and target.phase == Player.Play and not target.dead
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, data, "#xiantu-invoke::"..target.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name, 1)
    room:notifySkillInvoked(player, self.name)
    room:doIndicate(player.id, {target.id})
    room:setPlayerMark(player, "xiantu-phase", 1)
    player:drawCards(2, self.name)
    if player:isNude() then return end
    local cards
    if #player:getCardIds{Player.Hand, Player.Equip} <= 2 then
      cards = player:getCardIds{Player.Hand, Player.Equip}
    else
      cards = room:askForCard(player, 2, 2, true, self.name, false, ".", "#xiantu-give::"..target.id)
    end
    room:moveCardTo(cards, Player.Hand, target, fk.ReasonGive, self.name, nil, false, player.id)
  end,
}
local xiantu_trigger = fk.CreateTriggerSkill{
  name = "#xiantu_trigger",
  mute = true,
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    if target ~= player and target.phase == Player.Play and player:getMark("xiantu-phase") > 0 then
      return #player.room.logic:getEventsOfScope(GameEvent.Death, 1, function(e)
        local death = e.data[1]
        return death.damage and death.damage.from == target
      end, Player.HistoryPhase) == 0
    end
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("xiantu", 2)
    room:notifySkillInvoked(player, "xiantu", "negative")
    room:loseHp(player, 1, "xiantu")
  end,
}
qiangzhi:addRelatedSkill(qiangzhi_trigger)
xiantu:addRelatedSkill(xiantu_trigger)
zhangsong:addSkill(qiangzhi)
zhangsong:addSkill(xiantu)
Fk:loadTranslationTable{
  ["zhangsong"] = "张松",
  ["#zhangsong"] = "怀璧待凤仪",
  ["designer:zhangsong"] = "冷王无双",
  ["illustrator:zhangsong"] = "尼乐小丑",
  ["qiangzhi"] = "强识",
  [":qiangzhi"] = "出牌阶段开始时，你可以展示一名其他角色的一张手牌，然后当你于此阶段内使用与此牌类别相同的牌时，你可以摸一张牌。",
  ["xiantu"] = "献图",
  [":xiantu"] = "其他角色的出牌阶段开始时，你可以摸两张牌，然后交给其两张牌，然后此阶段结束时，若其于此回合内未杀死过角色，则你失去1点体力。",
  ["#qiangzhi-choose"] = "强识：展示一名其他角色的一张手牌，此阶段内你使用类别相同的牌时，你可以摸一张牌",
  ["#qiangzhi-invoke"] = "强识：你可以摸一张牌",
  ["@qiangzhi-phase"] = "强识",
  ["#xiantu-invoke"] = "献图：你可以摸两张牌并交给 %dest 两张牌",
  ["#xiantu-give"] = "献图：选择交给 %dest 的两张牌",

  ["$qiangzhi1"] = "容我过目，即刻咏来。",
  ["$qiangzhi2"] = "文书强识，才可博于运筹。",
  ["$xiantu1"] = "将军莫虑，且看此图。",
  ["$xiantu2"] = "我已诚心相献，君何踌躇不前？",
  ["~zhangsong"] = "皇叔不听吾谏言，悔时晚矣！",
}

local guyong = General(extension, "guyong", "wu", 3)
local shenxing = fk.CreateActiveSkill{
  name = "shenxing",
  anim_type = "drawcard",
  prompt = "#shenxing-active",
  card_num = 2,
  target_num = 0,
  can_use = Util.TrueFunc,
  card_filter = function(self, to_select, selected)
    return #selected < 2 and not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, self.name, player, player)
    if not player.dead then
      player:drawCards(1, self.name)
    end
  end
}
local bingyi = fk.CreateTriggerSkill{
  name = "bingyi",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish and not player:isKongcheng()
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
    local tos = room:askForChoosePlayers(player, table.map(room:getAlivePlayers(), Util.IdMapper), 1, #cards, "#bingyi-choose:::"..#cards, self.name, true)
    if #tos > 0 then
      for _, p in ipairs(tos) do
        room:getPlayerById(p):drawCards(1, self.name)
      end
    end
  end,
}
guyong:addSkill(shenxing)
guyong:addSkill(bingyi)
Fk:loadTranslationTable{
  ["guyong"] = "顾雍",
  ["#guyong"] = "庙堂的玉磐",
  ["designer:guyong"] = "睿笛终落",
  ["illustrator:guyong"] = "大佬荣",
  ["shenxing"] = "慎行",
  [":shenxing"] = "出牌阶段，你可以弃置两张牌，然后摸一张牌。",
  ["bingyi"] = "秉壹",
  [":bingyi"] = "结束阶段开始时，你可以展示所有手牌，若均为同一颜色，则你令至多X名角色各摸一张牌（X为你的手牌数）。",

  ["#shenxing-active"] = "发动 慎行，选择要弃置的两张牌",
  ["#bingyi-choose"] = "秉壹：你可以令至多%arg名角色各摸一张牌",

  ["$shenxing1"] = "审时度势，乃容万变。",
  ["$shenxing2"] = "此需斟酌一二。",
  ["$bingyi1"] = "公正无私，秉持如一。",
  ["$bingyi2"] = "诸君看仔细了！",
  ["~guyong"] = "病躯渐重，国事难安……",
}

local sunluban = General(extension, "sunluban", "wu", 3, 3, General.Female)
local zenhui = fk.CreateTriggerSkill{
  name = "zenhui",
  anim_type = "offensive",
  events = {fk.AfterCardTargetDeclared},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:usedSkillTimes(self.name) == 0 and
      data.tos and #data.tos == 1 and
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
    local to = room:askForChoosePlayers(player, targets, 1, 1, "#zenhui-choose:::"..data.card:toLogString(), self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    if to:isNude() then
      table.insert(data.tos, {self.cost_data})
      return
    end
    local card = room:askForCard(to, 1, 1, true, self.name, true, ".", "#zenhui-give::"..player.id)
    if #card > 0 then
      room:obtainCard(player, card[1], false, fk.ReasonGive, to.id)
      data.from = to.id
      --room.logic:trigger(fk.PreCardUse, to, data)
    else
      table.insert(data.tos, {self.cost_data})
    end
  end,
}
local jiaojin = fk.CreateTriggerSkill{
  name = "jiaojin",
  anim_type = "defensive",
  events = {fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.from and data.from:isMale() and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    return #player.room:askForDiscard(player, 1, 1, true, self.name, true, ".|.|.|.|.|equip", "#jiaojin-cost") > 0
  end,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage - 1
  end,
}
sunluban:addSkill(zenhui)
sunluban:addSkill(jiaojin)
Fk:loadTranslationTable{
  ["sunluban"] = "孙鲁班",
  ["#sunluban"] = "为虎作伥",
  ["designer:sunluban"] = "CatCat44",
  ["illustrator:sunluban"] = "FOOLTOWN",
  ["zenhui"] = "谮毁",
  [":zenhui"] = "出牌阶段限一次，当你使用【杀】或黑色非延时类锦囊牌指定唯一目标时，你令可以成为此牌目标的另一名其他角色选择一项："..
  "交给你一张牌并成为此牌的使用者；或成为此牌的额外目标。",
  ["jiaojin"] = "骄矜",
  [":jiaojin"] = "每当你受到一名男性角色造成的伤害时，你可以弃置一张装备牌，令此伤害-1。",
  ["#zenhui-choose"] = "谮毁：你可以令一名角色选择一项：交给你一张牌并成为%arg的使用者；或成为此牌的额外目标",
  ["#zenhui-give"] = "谮毁：交给 %dest 一张牌以成为此牌使用者，否则你成为此牌额外目标",
  ["#jiaojin-discard"] = "骄矜：你可以弃置一张装备牌，令此伤害-1",

  ["$zenhui1"] = "你也休想置身事外！",
  ["$zenhui2"] = "你可别不识抬举！",
  ["$jiaojin1"] = "就凭你，还想算计于我？",
  ["$jiaojin2"] = "是谁借给你的胆子？",
  ["~sunluban"] = "本公主，何罪之有？",
}

local nos__zhuhuan = General(extension, "nos__zhuhuan", "wu", 4)
local youdi = fk.CreateTriggerSkill{
  name = "youdi",
  anim_type = "control",
  mute = true,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askForChoosePlayers(player, table.map(player.room:getOtherPlayers(player, false), Util.IdMapper),
      1, 1, "#youdi-choose", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    player:broadcastSkillInvoke(self.name, 1)
    room:notifySkillInvoked(player, self.name)
    local card = room:askForCardChosen(to, player, "he", self.name)
    room:throwCard({card}, self.name, player, to)
    if Fk:getCardById(card).trueName ~= "slash" and not to:isNude() then
      player:broadcastSkillInvoke(self.name, 2)
      room:notifySkillInvoked(player, self.name)
      local card2 = room:askForCardChosen(player, to, "he", self.name)
      room:obtainCard(player.id, card2, false)
    end
  end,
}
nos__zhuhuan:addSkill(youdi)
Fk:loadTranslationTable{
  ["nos__zhuhuan"] = "朱桓",
  ["#nos__zhuhuan"] = "中洲拒天人",
  ["designer:nos__zhuhuan"] = "半缘修道",
  ["illustrator:nos__zhuhuan"] = "XXX",
  ["youdi"] = "诱敌",
  [":youdi"] = "结束阶段开始时，你可以令一名其他角色弃置你的一张牌，若此牌不为【杀】，你获得该角色的一张牌。",
  ["#youdi-choose"] = "诱敌：令一名其他角色弃置你的一张牌，若不为【杀】，你获得其一张牌",

  ["$youdi1"] = "无名小卒，可敢再前进一步！",
  ["$youdi2"] = "予以小利，必有大获。",
  ["~nos__zhuhuan"] = "这巍巍巨城，吾竟无力撼动。",
}

local zhuhuan = General(extension, "zhuhuan", "wu", 4, 4)
local fenli = fk.CreateTriggerSkill{
  name = "fenli",
  events = {fk.EventPhaseChanging},
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(self) then return false end
    if data.to == Player.Draw then
      return table.every(player.room:getOtherPlayers(player), function (p)
        return p:getHandcardNum() <= player:getHandcardNum() end)
    elseif data.to == Player.Play then
      return table.every(player.room:getOtherPlayers(player), function (p) return p.hp <= player.hp end)
    elseif data.to == Player.Discard and #player.player_cards[Player.Equip] > 0 then
      return table.every(player.room:getOtherPlayers(player), function (p)
        return #p.player_cards[Player.Equip] <= #player.player_cards[Player.Equip] end)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local phases = {"phase_draw", "phase_play", "phase_discard"}
    return player.room:askForSkillInvoke(player, self.name, data, "#fenli-invoke:::"..phases[data.to - 3])
  end,
  on_use = function(self, event, target, player, data)
    player:skip(data.to)
    return true
  end,
}
local pingkou = fk.CreateTriggerSkill{
  name = "pingkou",
  mute = true,
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish and type(player.skipped_phases) == "table"
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local n = 0
    for _, phase in ipairs({Player.Start, Player.Judge, Player.Draw, Player.Play, Player.Discard, Player.Finish}) do
      if player.skipped_phases[phase] then
        n = n + 1
      end
    end
    local targets = room:askForChoosePlayers(player, table.map(room:getOtherPlayers(player, false), Util.IdMapper),
      1, n, "#pingkou-choose:::"..n, self.name, true)
    if #targets > 0 then
      room:sortPlayersByAction(targets)
      self.cost_data = targets
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, pid in ipairs(self.cost_data) do
      local p = room:getPlayerById(pid)
      if not p.dead then
        room:damage{
          from = player,
          to = p,
          damage = 1,
          skillName = self.name,
        }
      end
    end
  end,
}
zhuhuan:addSkill(fenli)
zhuhuan:addSkill(pingkou)
Fk:loadTranslationTable{
  ["zhuhuan"] = "朱桓",
  ["#zhuhuan"] = "中洲拒天人",
  ["illustrator:zhuhuan"] = "木碗Rae", -- 飞刀制敌
  ["fenli"] = "奋励",
  [":fenli"] = "若你的手牌数为全场最多，你可以跳过摸牌阶段；若你的体力值为全场最多，你可以跳过出牌阶段；"..
  "若你的装备区里有牌且数量为全场最多，你可以跳过弃牌阶段。",
  ["pingkou"] = "平寇",
  [":pingkou"] = "回合结束时，你可以对至多X名其他角色各造成1点伤害（X为你本回合跳过的阶段数）。",
  ["#fenli-invoke"] = "奋励：你可以跳过%arg",
  ["#pingkou-choose"] = "平寇：你可以对至多%arg名角色各造成1点伤害",

  ["$fenli1"] = "以逸待劳，坐收渔利。",
  ["$fenli2"] = "以主制客，占尽优势。",
  ["$pingkou1"] = "对敌人仁慈，就是对自己残忍。",
  ["$pingkou2"] = "反守为攻，直捣黄龙！",
  ["~zhuhuan"] = "我不要死在这病榻之上……",
}

local caifuren = General(extension, "caifuren", "qun", 3, 3, General.Female)
local qieting = fk.CreateTriggerSkill{
  name = "qieting",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target ~= player and target.phase == Player.Finish and player:getMark("qieting-turn") == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choices = {"draw1"}
    local ids = {}
    if target:canMoveCardsInBoardTo(player, "e") then
      table.insert(choices, 1, "qieting_move")
    end
    local choice = room:askForChoice(player, choices, self.name)
    if choice == "qieting_move" then
      room:askForMoveCardInBoard(player, target, player, self.name, "e", target)
    else
      player:drawCards(1, self.name)
    end
  end,

  refresh_events = {fk.CardUsing},
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(self, true) and target ~= player and target.phase ~= Player.NotActive and data.tos
  end,
  on_refresh = function(self, event, target, player, data)
    for _, info in ipairs(data.tos) do
      for _, p in ipairs(info) do
        if p ~= data.from then
          player.room:addPlayerMark(player, "qieting-turn", 1)
          return
        end
      end
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
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and #player.player_cards[Player.Equip] > 0
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
    room:obtainCard(target, player:getCardIds(Player.Equip), false, fk.ReasonGive, player.id)
    local targets = table.map(table.filter(room:getOtherPlayers(target), function(p)
      return target:inMyAttackRange(p) end), Util.IdMapper)
    if #targets > 0 then
      local tos = room:askForChoosePlayers(target, targets, 1, n, "#xianzhou-choose:"..player.id.."::"..n, self.name, true)
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
  ["#caifuren"] = "襄江的蒲苇",
  ["designer:caifuren"] = "Dream彼端",
  ["illustrator:caifuren"] = "B_LEE",
  ["qieting"] = "窃听",
  [":qieting"] = "一名其他角色的回合结束时，若其未于此回合内使用过指定另一名角色为目标的牌，你可以选择一项："..
  "将其装备区里的一张牌移动至你装备区里的相应位置；或摸一张牌。",
  ["xianzhou"] = "献州",
  [":xianzhou"] = "限定技，出牌阶段，你可以将装备区里的所有牌交给一名其他角色，然后该角色选择一项：1.令你回复X点体力；"..
  "2.对其攻击范围内的至多X名角色各造成1点伤害（X为你以此法交给该角色的牌的数量）。",
  ["qieting_move"] = "将其一张装备移动给你",
  ["#xianzhou-choose"] = "献州：对你攻击范围内的至多%arg名角色各造成1点伤害，或点“取消”令 %src 回复体力",

  ["$qieting1"] = "此人不露锋芒，断不可留！",
  ["$qieting2"] = "想欺我蔡氏，痴心妄想！",
  ["$xianzhou1"] = "献荆襄九郡，图一世之安。",
  ["$xianzhou2"] = "丞相携天威而至，吾等安敢不降。",
  ["~caifuren"] = "孤儿寡母，何必赶尽杀绝呢……",
}

local jvshou = General(extension, "jvshou", "qun", 3)
local jianying = fk.CreateTriggerSkill{
  name = "jianying",
  anim_type = "drawcard",
  events = {fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.extra_data and data.extra_data.jianyingCheck
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,

  refresh_events = {fk.CardUsing},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self, true) and player.phase == Player.Play
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if data.card.suit == Card.NoSuit then
      room:setPlayerMark(player, "@jianying-phase", 0)
    else
      local mark = player:getTableMark("@jianying-phase")
      if data.card:getSuitString(true) == mark[1] or data.card.number == mark[2] then
        data.extra_data = data.extra_data or {}
        data.extra_data.jianyingCheck = true
      end
      room:setPlayerMark(player, "@jianying-phase", {data.card:getSuitString(true), data.card.number})
    end
  end,

  on_lose = function (self, player)
    if player:getMark("@jianying-phase") ~= 0 then
      player.room:setPlayerMark(player, "@jianying-phase", 0)
    end
  end,
}
local shibei = fk.CreateTriggerSkill{
  name = "shibei",
  mute = true,
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  events = {fk.Damaged},
  on_use = function(self, event, target, player, data)
    local room = player.room
    if data.isVirtualDMG then return end -- 虚拟伤害别管了
    local firstDamage = room.logic:getActualDamageEvents(1, function(e) return e.data[1].to == player end)[1]
    if firstDamage and firstDamage.data[1] == data then
      player:broadcastSkillInvoke(self.name, 1)
      room:notifySkillInvoked(player, self.name)
      if player:isWounded() then
        room:recover{
          who = player,
          num = 1,
          skillName = self.name
        }
      end
    else
      player:broadcastSkillInvoke(self.name, 2)
      room:notifySkillInvoked(player, self.name, "negative")
      room:loseHp(player, 1, self.name)
    end
  end,
}
jvshou:addSkill(jianying)
jvshou:addSkill(shibei)
Fk:loadTranslationTable{
  ["jvshou"] = "沮授",
  ["#jvshou"] = "监军谋国",
  ["designer:jvshou"] = "精精神神",
  ["illustrator:jvshou"] = "酱油之神",
  ["jianying"] = "渐营",
  [":jianying"] = "每当你于出牌阶段内使用的牌与此阶段你使用的上一张牌点数或花色相同时，你可以摸一张牌。",
  ["shibei"] = "矢北",
  [":shibei"] = "锁定技，每当你受到伤害后，若此伤害是你本回合第一次受到的伤害，你回复1点体力；否则你失去1点体力。",
  ["@jianying-phase"] = "渐营",

  ["$jianying1"] = "由缓至急，循循而进。",
  ["$jianying2"] = "事需缓图，欲速不达也。",
  ["$shibei1"] = "矢志于北，尽忠于国！",
  ["$shibei2"] = "命系袁氏，一心向北。",
  ["~jvshou"] = "智士凋亡，河北哀矣……",
}

return extension

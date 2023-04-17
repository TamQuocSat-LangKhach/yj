local extension = Package("yjcm2013")
extension.extensionName = "yj"

Fk:loadTranslationTable{
  ["yjcm2013"] = "一将成名2013",
}

local caochong = General(extension, "caochong", "wei", 3)
local chengxiang = fk.CreateTriggerSkill{
  name = "chengxiang",
  anim_type = "masochism",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and target:hasSkill(self.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card_ids = room:getNCards(4)
    local get, throw = {}, {}
    room:moveCards({
      ids = card_ids,
      toArea = Card.Processing,
      moveReason = fk.ReasonPut,
    })
    table.forEach(room.players, function(p)
      room:fillAG(p, card_ids)
    end)
    while true do
      local sum = 0
      table.forEach(get, function(id)
        sum = sum + Fk:getCardById(id).number
      end)
      for i = #card_ids, 1, -1 do
        local id = card_ids[i]
        if sum + Fk:getCardById(id).number > 13 then
            room:takeAG(player, id, room.players)
            table.insert(throw, id)
            table.removeOne(card_ids, id)
        end
      end
      if #card_ids == 0 then break end
      local card_id = room:askForAG(player, card_ids, false, self.name)
      --if card_id == nil then break end
      room:takeAG(player, card_id, room.players)
      table.insert(get, card_id)
      table.removeOne(card_ids, card_id)
      if #card_ids == 0 then break end
    end
    table.forEach(room.players, function(p)
      room:closeAG(p)
    end)
    if #get > 0 then
      local dummy = Fk:cloneCard("dilu")
      dummy:addSubcards(get)
      room:obtainCard(player.id, dummy, true, fk.ReasonPrey)
    end
    if #throw > 0 then
      room:moveCards({
        ids = throw,
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonPutIntoDiscardPile,
      })
    end
  end
}
local renxin = fk.CreateTriggerSkill{
  name = "renxin",
  anim_type = "support",
  events = {fk.DamageInflicted},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and target ~= player and target.hp == 1 and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForCard(player, 1, 1, true, self.name, true, ".|.|.|.|.|equip")
    if #card > 0 then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:throwCard(self.cost_data, self.name, player, player)
    player:turnOver()
    return true
  end,
}
caochong:addSkill(chengxiang)
caochong:addSkill(renxin)
Fk:loadTranslationTable{
  ["caochong"] = "曹冲",
  ["chengxiang"] = "称象",
  [":chengxiang"] = "每当你受到一次伤害后，你可以亮出牌堆顶的四张牌，然后获得其中任意数量点数之和小于或等于13的牌，将其余的牌置入弃牌堆。",
  ["renxin"] = "仁心",
  [":renxin"] = "每当体力值为1的一名其他角色受到伤害时，你可以将武将牌翻面并弃置一张装备牌，然后防止此伤害。",
}

local guohuai = General(extension, "guohuai", "wei", 4)
local jingce = fk.CreateTriggerSkill{
  name = "jingce",
  anim_type = "drawcard",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Play and player:getMark("@jingce-turn") >= player.hp
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(2)
  end,

  refresh_events = {fk.CardUsing},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase < Player.Discard
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@jingce-turn", 1)
  end,
}
guohuai:addSkill(jingce)
Fk:loadTranslationTable{
  ["guohuai"] = "郭淮",
  ["jingce"] = "精策",
  [":jingce"] = "出牌阶段结束时，若你本回合已使用的牌数大于或等于你的体力值，你可以摸两张牌。",
  ["@jingce-turn"] = "精策",
}

local manchong = General(extension, "manchong", "wei", 3)
local junxing = fk.CreateActiveSkill{
  name = "junxing",
  anim_type = "control",
  min_card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) == 0 and not player:isKongcheng()
  end,
  card_filter = function(self, to_select, selected)
    return Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:throwCard(effect.cards, self.name, player)
    local types = {"basic", "trick", "equip"}
    for _, id in ipairs(effect.cards) do
      table.removeOne(types, Fk:getCardById(id):getTypeString())
    end
    local card = room:askForCard(target, 1, 1, false, self.name, true, ".|.|.|hand|.|"..table.concat(types, ","))
    if #card > 0 then
      room:throwCard(card, self.name, target)
    else
      target:turnOver()
      target:drawCards(#effect.cards)
    end
  end
}
local yuce = fk.CreateTriggerSkill{
  name = "yuce",
  anim_type = "defensive",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForCard(player, 1, 1, false, self.name, true)
    if #card > 0 then
      self.cost_data = card[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local c = self.cost_data
    player:showCards({c})
    if data.from == nil or data.from.dead or data.from:isKongcheng() then
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name
      }
    else
      local types = {"basic", "trick", "equip"}
      table.removeOne(types, Fk:getCardById(c):getTypeString())
      local card = room:askForCard(data.from, 1, 1, false, self.name, true, ".|.|.|hand|.|"..table.concat(types, ","))
      if #card > 0 then
        room:throwCard(card, self.name, data.from)
      else
        room:recover{
          who = player,
          num = 1,
          recoverBy = player,
          skillName = self.name
        }
      end
    end
  end,
}
manchong:addSkill(junxing)
manchong:addSkill(yuce)
Fk:loadTranslationTable{
  ["manchong"] = "满宠",
  ["junxing"] = "峻刑",
  [":junxing"] = "出牌阶段，你可以弃置至少一张手牌，令一名其他角色弃置一张与你所弃置的牌类别均不同的手牌，若其不如此做，该角色将武将牌翻面并摸等同于你弃牌数的牌，每阶段限一次。",
  ["yuce"] = "御策",
  [":yuce"] = "每当你受到一次伤害后，你可以展示一张手牌，令伤害来源弃置一张类别不同的手牌，否则，你回复1点体力。",
}

local guanping = General(extension, "guanping", "shu", 4)
local longyin = fk.CreateTriggerSkill{
  name = "longyin",
  anim_type = "support",
  events = {fk.AfterCardUseDeclared},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and not player:isNude() and target.phase == Player.Play and data.card.trueName == "slash"
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForCard(player, 1, 1, true, self.name, true, ".")
    if #card > 0 then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(self.cost_data, self.name, player, player)
    target:addCardUseHistory(data.card.trueName, -1)
    if data.card.color == Card.Red then
      player:drawCards(1)
    end
  end,
}
guanping:addSkill(longyin)
Fk:loadTranslationTable{
  ["guanping"] = "关平",
  ["longyin"] = "龙吟",
  [":longyin"] = "每当一名角色在其出牌阶段使用【杀】时，你可以弃置一张牌令此【杀】不计入出牌阶段使用次数，若此【杀】为红色，你摸一张牌。",
}

--local jianyong = General(extension, "jianyong", "shu", 3)
Fk:loadTranslationTable{
  ["jianyong"] = "简雍",
  ["qiaoshui"] = "巧说",
  [":qiaoshui"] = "出牌阶段开始时，你可以与一名其他角色拼点，若你赢，你使用的下一张基本牌或非延时类锦囊牌可以额外指定任意一名其他角色为目标或减少指定一个目标；若你没赢，你不能使用锦囊牌直到回合结束。",
  ["zongshij"] = "纵适",
  [":zongshij"] = "每当你拼点赢，你可以对方此次拼点的牌；每当你拼点没赢，你可以收回你此次拼点的牌。",
}

--local liufeng = General(extension, "liufeng", "shu", 4)
local xiansi = fk.CreateTriggerSkill{
  name = "xiansi",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self.name) and player.phase == Player.Start then
      for _, p in ipairs(player.room:getOtherPlayers(player)) do
        if not p:isNude() then
          return true
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if not p:isNude() then
        table.insert(targets, p.id)
      end
    end

    local tos = room:askForChoosePlayers(player, targets, 1, 2, "#xiansi-choose", self.name, true)
    if #tos > 0 then
      self.cost_data = tos
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, id in ipairs(self.cost_data) do
      local c = room:askForCardChosen(player, room:getPlayerById(id), "he", self.name)
      player:addToPile("ni", c, true, self.name)
    end
  end,
}
--liufeng:addSkill(xiansi)
Fk:loadTranslationTable{
  ["liufeng"] = "刘封",
  ["xiansi"] = "陷嗣",
  [":xiansi"] = "回合开始阶段开始时，你可以将至多两名其他角色的各一张牌置于你的武将牌上，称为“逆”。每当其他角色需要对你使用一张【杀】时，该角色可以弃置你武将牌上的两张“逆”，视为对你使用一张【杀】。",
  ["#xiansi-choose"] = "陷嗣：你可以将至多两名其他角色的各一张牌置于你的武将牌上",
  ["ni"] = "逆",
}

local panzhangmazhong = General(extension, "panzhangmazhong", "wu", 4)
local duodao = fk.CreateTriggerSkill{
  name = "duodao",
  anim_type = "masochism",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and not player:isNude() and data.card ~= nil and data.card.trueName == "slash"
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForCard(player, 1, 1, true, self.name, true, ".")
    if #card > 0 then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(self.cost_data, self.name, player, player)
    if data.from == nil or data.from.dead then return end
    local weapon = data.from:getEquipment(Card.SubtypeWeapon)
    if weapon ~= nil then
      room:obtainCard(player.id, weapon, true, fk.ReasonPrey)
    end
  end
}
local anjian = fk.CreateTriggerSkill{
  name = "anjian",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.card.trueName == "slash" and not data.chain and not data.to:inMyAttackRange(player)
  end,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + 1
  end,
}
panzhangmazhong:addSkill(duodao)
panzhangmazhong:addSkill(anjian)
Fk:loadTranslationTable{
  ["panzhangmazhong"] = "潘璋马忠",
  ["duodao"] = "夺刀",
  [":duodao"] = "每当你受到【杀】造成的一次伤害后，你可以弃置一张牌，然后获得伤害来源装备区里的武器牌。",
  ["anjian"] = "暗箭",
  [":anjian"] = "锁定技，当你使用的【杀】对目标角色造成伤害时，若你不在其攻击范围内，则此【杀】伤害+1。",
}

local yufan = General(extension, "yufan", "wu", 3)
local zongxuan = fk.CreateTriggerSkill{
  name = "zongxuan",
  anim_type = "control",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) then
      for _, move in ipairs(data) do
        return move.from == player.id and move.toArea == Card.DiscardPile and move.moveReason == fk.ReasonDiscard
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = {}
    for _, move in ipairs(data) do
      if move.from == player.id and move.toArea == Card.DiscardPile and move.moveReason == fk.ReasonDiscard then  --ATTENTION: recast iron_chain may trigger this!
        for _, info in ipairs(move.moveInfo) do
          table.insertIfNeed(cards, info.cardId)
        end
      end
    end
    while #cards > 0 do
      room:fillAG(player, cards)
      local id = room:askForAG(player, cards, true, self.name)  --TODO: temporarily use AG. AG function need cancelable!
      if id ~= nil then
        table.removeOne(cards, id)
        table.insert(room.draw_pile, 1, id)
        room:closeAG(player)
      else
        room:closeAG(player)
        break
      end
    end
  end,
}
local zhiyan = fk.CreateTriggerSkill{
  name = "zhiyan",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Finish
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askForChoosePlayers(player, table.map(player.room:getAlivePlayers(), function(p) return p.id end), 1, 1, "#zhiyan-choose", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    local card = Fk:getCardById(to:drawCards(1)[1])
    to:showCards(card)
    if card.type == Card.TypeEquip then
      room:useCard({
        from = to.id,
        tos = {{to.id}},
        card = card,
      })
      if to:isWounded() then
        room:recover({
          who = to,
          num = 1,
          recoverBy = player,
          skillName = self.name
        })
      end
    end
  end,
}
yufan:addSkill(zongxuan)
yufan:addSkill(zhiyan)
Fk:loadTranslationTable{
  ["yufan"] = "虞翻",
  ["zongxuan"] = "纵玄",
  [":zongxuan"] = "每当你的牌因弃置进入弃牌堆前，你可以将此牌置于牌堆顶。",
  ["zhiyan"] = "直言",
  [":zhiyan"] = "回合结束阶段开始时，你可以令一名角色摸一张牌并展示之，若此牌为装备牌，该角色回复1点体力并使用此牌。",
  ["#zhiyan-choose"] = "直言：你可以令一名角色摸一张牌并展示之",
}

--local nos__zhuran = General(extension, "zhuran", "wu", 4)
local nos__danshou = fk.CreateTriggerSkill{
  name = "nos__danshou",
  anim_type = "offensive",
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1)
    room.current:changePhase(room.current.phase, Player.NotActive)
    room.logic:breakEvent(false)
  end
}
--nos__zhuran:addSkill(nos__danshou)
Fk:loadTranslationTable{
  ["nos__zhuran"] = "朱然",
  ["nos__danshou"] = "胆守",
  [":nos__danshou"] = "每当你造成一次伤害后，你可以摸一张牌，若如此做，终止一切结算，当前回合结束。",
}

--local fuhuanghou = General(extension, "fuhuanghou", "qun", 3, 3, General.Female)
local zhuikong = fk.CreateTriggerSkill{
  name = "zhuikong",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if target ~= player and player:hasSkill(self.name) and target.phase == Player.Start then
      return player:isWounded() and not player:isKongcheng() and not target:isKongcheng()
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local pindian = player:pindian({room.current}, self.name)  --can't use 'target' here!
    
  end
}
local qiuyuan = fk.CreateTriggerSkill{
  name = "qiuyuan",
  anim_type = "defensive",
  events = {fk.TargetConfirming},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.card.trueName == "slash"
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    for _, p in ipairs(room:getAlivePlayers()) do
      if p.id ~= data.from then
        table.insert(targets, p.id)
      end
    end
    local to = room:askForChoosePlayers(player, targets, 1, 1, "#qiuyuan-choose", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = self.cost_data
    room:doIndicate(player.id, {to})
    local card = room:askForCard(room:getPlayerById(to), 1, 1, false, self.name, true, "jink")
    if #card > 0 then
      room:obtainCard(player, Fk:getCardById(card[1]), true, fk.ReasonGive)
    else
      TargetGroup:pushTargets(data.targetGroup, to)
    end
  end,
}
--fuhuanghou:addSkill(zhuikong)
--fuhuanghou:addSkill(qiuyuan)
Fk:loadTranslationTable{
  ["fuhuanghou"] = "伏皇后",
  ["zhuikong"] = "惴恐",
  [":zhuikong"] = "一名角色的回合开始时，若你已受伤，你可以与该角色拼点，若你赢，该角色本回合使用的牌不能指定除该角色以外的角色为目标；若你没赢，该角色与你的距离视为1直到回合结束。",
  ["qiuyuan"] = "求援",
  [":qiuyuan"] = "当你成为【杀】的目标时，你可以令另一名其他角色选择一项：交给你一张【闪】，或成为此【杀】的额外目标。",
  ["#qiuyuan-choose"] = "求援：令另一名其他角色交给你一张【闪】，或其成为此【杀】的额外目标",
}

local liru = General(extension, "liru", "qun", 3)
local juece = fk.CreateTriggerSkill{
  name = "juece",
  anim_type = "offensive",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    local room = player.room
    if player:hasSkill(self.name) and player.phase ~= Player.NotActive then
      for _, move in ipairs(data) do
        if move.from then
          local p = room:getPlayerById(move.from)
          if p:isKongcheng() and not p.dead then
            for _, info in ipairs(move.moveInfo) do
              if info.fromArea == Card.PlayerHand then
                self.juece_to = {p}
                return true
              end
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:damage{
      from = player,
      to = self.juece_to[1],
      damage = 1,
      skillName = self.name,
    }
  end,
}
local mieji = fk.CreateTriggerSkill{
  name = "mieji",
  anim_type = "offensive",
  events = {fk.TargetSpecifying},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and
      data.card.color == Card.Black and data.card.type == Card.TypeTrick and data.card.sub_type ~= Card.SubtypeDelayedTrick and
      data.targetGroup and #data.targetGroup == 1
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if not table.contains(AimGroup:getAllTargets(data.tos), p.id) then  --TODO: target filter
        table.insertIfNeed(targets, p.id)
      end
    end
    local to = room:askForChoosePlayers(player, targets, 1, 1, "#mieji-cost", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    if data.card.name == "collateral" then  --TODO:

    else
      TargetGroup:pushTargets(data.targetGroup, self.cost_data)  --TODO: sort by action order
    end
  end,
}
local fencheng = fk.CreateActiveSkill{
  name = "fencheng",
  anim_type = "offensive",
  card_num = 0,
  target_num = 0,
  frequency = Skill.Limited,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local targets = room:getOtherPlayers(player)
    for _, target in ipairs(targets) do
      local length = math.max(1, #target.player_cards[Player.Equip])
      local cards = room:askForDiscard(target, length, length, true, self.name, true)
      if #cards == 0 then
        room:damage{
          from = player,
          to = target,
          damage = 1,
          damageType = fk.FireDamage,
          skillName = self.name,
        }
      end
    end
  end
}
liru:addSkill(juece)
liru:addSkill(mieji)
liru:addSkill(fencheng)
Fk:loadTranslationTable{
  ["liru"] = "李儒",
  ["juece"] = "绝策",
  [":juece"] = "在你的回合内，一名角色失去最后的手牌时，你可以对其造成1点伤害。",
  ["mieji"] = "灭计",
  [":mieji"] = "你使用黑色非延时类锦囊仅指定一个目标时，可以额外指定一个目标。",
  ["fencheng"] = "焚城",
  [":fencheng"] = "限定技，出牌阶段，你可令所有其他角色依次选择一项：弃置X张牌，或受到1点火焰伤害。（X为该角色装备区里牌的数量且至少为1）",
  ["#mieji-cost"] = "灭计：你可以额外指定一个目标",
}

return extension

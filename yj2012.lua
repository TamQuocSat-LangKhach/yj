local extension = Package("yjcm2012")
extension.extensionName = "yj"

Fk:loadTranslationTable{
  ["yjcm2012"] = "一将成名2012",
}

local normal_tricks = {
  "dismantlement", "snatch", "duel", "collateral",
  "ex_nihilo", "savage_assault", "archery_attack", "god_salvation",
  "amazing_grace", "iron_chain", "fire_attack",
}
local xunyou = General(extension, "xunyou", "wei", 3)
local qice = fk.CreateViewAsSkill{
  name = "qice",
  interaction = UI.ComboBox {choices = normal_tricks},
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = function()
    return false
  end,
  view_as = function(self, cards)
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcards(Self:getCardIds(Player.Hand))
    card.skillName = self.name
    return card
  end,
}
local zhiyu = fk.CreateTriggerSkill{
  name = "zhiyu",
  anim_type = "masochism",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1)
    local cards = player.player_cards[Player.Hand]
    player:showCards(cards)
    if data.from and not data.from.dead and not data.from:isKongcheng() then
      for _, id in ipairs(cards) do
        if Fk:getCardById(id).color ~= Fk:getCardById(cards[1]).color then
          return
        end
      end
      room:askForDiscard(data.from, 1, 1, false, self.name, false)
    end
  end,
}
xunyou:addSkill(qice)
xunyou:addSkill(zhiyu)
Fk:loadTranslationTable{
  ["xunyou"] = "荀攸",
  ["qice"] = "奇策",
  [":qice"] = "出牌阶段，你可以将所有的手牌（至少一张）当做任意一张非延时类锦囊牌使用。每阶段限一次。",
  ["zhiyu"] = "智愚",
  [":zhiyu"] = "每当你受到一次伤害后，你可以摸一张牌，然后展示所有手牌，若颜色均相同，伤害来源弃置一张手牌。",
}

local caozhang = General(extension, "caozhang", "wei", 4)
local jiangchi = fk.CreateTriggerSkill{
  name = "jiangchi",
  anim_type = "drawcard",
  events = {fk.DrawNCards},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
  end,
  on_use = function(self, event, target, player, data)
    local choices = {"jiangchi+1"}
    if data.n > 0 then
      table.insert(choices, "jiangchi-1")
    end
    local choice = player.room:askForChoice(player, choices, self.name)
    if choice == "jiangchi+1" then
      data.n = data.n + 1
    else
      data.n = data.n - 1
    end
    player.room:addPlayerMark(player, choice.."-turn", 1)
  end,
}
local jiangchi_targetmod = fk.CreateTargetModSkill{
  name = "#jiangchi_targetmod",
  residue_func = function(self, player, skill, scope)
    if skill.trueName == "slash_skill" and player:getMark("jiangchi-1-turn") > 0 and scope == Player.HistoryPhase then
      return 1
    end
  end,
  distance_limit_func =  function(self, player, skill)
    if skill.trueName == "slash_skill" and player:getMark("jiangchi-1-turn") > 0 then
      return 999
    end
  end,
}
local jiangchi_prohibit = fk.CreateProhibitSkill{
  name = "#jiangchi_prohibit",
  is_prohibited = function()
  end,
  prohibit_use = function(self, player, card)
    return player:getMark("jiangchi+1-turn") > 0 and card.trueName == "slash"
  end,
  prohibit_response = function(self, player, card)
    return player:getMark("jiangchi+1-turn") > 0 and card.trueName == "slash"
  end,
}
jiangchi:addRelatedSkill(jiangchi_targetmod)
jiangchi:addRelatedSkill(jiangchi_prohibit)
caozhang:addSkill(jiangchi)
Fk:loadTranslationTable{
  ["caozhang"] = "曹彰",
  ["jiangchi"] = "将驰",
  [":jiangchi"] = "摸牌阶段摸牌时，你可以选择一项：1.额外摸一张牌，若如此做，你不能使用或打出【杀】，直到回合结束。2.少摸一张牌，若如此做，出牌阶段你使用【杀】无距离限制，且你可以额外使用一张【杀】，直到回合结束。",
  ["jiangchi+1"] = "多摸一张牌，本回合不能使用或打出【杀】",
  ["jiangchi-1"] = "少摸一张牌，本阶段使用【杀】无距离限制且次数+1",
}

local nos__wangyi = General(extension, "nos__wangyi", "wei", 3, 3, General.Female)
local nos__zhenlie = fk.CreateTriggerSkill{
  name = "nos__zhenlie",
  anim_type = "control",
  events = {fk.AskForRetrial},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local move1 = {}
    move1.ids = room:getNCards(1)
    move1.toArea = Card.Processing
    move1.moveReason = fk.ReasonJustMove
    move1.skillName = self.name
    local move2 = {}
    move2.ids = {data.card:getEffectiveId()}
    move2.toArea = Card.DiscardPile
    move2.moveReason = fk.ReasonJustMove
    move2.skillName = self.name
    room:moveCards(move1, move2)
    data.card = Fk:getCardById(move1.ids[1])
    room:sendLog{
      type = "#ChangedJudge",
      from = player.id,
      to = {player.id},
      card = {move1.ids[1]},
      arg = self.name
    }
  end,
}
local nos__miji = fk.CreateTriggerSkill{
  name = "nos__miji",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player:isWounded() and (player.phase == Player.Start or player.phase == Player.Finish)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judge = {
      who = player,
      reason = self.name,
      pattern = ".|.|spade,club",
    }
    room:judge(judge)
    if judge.card.color == Card.Black then
      local cards = room:getNCards(player.maxHp - player.hp)
      room:fillAG(player, cards)
      local tos = room:askForChoosePlayers(player, table.map(room:getAlivePlayers(), function(p) return p.id end), 1, 1, "#nos__miji-choose", self.name)
      local to
      if #tos > 0 then
        to = tos[1]
      else
        to = player.id
      end
      room:moveCards({
        ids = cards,
        to = to,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonJustMove,
      })
      room:closeAG(player)
    end
  end,
}
nos__wangyi:addSkill(nos__zhenlie)
nos__wangyi:addSkill(nos__miji)
Fk:loadTranslationTable{
  ["nos__wangyi"] = "王异",
  ["nos__zhenlie"] = "贞烈",
  [":nos__zhenlie"] = "当你的判定牌生效前，你可以亮出牌堆顶的一张牌代替之。",
  ["nos__miji"] = "秘计",
  [":nos__miji"] = "回合开始阶段或回合结束阶段开始时，若你已受伤，你可以进行一次判定，若判定结果为黑色，你观看牌堆顶的X张牌（X为你已损失的体力值），然后将这些牌交给一名角色。",
  ["#nos__miji-choose"] = "秘计：选择一名角色获得“秘计”牌",
}

local wangyi = General(extension, "wangyi", "wei", 3, 3, General.Female)
local zhenlie = fk.CreateTriggerSkill{
  name = "zhenlie",
  anim_type = "defensive",
  events = {fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self.name) and data.from ~= player.id then
      return (data.card.type == Card.TypeTrick and data.card.sub_type ~= Card.SubtypeDelayedTrick) or data.card.trueName == "slash"
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:loseHp(player, 1, self.name)
    if player.dead then return end
    table.insertIfNeed(data.nullifiedTargets, player.id)
    local to = room:getPlayerById(data.from)
    if to:isNude() then return end
    local id = room:askForCardChosen(player, to, "he", self.name)
    room:throwCard({id}, self.name, to, player)
  end,
}
local miji = fk.CreateTriggerSkill{
  name = "miji",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Finish and player:isWounded()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = player:getLostHp()
    player:drawCards(n, self.name)
    room:setPlayerMark(player, self.name, n)
    room:askForUseActiveSkill(player, "#miji_active", "#miji-invoke", true)
  end,
}
local miji_active = fk.CreateActiveSkill{
  name = "#miji_active",
  anim_type = "support",
  max_card_num = function ()
    return Self:getMark("miji")
  end,
  min_card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return not player:isKongcheng()
  end,
  card_filter = function(self, to_select, selected, targets)
    return Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0
  end,
  on_use = function(self, room, effect)
    local target = room:getPlayerById(effect.tos[1])
    local dummy = Fk:cloneCard("dilu")
    dummy:addSubcards(effect.cards)
    room:obtainCard(target, dummy, false, fk.ReasonGive)
  end,
}
miji:addRelatedSkill(miji_active)
wangyi:addSkill(zhenlie)
wangyi:addSkill(miji)
Fk:loadTranslationTable{
  ["wangyi"] = "王异",
  ["zhenlie"] = "贞烈",
  [":zhenlie"] = "当你成为其他角色使用【杀】或普通锦囊牌的目标后，你可以失去1点体力使此牌对你无效，然后你弃置其一张牌。",
  ["miji"] = "秘计",
  [":miji"] = "结束阶段，你可以摸至多X张牌（X为你已损失的体力值），然后你可以将等量的手牌交给其他角色。",
  ["#miji_active"] = "秘计",
  ["#miji-invoke"] = "秘计：你可以将牌交给一名其他角色",

  ["$zhenlie1"] = "虽是妇人，亦当奋身一搏！",
  ["$zhenlie2"] = "为雪前耻，不惜吾身！",
  ["$miji1"] = "此计，可歼敌精锐！",
  ["$miji2"] = "此举，可破敌之围！",
  ["~wangyi"] = "月儿，不要责怪你爹爹……",
}

local nos__madai = General(extension, "nos__madai", "shu", 4)
local nos__qianxi = fk.CreateTriggerSkill{
  name = "nos__qianxi",
  anim_type = "offensive",
  events = {fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.card.trueName == "slash" and player:distanceTo(data.to) == 1
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judge = {
      who = data.to,
      reason = self.name,
      pattern = ".|.|spade,club,diamond",
    }
    room:judge(judge)
    if self.qianxi_maxhp then
      room:changeMaxHp(data.to, -1)
      return true
    end
  end,

  refresh_events = {fk.FinishJudge},
  can_refresh = function(self, event, target, player, data)
    return data.reason == self.name
  end,
  on_refresh = function(self, event, target, player, data)
    if data.card.suit == Card.Heart then
      self.qianxi_maxhp = false
    else
      self.qianxi_maxhp = true
    end
  end,
}
nos__madai:addSkill("mashu")
nos__madai:addSkill(nos__qianxi)
Fk:loadTranslationTable{
  ["nos__madai"] = "马岱",
  ["nos__qianxi"] = "潜袭",
  [":nos__qianxi"] = "每当你使用【杀】对距离为1的目标角色造成伤害时，你可以进行一次判定，若判定结果不为♥，你防止此伤害，改为令其减1点体力上限。",
}

local madai = General(extension, "madai", "shu", 4)
local qianxi = fk.CreateTriggerSkill{
  name = "qianxi",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judge = {
      who = player,
      reason = self.name,
      pattern = ".",
    }
    room:judge(judge)
    local targets = {}
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if player:distanceTo(p) == 1 then
        table.insert(targets, p.id)
      end
    end
    if #targets == 0 then return end
    local tos = room:askForChoosePlayers(player, targets, 1, 1, "#qianxi-choose", self.name)
    local to
    if #tos > 0 then
      to = tos[1]
    else
      to = targets[math.random(1, #targets)]
    end
    room:setPlayerMark(room:getPlayerById(to), "@qianxi-turn", judge.card:getColorString())
  end,
}
local qianxi_prohibit = fk.CreateProhibitSkill{
  name = "#qianxi_prohibit",
  is_prohibited = function()
  end,
  prohibit_use = function(self, player, card)
    return player:getMark("@qianxi-turn") ~= 0 and card:getColorString() == player:getMark("@qianxi-turn")
  end,
  prohibit_response = function(self, player, card)
    return player:getMark("@qianxi-turn") ~= 0 and card:getColorString() == player:getMark("@qianxi-turn")
  end,
}
qianxi:addRelatedSkill(qianxi_prohibit)
madai:addSkill("mashu")
madai:addSkill(qianxi)
Fk:loadTranslationTable{
  ["madai"] = "马岱",
  ["qianxi"] = "潜袭",
  [":qianxi"] = "准备阶段，你可以进行判定，然后令距离为1的一名角色本回合不能使用或打出与结果颜色相同的手牌。",
  ["#qianxi-choose"] = "潜袭：令一名角色本回合不能使用或打出此颜色的手牌",
  ["@qianxi-turn"] = "潜袭",
}

local liaohua = General(extension, "liaohua", "shu", 4)
local dangxian = fk.CreateTriggerSkill{
  name = "dangxian",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseChanging},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.to == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    data.to = Player.Play
  end,
}
local fuli = fk.CreateTriggerSkill{
  name = "fuli",
  anim_type = "defensive",
  frequency = Skill.Limited,
  events = {fk.AskForPeaches},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.dying and player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local kingdoms = {}
    for _, p in ipairs(room:getAlivePlayers()) do
      table.insertIfNeed(kingdoms, p.kingdom)
    end
    room:recover({
      who = player,
      num = #kingdoms - player.hp,
      recoverBy = player,
      skillName = self.name
    })
    player:turnOver()
  end,
}
liaohua:addSkill(dangxian)
liaohua:addSkill(fuli)
Fk:loadTranslationTable{
  ["liaohua"] = "廖化",
  ["dangxian"] = "当先",
  [":dangxian"] = "锁定技，回合开始时，你执行一个额外的出牌阶段。",
  ["fuli"] = "伏枥",
  [":fuli"] = "限定技，当你处于濒死状态时，你可以将体力值回复至X点（X为现存势力数），然后将你的武将牌翻面。",
}

local nos__guanxingzhangbao = General(extension, "nos__guanxingzhangbao", "shu", 4)
local nos__fuhun = fk.CreateTriggerSkill{
  name = "nos__fuhun",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.Draw
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local move = {
      ids = room:getNCards(2),
      toArea = Card.Processing,
      moveReason = fk.ReasonJustMove,
      skillName = self.name,
    }
    room:moveCards(move)
    room:delay(2000)
    local dummy = Fk:cloneCard("dilu")
    dummy:addSubcards(move.ids)
    room:obtainCard(player.id, dummy, true)
    if Fk:getCardById(move.ids[1]).color ~= Fk:getCardById(move.ids[2]).color then
      room:handleAddLoseSkills(player, "wusheng|paoxiao", nil, true, false)
    end
    return true
  end,

  refresh_events = {fk.EventPhaseStart},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name, true) and player.phase == Player.NotActive
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:handleAddLoseSkills(player, "-wusheng|-paoxiao", nil, true, false)
  end,
}
nos__guanxingzhangbao:addSkill(nos__fuhun)
nos__guanxingzhangbao:addRelatedSkill("wusheng")
nos__guanxingzhangbao:addRelatedSkill("paoxiao")
Fk:loadTranslationTable{
  ["nos__guanxingzhangbao"] = "关兴张苞",
  ["nos__fuhun"] = "父魂",
  [":nos__fuhun"] = "摸牌阶段，你可以放弃摸牌，改为亮出牌堆顶的两张牌并获得之，若亮出的牌颜色不同，你获得技能“武圣”、“咆哮”，直到回合结束。",
}

local guanxingzhangbao = General(extension, "guanxingzhangbao", "shu", 4)
local fuhun = fk.CreateViewAsSkill{
  name = "fuhun",
  pattern = "slash",
  card_filter = function(self, to_select, selected)
    return #selected < 2 and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  view_as = function(self, cards)
    if #cards ~= 2 then return end
    local c = Fk:cloneCard("slash")
    c.skillName = self.name
    c:addSubcards(cards)
    return c
  end,
}
local fuhun_record = fk.CreateTriggerSkill{
  name = "#fuhun_record",
  anim_type = "offensive",

  refresh_events = {fk.Damage, fk.EventPhaseStart},
  can_refresh = function(self, event, target, player, data)
    if target == player and player:hasSkill(self.name) then
      if event == fk.Damage then
        return data.card and table.contains(data.card.skillNames, "fuhun") and player.phase == Player.Play and
          not (player:hasSkill("wusheng", true) and player:hasSkill("wusheng", true))
      else
        return player:hasSkill(self.name, true) and player.phase == Player.NotActive
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    if event == fk.Damage then
      player.room:handleAddLoseSkills(player, "wusheng|paoxiao", nil, true, false)
    else
      player.room:handleAddLoseSkills(player, "-wusheng|-paoxiao", nil, true, false)
    end
  end,
}
fuhun:addRelatedSkill(fuhun_record)
guanxingzhangbao:addSkill(fuhun)
guanxingzhangbao:addRelatedSkill("wusheng")
guanxingzhangbao:addRelatedSkill("paoxiao")
Fk:loadTranslationTable{
  ["guanxingzhangbao"] = "关兴张苞",
  ["fuhun"] = "父魂",
  [":fuhun"] = "你可以将两张手牌当【杀】使用或打出；当你于出牌阶段内以此法造成伤害后，本回合获得〖武圣〗和〖咆哮〗。",
}

local chengpu = General(extension, "chengpu", "wu", 4)
local lihuo = fk.CreateViewAsSkill{
  name = "lihuo",
  anim_type = "offensive",
  pattern = "slash",
  card_filter = function(self, to_select, selected)
    if #selected == 1 then return false end
    return Fk:getCardById(to_select).name == "slash"
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then
      return nil
    end
    local c = Fk:cloneCard("fire__slash")
    c:addSubcard(cards[1])
    c.skillName = self.name
    return c
  end,
}
local lihuo_targetmod = fk.CreateTargetModSkill{
  name = "#lihuo_targetmod",
  extra_target_func = function(self, player, skill)
    if player:hasSkill("lihuo") and skill.name == "fire__slash_skill" then
      return 1
    end
    return 0
  end,
}
local lihuo_record = fk.CreateTriggerSkill{
  name = "#lihuo_record",
  anim_type = "negative",

  refresh_events = {fk.Damage, fk.CardUseFinished},
  can_refresh = function(self, event, target, player, data)
    return target == player and data.card and data.card.skillName == "lihuo"
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.Damage then
      data.card.lihuo = true
    else
      if data.card.lihuo then
        room:loseHp(player, 1, self.name)
      end
    end
  end,
}
local chunlao = fk.CreateTriggerSkill{
  name = "chunlao",
  anim_type = "support",
  expand_pile = "chun",
  events = {fk.EventPhaseStart, fk.AskForPeaches},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) then
      if event == fk.EventPhaseStart then
        return target == player and player.phase == Player.Finish and #player:getPile("chun") == 0 and not player:isKongcheng()
      else
        return target.dying and #player:getPile("chun") > 0
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = {}
    if event == fk.EventPhaseStart then
      cards = room:askForCard(player, 1, #player.player_cards[Player.Hand], false, self.name, true, "slash", "#chunlao-cost")
    else
      cards = room:askForCard(player, 1, 1, false, self.name, true, ".|.|.|chun|.|.", "#chunlao-invoke", "chun")
    end
    if #cards > 0 then
      self.cost_data = cards
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      player:addToPile("chun", self.cost_data, false, self.name)
    else
      room:moveCards({
        from = player.id,
        ids = self.cost_data,
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonPutIntoDiscardPile,
        skillName = self.name,
        specialName = self.name,
      })
      player:removeCards(Player.Special, self.cost_data, "chun")
      local analeptic = Fk:cloneCard("analeptic")
      local extra_data = {analepticRecover = true}
      room:useCard({
        card = analeptic,
        from = target.id,
        tos = {{target.id}},
        extra_data = extra_data,
        skillName = self.name,
      })
    end
  end,
}
lihuo:addRelatedSkill(lihuo_targetmod)
lihuo:addRelatedSkill(lihuo_record)
chengpu:addSkill(lihuo)
chengpu:addSkill(chunlao)
Fk:loadTranslationTable{
  ["chengpu"] = "程普",
  ["lihuo"] = "疬火",
  [":lihuo"] = "你可以将一张普通【杀】当火【杀】使用，若此法使用的【杀】造成了伤害，在此【杀】结算后你失去1点体力；你使用火【杀】时，可以额外选择一个目标。",
  ["chunlao"] = "醇醪",
  [":chunlao"] = "回合结束阶段开始时，若你的武将牌上没有牌，你可以将任意数量的【杀】置于你的武将牌上，称为“醇”；当一名角色处于濒死状态时，你可以将一张“醇”置入弃牌堆，视为该角色使用一张【酒】。",
  ["chun"] = "醇",
  ["#chunlao-cost"] = "醇醪：你可以将任意张【杀】置为“醇”",
  ["#chunlao-invoke"] = "醇醪：你可以将一张“醇”置入弃牌堆，视为该角色使用一张【酒】",
}

local bulianshi = General(extension, "bulianshi", "wu", 3, 3, General.Female)
local anxu = fk.CreateActiveSkill{
  name = "anxu",
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
    if #selected > 1 or to_select == Self.id then return false end
    if #selected == 0 then
      return true
    elseif #selected == 1 then
      local target1 = Fk:currentRoom():getPlayerById(to_select)
      local target2 = Fk:currentRoom():getPlayerById(selected[1])
      return #target1.player_cards[Player.Hand] ~= #target2.player_cards[Player.Hand]
    else
      return false
    end
  end,
  on_use = function(self, room, use)
    local target1 = room:getPlayerById(use.tos[1])
    local target2 = room:getPlayerById(use.tos[2])
    local from, to
    if #target1.player_cards[Player.Hand] < #target2.player_cards[Player.Hand] then
      from = target1
      to = target2
    else
      from = target2
      to = target1
    end
    local card = room:askForCardChosen(from, to, "h", self.name)
    room:obtainCard(from.id, card, true)
    if Fk:getCardById(card).suit ~= Card.Spade then
      room:getPlayerById(use.from):drawCards(1)
    end
  end,
}
local zhuiyi = fk.CreateTriggerSkill{
  name = "zhuiyi",
  anim_type = "support",
  events = {fk.Death},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name, false, true)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    for _, p in ipairs(room:getOtherPlayers(player)) do
      table.insert(targets, p.id)
    end
    if data.damage then
      table.removeOne(targets, data.damage.from.id)
    end
    local p = room:askForChoosePlayers(player, targets, 1, 1, "#zhuiyi-target", self.name, true)
    if #p > 0 then
      self.cost_data = p[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    to:drawCards(3)
    if to:isWounded() then
      room:recover{
        who = to,
        num = 1,
        recoverBy = player,
        skillName = self.name
      }
    end
  end,
}
bulianshi:addSkill(anxu)
bulianshi:addSkill(zhuiyi)
Fk:loadTranslationTable{
  ["bulianshi"] = "步练师",
  ["anxu"] = "安恤",
  [":anxu"] = "出牌阶段，你可以选择两名手牌数不相等的其他角色，令其中手牌少的角色获得手牌多的角色一张手牌并展示之，若此牌不为♠，你摸一张牌。每阶段限一次。",
  ["zhuiyi"] = "追忆",
  [":zhuiyi"] = "你死亡时，可以令一名其他角色（杀死你的角色除外）摸三张牌并回复1点体力。",
  ["#zhuiyi-target"] = "追忆：你死亡时，可以令一名其他角色（凶手除外）摸三张牌并回复1点体力",
}

--local nos_handang = General(extension, "nos_handang", "wu", 4)
local nos_gongqi = fk.CreateViewAsSkill{
  name = "nos_gongqi",
  anim_type = "offensive",
  pattern = "slash",
  card_filter = function(self, to_select, selected)
    if #selected == 1 then return false end
    return Fk:getCardById(to_select).type == Card.TypeEquip
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then return nil end
    local card = Fk:cloneCard("slash")
    card:addSubcard(cards[1])
    card.skillName = self.name
    return card
  end,
}
local gongqi_targetmod = fk.CreateTargetModSkill{
  name = "#gongqi_targetmod",
  distance_limit_func =  function(self, player, skill, card)
    if card ~= nil and table.contains(card.skillNames, "gongqi") then
      return 999
    end
  end,
}
nos_gongqi:addRelatedSkill(gongqi_targetmod)
--handang:addSkill(nos_gongqi)
Fk:loadTranslationTable{
  ["nos_handang"] = "韩当",
  ["nos_gongqi"] = "弓骑",
  [":nos_gongqi"] = "你可以将一张装备牌当【杀】使用或打出；你以此法使用的【杀】无距离限制。",
  ["nos_jiefan"] = "解烦",
  [":nos_jiefan"] = "你的回合外，当一名角色处于濒死状态时，你可以对当前回合角色使用一张【杀】，此【杀】造成伤害时，你防止此伤害，视为对该濒死角色使用了一张【桃】。",
}

local handang = General(extension, "handang", "wu", 4)
local gongqi = fk.CreateActiveSkill{
  name = "gongqi",
  anim_type = "offensive",
  card_num = 1,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) == 0 and not player:isNude()
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  target_filter = function(self, to_select, selected)
    return false
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, self.name, player, player)
    room:addPlayerMark(player, "gongqi-turn", 999)
    if Fk:getCardById(effect.cards[1]).type == Card.TypeEquip then
      local to = room:askForChoosePlayers(player, table.map(table.filter(room:getOtherPlayers(player), function(p)
        return not p:isNude() end), function(p) return p.id end), 1, 1, "#gongqi-choose", self.name)
      if #to > 0 then
        local target = room:getPlayerById(to[1])
        local id = room:askForCardChosen(player, target, "he", self.name)
        room:throwCard({id}, self.name, target, player)
      end
    end
  end,
}
local gongqi_attackrange = fk.CreateAttackRangeSkill{
  name = "#gongqi_attackrange",
  correct_func = function (self, from, to)
    return from:getMark("gongqi-turn")  --ATTENTION: this is a status skill, shouldn't do arithmatic on it
  end,
}
local jiefan = fk.CreateActiveSkill{
  name = "jiefan",
  anim_type = "drawcard",
  card_num = 0,
  target_num = 1,
  frequency = Skill.Limited,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  card_filter = function(self, to_select, selected)
    return false
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  on_use = function(self, room, effect)
    local target = room:getPlayerById(effect.tos[1])
    for _, p in ipairs(room:getOtherPlayers(target)) do
      if p:inMyAttackRange(target) then
        if #room:askForDiscard(p, 1, 1, true, self.name, true, ".|.|.|.|.|equip", "#jiefan-discard::"..target.id) == 0 then  --TODO: pattern weapon
          target:drawCards(1, self.name)
        end
      end
    end
  end,
}
gongqi:addRelatedSkill(gongqi_attackrange)
handang:addSkill(gongqi)
handang:addSkill(jiefan)
Fk:loadTranslationTable{
  ["handang"] = "韩当",
  ["gongqi"] = "弓骑",
  [":gongqi"] = "出牌阶段限一次，你可以弃置一张牌使你本回合的攻击范围无限。若弃置的为装备牌，你可以弃置一名其他角色的一张牌。",
  ["jiefan"] = "解烦",
  [":jiefan"] = "限定技，出牌阶段，你可以选择一名角色，然后令攻击范围内含有该角色的所有角色各选择一项：1.弃置一张武器牌；2.令其摸一张牌。",
  ["#gongqi-choose"] = "弓骑：你可以弃置一名其他角色的一张牌",
  ["#jiefan-discard"] = "解烦：弃置一张武器牌，否则 %dest 摸一张牌",
}

local liubiao = General(extension, "liubiao", "qun", 4)
local zishou = fk.CreateTriggerSkill{
  name = "zishou",
  anim_type = "drawcard",
  events = {fk.DrawNCards},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and player.phase == Player.Draw and player:isWounded()
  end,
  on_use = function(self, event, target, player, data)
    data.n = data.n + player:getLostHp()
    player:skip(Player.Play)
  end,
}
local zongshi = fk.CreateMaxCardsSkill{
  name = "zongshi",
  correct_func = function(self, player)
    local kingdoms = {}
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      table.insertIfNeed(kingdoms, p.kingdom)
    end
    if player:hasSkill(self.name) then
      return #kingdoms
    else
      return 0
    end
  end,
}
liubiao:addSkill(zishou)
liubiao:addSkill(zongshi)
Fk:loadTranslationTable{
  ["liubiao"] = "刘表",
  ["zishou"] = "自守",
  [":zishou"] = "摸牌阶段，你可以额外摸X张牌（X为你已损失的体力值），然后跳过你的出牌阶段。",
  ["zongshi"] = "宗室",
  [":zongshi"] = "锁定技，场上每有一种势力，你的手牌上限便+1。",
}

local huaxiong = General(extension, "huaxiong", "qun", 6)
local shiyong = fk.CreateTriggerSkill{
  name = "shiyong",
  anim_type = "negative",
  events = {fk.Damaged},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.card ~= nil and
      data.card.trueName == "slash" and data.card.color == Card.Red  --FIXME: drank damage
  end,
  on_use = function(self, event, target, player, data)
    player.room:changeMaxHp(player, -1)
  end,
}
huaxiong:addSkill(shiyong)
Fk:loadTranslationTable{
  ["huaxiong"] = "华雄",
  ["shiyong"] = "恃勇",
  [":shiyong"] = "锁定技，每当你受到一次红色【杀】或【酒】【杀】造成的伤害后，你减1点体力上限。",
}

local zhonghui = General(extension, "zhonghui", "wei", 4)
local quanji = fk.CreateTriggerSkill{
  name = "quanji",
  anim_type = "masochism",
  events = {fk.Damaged},
  on_trigger = function(self, event, target, player, data)
    self.cancel_cost = false
    for i = 1, data.damage do
      if self.cancel_cost then break end
      self:doCost(event, target, player, data)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askForSkillInvoke(player, self.name, data) then
      return true
    end
    self.cancel_cost = true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1)
    local card = room:askForCard(player, 1, 1, false, self.name, false)
    player:addToPile("quan", card, false, self.name)
  end,
}
local quanji_maxcards = fk.CreateMaxCardsSkill{
  name = "#quanji_maxcards",
  correct_func = function(self, player)
    if player:hasSkill(self.name) then
      return #player:getPile("quan")
    else
      return 0
    end
  end,
}
local zili = fk.CreateTriggerSkill{
  name = "zili",
  frequency = Skill.Wake,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and
     player.phase == Player.Start and
     #player:getPile("quan") > 2
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, -1)
    local choices = {"draw2"}
    if player:isWounded() then
      table.insert(choices, "recover")
    end
    local choice = room:askForChoice(player, choices, self.name)
    if choice == "draw2" then
      player:drawCards(2)
    else
      room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name
      })
    end
    room:handleAddLoseSkills(player, "paiyi", nil)
  end,
}
local paiyi = fk.CreateActiveSkill{
  name = "paiyi",
  anim_type = "control",
  target_num = 1,
  card_num = 1,
  expand_pile = "quan",
  can_use = function(self, player)
    return #player:getPile("quan") > 0 and player:usedSkillTimes(self.name) == 0
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Self:getPileNameOfId(to_select) == "quan"
  end,
  on_use = function(self, room, use)
    local player = room:getPlayerById(use.from)
    local target = room:getPlayerById(use.tos[1])
    room:moveCards({
      from = player.id,
      ids = use.cards,
      toArea = Card.DiscardPile,
      moveReason = fk.ReasonPutIntoDiscardPile,
      skillName = self.name,
    })
    player:removeCards(Player.Special, use.cards, self.name)
    target:drawCards(2)
    if #target.player_cards[Player.Hand] > #player.player_cards[Player.Hand] then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = self.name,
      }
    end
  end,
}
quanji:addRelatedSkill(quanji_maxcards)
zhonghui:addSkill(quanji)
zhonghui:addSkill(zili)
zhonghui:addRelatedSkill(paiyi)
Fk:loadTranslationTable{
  ["zhonghui"] = "钟会",
  ["quanji"] = "权计",
  [":quanji"] = "每当你受到1点伤害后，你可以摸一张牌，然后将一张手牌置于武将牌上，称为“权”；每有一张“权”，你的手牌上限便+1。",
  ["zili"] = "自立",
  [":zili"] = "觉醒技，回合开始阶段开始时，若“权”的数量达到3或更多，你须减1点体力上限，然后回复1点体力或摸两张牌，并获得技能“排异”。",
  ["paiyi"] = "排异",
  [":paiyi"] = "出牌阶段，你可以将一张“权”置入弃牌堆，令一名角色摸两张牌，然后若该角色的手牌数大于你的手牌数，你对其造成1点伤害。每阶段限一次。",
  ["quan"] = "权",
}

return extension

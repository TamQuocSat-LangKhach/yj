local extension = Package("yczh2016")
extension.extensionName = "yj"

Fk:loadTranslationTable{
  ["yczh2016"] = "原创之魂2016",
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
      return not p.chained end), function(p)  return p.id end)
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
    return target == player and player:hasSkill(self.name) and data.damageType == fk.FireDamage and player.chained and not data.chain
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
    return player:hasSkill(self.name) and (event == fk.GameStart or
      (event == fk.Deathed and table.every(player.room:getAlivePlayers(), function(p) return p.kingdom ~= target.kingdom end)))
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.GameStart then
      room:broadcastSkillInvoke(self.name)
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
  ["zhige"] = "止戈",
  [":zhige"] = "出牌阶段限一次，若你的手牌数大于体力值，你可以令一名攻击范围包含你的其他角色选择一项：1.使用一张【杀】；2.将装备区里的一张牌交给你。",
  ["zongzuo"] = "宗祚",
  [":zongzuo"] = "锁定技，游戏开始时，你加X点体力上限和体力（X为全场势力数）；当每个势力的最后一名角色死亡后，你减1点体力上限。",
  ["#zhige-use"] = "止戈：使用一张【杀】，否则将装备区内一张牌交给 %src",
  ["#zhige-card"] = "止戈：将装备区内一张牌交给 %src",

  ["$zhige1"] = "天下和而平乱，神器宁而止戈。",
  ["$zhige2"] = "刀兵纷争既止，国运福祚绵长。",
  ["$zongzuo1"] = "乾坤倒，黎民苦，高祖后，岂任之？",
  ["$zongzuo2"] = "尽死生之力，保大厦不倾。",
  ["~liuyu"] = "怀柔之计，终非良策。",
}

local zhangrang = General(extension, "zhangrang", "qun", 3)
local taoluan = fk.CreateViewAsSkill{
  name = "taoluan",
  pattern = ".",
  interaction = function()
    local names = {}
    local mark = Self:getMark("@$taoluan")
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id)
      if (card.type == Card.TypeBasic or card:isCommonTrick()) and not card.is_derived and
        ((Fk.currentResponsePattern == nil and card.skill:canUse(Self)) or
        (Fk.currentResponsePattern and Exppattern:Parse(Fk.currentResponsePattern):match(card))) then
        if mark == 0 or (not table.contains(mark, card.trueName)) then
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
    return not player:isNude() and player:getMark("taoluan-turn") == 0 and
      table.every(Fk:currentRoom().alive_players, function(p) return not p.dying end)
  end,
  enabled_at_response = function(self, player, response)
    return not response and not player:isNude() and player:getMark("taoluan-turn") == 0 and
      table.every(Fk:currentRoom().alive_players, function(p) return not p.dying end)
  end,
}
local taoluan_trigger = fk.CreateTriggerSkill{
  name = "#taoluan_trigger",
  mute = true,
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    return target == player and table.contains(data.card.skillNames, "taoluan")
  end,
  on_cost = function(self, event, target, player, data)
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(room:getOtherPlayers(player), function(p) return p.id end)
    local type = data.card:getTypeString()
    local to = room:askForChoosePlayers(player, targets, 1, 1, "#taoluan-choose:::"..type, "taoluan", false)
    if #to > 0 then
      to = room:getPlayerById(to[1])
    else
      to = room:getPlayerById(table.random(targets))
    end
    local card = room:askForCard(to, 1, 1, true, "taoluan", true, ".|.|.|.|.|^"..type, "#taoluan-card:"..player.id.."::"..type)
    if #card > 0 then
      room:obtainCard(player, card[1], false, fk.ReasonGive)
    else
      room:loseHp(player, 1, "taoluan")
      room:setPlayerMark(player, "taoluan-turn", 1)
    end
  end,
}
taoluan:addRelatedSkill(taoluan_trigger)
zhangrang:addSkill(taoluan)
Fk:loadTranslationTable{
  ["zhangrang"] = "张让",
  ["taoluan"] = "滔乱",
  [":taoluan"] = "当你需要使用一张基本牌或普通锦囊牌时，若没有角色处于濒死状态，你可以将一张牌当任意一张基本牌或普通锦囊牌使用（每种牌名每局游戏限一次），"..
  "然后你令一名其他角色选择一项：1.交给你一张与你以此法使用的牌类别不同的牌；2.令你失去1点体力，且你本回合〖滔乱〗失效。",
  ["@$taoluan"] = "滔乱",
  ["#taoluan-choose"] = "滔乱：令一名其他角色交给你一张非%arg，或你失去1点体力且本回合〖滔乱〗失效",
  ["#taoluan-card"] = "滔乱：你需交给 %src 一张非%arg，否则其失去1点体力且本回合〖滔乱〗失效",

  ["$taoluan1"] = "睁开你的眼睛看看，现在是谁说了算？",
  ["$taoluan2"] = "国家承平，神器稳固，陛下勿忧。",
  ["~zhangrang"] = "臣等殄灭，唯陛下自爱……（跳水声）",
}

return extension

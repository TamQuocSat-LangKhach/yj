local extension = Package("yczh2016")
extension.extensionName = "yj"

Fk:loadTranslationTable{
  ["yczh2016"] = "原创之魂2016",
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
    local mark = Self:getMark("taoluan")
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id)
      if (card.type == Card.TypeBasic or (card.type == Card.TypeTrick and card.sub_type ~= Card.SubtypeDelayedTrick)) and
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
    if #cards ~= 1 then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcard(cards[1])
    card.skillName = self.name
    return card
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
local taoluan_record = fk.CreateTriggerSkill{
  name = "#taoluan_record",

  refresh_events = {fk.AfterCardUseDeclared, fk.CardUseFinished},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name, true) and table.contains(data.card.skillNames, "taoluan")
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.AfterCardUseDeclared then
      local mark = player:getMark("taoluan")
      if mark == 0 then mark = {} end
      table.insert(mark, data.card.trueName)
      room:setPlayerMark(player, "taoluan", mark)
    else
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
        room:addPlayerMark(player, "taoluan-turn", 1)
      end
    end
  end,
}
taoluan:addRelatedSkill(taoluan_record)
zhangrang:addSkill(taoluan)
Fk:loadTranslationTable{
  ["zhangrang"] = "张让",
  ["taoluan"] = "滔乱",
  [":taoluan"] = "当你需要使用一张基本牌或普通锦囊牌时，若没有角色处于濒死状态，你可以将一张牌当任意一张基本牌或普通锦囊牌使用（每种牌名每局游戏限一次），"..
  "然后你令一名其他角色选择一项：1.交给你一张与你以此法使用的牌类别不同的牌；2.令你失去1点体力，且你本回合〖滔乱〗失效。",
  ["#taoluan-choose"] = "滔乱：令一名其他角色交给你一张非%arg，或你失去1点体力且本回合〖滔乱〗失效",
  ["#taoluan-card"] = "滔乱：你需交给 %src 一张非%arg，否则其失去1点体力且本回合〖滔乱〗失效",

  ["$taoluan1"] = "睁开你的眼睛看看，现在是谁说了算？",
  ["$taoluan2"] = "国家承平，神器稳固，陛下勿忧。",
  ["~zhangrang"] = "臣等殄灭，唯陛下自爱……（跳水声）",
}

return extension

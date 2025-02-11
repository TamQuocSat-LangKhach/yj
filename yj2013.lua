local extension = Package("yjcm2013")
extension.extensionName = "yj"

local U = require "packages/utility/utility"

Fk:loadTranslationTable{
  ["yjcm2013"] = "一将成名2013",
}

local caochong = General(extension, "caochong", "wei", 3)
Fk:addPoxiMethod{
  name = "chengxiang_count",
  card_filter = function(to_select, selected, data)
    if table.contains(data[2], to_select) then return true end
    local n = Fk:getCardById(to_select).number
    for _, id in ipairs(data[2]) do
      n = n + Fk:getCardById(id).number
    end
    return n < 14
  end,
  feasible = function(selected)
    return true
  end,
}
local chengxiang = fk.CreateTriggerSkill{
  name = "chengxiang",
  anim_type = "masochism",
  events = {fk.Damaged},
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:getNCards(4)
    room:moveCards({
      ids = cards,
      toArea = Card.Processing,
      moveReason = fk.ReasonPut,
      proposer = player.id,
      skillName = self.name,
    })
    local get = room:askForArrangeCards(player, self.name, {cards},
    "#chengxiang-choose", false, 0, {4, 4}, {0, 1}, ".", "chengxiang_count", {{}, {cards[1]}})[2]
    room:moveCardTo(get, Player.Hand, player, fk.ReasonJustMove, self.name, "", true, player.id)
    cards = table.filter(cards, function(id) return room:getCardArea(id) == Card.Processing end)
    if #cards > 0 then
      room:moveCards({
        ids = cards,
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
    return player:hasSkill(self) and target ~= player and target.hp == 1 and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForDiscard(player, 1, 1, true, self.name, true, ".|.|.|.|.|equip", "#renxin-invoke::"..target.id, true)
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
  ["#caochong"] = "仁爱的神童",
  ["cv:caochong"] = "水原",
  ["illustrator:caochong"] = "amo",
  ["chengxiang"] = "称象",
  [":chengxiang"] = "每当你受到一次伤害后，你可以亮出牌堆顶的四张牌，然后获得其中任意数量点数之和小于或等于13的牌，将其余的牌置入弃牌堆。",
  ["renxin"] = "仁心",
  [":renxin"] = "每当体力值为1的一名其他角色受到伤害时，你可以弃置一张装备牌，将武将牌翻面并防止此伤害。",
  ["#renxin-invoke"] = "仁心：你可以弃置一张装备牌，防止 %dest 受到的致命伤害",
  ["#chengxiang-choose"] = "称象：获得任意点数之和小于或等于13的牌",

  ["$chengxiang1"] = "依我看，小事一桩。",
  ["$chengxiang2"] = "孰重孰轻，一称便知。",
  ["$renxin1"] = "仁者爱人，人恒爱之。",
  ["$renxin2"] = "有我在，别怕。",
  ["~caochong"] = "子桓哥哥……",
}

local nos__caochong = General(extension, "nos__caochong", "wei", 3)
Fk:addPoxiMethod{
  name = "nos__chengxiang_count",
  card_filter = function(to_select, selected, data)
    if table.contains(data[2], to_select) then return true end
    local n = Fk:getCardById(to_select).number
    for _, id in ipairs(data[2]) do
      n = n + Fk:getCardById(id).number
    end
    return n < 13
  end,
  feasible = function(selected)
    return true
  end,
}
local nos__chengxiang = fk.CreateTriggerSkill{
  name = "nos__chengxiang",
  anim_type = "masochism",
  events = {fk.Damaged},
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:getNCards(4)
    room:moveCards({
      ids = cards,
      toArea = Card.Processing,
      moveReason = fk.ReasonPut,
      proposer = player.id,
      skillName = self.name,
    })
    local get = {}
    for _, id in ipairs(cards) do
      if Fk:getCardById(id, true).number < 13 then
        table.insert(get, id)
        break
      end
    end
    get = room:askForArrangeCards(player, self.name, {cards},
    "#nos__chengxiang-choose", false, 0, {4, 4}, {0, #get}, ".", "nos__chengxiang_count", {{}, get})[2]
    if #get > 0 then
      room:moveCardTo(get, Player.Hand, player, fk.ReasonJustMove, self.name, "", true, player.id)
    end
    cards = table.filter(cards, function(id) return room:getCardArea(id) == Card.Processing end)
    if #cards > 0 then
      room:moveCards({
        ids = cards,
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonPutIntoDiscardPile,
      })
    end
  end
}
local nos__renxin = fk.CreateTriggerSkill{
  name = "nos__renxin",
  anim_type = "support",
  events = {fk.AskForPeaches},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and not player:isKongcheng() and
    player.room:getPlayerById(data.who) and data.who ~= player.id
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#nos__renxin-invoke::"..data.who)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local dying = player.room:getPlayerById(data.who)
    player:turnOver()
    room:obtainCard(dying.id, player:getCardIds(Player.Hand), false, fk.ReasonGive, player.id)
    if not dying.dead and dying:isWounded() then
      room:recover({
        who = dying,
        num = 1,
        recoverBy = player,
        skillName = self.name
      })
    end
  end,
}
nos__caochong:addSkill(nos__chengxiang)
nos__caochong:addSkill(nos__renxin)
Fk:loadTranslationTable{
  ["nos__caochong"] = "曹冲",
  ["#nos__caochong"] = "仁爱的神童",
  ["illustrator:nos__caochong"] = "alien", -- 飞虹云象
  ["nos__chengxiang"] = "称象",
  [":nos__chengxiang"] = "每当你受到一次伤害后，你可以亮出牌堆顶的四张牌，然后获得其中任意数量点数之和小于13的牌。",
  ["nos__renxin"] = "仁心",
  [":nos__renxin"] = "当一名其他角色处于濒死状态时，你可以将武将牌翻面并将所有手牌（至少一张）交给该角色。若如此做，该角色回复1点体力。",
  ["#nos__renxin-invoke"] = "仁心：你可以将所有手牌交给 %dest，令其回复1点体力",
  ["#nos__chengxiang-choose"] = "称象：获得任意点数之和小于13的牌",

  ["$nos__chengxiang1"] = "以船载象，以石易象，称石则可得象斤重。",
  ["$nos__chengxiang2"] = "若以冲所言行事，则此象之重可称也。",
  ["$nos__renxin1"] = "冲愿以此仁心，消弭杀机，保将军周全。",
  ["$nos__renxin2"] = "阁下罪不至死，冲愿施以援手相救。",
  ["~nos__caochong"] = "父亲，冲儿……再不能承欢膝下了。",
}

local guohuai = General(extension, "guohuai", "wei", 4)
local jingce = fk.CreateTriggerSkill{
  name = "jingce",
  anim_type = "drawcard",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Play and #player.room.logic:getEventsOfScope(GameEvent.UseCard, 998, function(e)
      local use = e.data[1]
      return use.from == player.id
    end, Player.HistoryTurn) >= player.hp
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(2, self.name)
  end,
}
guohuai:addSkill(jingce)
Fk:loadTranslationTable{
  ["guohuai"] = "郭淮",
  ["#guohuai"] = "垂问秦雍",
  ["designer:guohuai"] = "五月fy",
  ["illustrator:guohuai"] = "DH",
  ["jingce"] = "精策",
  [":jingce"] = "出牌阶段结束时，若你本回合已使用的牌数大于或等于你的体力值，你可以摸两张牌。",

  ["$jingce1"] = "方策精详，有备无患。",
  ["$jingce2"] = "精兵据敌，策守如山。",
  ["~guohuai"] = "姜维小儿，竟然……",
}

local manchong = General(extension, "manchong", "wei", 3)
local junxing = fk.CreateActiveSkill{
  name = "junxing",
  anim_type = "control",
  min_card_num = 1,
  target_num = 1,
  prompt = "#junxing",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = function(self, to_select, selected)
    return Fk:currentRoom():getCardArea(to_select) ~= Player.Equip and not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:throwCard(effect.cards, self.name, player)
    if target.dead then return end
    local types = {"basic", "trick", "equip"}
    for _, id in ipairs(effect.cards) do
      table.removeOne(types, Fk:getCardById(id):getTypeString())
    end
    if #types == 0 or #room:askForDiscard(target, 1, 1, false, self.name, true, ".|.|.|hand|.|"..table.concat(types, ","), "#junxing-discard") == 0 then
      target:turnOver()
      if not target.dead then
        target:drawCards(#effect.cards, self.name)
      end
    end
  end
}
local yuce = fk.CreateTriggerSkill{
  name = "yuce",
  anim_type = "defensive",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForCard(player, 1, 1, false, self.name, true, ".", "#yuce-invoke")
    if #card > 0 then
      self.cost_data = card[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local c = self.cost_data
    player:showCards({c})
    if player.dead then return end
    if not data.from or data.from.dead or data.from:isKongcheng() then
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name
      }
    else
      local types = {"basic", "trick", "equip"}
      table.removeOne(types, Fk:getCardById(c):getTypeString())
      if #room:askForDiscard(data.from, 1, 1, false, self.name, true, ".|.|.|hand|.|"..table.concat(types, ","),
        "#yuce-discard:"..player.id..":"..Fk:getCardById(c):getTypeString()) == 0 then
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
  ["#manchong"] = "政法兵谋",
  ["designer:manchong"] = "VirgoPaladin",
  ["illustrator:manchong"] = "Aimer彩三",
  ["junxing"] = "峻刑",
  [":junxing"] = "出牌阶段限一次，你可以弃置至少一张手牌，令一名其他角色选择一项：1.弃置一张与你弃置的牌类别均不同的手牌；2.翻面并摸等同于你弃牌数的牌。",
  ["yuce"] = "御策",
  [":yuce"] = "每当你受到一次伤害后，你可以展示一张手牌，令伤害来源弃置一张类别不同的手牌，否则你回复1点体力。",
  ["#junxing"] = "峻刑：弃置任意张手牌，令一名角色选择弃置一张不同类别的手牌或翻面并摸等量牌",
  ["#junxing-discard"] = "峻刑：你需弃置一张不同类别的手牌，否则翻面并摸弃牌数的牌",
  ["#yuce-invoke"] = "御策：你可以展示一张手牌，伤害来源需弃置一张类别不同的手牌，否则你回复1点体力",
  ["#yuce-discard"] = "御策：你需弃置一张非%arg手牌，否则 %src 回复1点体力",

  ["$junxing1"] = "严刑峻法，以破奸诡之胆。",
  ["$junxing2"] = "你招还是不招？",
  ["$yuce1"] = "御敌之策，成竹于胸。",
  ["$yuce2"] = "以缓制急，不战屈兵。",
  ["~manchong"] = "援军为何迟迟未到……",
}

local guanping = General(extension, "guanping", "shu", 4)
local longyin = fk.CreateTriggerSkill{
  name = "longyin",
  anim_type = "support",
  events = {fk.CardUsing},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target.phase == Player.Play and data.card.trueName == "slash" and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForDiscard(player, 1, 1, true, self.name, true, ".", "#longyin-invoke::"..target.id, true)
    if #card > 0 then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:throwCard(self.cost_data, self.name, player, player)
    if not data.extraUse then
      target:addCardUseHistory(data.card.trueName, -1)
      data.extraUse = true
    end
    if data.card.color == Card.Red and not player.dead then
      player:drawCards(1, self.name)
    end
  end,
}
guanping:addSkill(longyin)
Fk:loadTranslationTable{
  ["guanping"] = "关平",
  ["#guanping"] = "忠臣孝子",
  ["designer:guanping"] = "昂翼天使",
  ["illustrator:guanping"] = "樱花闪乱",
  ["longyin"] = "龙吟",
  [":longyin"] = "每当一名角色在其出牌阶段使用【杀】时，你可以弃置一张牌令此【杀】不计入出牌阶段使用次数，若此【杀】为红色，你摸一张牌。",
  ["#longyin-invoke"] = "龙吟：你可以弃置一张牌令 %dest 的【杀】不计入次数限制",

  ["$longyin1"] = "破阵杀敌，愿献犬马之劳！",
  ["$longyin2"] = "虎啸既响，龙吟当附！",
  ["~guanping"] = "父亲快走，孩儿断后……",
}

local jianyong = General(extension, "jianyong", "shu", 3)
local qiaoshui = fk.CreateTriggerSkill{
  name = "qiaoshui",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Play and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
      local targets = table.map(table.filter(room:getOtherPlayers(player), function(p)
        return player:canPindian(p) end), Util.IdMapper)
      if #targets == 0 then return end
      local to = room:askForChoosePlayers(player, targets, 1, 1, "#qiaoshui-invoke", self.name, true)
      if #to > 0 then
        self.cost_data = {tos = to}
        return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data.tos[1])
    local pindian = player:pindian({to}, self.name)
    if pindian.results[to.id].winner == player then
      room:addPlayerMark(player, "@@qiaoshui-turn", 1)
    else
    room:addPlayerMark(player, "@@qiaoshui_lose-turn", 1)
    end
  end,
}
local qiaoshui_delay = fk.CreateTriggerSkill{
  name = "#qiaoshui_delay",
  events = {fk.AfterCardTargetDeclared},
  mute = true,
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return target == player and player:getMark("@@qiaoshui-turn") > 0 and
      data.card.type ~= Card.TypeEquip and data.card.sub_type ~= Card.SubtypeDelayedTrick
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@qiaoshui-turn", 0)
    local targets = room:getUseExtraTargets(data)
    table.insertTableIfNeed(targets, TargetGroup:getRealTargets(data.tos))
    if #targets == 0 then return false end
    local tos = room:askForChoosePlayers(player, targets, 1, 1, "#qiaoshui-choose:::"..data.card:toLogString(), self.name, true)
    if #tos > 0 then
      local to = tos[1]
      if TargetGroup:includeRealTargets(data.tos, to) then
        TargetGroup:removeTarget(data.tos, to)
      else
        table.insert(data.tos, {to})
      end
    end
  end,
}
qiaoshui:addRelatedSkill(qiaoshui_delay)
local qiaoshui_prohibit = fk.CreateProhibitSkill{
  name = "#qiaoshui_prohibit",
  prohibit_use = function(self, player, card)
    return player:hasSkill(self, true) and player:getMark("@@qiaoshui_lose-turn") > 0 and card.type == Card.TypeTrick
  end,
}
local zongshij = fk.CreateTriggerSkill{
  name = "zongshij",
  anim_type = "drawcard",
  events = {fk.PindianResultConfirmed},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      self.cost_data = nil
      if data.winner and data.winner == player then
        if data.from == player then
          self.cost_data = data.toCard
        else
          self.cost_data = data.fromCard
        end
      else
        if data.from == player then
          self.cost_data = data.fromCard
        elseif data.to == player then
          self.cost_data = data.toCard
        end
      end
      return self.cost_data and player.room:getCardArea(self.cost_data) == Card.Processing
    end
  end,
  on_cost = function(self, event, target, player, data)
    local prompt
    if data.winner and data.winner == player then
      prompt = "#zongshij1-get:::"
    else
      prompt = "#zongshij2-get:::"
    end
    return player.room:askForSkillInvoke(player, self.name, data, prompt..self.cost_data:toLogString())
  end,
  on_use = function(self, event, target, player, data)
    player.room:obtainCard(player, self.cost_data, true, fk.ReasonJustMove)
  end,
}
qiaoshui:addRelatedSkill(qiaoshui_prohibit)
jianyong:addSkill(qiaoshui)
jianyong:addSkill(zongshij)
Fk:loadTranslationTable{
  ["jianyong"] = "简雍",
  ["#jianyong"] = "悠游风议",
  ["designer:jianyong"] = "Nocihoo",
  ["illustrator:jianyong"] = "Thinking",
  ["qiaoshui"] = "巧说",
  [":qiaoshui"] = "出牌阶段开始时，你可以与一名其他角色拼点，若你赢，你使用的下一张基本牌或非延时类锦囊牌可以额外指定任意一名其他角色为目标或"..
  "减少指定一个目标；若你没赢，你不能使用锦囊牌直到回合结束。",
  ["zongshij"] = "纵适",
  [":zongshij"] = "每当你拼点赢，你可以获得对方此次拼点的牌；每当你拼点没赢，你可以收回你此次拼点的牌。",
  ["#qiaoshui-invoke"] = "巧说：你可以拼点，若赢，下一张基本牌或锦囊牌可以增加/减少一个目标",
  ["#qiaoshui-choose"] = "巧说：你可以为%arg增加/减少一个目标",
  ["@@qiaoshui-turn"] = "巧说 赢",
  ["@@qiaoshui_lose-turn"] = "巧说 没赢",
  ["#qiaoshui_delay"] = "巧说",
  ["#zongshij1-get"] = "纵适：你可以获得对方的拼点牌%arg",
  ["#zongshij2-get"] = "纵适：你可以收回你的拼点牌%arg",

  ["$qiaoshui1"] = "合则两利，斗则两伤。",
  ["$qiaoshui2"] = "君且安坐，听我一言。",
  ["$zongshij1"] = "买卖不成，情义还在。",
  ["$zongshij2"] = "此等小事，何须挂耳？",
  ["~jianyong"] = "两国交战……不斩……",
}

local liufeng = General(extension, "liufeng", "shu", 4)
local xiansi = fk.CreateTriggerSkill{
  name = "xiansi",
  anim_type = "control",
  attached_skill_name = "xiansi&",
  derived_piles = "liufeng_ni",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and player.phase == Player.Start then
      return not table.every(player.room:getOtherPlayers(player), function (p) return p:isNude() end)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room:getOtherPlayers(player), function(p)
      return not p:isNude() end), Util.IdMapper)
    local tos = room:askForChoosePlayers(player, targets, 1, 2, "#xiansi-choose", self.name, true)
    if #tos > 0 then
      room:sortPlayersByAction(tos)
      self.cost_data = tos
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, pid in ipairs(self.cost_data) do
      if player.dead then break end
      local p = room:getPlayerById(pid)
      if not p:isNude() then
        local id = room:askForCardChosen(player, p, "he", self.name)
        player:addToPile("liufeng_ni", id, true, self.name)
      end
    end
  end,
}
local xiansi_viewas = fk.CreateViewAsSkill{
  name = "xiansi&",
  anim_type = "negative",
  pattern = "slash",
  card_filter = Util.FalseFunc,
  view_as = function(self, cards)
    local c = Fk:cloneCard("slash")
    c.skillName = "xiansi"
    return c
  end,
  before_use = function(self, player, use)
    local room = player.room
    for _, id in ipairs(TargetGroup:getRealTargets(use.tos)) do
      local p = room:getPlayerById(id)
      if p:hasSkill("xiansi", true) and #p:getPile("liufeng_ni") > 1 then
        local cards = table.random(p:getPile("liufeng_ni"), 2)
        room:moveCards({
          from = id,
          ids = cards,
          toArea = Card.DiscardPile,
          moveReason = fk.ReasonPutIntoDiscardPile,
          skillName = "xiansi",
        })
        break
      end
    end
  end,
  enabled_at_play = function(self, player)
    return table.find(Fk:currentRoom().alive_players, function(p)
      return (p:hasSkill("xiansi", true) and #p:getPile("liufeng_ni") > 1) end)
  end,
  enabled_at_response = function(self, player, response)
    return not response and table.find(Fk:currentRoom().alive_players, function(p)
      return (p:hasSkill("xiansi", true) and #p:getPile("liufeng_ni") > 1) end)
  end,
}
local xiansi_prohibit = fk.CreateProhibitSkill{  --FIXME: 目标多指！
  name = "#xiansi_prohibit",
  is_prohibited = function(self, from, to, card)
    if from:hasSkill(self, true) then
      return card.trueName == "slash" and table.contains(card.skillNames, "xiansi") and
        not (to:hasSkill("xiansi", true) and #to:getPile("liufeng_ni") > 1)
    end
  end,
}
xiansi_viewas:addRelatedSkill(xiansi_prohibit)
Fk:addSkill(xiansi_viewas)
liufeng:addSkill(xiansi)
Fk:loadTranslationTable{
  ["liufeng"] = "刘封",
  ["#liufeng"] = "骑虎之殇",
  ["designer:liufeng"] = "香蒲神殇",
  ["illustrator:liufeng"] = "Thinking",
  ["xiansi"] = "陷嗣",
  [":xiansi"] = "回合开始阶段开始时，你可以将至多两名其他角色的各一张牌置于你的武将牌上，称为“逆”。每当其他角色需要对你使用一张【杀】时，"..
  "该角色可以弃置你武将牌上的两张“逆”，视为对你使用一张【杀】。",
  ["#xiansi-choose"] = "陷嗣：你可以将至多两名其他角色各一张牌置为“逆”",
  ["liufeng_ni"] = "逆",
  ["xiansi&"] = "陷嗣",
  [":xiansi&"] = "当你需使用【杀】时，你可以弃置刘封的两张“逆”，视为对其使用一张【杀】。",

  ["$xiansi1"] = "袭人于不意，溃敌于无形！",
  ["$xiansi2"] = "破敌军阵，父亲定会刮目相看！",
  ["$xiansi3"] = "此乃孟达之计，非我所愿！",
  ["$xiansi4"] = "我有何罪？！",
  ["~liufeng"] = "父亲，为什么……",
}

local panzhangmazhong = General(extension, "panzhangmazhong", "wu", 4)
local duodao = fk.CreateTriggerSkill{
  name = "duodao",
  anim_type = "masochism",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card and data.card.trueName == "slash" and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local prompt
    if data.from and not data.from.dead then
      prompt = "#duodao-invoke::"..data.from.id
    else
      prompt = "#duodao-discard"
    end
    local card = player.room:askForDiscard(player, 1, 1, true, self.name, true, ".", prompt, true)
    if #card > 0 then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(self.cost_data, self.name, player, player)
    local from = data.from
    if not from or from.dead or player.dead then return end
    local weapon = from:getEquipment(Card.SubtypeWeapon)
    if weapon then
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
    return target == player and player:hasSkill(self) and data.card and data.card.trueName == "slash" and
      not data.to:inMyAttackRange(player) and player.room.logic:damageByCardEffect()
  end,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + 1
  end,
}
panzhangmazhong:addSkill(duodao)
panzhangmazhong:addSkill(anjian)
Fk:loadTranslationTable{
  ["panzhangmazhong"] = "潘璋马忠",
  ["#panzhangmazhong"] = "擒龙伏虎",
  ["designer:panzhangmazhong"] = "Michael_Lee",
  ["illustrator:panzhangmazhong"] = "zzyzzyy",
  ["duodao"] = "夺刀",
  [":duodao"] = "当你受到【杀】造成的伤害后，你可以弃置一张牌，然后获得伤害来源装备区里的武器牌。",
  ["anjian"] = "暗箭",
  [":anjian"] = "锁定技，当你使用的【杀】对目标角色造成伤害时，若你不在其攻击范围内，则此【杀】伤害+1。",
  ["#duodao-invoke"] = "夺刀：你可以弃置一张牌，若%dest装备区有武器牌则获得之",
  ["#duodao-discard"] = "夺刀：你可以弃置一张牌",

  ["$duodao1"] = "这刀岂是你配用的？",
  ["$duodao2"] = "夺敌兵刃，如断其臂！",
  ["$anjian1"] = "击其懈怠，攻其不备！",
  ["$anjian2"] = "哼，你满身都是破绽！",
  ["~panzhangmazhong"] = "怎么可能，我明明亲手将你……",
}

local yufan = General(extension, "yufan", "wu", 3)
local zongxuan = fk.CreateTriggerSkill{
  name = "zongxuan",
  anim_type = "control",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      for _, move in ipairs(data) do
        if move.from == player.id and move.toArea == Card.DiscardPile and move.moveReason == fk.ReasonDiscard then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
              if player.room:getCardArea(info.cardId) == Card.DiscardPile then
                return true
              end
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = {}
    for _, move in ipairs(data) do
      if move.from == player.id and move.toArea == Card.DiscardPile and move.moveReason == fk.ReasonDiscard then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
            if room:getCardArea(info.cardId) == Card.DiscardPile then
              table.insertIfNeed(cards, info.cardId)
            end
          end
        end
      end
    end
    if #cards > 0 then
      local top = room:askForGuanxing(player, cards, {1, #cards}, nil, self.name, true, {nil, "zongxuanNoput"}).top
      if #top > 0 then
        room:moveCards({
          ids = table.reverse(top),
          toArea = Card.DrawPile,
          moveReason = fk.ReasonPut,
          skillName = self.name,
          proposer = player.id,
        })
      end
    end
  end,
}
local zhiyan = fk.CreateTriggerSkill{
  name = "zhiyan",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askForChoosePlayers(player, table.map(player.room:getAlivePlayers(), Util.IdMapper), 1, 1, "#zhiyan-choose", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    local id = to:drawCards(1, self.name)[1]
    if room:getCardOwner(id) ~= to or room:getCardArea(id) ~= Card.PlayerHand then return end
    local card = Fk:getCardById(id)
    to:showCards(card)
    if to.dead then return end
    room:delay(1000)  --防止天机图卡手牌
    if card.type == Card.TypeEquip and not to:prohibitUse(card) and not to:isProhibited(to, card) then
      room:useCard({
        from = to.id,
        tos = {{to.id}},
        card = card,
      })
      if to:isWounded() and not to.dead then
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
  ["#yufan"] = "狂直之士",
  ["designer:yufan"] = "幻岛",
  ["illustrator:yufan"] = "L",
  ["zongxuan"] = "纵玄",
  [":zongxuan"] = "当你的牌因弃置而移至弃牌堆后，你可以将其中至少一张牌置于牌堆顶。",
  ["zhiyan"] = "直言",
  [":zhiyan"] = "结束阶段开始时，你可以令一名角色摸一张牌并展示之，若此牌为装备牌，其使用此牌并回复1点体力。",
  ["zongxuanNoput"] = "不置于牌堆顶",
  ["#zhiyan-choose"] = "直言：你可以令一名角色摸一张牌并展示之，若为装备牌其使用之并回复1点体力",

  ["$zongxuan1"] = "依易设象，以占吉凶。",
  ["$zongxuan2"] = "世间万物，皆有定数。",
  ["$zhiyan1"] = "志节分明，折而不屈！",
  ["$zhiyan2"] = "直言劝谏，不惧祸否！",
  ["~yufan"] = "我枉称东方朔再世……",
}

local nos__zhuran = General(extension, "nos__zhuran", "wu", 4)
local nos__danshou = fk.CreateTriggerSkill{
  name = "nos__danshou",
  anim_type = "control",
  mute = true,
  events = {fk.Damage},
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("danshou")
    room:notifySkillInvoked(player, self.name)
    player:drawCards(1, self.name)
    room.logic:breakTurn()
  end,
}
nos__zhuran:addSkill(nos__danshou)
Fk:loadTranslationTable{
  ["nos__zhuran"] = "朱然",
  ["#nos__zhuran"] = "不动之督",
  ["designer:nos__zhuran"] = "迁迁婷婷",
  ["illustrator:nos__zhuran"] = "Ccat",
  ["nos__danshou"] = "胆守",
  [":nos__danshou"] = "每当你造成一次伤害后，你可以摸一张牌，若如此做，终止一切结算，当前回合结束。",

  ["$nos__danshou1"] = "到此为止了！",
  ["$nos__danshou2"] = "以胆为守，扼敌咽喉！",
  ["~nos__zhuran"] = "何人竟有如此之胆！？",
}

local zhuran = General(extension, "zhuran", "wu", 4)
local danshou = fk.CreateActiveSkill{
  name = "danshou",
  anim_type = "offensive",
  card_num = function (self)
    return Self:usedSkillTimes(self.name, Player.HistoryPhase) + 1
  end,
  target_num = 1,
  can_use = function(self, player)
    return not player:isNude()
  end,
  prompt = function(self)
    local n = Self:usedSkillTimes(self.name, Player.HistoryPhase) + 1
    if n < 4 then
      return "#danshou"..n
    else
      return "#danshou4:::"..n
    end
  end,
  card_filter = function(self, to_select, selected)
    return #selected < Self:usedSkillTimes(self.name, Player.HistoryPhase) + 1 and not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    if #selected == 0 and to_select ~= Self.id and #selected_cards == Self:usedSkillTimes(self.name, Player.HistoryPhase) + 1 then
      local target = Fk:currentRoom():getPlayerById(to_select)
      if Self:inMyAttackRange(target) then
        if #selected_cards < 3 then
          return not target:isNude()
        else
          return true
        end
      end
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:throwCard(effect.cards, self.name, player, player)
    if #effect.cards == 1 then
      if player.dead then return end
      local id = room:askForCardChosen(player, target, "he", self.name)
      room:throwCard({id}, self.name, target, player)
    elseif #effect.cards == 2 then
      if player.dead or target.dead or target:isNude() then return end
      local card = room:askForCard(target, 1, 1, true, self.name, false, ".", "#danshou-give::"..player.id)
      room:obtainCard(player.id, card[1], false, fk.ReasonGive, target.id)
    elseif #effect.cards == 3 then
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = self.name,
      }
    else
      if not player.dead then
        player:drawCards(2, self.name)
      end
      if not target.dead then
        target:drawCards(2, self.name)
      end
    end
  end,
}
zhuran:addSkill(danshou)
Fk:loadTranslationTable{
  ["zhuran"] = "朱然",
  ["#zhuran"] = "不动之督",
  ["designer:zhuran"] = "Loun老萌",
  ["illustrator:zhuran"] = "NOVART", -- 猇亭之战
  ["danshou"] = "胆守",
  [":danshou"] = "出牌阶段，你可以弃置X张牌并选择你攻击范围内的一名其他角色（X为你此阶段内发动〖胆守〗的次数），若X为：1，你弃置其一张牌；"..
  "2，其将一张牌交给你；3，你对其造成1点伤害；不小于4，你与其各摸两张牌。",
  ["#danshou1"] = "胆守：你可以弃置1张牌，弃置攻击范围内一名角色一张牌",
  ["#danshou2"] = "胆守：你可以弃置2张牌，令攻击范围内一名角色交给你一张牌",
  ["#danshou3"] = "胆守：你可以弃置3张牌，对攻击范围内一名角色造成1点伤害",
  ["#danshou4"] = "胆守：你可以弃置%arg张牌，与攻击范围内一名角色各摸两张牌",
  ["#danshou-give"] = "胆守：你需交给 %dest 一张牌",

  ["$danshou1"] = "到此为止了！",
  ["$danshou2"] = "以胆为守，扼敌咽喉！",
  ["~zhuran"] = "何人竟有如此之胆！？",
}

local fuhuanghou = General(extension, "fuhuanghou", "qun", 3, 3, General.Female)
local zhuikong = fk.CreateTriggerSkill{
  name = "zhuikong",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and target ~= player and target.phase == Player.Start then
      return player:isWounded() and player:canPindian(target)
    end
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, data, "#zhuikong-invoke::"..target.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local pindian = player:pindian({target}, self.name)
    if pindian.results[target.id].winner == player then
      room:addPlayerMark(target, "zhuikong_prohibit-turn", 1)
    else
      room:addPlayerMark(player, "zhuikong-turn", 1)
    end
  end
}
local zhuikong_prohibit = fk.CreateProhibitSkill{
  name = "#zhuikong_prohibit",
  is_prohibited = function(self, from, to, card)
    return from:getMark("zhuikong_prohibit-turn") > 0 and from ~= to
  end,
}
local zhuikong_distance = fk.CreateDistanceSkill{
  name = "#zhuikong_distance",
  fixed_func = function(self, from, to)
    if to:usedSkillTimes("zhuikong", Player.HistoryTurn) > 0 and to:getMark("zhuikong-turn") > 0 then
      return 1
    end
  end,
}
local qiuyuan = fk.CreateTriggerSkill{
  name = "qiuyuan",
  anim_type = "defensive",
  events = {fk.TargetConfirming},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.trueName == "slash"
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room:getOtherPlayers(player), function(p)
      return p.id ~= data.from end), Util.IdMapper)
    local to = room:askForChoosePlayers(player, targets, 1, 1, "#qiuyuan-choose", self.name, true)
    if #to > 0 then
      self.cost_data = {tos = to}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = self.cost_data.tos[1]
    local card = room:askForCard(room:getPlayerById(to), 1, 1, false, self.name, true, "jink", "#qiuyuan-give::"..player.id)
    if #card > 0 then
      room:obtainCard(player.id, Fk:getCardById(card[1]), true, fk.ReasonGive, to, self.name)
    else
      TargetGroup:pushTargets(data.targetGroup, to)
    end
  end,
}
zhuikong:addRelatedSkill(zhuikong_prohibit)
zhuikong:addRelatedSkill(zhuikong_distance)
fuhuanghou:addSkill(zhuikong)
fuhuanghou:addSkill(qiuyuan)
Fk:loadTranslationTable{
  ["fuhuanghou"] = "伏皇后",
  ["#fuhuanghou"] = "孤注一掷",
  ["designer:fuhuanghou"] = "萌D",
  ["illustrator:fuhuanghou"] = "小莘",
  ["zhuikong"] = "惴恐",
  [":zhuikong"] = "一名角色的回合开始时，若你已受伤，你可以与该角色拼点，若你赢，该角色本回合使用的牌不能指定除该角色以外的角色为目标；若你没赢，该角色与你的距离视为1直到回合结束。",
  ["qiuyuan"] = "求援",
  [":qiuyuan"] = "当你成为【杀】的目标时，你可以令另一名其他角色选择一项：交给你一张【闪】，或成为此【杀】的额外目标。",
  ["#zhuikong-invoke"] = "惴恐：你可以与 %dest 拼点，若赢则其本回合使用牌只能指定自己为目标",
  ["#qiuyuan-choose"] = "求援：令另一名其他角色交给你一张【闪】，否则其成为此【杀】额外目标",
  ["#qiuyuan-give"] = "求援：你需交给 %dest 一张【闪】，否则成为此【杀】额外目标",

  ["$zhuikong1"] = "诚惶诚恐，夜不能寐。",
  ["$zhuikong2"] = "嘘，隔墙有耳。",
  ["$qiuyuan1"] = "逆贼逞凶，卿可灭之。",
  ["$qiuyuan2"] = "求父亲救救大汉江山吧！",
  ["~fuhuanghou"] = "陛下为何不救臣妾……",
}

local nos__fuhuanghou = General(extension, "nos__fuhuanghou", "qun", 3, 3, General.Female)
local nos__zhuikong = fk.CreateTriggerSkill{
  name = "nos__zhuikong",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and target ~= player and target.phase == Player.Start then
      return player:isWounded() and player:canPindian(target)
    end
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, data, "#nos__zhuikong-invoke::"..target.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local pindian = player:pindian({target}, self.name)
    if pindian.results[target.id].winner == player then
      target:skip(Player.Play)
    else
      room:addPlayerMark(player, "nos__zhuikong-turn", 1)
    end
  end
}
local nos__zhuikong_distance = fk.CreateDistanceSkill{
  name = "#nos__zhuikong_distance",
  correct_func = function(self, from, to) return 0 end,
  fixed_func = function(self, from, to)
    if to:usedSkillTimes("nos__zhuikong", Player.HistoryTurn) > 0 and to:getMark("nos__zhuikong-turn") > 0 then
      return 1
    end
  end,
}
local nos__qiuyuan = fk.CreateTriggerSkill{
  name = "nos__qiuyuan",
  anim_type = "defensive",
  events = {fk.TargetConfirming},
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self) and data.card.trueName == "slash") then return end
    local targets = table.map(table.filter(player.room:getOtherPlayers(player), function(p)
      return p.id ~= data.from and not p:isKongcheng() end), Util.IdMapper)
    return #targets > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(table.filter(room:getOtherPlayers(player), function(p)
      return p.id ~= data.from and not p:isKongcheng() end), Util.IdMapper)
    local to = room:askForChoosePlayers(player, targets, 1, 1, "#nos__qiuyuan-choose", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = self.cost_data
    room:doIndicate(player.id, {to})
    local card = room:askForCard(room:getPlayerById(to), 1, 1, false, self.name, false, ".|.|.|hand", "#nos__qiuyuan-give::"..player.id)
    if #card > 0 then
      local card = Fk:getCardById(card[1])
      room:obtainCard(player.id, card, true, fk.ReasonGive, to)
      if card.name ~= "jink" then
        TargetGroup:pushTargets(data.targetGroup, to)
      end
    end
  end,
}
nos__zhuikong:addRelatedSkill(nos__zhuikong_distance)
nos__fuhuanghou:addSkill(nos__zhuikong)
nos__fuhuanghou:addSkill(nos__qiuyuan)
Fk:loadTranslationTable{
  ["nos__fuhuanghou"] = "伏皇后",
  ["#nos__fuhuanghou"] = "孤注一掷",
  ["designer:nos__fuhuanghou"] = "萌D",
  ["illustrator:nos__fuhuanghou"] = "琛·美弟奇",
  ["nos__zhuikong"] = "惴恐",
  [":nos__zhuikong"] = "一名角色的回合开始时，若你已受伤，你可以和该角色进行一次拼点。若你赢，该角色跳过本回合的出牌阶段；"..
  "若你没赢，该角色与你距离为1直到回合结束。",
  ["nos__qiuyuan"] = "求援",
  [":nos__qiuyuan"] = "当你成为【杀】的目标时，你可以令一名有手牌的其他角色交给你一张手牌。若此牌不为【闪】，该角色也成为此【杀】的目标"..
  "（该角色不得是此【杀】的使用者）。",
  ["#nos__zhuikong-invoke"] = "惴恐：你可以与 %dest 拼点，若赢则其本回合跳过出牌阶段",
  ["#nos__qiuyuan-choose"] = "求援：令另一名其他角色交给你一张手牌",
  ["#nos__qiuyuan-give"] = "求援：你需交给 %dest 一张手牌",

  ["$nos__zhuikong1"] = "此密信，切勿落入曹贼手中。",
  ["$nos__zhuikong2"] = "此密诏一出，安知是福是祸？",
  ["$nos__qiuyuan1"] = "陛下，我该怎么办？",
  ["$nos__qiuyuan2"] = "曹贼暴虐，谁可诛之！",
  ["~nos__fuhuanghou"] = "曹贼！汝，定不得好死！",
}

local nos__liru = General(extension, "nos__liru", "qun", 3)
local nos__juece = fk.CreateTriggerSkill{
  name = "nos__juece",
  anim_type = "offensive",
  events = {fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and player.phase ~= Player.NotActive then
      for _, move in ipairs(data) do
        if move.from and player.room:getPlayerById(move.from):isKongcheng() and not player.room:getPlayerById(move.from).dead then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand then
              return true
            end
          end
        end
      end
    end
  end,
  on_trigger = function(self, event, target, player, data)
    local targets = {}
    for _, move in ipairs(data) do
      if move.from and player.room:getPlayerById(move.from):isKongcheng() and not player.room:getPlayerById(move.from).dead then
        for _, info in ipairs(move.moveInfo) do
          if info.fromArea == Card.PlayerHand then
            table.insertIfNeed(targets, move.from)
          end
        end
      end
    end
    if #targets > 0 then
      self:doCost(event, target, player, targets)
    end
  end,
  on_cost = function(self, event, target, player, data)
    if #data == 1 then
      if player.room:askForSkillInvoke(player, self.name, nil, "#nos__juece-invoke::"..data[1]) then
        self.cost_data = data
        return true
      end
    else
      local tos = player.room:askForChoosePlayers(player, data, 1, 999, "#nos__juece-choose", self.name, true)
      if #tos > 0 then
        self.cost_data = tos
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.simpleClone(self.cost_data)
    room:doIndicate(player.id, targets)
    for _, id in ipairs(targets) do
      local p = room:getPlayerById(id)
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
local nos__mieji = fk.CreateTriggerSkill{
  name = "nos__mieji",
  anim_type = "offensive",
  events = {fk.AfterCardTargetDeclared},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and
      data.card.color == Card.Black and data.card:isCommonTrick() and
      #TargetGroup:getRealTargets(data.tos) == 1 and #player.room:getUseExtraTargets(data) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askForChoosePlayers(player, room:getUseExtraTargets(data), 1, 1,
      "#nos__mieji-choose:::"..data.card:toLogString(), self.name, true)
    if #to > 0 then
      self.cost_data = {tos = to}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    table.insert(data.tos, self.cost_data.tos)
  end,
}
local nos__fencheng = fk.CreateActiveSkill{
  name = "nos__fencheng",
  anim_type = "offensive",
  card_num = 0,
  target_num = 0,
  card_filter = Util.FalseFunc,
  frequency = Skill.Limited,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local targets = room:getOtherPlayers(player)
    for _, target in ipairs(targets) do
      local length = math.max(1, #target.player_cards[Player.Equip])
      local cards = room:askForDiscard(target, length, length, true, self.name, true, ".", "#nos__fencheng-discard:::"..tostring(length))
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
nos__liru:addSkill(nos__juece)
nos__liru:addSkill(nos__mieji)
nos__liru:addSkill(nos__fencheng)
Fk:loadTranslationTable{
  ["nos__liru"] = "李儒",
  ["#nos__liru"] = "魔仕",
  ["designer:nos__liru"] = "淬毒",
  ["illustrator:nos__liru"] = "zoo", -- 烈火焚城
  ["nos__juece"] = "绝策",
  [":nos__juece"] = "在你的回合内，一名角色失去最后的手牌时，你可以对其造成1点伤害。",
  ["nos__mieji"] = "灭计",
  [":nos__mieji"] = "你使用黑色非延时类锦囊仅指定一个目标时，可以额外指定一个目标。",
  ["nos__fencheng"] = "焚城",
  [":nos__fencheng"] = "限定技，出牌阶段，你可令所有其他角色依次选择一项：弃置X张牌，或受到1点火焰伤害。（X为该角色装备区里牌的数量且至少为1）",
  ["#nos__juece-invoke"] = "绝策：你可以对 %dest 造成1点伤害",
  ["#nos__juece-choose"] = "绝策：你可以对这些角色造成1点伤害",
  ["#nos__mieji-choose"] = "灭计：你可以为%arg额外指定一个目标",
  ["#nos__fencheng-discard"] = "焚城：你需弃置%arg张牌，否则受到1点火焰伤害",

  ["$nos__juece1"] = "我，最喜欢落井下石。",
  ["$nos__juece2"] = "一无所有？那就拿命来填！",
  ["$nos__mieji1"] = "我要的是斩草除根。",
  ["$nos__mieji2"] = "叫天天不应，叫地地不灵~",
  ["$nos__fencheng1"] = "我要这满城的人都来给你陪葬。",
  ["$nos__fencheng2"] = "一把火烧他个精光吧！诶啊哈哈哈哈哈~",
  ["~nos__liru"] = "乱世的好戏才刚刚开始……",
}

local liru = General(extension, "liru", "qun", 3)
local juece = fk.CreateTriggerSkill{
  name = "juece",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish and
      #table.filter(player.room:getOtherPlayers(player), function(p) return (p:isKongcheng()) end) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askForChoosePlayers(player, table.map(table.filter(room:getOtherPlayers(player), function(p)
      return (p:isKongcheng()) end), Util.IdMapper),
      1, 1, "#juece-choose", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:damage{
      from = player,
      to = player.room:getPlayerById(self.cost_data),
      damage = 1,
      skillName = self.name,
    }
  end,
}
local mieji = fk.CreateActiveSkill{
  name = "mieji",
  anim_type = "offensive",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = function(self, to_select, selected, targets)
    local card = Fk:getCardById(to_select)
    return #selected == 0 and card.type == Card.TypeTrick and card.color == Card.Black
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and not Fk:currentRoom():getPlayerById(to_select):isNude()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:moveCards({
      ids = effect.cards,
      from = player.id,
      fromArea = Card.PlayerHand,
      toArea = Card.DrawPile,
      moveReason = fk.ReasonJustMove,
      skillName = self.name,
    })
    local ids = room:askForDiscard(target, 1, 1, true, self.name, false, ".", "#mieji-discard1")
    if Fk:getCardById(ids[1]).type ~= Card.TypeTrick then
      room:askForDiscard(target, 1, 1, true, self.name, false, ".|.|.|.|.|basic,equip", "#mieji-discard2")
    end
  end,
}
local fencheng = fk.CreateActiveSkill{
  name = "fencheng",
  anim_type = "offensive",
  card_num = 0,
  target_num = 0,
  card_filter = Util.FalseFunc,
  frequency = Skill.Limited,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local targets = room:getOtherPlayers(player)
    local n = 0
    for _, target in ipairs(targets) do
      local total = #target:getCardIds{Player.Hand, Player.Equip}
      if total < n + 1 then
        room:damage{
          from = player,
          to = target,
          damage = 2,
          damageType = fk.FireDamage,
          skillName = self.name,
        }
        n = 0
      else
        local cards = room:askForDiscard(target, n + 1, 999, true, self.name, true, ".", "#fencheng-discard:::"..tostring(n + 1))
        if #cards == 0 then
          room:damage{
            from = player,
            to = target,
            damage = 2,
            damageType = fk.FireDamage,
            skillName = self.name,
          }
          n = 0
        else
          n = #cards
        end
      end
    end
  end
}
liru:addSkill(juece)
liru:addSkill(mieji)
liru:addSkill(fencheng)
Fk:loadTranslationTable{
  ["liru"] = "李儒",
  ["#liru"] = "魔仕",
  ["designer:liru"] = "淬毒",
  ["illustrator:liru"] = "MSNZero",
  ["juece"] = "绝策",
  [":juece"] = "结束阶段，你可以对一名没有手牌的其他角色造成1点伤害。",
  ["mieji"] = "灭计",
  [":mieji"] = "出牌阶段限一次，你可以将一张黑色锦囊牌置于牌堆顶并选择一名其他角色，然后令该角色选择一项：1.弃置一张锦囊牌；2.依次弃置两张非锦囊牌。",
  ["fencheng"] = "焚城",
  [":fencheng"] = "限定技，出牌阶段，你可以令所有其他角色依次选择一项：1.弃置至少X+1张牌（X为该角色的上家以此法弃置牌的数量）；"..
  "2.受到你造成的2点火焰伤害。",
  ["#juece-choose"] = "绝策：你可以对一名没有手牌的其他角色造成1点伤害",
  ["#mieji-discard1"] = "灭计：弃置一张锦囊牌或依次弃置两张非锦囊牌",
  ["#mieji-discard2"] = "灭计：再弃置一张非锦囊牌",
  ["#fencheng-discard"] = "焚城：弃置至少%arg张牌，否则受到2点火焰伤害",

  ["$juece1"] = "哼！你走投无路了。",
  ["$juece2"] = "无用之人，死！",
  ["$mieji1"] = "宁错杀，无放过！",
  ["$mieji2"] = "你能逃得出我的手掌心吗？",
  ["$fencheng1"] = "我得不到的，你们也别想得到！",
  ["$fencheng2"] = "让这一切都灰飞烟灭吧！哼哼哼哼……",
  ["~liru"] = "如遇明主，大业必成……",
}

return extension

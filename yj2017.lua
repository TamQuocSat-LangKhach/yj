local extension = Package("yczh2017")
extension.extensionName = "yj"

local U = require "packages/utility/utility"

Fk:loadTranslationTable{
  ["yczh2017"] = "原创之魂2017",
}

local xinxianying = General(extension, "xinxianying", "wei", 3, 3, General.Female)
local zhongjian = fk.CreateActiveSkill{
  name = "zhongjian",
  anim_type = "control",
  card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) < (1 + player:getMark("zhongjian_times-turn"))
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  target_filter = function(self, to_select, selected)
    if #selected == 0 and Self.id ~= to_select then
      local target = Fk:currentRoom():getPlayerById(to_select)
      return target:getHandcardNum() > target.hp
    end
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    player:showCards(effect.cards)
    local x = target:getHandcardNum() - target.hp
    if x <= 0 or player.dead then return end
    local show = room:askForCardsChosen(player, target, x, x, "h", self.name)
    target:showCards(show)
    if player.dead then return end
    local card = Fk:getCardById(effect.cards[1])
    local hasSame
    if table.find(show, function(id) return Fk:getCardById(id).color == card.color end) then
      local choices = {"draw1"}
      if not target:isNude() then table.insert(choices, "zhongjian_throw:"..target.id) end
      if room:askForChoice(player, choices, self.name) == "draw1" then
        player:drawCards(1, self.name)
      else
        local cid = room:askForCardChosen(player, target, "h", self.name)
        room:throwCard({cid}, self.name, target, player)
      end
      hasSame = true
    end
    if table.find(show, function(id) return Fk:getCardById(id).number == card.number end) then
      room:setPlayerMark(player, "zhongjian_times-turn", 1)
      hasSame = true
    end
    if not hasSame and player:getMaxCards() > 0 then
      room:addPlayerMark(player, MarkEnum.MinusMaxCards, 1)
      room:broadcastProperty(player, "MaxCards")
    end
  end,
}
xinxianying:addSkill(zhongjian)
local caishi = fk.CreateTriggerSkill{
  name = "caishi",
  anim_type = "defensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and player == target and player.phase == Player.Draw
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local choices = {"#caishi1","cancel"}
    if player:isWounded() then table.insert(choices,2, "#caishi2") end
    local choice = target.room:askForChoice(target, choices, self.name)
    if choice ~= "cancel" then
      self.cost_data = choice
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = self.cost_data
    if choice == "#caishi1" then
      room:addPlayerMark(player, MarkEnum.AddMaxCards, 1)
      room:addPlayerMark(player, "caishi_other-turn")
    else
      room:recover({ who = player,  num = 1, skillName = self.name })
      room:addPlayerMark(player, "caishi_self-turn")
    end
  end,
}
local caishi_prohibit = fk.CreateProhibitSkill{
  name = "#caishi_prohibit",
  is_prohibited = function(self, from, to)
    return (from:getMark("caishi_other-turn") > 0 and from ~= to) or (from:getMark("caishi_self-turn") > 0 and from == to)
  end,
}
caishi:addRelatedSkill(caishi_prohibit)
xinxianying:addSkill(caishi)
Fk:loadTranslationTable{
  ["xinxianying"] = "辛宪英",
  ["#xinxianying"] = "名门智女",
  ["designer:xinxianying"] = "如释帆飞",
	["cv:xinxianying"] = "小N",
  ["illustrator:xinxianying"] = "玫芍之言",

  ["zhongjian"] = "忠鉴",
  [":zhongjian"] = "出牌阶段限一次，你可以展示一张手牌，然后展示手牌数大于体力值的一名其他角色X张手牌（X为其手牌数和体力值之差）。若其以此法"..
  "展示的牌与你展示的牌：有颜色相同的，你摸一张牌或弃置其一张牌；有点数相同的，本回合此技能改为“出牌阶段限两次”；均不同且你手牌上限大于0，你的手牌上限-1。",
  ["zhongjian_throw"] = "弃置%src一张牌",
  ["caishi"] = "才识",
  [":caishi"] = "摸牌阶段开始时，你可以选择一项：1.手牌上限+1，然后本回合你的牌不能对其他角色使用；2.回复1点体力，然后本回合你的牌不能对自己使用。",
  ["#caishi1"] = "手牌上限+1，本回合不能对其他角色用牌",
  ["#caishi2"] = "回复1点体力，本回合不能对自己用牌",
  ["#caishi_prohibit"] = "才识",

  ["$zhongjian1"] = "浊世风云变幻，当以明眸洞察。",
  ["$zhongjian2"] = "心中自有明镜，可鉴奸佞忠良。",
  ["$caishi1"] = "清识难尚，至德可师。",
  ["$caishi2"] = "知书达礼，博古通今。",
  ["~xinxianying"] = "吾一生明鉴，竟错看于你。",
}

local jikang = General(extension, "jikang", "wei", 3)
local doQingxian = function (room, to, from, choice, skillName)
  if to.dead then return nil end
  local returnCard
  if choice == "qingxian_losehp" then
    room:loseHp(to, 1, skillName)
    if to.dead then return end
    local cards = {}
    for _, cid in ipairs(room.draw_pile) do
      local card = Fk:getCardById(cid)
      if card.type == Card.TypeEquip and to:canUse(card) then
        table.insert(cards, card)
      end
    end
    if #cards > 0 then
      returnCard = table.random(cards)
      room:useCard({ from = to.id, tos = {{to.id}}, card = returnCard })
    end
  else
    if to:isWounded() then
      room:recover({ who = to, num = 1, recoverBy = from, skillName = skillName })
    end
    if not to.dead and not to:isNude() then
      local throw = room:askForDiscard(to, 1, 1, true, skillName, false, ".|.|.|.|.|equip")
      if #throw > 0 then
        returnCard = Fk:getCardById(throw[1])
      end
    end
  end
  return returnCard
end
local qingxian = fk.CreateTriggerSkill{
  name = "qingxian",
  events = { fk.Damaged , fk.HpRecover },
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and target == player then
      if event == fk.Damaged then
        return data.from and not data.from.dead
      else
        return true
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    if event == fk.Damaged then
      return room:askForSkillInvoke(player, self.name, data, "#skilltosb::"..data.from.id..":"..self.name)
    else
      local tos = room:askForChoosePlayers(player, table.map(room:getOtherPlayers(player), Util.IdMapper), 1, 1,
        "#skillchooseother:::"..self.name, self.name, true)
      if #tos > 0 then
        self.cost_data = tos[1]
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = (event == fk.Damaged) and data.from or room:getPlayerById(self.cost_data)
    local choice = room:askForChoice(player, {"qingxian_losehp","qingxian_recover"}, self.name)
    local card = doQingxian(room, to, player, choice, self.name)
    if card and card.suit == Card.Club and player:isWounded() and not player.dead then
      room:recover({ who = player, num = 1, recoverBy = player, skillName = self.name })
    end
  end,
}
jikang:addSkill(qingxian)
local juexiang = fk.CreateTriggerSkill{
  name = "juexiang",
  anim_type = "support",
  events = {fk.Death},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name,false,true) and target == player
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local tos = room:askForChoosePlayers(player, table.map(room:getOtherPlayers(player), Util.IdMapper), 1, 1,
      "#skillchooseother:::"..self.name, self.name, true)
    if #tos > 0 then
      self.cost_data = tos[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    local skills = table.filter({"jixiann","liexian","rouxian","hexian"}, function (s) return not to:hasSkill(s,true) end)
    if #skills > 0 then
      room:handleAddLoseSkills(to, table.random(skills), nil)
    end
    room:setPlayerMark(to, "@@juexiang", 1)
  end,
  refresh_events = {fk.TurnStart},
  can_refresh = function (self, event, target, player, data)
    return target == player and player:getMark("@@juexiang") > 0
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "@@juexiang", 0)
  end,
}
local juexiang_prohibit = fk.CreateProhibitSkill{
  name = "#juexiang_prohibit",
  is_prohibited = function(self, from, to, card)
    if card and card.suit == Card.Club then
      return to:getMark("@@juexiang") > 0 and from ~= to
    end
  end,
}
juexiang:addRelatedSkill(juexiang_prohibit)
jikang:addSkill(juexiang)
local jixiann = fk.CreateTriggerSkill{
  name = "jixiann",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and data.from and not data.from.dead
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, data, "#skilltosb::"..data.from.id..":"..self.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    doQingxian(room, data.from, player, "qingxian_losehp", self.name)
  end,
}
jikang:addRelatedSkill(jixiann)
local liexian = fk.CreateTriggerSkill{
  name = "liexian",
  events = {fk.HpRecover},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local tos = room:askForChoosePlayers(player, table.map(room:getOtherPlayers(player), Util.IdMapper), 1, 1,
      "#skillchooseother:::"..self.name, self.name, true)
    if #tos > 0 then
      self.cost_data = tos[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    doQingxian(room, room:getPlayerById(self.cost_data), player, "qingxian_losehp", self.name)
  end,
}
jikang:addRelatedSkill(liexian)
local rouxian = fk.CreateTriggerSkill{
  name = "rouxian",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player and data.from and not data.from.dead
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, data, "#skilltosb::"..data.from.id..":"..self.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    doQingxian(room, data.from, player, "qingxian_recover", self.name)
  end,
}
jikang:addRelatedSkill(rouxian)
local hexian = fk.CreateTriggerSkill{
  name = "hexian",
  events = {fk.HpRecover},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target == player
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local tos = room:askForChoosePlayers(player, table.map(room:getOtherPlayers(player), Util.IdMapper), 1, 1,
      "#skillchooseother:::"..self.name, self.name, true)
    if #tos > 0 then
      self.cost_data = tos[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    doQingxian(room, room:getPlayerById(self.cost_data), player, "qingxian_recover", self.name)
  end,
}
jikang:addRelatedSkill(hexian)
Fk:loadTranslationTable{
  ["jikang"] = "嵇康",
  ["#jikang"] = "峻峰孤松",
  ["cv:jikang"] = "曹毅",
  ["illustrator:jikang"] = "眉毛子",

  ["qingxian"] = "清弦",
  [":qingxian"] = "当你受到伤害/回复体力后，你可以选一项令伤害来源/一名其他角色执行：1.失去1点体力并随机使用牌堆一张装备牌；"..
  "2.回复1点体力并弃置一张装备牌。若其使用或弃置的牌的花色为♣，你回复1点体力。",
  ["qingxian_losehp"] = "失去1点体力并随机使用牌堆一张装备牌",
  ["qingxian_recover"] = "回复1点体力并弃置一张装备牌",
  ["juexiang"] = "绝响",
  [":juexiang"] = "当你死亡时，你可以令一名其他角色随机获得〖激弦〗、〖烈弦〗、〖柔弦〗、〖和弦〗中的一个技能，然后直到其下回合开始前，"..
  "该角色不能成为除其以外的角色使用♣牌的目标。",
  ["@@juexiang"] = "绝响",
  ["#juexiang_prohibit"] = "绝响",
  ["jixiann"] = "激弦",
  [":jixiann"] = "当你受到伤害后，你可以令伤害来源失去1点体力并随机使用牌堆一张装备牌。",
  ["liexian"] = "烈弦",
  [":liexian"] = "当你回复体力后，你可以令一名其他角色失去1点体力并随机使用牌堆一张装备牌。",
  ["rouxian"] = "柔弦",
  [":rouxian"] = "当你受到伤害后，你可以令伤害来源回复1点体力并弃置一张装备牌。",
  ["hexian"] = "和弦",
  [":hexian"] = "当你回复体力后，你可以令一名其他角色回复1点体力并弃置一张装备牌。",
  ["#skilltosb"] = "你可以对 %dest 发动“%arg”",
  ["#skillchooseother"] = "你可以对一名其他角色发动“%arg”",  --FIXME: 这两个prompt名不好，要改掉

  ["$qingxian1"] = "抚琴拨弦，悠然自得。",
  ["$qingxian2"] = "寄情于琴，合于天地。",
  ["$juexiang1"] = "此曲不能绝矣！",
  ["$juexiang2"] = "一曲琴音，为我送别。",
  ["$jixiann"] = "一弹一拨，铿锵有力！",
  ["$liexian"] = "一壶烈云烧，一曲人皆醉。",
  ["$rouxian"] = "君子以琴会友，以瑟辅人。",
  ["$hexian"] = "悠悠琴音，人人自醉。",
  ["~jikang"] = "多少遗恨，俱随琴音去。",
}

local wuxian = General(extension, "wuxian", "shu", 3, 3, General.Female)
local fumian = fk.CreateTriggerSkill{
  name = "fumian",
  anim_type = "support",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start
  end,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    if player:getMark("fumian1_record") > 0 or player:getMark("fumian2_record") > 0 then
      for i = 1, 2, 1 do
        if player:getMark("fumian"..i.."_record") > 0 then
          room:setPlayerMark(player, "fumian"..i.."_record", 0)
          room:setPlayerMark(player, "fumian"..i.."-tmp", 1)
        end
      end
    end
    self:doCost(event, target, player, data)
    room:setPlayerMark(player, "fumian1-tmp", 0)
    room:setPlayerMark(player, "fumian2-tmp", 0)
  end,
  on_cost = function(self, event, target, player, data)
    local choices = {"fumian1:::"..(player:getMark("fumian2-tmp") + 1), "fumian2:::"..(player:getMark("fumian1-tmp") + 1), "Cancel"}
    local choice = player.room:askForChoice(player, choices, self.name)
    if choice ~= "Cancel" then
      self.cost_data = choice
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = self.cost_data[7]
    if n == "1" then
      room:setPlayerMark(player, "@fumian1-turn", player:getMark("fumian2-tmp") + 1)
    else
      room:setPlayerMark(player, "@fumian2-turn", player:getMark("fumian1-tmp") + 1)
    end
    room:setPlayerMark(player, "fumian"..n.."_record", 1)
  end,
}
local fumian_trigger = fk.CreateTriggerSkill{
  name = "#fumian_trigger",
  mute = true,
  events = {fk.DrawNCards, fk.AfterCardTargetDeclared},
  can_trigger = function(self, event, target, player, data)
    if target == player then
      if event == fk.DrawNCards then
        return player:getMark("@fumian1-turn") > 0
      else
        return player:getMark("@fumian2-turn") > 0 and data.card.color == Card.Red and data.tos and
          #U.getUseExtraTargets(player.room, data, false) > 0
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    if event == fk.DrawNCards then
      return true
    else
      local tos = player.room:askForChoosePlayers(player, U.getUseExtraTargets(player.room, data, false), 1, player:getMark("@fumian2-turn"),
        "#fumian-choose:::"..data.card:toLogString()..":"..player:getMark("@fumian2-turn"), "fumian", true)
      if #tos > 0 then
        self.cost_data = tos
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.DrawNCards then
      data.n = data.n + player:getMark("@fumian1-turn")
      room:setPlayerMark(player, "@fumian1-turn", 0)
    else
      room:setPlayerMark(player, "@fumian2-turn", 0)
      for _, id in ipairs(self.cost_data) do
        TargetGroup:pushTargets(data.tos, id)
      end
    end
  end,
}
local daiyan = fk.CreateTriggerSkill{
  name = "daiyan",
  anim_type = "support",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish
  end,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    if player:getMark("daiyan_record") ~= 0 then
      local to = room:getPlayerById(player:getMark("daiyan_record"))
      room:setPlayerMark(player, "daiyan_record", 0)
      if not to.dead then
        room:setPlayerMark(to, "@@daiyan-tmp", 1)
      end
    end
    self:doCost(event, target, player, data)
    for _, p in ipairs(room.players) do
      room:setPlayerMark(p, "@@daiyan-tmp", 0)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local to = player.room:askForChoosePlayers(player, table.map(player.room:getOtherPlayers(player), Util.IdMapper),
      1, 1, "#daiyan-choose", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "daiyan_record", self.cost_data)
    local to = room:getPlayerById(self.cost_data)
    local card = room:getCardsFromPileByRule(".|.|heart|.|.|basic")
    if #card > 0 then
      room:moveCards({
        ids = card,
        to = to.id,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonJustMove,
        proposer = player.id,
        skillName = self.name,
        moveVisible = true,
      })
    end
    if not to.dead and to:getMark("@@daiyan-tmp") > 0 then
      room:loseHp(to, 1, self.name)
    end
  end,
}
fumian:addRelatedSkill(fumian_trigger)
wuxian:addSkill(fumian)
wuxian:addSkill(daiyan)
Fk:loadTranslationTable{
  ["wuxian"] = "吴苋",
  ["#wuxian"] = "穆皇后",
	["designer:wuxian"] = "wlf元首",
	["cv:wuxian"] = "冯骏骅",
	["illustrator:wuxian"] = "缨尧",

  ["fumian"] = "福绵",
  [":fumian"] = "准备阶段，你可以选择一项：1.本回合下个摸牌阶段摸牌数+1；2.本回合限一次，当你使用红色牌时，可以令此牌目标数+1。若你选择的选项"..
  "与你上回合选择的选项不同，则本回合该选项数值+1。",
  ["daiyan"] = "怠宴",
  [":daiyan"] = "结束阶段，你可以令一名其他角色从牌堆中获得一张<font color='red'>♥</font>基本牌，然后若其是上回合此技能选择的角色，其失去1点体力。",
  ["fumian1"] = "摸牌阶段摸牌数+%arg",
  ["fumian2"] = "使用红色牌目标数+%arg",
  ["@fumian1-turn"] = "福绵 摸牌数+",
  ["@fumian2-turn"] = "福绵 目标数+",
  ["#fumian-choose"] = "福绵：你可以为%arg额外指定%arg2个目标",
  ["#daiyan-choose"] = "怠宴：你可以令一名其他角色摸一张<font color='red'>♥</font>基本牌，若为上回合选择的角色，其失去1点体力",
  ["@@daiyan-tmp"] = "上次怠宴目标",

  ["$fumian1"] = "人言吾吉人天相，福寿绵绵。",
  ["$fumian2"] = "永理二子，当保大汉血脉长存。",
  ["$daiyan1"] = "汝可于宫中多留几日无妨。",
  ["$daiyan2"] = "胡氏受屈，吾亦心不安。",
  ["~wuxian"] = "所幸伴君半生，善始终得善终。",
}

local qinmi = General(extension, "qinmi", "shu", 3)
local jianzhengq = fk.CreateTriggerSkill{
  name = "jianzhengq",
  anim_type = "control",
  events = {fk.TargetSpecifying},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target ~= player and data.card.trueName == "slash" and data.firstTarget and
      not table.contains(AimGroup:getAllTargets(data.tos), player.id) and target:inMyAttackRange(player) and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local card = player.room:askForCard(player, 1, 1, false, self.name, true, ".",
      "#jianzhengq-invoke::"..target.id..":"..data.card:toLogString())
    if #card > 0 then
      self.cost_data = card
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    room:moveCards({
      ids = self.cost_data,
      from = player.id,
      fromArea = Card.PlayerHand,
      toArea = Card.DrawPile,
      moveReason = fk.ReasonJustMove,
      skillName = self.name,
    })
    for _, id in ipairs(TargetGroup:getRealTargets(data.tos)) do
      AimGroup:cancelTarget(data, id)
    end
    if not player.dead and data.card.color ~= Card.Black then
      room:doIndicate(target.id, {player.id})
      AimGroup:addTargets(room, data, player.id)
    end
  end,
}
local zhuandui = fk.CreateTriggerSkill{
  name = "zhuandui",
  mute = true,
  events ={fk.TargetSpecified, fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and data.card.trueName == "slash" and not player:isKongcheng() then
      if event == fk.TargetSpecified then
        return data.to ~= player.id and not player.room:getPlayerById(data.to):isKongcheng()
      else
        return data.from ~= player.id and not player.room:getPlayerById(data.from):isKongcheng()
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local prompt
    if event == fk.TargetSpecified then
      prompt = "zhuandui1-invoke::"..data.to..":"..data.card:toLogString()
    else
      prompt = "zhuandui2-invoke::"..data.from..":"..data.card:toLogString()
    end
    return player.room:askForSkillInvoke(player, self.name, nil, prompt)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(self.name)
    if event == fk.TargetSpecified then
      room:notifySkillInvoked(player, self.name, "offensive")
      room:doIndicate(player.id, {data.to})
      local pindian = player:pindian({room:getPlayerById(data.to)}, self.name)
      if pindian.results[data.to].winner == player then
        data.disresponsiveList = data.disresponsiveList or {}
        table.insert(data.disresponsiveList, data.to)
      end
    else
      room:notifySkillInvoked(player, self.name, "defensive")
      room:doIndicate(player.id, {data.from})
      local pindian = player:pindian({room:getPlayerById(data.from)}, self.name)
      if pindian.results[data.from].winner == player then
        table.insertIfNeed(data.nullifiedTargets, player.id)
      end
    end
  end,
}
local tianbian = fk.CreateTriggerSkill{
  name = "tianbian",
  anim_type = "special",
  events ={fk.StartPindian, fk.PindianCardsDisplayed},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.StartPindian then
        return player == data.from or table.contains(data.tos, player)
      else
        if player == data.from then
          return data.fromCard.suit == Card.Heart
        elseif data.results[player.id] then
          return data.results[player.id].toCard.suit == Card.Heart
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.StartPindian then
      return player.room:askForSkillInvoke(player, self.name, nil, "#tianbian-invoke")
    else
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.StartPindian then
      if player == data.from then
        data.fromCard = Fk:getCardById(player.room.draw_pile[1])
      else
        data.results[player.id] = data.results[player.id] or {}
        data.results[player.id].toCard = Fk:getCardById(player.room.draw_pile[1])
      end
    else
      if player == data.from then
        data.fromCard.number = 13
      elseif data.results[player.id] then
        data.results[player.id].toCard.number = 13
      end
    end
  end,
}
qinmi:addSkill(jianzhengq)
qinmi:addSkill(zhuandui)
qinmi:addSkill(tianbian)
Fk:loadTranslationTable{
  ["qinmi"] = "秦宓",
  ["#qinmi"] = "彻天之舌",
  ["cv:qinmi"] = "曹真",
	["illustrator:qinmi"] = "Thinking",
  ["jianzhengq"] = "谏征",
  [":jianzhengq"] = "其他角色使用【杀】指定其他角色为目标时，若你在其攻击范围内，你可以将一张手牌置于牌堆顶，取消所有目标，然后若此【杀】"..
  "不为黑色，你成为目标。",
  ["zhuandui"] = "专对",
  [":zhuandui"] = "当你使用【杀】指定目标后，你可以与目标拼点：若你赢，其不能响应此【杀】。当你成为【杀】的目标后，你可以与使用者拼点：若你赢，"..
  "此【杀】对你无效。",
  ["tianbian"] = "天辩",
  [":tianbian"] = "当你拼点时，你可以改为用牌堆顶的一张牌进行拼点；当你的拼点牌亮出后，若此牌花色为<font color='red'>♥</font>，则点数视为K。",
  ["#jianzhengq-invoke"] = "谏征：%dest 使用%arg，你可以将一张手牌置于牌堆顶取消所有目标",
  ["zhuandui1-invoke"] = "专对：你可以与 %dest 拼点，若赢，其不能响应此%arg",
  ["zhuandui2-invoke"] = "专对：你可以与 %dest 拼点，若赢，此%arg对你无效",
  ["#tianbian-invoke"] = "天辩：是否用牌堆顶牌拼点？",

  ["$jianzhengq1"] = "且慢，此仗打不得！",
  ["$jianzhengq2"] = "天时不当，必难取胜！",
  ["$zhuandui1"] = "黄口小儿，也敢来班门弄斧？",
  ["$zhuandui2"] = "你已无话可说了吧！",
  ["$tianbian1"] = "当今天子为刘，天亦姓刘！",
  ["$tianbian2"] = "阁下知其然，而未知其所以然。",
  ["~qinmi"] = "我竟然，也百口莫辩了……",
}

local xushi = General(extension, "xushi", "wu", 3, 3, General.Female)
local wengua = fk.CreateActiveSkill{
  name = "wengua",
  anim_type = "support",
  card_num = 1,
  target_num = 0,
  prompt = "#wengua",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isNude()
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local choices = {"Cancel", "Top", "Bottom"}
    local choice = room:askForChoice(player, choices, self.name,
      "#wengua-choice::"..player.id..":"..Fk:getCardById(effect.cards[1]):toLogString())
    if choice == "Cancel" then return end
    local index = 1
    if choice == "Bottom" then
      index = -1
    end
    room:moveCards({
      ids = effect.cards,
      from = player.id,
      toArea = Card.DrawPile,
      moveReason = fk.ReasonJustMove,
      skillName = self.name,
      drawPilePosition = index,
    })
    if player.dead then return end
    if choice == "Top" then
      player:drawCards(1, self.name, "bottom")
      if not player.dead then
        player:drawCards(1, self.name, "bottom")
      end
    else
      player:drawCards(1, self.name)
      if not player.dead then
        player:drawCards(1, self.name)
      end
    end
  end,
}
local wengua_trigger = fk.CreateTriggerSkill{
  name = "#wengua_trigger",

  refresh_events = {fk.GameStart, fk.EventAcquireSkill, fk.EventLoseSkill, fk.Deathed},
  can_refresh = function(self, event, target, player, data)
    if event == fk.GameStart then
      return player:hasSkill(self.name, true)
    elseif event == fk.EventAcquireSkill or event == fk.EventLoseSkill then
      return data == self and not table.find(player.room:getOtherPlayers(player), function(p) return p:hasSkill("wengua", true) end)
    else
      return target == player and player:hasSkill(self.name, true, true) and
        not table.find(player.room:getOtherPlayers(player), function(p) return p:hasSkill("wengua", true) end)
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    if event == fk.GameStart or event == fk.EventAcquireSkill then
      if player:hasSkill(self.name, true) then
        for _, p in ipairs(room:getOtherPlayers(player)) do
          room:handleAddLoseSkills(p, "wengua&", nil, false, true)
        end
      end
    elseif event == fk.EventLoseSkill or event == fk.Deathed then
      for _, p in ipairs(room:getOtherPlayers(player)) do
        room:handleAddLoseSkills(p, "-wengua&", nil, false, true)
      end
    end
  end,
}
local wengua_active = fk.CreateActiveSkill{
  name = "wengua&",
  anim_type = "support",
  card_num = 1,
  target_num = 1,
  prompt = "#wengua&",
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id and Fk:currentRoom():getPlayerById(to_select):hasSkill("wengua")
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local id = effect.cards[1]
    room:obtainCard(target.id, id, false, fk.ReasonGive)
    if room:getCardOwner(id) ~= target or room:getCardArea(id) ~= Card.PlayerHand then return end
    local choices = {"Cancel", "Top", "Bottom"}
    local choice = room:askForChoice(target, choices, "wengua",
      "#wengua-choice::"..player.id..":"..Fk:getCardById(id):toLogString())
    if choice == "Cancel" then return end
    local index = 1
    if choice == "Bottom" then
      index = -1
    end
    room:moveCards({
      ids = effect.cards,
      from = target.id,
      toArea = Card.DrawPile,
      moveReason = fk.ReasonJustMove,
      skillName = "wengua",
      drawPilePosition = index,
    })
    if player.dead then return end
    if choice == "Top" then
      player:drawCards(1, "wengua", "bottom")
      if not target.dead then
        target:drawCards(1, "wengua", "bottom")
      end
    else
      player:drawCards(1, "wengua")
      if not target.dead then
        target:drawCards(1, "wengua")
      end
    end
  end,
}
local fuzhu = fk.CreateTriggerSkill{
  name = "fuzhu",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and target ~= player and target.phase == Player.Finish and
      target.gender == General.Male and #player.room.draw_pile <= 10 * player.hp
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#fuzhu-invoke::"..target.id)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:doIndicate(player.id, {target.id})
    local n = 0
    local cards = table.simpleClone(room.draw_pile)
    for _, id in ipairs(cards) do
      local card = Fk:getCardById(id, true)
      if card.trueName == "slash" then
        room:useCard({
          from = player.id,
          tos = {{target.id}},
          card = card,
        })
        n = n + 1
      end
      if n >= #room.players or player.dead or target.dead then
        break
      end
    end
    room:shuffleDrawPile()
  end,
}
Fk:addSkill(wengua_active)
wengua:addRelatedSkill(wengua_trigger)
xushi:addSkill(wengua)
xushi:addSkill(fuzhu)
Fk:loadTranslationTable{
  ["xushi"] = "徐氏",
  ["wengua"] = "问卦",
  [":wengua"] = "每名角色出牌阶段限一次，其可以交给你一张牌，然后你可以将此牌置于牌堆顶或牌堆底，你与其从另一端摸一张牌。",
  ["fuzhu"] = "伏诛",
  [":fuzhu"] = "一名男性角色结束阶段，若牌堆剩余牌数不大于你体力值的十倍，你可以依次对其使用牌堆中所有的【杀】（不能超过游戏人数），然后洗牌。",
  ["#wengua"] = "问卦：你可以将一张牌置于牌堆顶或牌堆底，从另一端摸两张牌",
  ["#wengua-choice"] = "问卦：你可以将 %arg 置于牌堆顶或牌堆底，然后你与 %dest 从另一端摸一张牌",
  ["wengua&"] = "问卦",
  [":wengua&"] = "出牌阶段限一次，你可以交给徐氏一张牌，然后其可以将此牌置于牌堆顶或牌堆底，其与你从另一端摸一张牌。",
  ["#wengua&"] = "问卦：你可以交给徐氏一张牌，然后其可以将此牌置于牌堆顶或牌堆底，从另一端各摸一张牌",
  ["#fuzhu-invoke"] = "伏诛：你可以对 %dest 使用牌堆中所有【杀】！",

  ["$wengua1"] = "阴阳相生相克，万事周而复始。",
  ["$wengua2"] = "卦不能佳，可须异日。",
  ["$fuzhu1"] = "我连做梦都在等这一天呢。",
  ["$fuzhu2"] = "既然来了，就别想走了。",
  ["~xushi"] = "莫问前程凶吉，但求落幕无悔。",
}

local xuezong = General(extension, "xuezong", "wu", 3)
local funan = fk.CreateTriggerSkill{
  name = "funan",
  anim_type = "control",
  events = {fk.CardUseFinished, fk.CardRespondFinished},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and target ~= player and
      data.responseToEvent and data.responseToEvent.from == player.id then
      if (event == fk.CardUseFinished and data.toCard) or event == fk.CardRespondFinished then
        return data.responseToEvent.card and player.room:getCardArea(data.responseToEvent.card) == Card.Processing
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil,
      "#funan-invoke::"..target.id..":"..data.responseToEvent.card:toLogString()..":"..data.card:toLogString())
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = data.responseToEvent.card
    room:obtainCard(target, card, false, fk.ReasonPrey)
    local cards = type(target:getMark("funan-turn")) == "table" and target:getMark("funan-turn") or {}
    table.insertTable(cards, card:isVirtual() and card.subcards or {card.id})
    room:setPlayerMark(target, "funan-turn", cards)
    if room:getCardArea(data.card) == Card.Processing then
      room:obtainCard(player, data.card, false, fk.ReasonPrey)
    end
  end,
}
local funan_prohibit = fk.CreateProhibitSkill{
  name = "#funan_prohibit",
  prohibit_use = function(self, player, card)
    if type(player:getMark("funan-turn")) == "table" then return table.contains(player:getMark("funan-turn"), card.id) end
  end,
  prohibit_response = function(self, player, card)
    if type(player:getMark("funan-turn")) == "table" then return table.contains(player:getMark("funan-turn"), card.id) end
  end,
}
local jiexun = fk.CreateTriggerSkill{
  name = "jiexun",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local n1 = 0
    for _, p in ipairs(room.alive_players) do
      n1 = n1 + #table.filter(p:getCardIds("ej"), function(id) return Fk:getCardById(id).suit == Card.Diamond end)
    end
    local n2 = player:getMark("@jiexun") + 1
    local to = room:askForChoosePlayers(player, table.map(player.room:getOtherPlayers(player, false), Util.IdMapper),
      1, 1, "#jiexun-choose:::"..n1..":"..n2, self.name, true)
    if #to > 0 then
      self.cost_data = {to[1], n1, n2}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "@jiexun")
    local to = room:getPlayerById(self.cost_data[1])
    local n1, n2 = self.cost_data[2], self.cost_data[3]
    if n1 > 0 then
      to:drawCards(n1, self.name)
    end
    if to:isNude() or to.dead then return end
    local throw = room:askForDiscard(to, n2, n2, true, self.name, false, ".", nil, true)
    local change = (#throw == #to:getCardIds("he"))
    room:throwCard(throw, self.name, to, to)
    if change and not player.dead then
      room:handleAddLoseSkills(player, "-jiexun", nil, true, false)
      if player:hasSkill("funan", true) then
        room:handleAddLoseSkills(player, "-funan|funanEx", nil, false, true)
      end
    end
  end,

  refresh_events = {fk.EventLoseSkill},
  can_refresh = function (self, event, target, player, data)
    return player == target and data == self
  end,
  on_refresh = function (self, event, target, player, data)
    player.room:setPlayerMark(player, "@jiexun", 0)
  end,
}
local funanEx = fk.CreateTriggerSkill{
  name = "funanEx",
  mute = true,
  events = {fk.CardUseFinished, fk.CardRespondFinished},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and target ~= player and
      data.responseToEvent and data.responseToEvent.from == player.id then
      if (event == fk.CardUseFinished and data.toCard) or event == fk.CardRespondFinished then
        return player.room:getCardArea(data.card) == Card.Processing
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#funanEx-invoke::"..target.id..":"..data.card:toLogString())
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke("funan")
    room:notifySkillInvoked(player, "funan", "drawcard")
    room:obtainCard(player, data.card, false, fk.ReasonPrey)
  end,
}
Fk:addSkill(funanEx)
funan:addRelatedSkill(funan_prohibit)
xuezong:addSkill(funan)
xuezong:addSkill(jiexun)
Fk:loadTranslationTable{
  ["xuezong"] = "薛综",
  ["#xuezong"] = "彬彬之玊",
  ["illustrator:xuezong"] = "秋呆呆",
  ["funan"] = "复难",
  [":funan"] = "其他角色使用或打出牌响应你使用的牌时，你可以令其获得你使用的牌（其本回合不能使用或打出这张牌），然后你获得其使用或打出的牌。",
  ["jiexun"] = "诫训",
  [":jiexun"] = "结束阶段，你可令一名其他角色摸等同于场上<font color='red'>♦</font>牌数的牌，然后弃置X张牌（X为本技能发动过的次数），"..
  "若其因此法弃置了所有牌，则你失去〖诫训〗，然后修改〖复难〗（删去“令其获得你使用的牌”）。",
  ["funanEx"] = "复难",
  [":funanEx"] = "其他角色使用或打出牌响应你使用的牌时，你可以获得其使用或打出的牌。",
  ["#funan-invoke"] = "复难：你可以令 %dest 获得你使用的%arg，你获得其使用的%arg2",
  ["#funanEx-invoke"] = "复难：你可以获得 %dest 使用的%arg",
  ["#jiexun-choose"] = "诫训：你可以令一名其他角色摸 %arg 张牌，然后弃置 %arg2 张牌",
  ["@jiexun"] = "诫训",

  ["$funan1"] = "礼尚往来，乃君子风范。",
  ["$funan2"] = "以子之矛，攻子之盾。",
  ["$jiexun1"] = "帝王应以社稷为重，以大观为主。",
  ["$jiexun2"] = "吾冒昧进谏，只求陛下思虑。",
  ["~xuezong"] = "尔等，竟做如此有辱斯文之事。",
}

local caojie = General(extension, "caojie", "qun", 3, 3, General.Female)
local shouxi = fk.CreateTriggerSkill{
  name = "shouxi",
  events = {fk.TargetConfirmed},
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card.trueName == "slash"
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local mark = type(player:getMark("@$shouxi")) == "table" and player:getMark("@$shouxi") or {}
    local names = {}
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id)
      if card.type ~= Card.TypeEquip and not card.is_derived and not table.contains(mark, card.trueName) then
        table.insertIfNeed(names, card.trueName)
      end
    end
    if #names > 0 then
      if room:askForSkillInvoke(player, self.name) then
        local choice = room:askForChoice(player, names, self.name)
        self.cost_data = choice
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local name = self.cost_data
    local mark = type(player:getMark("@$shouxi")) == "table" and player:getMark("@$shouxi") or {}
    table.insert(mark, name)
    room:setPlayerMark(player, "@$shouxi", mark)
    local from = room:getPlayerById(data.from)
    if #room:askForDiscard(from, 1, 1, false, self.name, true, name, "#shouxi-discard::"..player.id..":"..name) == 0 then
      table.insertIfNeed(data.nullifiedTargets, player.id)
    elseif not player:isNude() then
      local card = room:askForCardChosen(from, player, "he", self.name)
      room:obtainCard(from, card, false, fk.ReasonPrey)
    end
  end,
}
caojie:addSkill(shouxi)
local huimin = fk.CreateTriggerSkill{
  name = "huimin",
  events = {fk.EventPhaseStart},
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish and
    table.find(player.room.alive_players, function(p) return p:getHandcardNum() < p.hp end)
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local n = #table.filter(room.alive_players, function(p) return p:getHandcardNum() < p.hp end)
    return room:askForSkillInvoke(player, self.name, nil, "#huimin-invoke:::"..n)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local players = table.filter(room.alive_players, function(p) return p:getHandcardNum() < p.hp end)
    player:drawCards(#players, self.name)
    if player:isKongcheng() then return false end
    local cards = room:askForCard(player, #players, #players, false, self.name, false, ".", "#huimin-show:::"..#players)
    player:showCards(cards)
    local tos = room:askForChoosePlayers(player, table.map(players, Util.IdMapper), 1, 1, "#huimin-choose", self.name, false)
    local temp = room:getPlayerById(tos[1])
    table.forEach(room.players, function(p) room:fillAG(p, cards) end)
    while #cards > 0 and #players > 0 do
      if table.contains(players, temp) then
        table.removeOne(players, temp)
        local chosen = room:askForAG(temp, cards, false, self.name)
        room:takeAG(temp, chosen, room.players)
        room:obtainCard(temp, chosen, true, fk.ReasonPrey)
        table.removeOne(cards, chosen)
        cards = table.filter(cards, function(id) return room:getCardOwner(id) == player and room:getCardArea(id) == Card.PlayerHand end)
      end
      temp = temp.next
    end
    table.forEach(room.players, function(p) room:closeAG(p) end)
  end,
}
caojie:addSkill(huimin)
Fk:loadTranslationTable{
  ["caojie"] = "曹节",
  ["#caojie"] = "献穆皇后",
  ["designer:caojie"] = "会智迟的沮授",
  ["cv:caojie"] = "醋醋", -- 文晓依
	["illustrator:caojie"] = "小小鸡仔",

  ["shouxi"] = "守玺",
  [":shouxi"] = "当你成为【杀】的目标后，你可声明一种未以此法声明过的基本牌或锦囊牌的牌名，然后使用者选择一项：弃置一张你声明的牌，然后"..
  "获得你的一张牌；或令此【杀】对你无效。",
  ["@$shouxi"] = "守玺",
  ["#shouxi-discard"] = "守玺：1.弃置一张%arg并获得%dest一张牌2.此【杀】对%dest无效",

  ["huimin"] = "惠民",
  [":huimin"] = "结束阶段开始时，你可以摸X张牌（X为手牌数小于体力值的角色数），然后展示等量的手牌，从你指定的一名角色开始，这些角色依次获得其中一张。",
  ["#huimin-invoke"] = "惠民：摸%arg张牌，再展示等量手牌，令手牌数小于体力值的角色获得",
  ["#huimin-choose"] = "惠民：指定第一个选牌的角色",
  ["#huimin-show"] = "惠民：请展示%arg张手牌，从你指定的角色开始，手牌数小于体力值的角色依次获得其中一张",

  ["$shouxi1"] = "天子之位，乃归刘汉！",
  ["$shouxi2"] = "吾父功盖寰区，然且不敢篡窃神器。",
  ["$huimin1"] = "悬壶济世，施医救民。",
  ["$huimin2"] = "心系百姓，惠布山阳。",
  ["~caojie"] = "皇天必不祚尔。",
}

local caiyong = General(extension, "caiyong", "qun", 3, 3)
local pizhuan = fk.CreateTriggerSkill{
  name = "pizhuan",
  anim_type = "special",
  events = {fk.CardUsing, fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and data.card.suit == Card.Spade and #player:getPile("caiyong_book") < 4 then
      return event == fk.CardUsing or data.from ~= player.id
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:addToPile("caiyong_book", room:getNCards(1)[1], true, self.name)
  end,
}
local pizhuan_maxcards = fk.CreateMaxCardsSkill{
  name = "#pizhuan_maxcards",
  correct_func = function(self, player)
    if player:hasSkill(self) then
      return #player:getPile("caiyong_book")
    end
  end,
}
pizhuan:addRelatedSkill(pizhuan_maxcards)
caiyong:addSkill(pizhuan)
local tongbo = fk.CreateTriggerSkill{
  name = "tongbo",
  anim_type = "special",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Draw and #player:getPile("caiyong_book") > 0
      and not player:isNude()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local piles = room:askForExchange(player, {player:getPile("caiyong_book"), player:getCardIds("he")},
      {"caiyong_book", player.general}, self.name)
    local cards1, cards2 = {}, {}
    for _, id in ipairs(piles[1]) do
      if room:getCardArea(id) == Player.Hand or room:getCardArea(id) == Player.Equip then
        table.insert(cards1, id)
      end
    end
    for _, id in ipairs(piles[2]) do
      if room:getCardArea(id) == Card.PlayerSpecial then
        table.insert(cards2, id)
      end
    end
    room:moveCards(
      {
        ids = cards2,
        from = player.id,
        to = player.id,
        fromArea = Card.PlayerSpecial,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonExchange,
        proposer = player.id,
        specialName = "caiyong_book",
        skillName = self.name,
      },
      {
        ids = cards1,
        from = player.id,
        to = player.id,
        fromArea = Card.PlayerHand,
        toArea = Card.PlayerSpecial,
        moveReason = fk.ReasonExchange,
        proposer = player.id,
        specialName = "caiyong_book",
        skillName = self.name,
      }
    )
    local suits = {}
    for _, id in ipairs(player:getPile("caiyong_book")) do
      table.insertIfNeed(suits, Fk:getCardById(id).suit)
    end
    if #suits ~= 4 then return false end
    local moveInfos = {}
    local cards = table.simpleClone(player:getPile("caiyong_book"))
    for _, id in ipairs(cards) do room:setCardMark(Fk:getCardById(id), self.name, 1) end
    while #cards > 0 do
      local _, ret = room:askForUseActiveSkill(player, "tongbo_active", "#tongbo-give", false, data, true)
      local to, give_cards
      if ret then
        give_cards = ret.cards
        to =  ret.targets[1]
      else
        give_cards = cards
        to = table.random(table.map(room:getOtherPlayers(player), Util.IdMapper))
      end
      room:getCardArea(give_cards[1])
      for _, id in ipairs(give_cards) do
        table.removeOne(cards, id)
        room:setCardMark(Fk:getCardById(id), self.name, 0)
      end
      table.insert(moveInfos, {
        ids = give_cards,
        from = player.id,
        fromArea = Card.PlayerSpecial,
        to = to,
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonJustMove,
        proposer = player.id,
        specialName = "caiyong_book",
        skillName = self.name,
      })
    end
    room:moveCards(table.unpack(moveInfos))
  end,
}
caiyong:addSkill(tongbo)
local tongbo_active = fk.CreateActiveSkill{
  name = "tongbo_active",
  mute = true,
  min_card_num = 1,
  target_num = 1,
  expand_pile = "caiyong_book",
  card_filter = function(self, to_select)
    return Self:getPileNameOfId(to_select) == "caiyong_book" and Fk:getCardById(to_select):getMark("tongbo") > 0
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
}
Fk:addSkill(tongbo_active)
Fk:loadTranslationTable{
  ["caiyong"] = "蔡邕",
  ["#caiyong"] = "大鸿儒",
  ["illustrator:caiyong"] = "Town",

  ["pizhuan"] = "辟撰",
  [":pizhuan"] = "当你使用♠牌时，或你成为其他角色使用♠牌的目标后，你可以将牌堆顶的一张牌置于武将牌上，称为“书”；你至多拥有四张“书”，你的手牌上限+X"..
  "（X为“书”的数量）。",
  ["caiyong_book"] = "书",

  ["tongbo"] = "通博",
  [":tongbo"] = "摸牌阶段结束时，你可以用任意张牌替换等量的“书”，然后若你的“书”包含四种花色，你须将所有“书”分配给任意名其他角色。 ",
  ["#tongbo-exchange"] = "通博：你可以用任意张牌替换等量的“书”",
  ["#tongbo-give"] = "通博：你须将所有“书”分配给任意名其他角色",
  ["tongbo_active"] = "通博",

  ["$pizhuan1"] = "无墨不成书，无识不成才。",
  ["$pizhuan2"] = "笔可抒情，亦可诛心。",
  ["$tongbo1"] = "读万卷书，行万里路。",
  ["$tongbo2"] = "博学而不穷，笃行而不倦。",
  ["~caiyong"] = "感叹世事，何罪之有？",
}

return extension

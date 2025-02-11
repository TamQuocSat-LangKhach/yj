local extension = Package("yjcm2015")
extension.extensionName = "yj"

local U = require "packages/utility/utility"

Fk:loadTranslationTable{
  ["yjcm2015"] = "一将成名2015",
}

local caorui = General(extension, "caorui", "wei", 3)
local huituo = fk.CreateTriggerSkill{
  name = "huituo",
  anim_type = "masochism",
  events = {fk.Damaged},
  on_cost = function(self, event, target, player, data)
    local to = player.room:askForChoosePlayers(player, table.map(player.room:getAlivePlayers(), Util.IdMapper),
      1, 1, "#huituo-choose", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    local judge = {
      who = to,
      reason = self.name,
      pattern = ".",
    }
    room:judge(judge)
    if judge.card.color == Card.Red then
      if to:isWounded() then
        room:recover({
          who = to,
          num = 1,
          recoverBy = player,
          skillName = self.name
        })
      end
    elseif judge.card.color == Card.Black then
      to:drawCards(data.damage, self.name)
    end
  end,
}
local mingjian = fk.CreateActiveSkill{
  name = "mingjian",
  anim_type = "support",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return not player:isKongcheng() and player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:moveCardTo(player.player_cards[Player.Hand], Player.Hand, target, fk.ReasonGive, self.name, nil, false, player.id)
    room:addPlayerMark(target, "@@" .. self.name, 1)
  end,
}
local mingjian_record = fk.CreateTriggerSkill{
  name = "#mingjian_record",

  refresh_events = {fk.TurnStart},
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@mingjian") > 0 and target == player
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "@@mingjian-turn", player:getMark("@@mingjian"))
    room:addPlayerMark(player, MarkEnum.AddMaxCardsInTurn, player:getMark("@@mingjian"))
    room:setPlayerMark(player, "@@mingjian", 0)
  end,
}
local mingjian_targetmod = fk.CreateTargetModSkill{
  name = "#mingjian_targetmod",
  residue_func = function(self, player, skill, scope)
    if skill.trueName == "slash_skill" and player:getMark("@@mingjian-turn") > 0 and scope == Player.HistoryPhase then
      return player:getMark("@@mingjian-turn")
    end
  end,
}
local xingshuai = fk.CreateTriggerSkill{
  name = "xingshuai$",
  anim_type = "defensive",
  frequency = Skill.Limited,
  events = {fk.EnterDying},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player:usedSkillTimes(self.name, Player.HistoryGame) == 0 and
      not table.every(player.room:getOtherPlayers(player), function(p) return p.kingdom ~= "wei" end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if p.kingdom == "wei" and room:askForSkillInvoke(p, self.name, data, "#xingshuai-invoke::"..player.id) then
        table.insert(targets, p)
      end
    end
    if #targets > 0 then
      for _, p in ipairs(targets) do
        if player.dead or not player:isWounded() then break end
        room:recover{
          who = player,
          num = 1,
          recoverBy = p,
          skillName = self.name
        }
      end
    end
    if not player.dying then
      for _, p in ipairs(targets) do
        room:damage{
          to = p,
          damage = 1,
          skillName = self.name,
        }
      end
    end
  end,
}
mingjian:addRelatedSkill(mingjian_record)
mingjian:addRelatedSkill(mingjian_targetmod)
caorui:addSkill(huituo)
caorui:addSkill(mingjian)
caorui:addSkill(xingshuai)
Fk:loadTranslationTable{
  ["caorui"] = "曹叡",
  ["#caorui"] = "天姿的明君",
  ["designer:caorui"] = "Ptolemy_M7",
  ["illustrator:caorui"] = "Thinking",
  ["huituo"] = "恢拓",
  [":huituo"] = "当你受到伤害后，你可以令一名角色进行判定，若结果为：红色，其回复1点体力；黑色，其摸X张牌（X为伤害值）。",
  ["mingjian"] = "明鉴",
  [":mingjian"] = "出牌阶段限一次，你可以将所有手牌交给一名其他角色，然后该角色下回合的手牌上限+1，且出牌阶段内可以多使用一张【杀】。",
  ["xingshuai"] = "兴衰",
  [":xingshuai"] = "主公技，限定技，当你进入濒死状态时，你可令其他魏势力角色依次选择是否令你回复1点体力。选择是的角色在此次濒死结算结束后"..
  "受到1点无来源的伤害。",
  ["#huituo-choose"] = "恢拓：你可以令一名角色判定，若为红色，其回复1点体力；黑色，其摸X张牌",
  ["@@mingjian"] = "明鉴",
  ["@@mingjian-turn"] = "明鉴",
  ["#xingshuai-invoke"] = "兴衰：你可以令%dest回复1点体力，结算后你受到1点伤害",

  ["$huituo1"] = "大展宏图，就在今日！",
  ["$huituo2"] = "富我大魏，扬我国威！",
  ["$mingjian1"] = "你我推心置腹，岂能相负。",
  ["$mingjian2"] = "孰忠孰奸，朕尚能明辨！",
  ["$xingshuai1"] = "百年兴衰皆由人，不由天！",
  ["$xingshuai2"] = "聚群臣而嘉勋，隆天子之气运！",
  ["~caorui"] = "悔不该耽于逸乐，至有今日……",
}

local nos__caoxiu = General(extension, "nos__caoxiu", "wei", 4)
local nos__taoxi = fk.CreateTriggerSkill{
  name = "nos__taoxi",
  anim_type = "offensive",
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Play and data.to ~= player.id and
      #AimGroup:getAllTargets(data.tos) == 1 and
      not player.room:getPlayerById(data.to):isKongcheng() and
      player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askForSkillInvoke(player, self.name, nil, "#nos__taoxi-invoke::"..data.to) then
      self.cost_data = {tos = {data.to}}
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(data.to)
    local card = room:askForCardChosen(player, to, "h", self.name, "#nos__taoxi-choose::"..data.to)
    room:setCardMark(Fk:getCardById(card), "@@nos__taoxi-inhand-turn", 1)
    to:showCards(card)
  end,
}
local nos__taoxi_delay = fk.CreateTriggerSkill{
  name = "#nos__taoxi_delay",
  anim_type = "negative",
  events = {fk.TurnEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:usedSkillTimes("nos__taoxi", Player.HistoryTurn) > 0 and not player.dead and
      table.find(player.room:getOtherPlayers(player), function (p)
        return table.find(p:getCardIds("h"), function (id)
          return Fk:getCardById(id):getMark("@@nos__taoxi-inhand-turn") > 0
        end) ~= nil
      end)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:loseHp(player, 1, "nos__taoxi")
  end,
}
local nos__taoxi_filter = fk.CreateFilterSkill{
  name = "#nos__taoxi_filter",
  handly_cards = function (self, player)
    if player:usedSkillTimes("nos__taoxi", Player.HistoryTurn) > 0 then
      local ids = {}
      for _, p in ipairs(Fk:currentRoom().alive_players) do
        for _, id in ipairs(p:getCardIds("h")) do
          if Fk:getCardById(id):getMark("@@nos__taoxi-inhand-turn") > 0 then
            table.insertIfNeed(ids, id)
          end
        end
      end
      return ids
    end
  end,
}
nos__taoxi:addRelatedSkill(nos__taoxi_delay)
nos__taoxi:addRelatedSkill(nos__taoxi_filter)
nos__caoxiu:addSkill(nos__taoxi)
Fk:loadTranslationTable{
  ["nos__caoxiu"] = "曹休",
  ["#nos__caoxiu"] = "千里骐骥",
  ["designer:nos__caoxiu"] = "蹩脚狐小三",
  ["illustrator:nos__caoxiu"] = "eshao111",

  ["nos__taoxi"] = "讨袭",
  [":nos__taoxi"] = "出牌阶段限一次，当你使用牌仅指定一名其他角色为目标后，你可以亮出其一张手牌直到回合结束，并且你可以于此回合内将此牌"..
  "如手牌般使用或打出。回合结束时，若该角色未失去此手牌，则你失去1点体力。",
  ["#nos__taoxi-invoke"] = "讨袭：你可以亮出 %dest 一张手牌，本回合你可以使用或打出此牌",
  ["#nos__taoxi-choose"] = "讨袭：展示%dest一张手牌",
  ["@@nos__taoxi-inhand-turn"] = "讨袭",
  ["#nos__taoxi_delay"] = "讨袭",
  ["#nos__taoxi_filter"] = "讨袭",

  ["$nos__taoxi1"] = "策马疾如电，溃敌一瞬间。",
  ["$nos__taoxi2"] = "虎豹骑岂能徒有虚名？杀！",
  ["~nos__caoxiu"] = "兵行险招，终有一失。",
}

local caoxiu = General(extension, "caoxiu", "wei", 4)
local qianju = fk.CreateDistanceSkill{
  name = "qianju",
  correct_func = function(self, from, to)
    if from:hasSkill(self) then
      return -from:getLostHp()
    end
  end,
}
local qingxi = fk.CreateTriggerSkill{
  name = "qingxi",
  anim_type = "offensive",
  events = {fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.card and data.card.trueName == "slash"
      and data.to and player:getEquipment(Card.SubtypeWeapon)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = Fk:getCardById(player:getEquipment(Card.SubtypeWeapon)):getAttackRange(player)
    if #data.to.player_cards[Player.Hand] < n then
      data.damage = data.damage + 1
      return
    end
    if #room:askForDiscard(data.to, n, n, false, self.name, true, ".", "#qingxi-discard:::"..n) == n then
      room:throwCard({player:getEquipment(Card.SubtypeWeapon)}, self.name, player, data.to)
    else
      data.damage = data.damage + 1
    end
  end,
}
caoxiu:addSkill(qianju)
caoxiu:addSkill(qingxi)
Fk:loadTranslationTable{
  ["caoxiu"] = "曹休",
  ["#caoxiu"] = "千里骐骥",
  ["illustrator:caoxiu"] = "NOVAR", -- 皮肤 下辩扬威
  ["designer:caoxiu"] = "Roc",

  ["qianju"] = "千驹",
  [":qianju"] = "锁定技，你计算与其他角色的距离-X。（X为你已损失的体力值）",
  ["qingxi"] = "倾袭",
  [":qingxi"] = "当你使用【杀】造成伤害时，若你装备区内有武器牌，你可以令该角色选择一项：1.弃置X张手牌，然后弃置你的武器牌；2.令此【杀】伤害+1"..
  "（X为该武器的攻击范围）。",
  ["#qingxi-discard"] = "倾袭：你需弃置%arg张手牌，否则伤害+1",

  ["$qingxi1"] = "策马疾如电，溃敌一瞬间。",
  ["$qingxi2"] = "虎豹骑岂能徒有虚名？杀！",
  ["~caoxiu"] = "兵行险招，终有一失。",
}

local zhongyao = General(extension, "zhongyao", "wei", 3)
local huomo = fk.CreateViewAsSkill{
  name = "huomo",
  pattern = ".|.|.|.|.|basic",
  prompt = "#huomo",
  interaction = function(self)
    local all_names = U.getAllCardNames("b")
    local names = U.getViewAsCardNames(Self, self.name, all_names, nil, Self:getTableMark("huomo-turn"))
    if #names == 0 then return end
    return U.CardNameBox {choices = names, all_names = all_names}
  end,
  card_filter = function (self, to_select, selected)
    local card = Fk:getCardById(to_select)
    return #selected == 0 and card.type ~= Card.TypeBasic and card.color == Card.Black
  end,
  before_use = function (self, player, use)
    local room = player.room
    local put = use.card:getMark(self.name)
    if put ~= 0 and table.contains(player:getCardIds("he"), put) then
      room:moveCards({
        ids = {put},
        from = player.id,
        toArea = Card.DrawPile,
        moveReason = fk.ReasonPut,
        skillName = self.name,
        proposer = player.id,
        moveVisible = true,
      })
    end
  end,
  view_as = function(self, cards)
    if not self.interaction.data or #cards ~= 1 then return end
    local card = Fk:cloneCard(self.interaction.data)
    card:setMark(self.name, cards[1])
    card.skillName = self.name
    return card
  end,
  enabled_at_play = function(self, player)
    return not player:isNude()
  end,
  enabled_at_response = function(self, player, response)
    return not response and not player:isNude()
  end,

  on_acquire = function (self, player, is_start)
    if not is_start then
      local room = player.room
      local names = {}
      room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
        local use = e.data[1]
        if use.from == player.id and use.card.type == Card.TypeBasic then
          table.insertIfNeed(names, use.card.trueName)
        end
      end, Player.HistoryTurn)
      room:setPlayerMark(player, "huomo-turn", names)
    end
  end,
}
local huomo_trigger = fk.CreateTriggerSkill{
  name = "#huomo_trigger",

  refresh_events = {fk.AfterCardUseDeclared},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill("huomo", true)
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addTableMark(player, "huomo-turn", data.card.trueName)
  end,
}
huomo:addRelatedSkill(huomo_trigger)
zhongyao:addSkill(huomo)
local zuoding = fk.CreateTriggerSkill{
  name = "zuoding",
  anim_type = "drawcard",
  events = {fk.TargetSpecified},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) and target ~= player and target.phase == Player.Play and data.firstTarget
    and data.card.suit == Card.Spade
    and table.find(AimGroup:getAllTargets(data.tos), function(pid) return not player.room:getPlayerById(pid).dead end) then
      return #player.room.logic:getActualDamageEvents(1, Util.TrueFunc, Player.HistoryPhase) == 0
    end
  end,
  on_cost = function(self, event, target, player, data)
    local targets = table.filter(AimGroup:getAllTargets(data.tos), function(pid) return not player.room:getPlayerById(pid).dead end)
    local to = player.room:askForChoosePlayers(player, targets, 1, 1, "#zuoding-choose", self.name, true)
    if #to > 0 then
      self.cost_data = to[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:getPlayerById(self.cost_data):drawCards(1, self.name)
  end,
}
zhongyao:addSkill(zuoding)
Fk:loadTranslationTable{
  ["zhongyao"] = "钟繇",
  ["#zhongyao"] = "正楷萧曹",
  ["designer:zhongyao"] = "怀默",
  ["illustrator:zhongyao"] = "eshao111",
  ["huomo"] = "活墨",
  [":huomo"] = "当你需要使用基本牌时（你本回合使用过的基本牌除外），你可以将一张黑色非基本牌置于牌堆顶，视为使用此基本牌。",
  ["zuoding"] = "佐定",
  [":zuoding"] = "当其他角色于其出牌阶段内使用♠牌指定目标后，若本阶段没有角色受到过伤害，你可以令其中一名目标角色摸一张牌。",
  ["#huomo"] = "活墨：将一张黑色非基本牌置于牌堆顶，视为使用一张基本牌",
  ["#zuoding-choose"] = "佐定：你可以令一名目标角色摸一张牌",

  ["$huomo1"] = "笔墨写春秋，挥毫退万敌！",
  ["$huomo2"] = "妙笔在手，研墨在心。",
  ["$zuoding1"] = "只有忠心，没有谋略，是不够的。",
  ["$zuoding2"] = "承君恩宠，报效国家！",
  ["~zhongyao"] = "墨尽，岁终。",
}

local liuchen = General(extension, "liuchen", "shu", 4)
local zhanjue = fk.CreateViewAsSkill{
  name = "zhanjue",
  anim_type = "offensive",
  card_num = 0,
  min_target_num = 1,
  prompt = "#zhanjue",
  card_filter = function(self, to_select, selected)
    return false
  end,
  -- target_filter = function(self, to_select, selected, selected_cards)
  --   local card = Fk:cloneCard("duel")
  --   card:addSubcards(Self:getCardIds(Player.Hand))
  --   return Self:canUseTo(card, Fk:currentRoom():getPlayerById(to_select))
  -- end,
  view_as = function(self, cards)
    local card = Fk:cloneCard("duel")
    card:addSubcards(Self:getCardIds(Player.Hand))
    return card
  end,
  after_use = function(self, player, use)
    local room = player.room
    if not player.dead then
      player:drawCards(1, "zhanjue")
      room:addPlayerMark(player, "zhanjue-phase", 1)
    end
    if use.damageDealt then
      for _, p in ipairs(room.alive_players) do
        if use.damageDealt[p.id] then
          p:drawCards(1, "zhanjue")
          if p == player then
            room:addPlayerMark(player, "zhanjue-phase", 1)
          end
        end
      end
    end
  end,
  enabled_at_play = function(self, player)
    return player:getMark("zhanjue-phase") < 2 and not player:isKongcheng()
  end
}
local qinwang = fk.CreateViewAsSkill{
  name = "qinwang$",
  prompt = "#qinwang",
  mute = true,
  anim_type = "defensive",
  pattern = "slash",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and not Self:prohibitDiscard(Fk:getCardById(to_select))
  end,
  before_use = function(self, player, use)
    local room = player.room
    if use.card.extra_data and type(use.card.extra_data.qinwangCards) == "table" and #use.card.extra_data.qinwangCards > 0 then
      room:notifySkillInvoked(player, self.name)
      player:broadcastSkillInvoke(self.name)
      room:throwCard(use.card.extra_data.qinwangCards, self.name, player, player)
      if use.tos then
        room:doIndicate(player.id, TargetGroup:getRealTargets(use.tos))
      end

      for _, p in ipairs(room:getOtherPlayers(player)) do
        if p.kingdom == "shu" then
          local cardResponded = room:askForResponse(p, "slash", "slash", "#qinwang-ask:" .. player.id, true)
          if cardResponded then
            room:responseCard({
              from = p.id,
              card = cardResponded,
              skipDrop = true,
            })

            use.card = cardResponded
            use.extra_data = use.extra_data or {}
            use.extra_data.qinwangUser = p.id
            return
          end
        end
      end

      room:setPlayerMark(player, "qinwang-failed-phase", 1)
    end
    return self.name
  end,
  after_use = function(self, player, use)
    if use.extra_data and use.extra_data.qinwangUser then
      local p = player.room:getPlayerById(use.extra_data.qinwangUser)
      if p and not p.dead then
        p:drawCards(1, self.name)
      end
    end
  end,
  view_as = function(self, cards)
    if #cards < 1 then return end
    local c = Fk:cloneCard("slash")
    c.skillName = self.name
    c.extra_data = c.extra_data or {}
    c.extra_data.qinwangCards = cards
    return c
  end,
  enabled_at_play = function(self, player)
    return player:getMark("qinwang-failed-phase") == 0 and not player:isNude() and
      table.find(Fk:currentRoom().alive_players, function(p) return p ~= player and p.kingdom == "shu" end)
  end,
  enabled_at_response = function(self, player)
    return player:getMark("qinwang-failed-phase") == 0 and not player:isNude() and
      table.find(Fk:currentRoom().alive_players, function(p) return p ~= player and p.kingdom == "shu" end)
  end,
}
liuchen:addSkill(zhanjue)
liuchen:addSkill(qinwang)
Fk:loadTranslationTable{
  ["liuchen"] = "刘谌",
  ["#liuchen"] = "血荐轩辕",
  ["designer:liuchen"] = "列缺霹雳",
  ["illustrator:liuchen"] = "凌天翼&depp",
  ["zhanjue"] = "战绝",
  [":zhanjue"] = "出牌阶段，你可以将所有手牌当【决斗】使用，然后你和受伤的角色各摸一张牌。若你此法摸过两张或更多的牌，则本阶段〖战绝〗失效。",
  ["qinwang"] = "勤王",
  [":qinwang"] = "主公技，当你需要使用或打出【杀】时，你可以弃置一张牌，然后令其他蜀势力角色选择是否打出一张【杀】（视为由你使用或打出）。"..
  "若有角色响应，该角色摸一张牌。",
  ["#qinwang-ask"] = "勤王: 你可打出一张【杀】，视为 %src 使用或打出，若如此做，你摸一张牌",
  ["#zhanjue"] = "战绝：你可以将所有手牌当【决斗】使用，然后你和受伤的角色各摸一张牌",
  ["#qinwang"] = "勤王：你可以弃置一张牌，然后令其他蜀势力角色选择是否打出一张【杀】（视为由你使用或打出）",

  ["$zhanjue1"] = "成败在此一举，杀！",
  ["$zhanjue2"] = "此刻，唯有死战，安能言降！",
  ["$qinwang1"] = "大厦倾危，谁堪栋梁！",
  ["$qinwang2"] = "国有危难，哪位将军请战？",
  ["~liuchen"] = "无言对百姓，有愧，见先祖……",
}

local xiahoushi = General(extension, "xiahoushi", "shu", 3, 3, General.Female)
local qiaoshi = fk.CreateTriggerSkill{
  name = "qiaoshi",
  anim_type = "support",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(self) and target.phase == Player.Finish and not target.dead and
      player:getHandcardNum() == target:getHandcardNum()
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askForSkillInvoke(player, self.name, nil, "#qiaoshi-invoke::"..target.id)
  end,
  on_use = function(self, event, target, player, data)
    target:drawCards(1, self.name)
    if not player.dead then
      player:drawCards(1, self.name)
    end
  end,
}
local yanyu = fk.CreateActiveSkill{
  name = "yanyu",
  anim_type = "drawcard",
  card_num = 1,
  target_num = 0,
  can_use = function(self, player)
    return not player:isKongcheng()
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).trueName == "slash"
  end,
  on_use = function(self, room, effect)
    room:recastCard(effect.cards, room:getPlayerById(effect.from), self.name)
  end,
}
local yanyu_record = fk.CreateTriggerSkill{
  name = "#yanyu_record",
  anim_type = "support",
  events = {fk.EventPhaseEnd},
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == player.Play and player:usedSkillTimes("yanyu", Player.HistoryPhase) > 1 and
      not table.every(player.room:getOtherPlayers(player), function(p) return p.gender ~= General.Male end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:askForChoosePlayers(player, table.map(table.filter(room:getAlivePlayers(), function(p)
      return p:isMale() end), Util.IdMapper), 1, 1, "#yanyu-draw", self.name, true)
    if #to > 0 then
      self.cost_data = room:getPlayerById(to[1])
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    self.cost_data:drawCards(2, "yanyu")
  end,
}
yanyu:addRelatedSkill(yanyu_record)
xiahoushi:addSkill(qiaoshi)
xiahoushi:addSkill(yanyu)
Fk:loadTranslationTable{
  ["xiahoushi"] = "夏侯氏",
  ["#xiahoushi"] = "采缘撷睦",
  ["designer:xiahoushi"] = "淬毒",
  ["illustrator:xiahoushi"] = "2B铅笔",
  ["qiaoshi"] = "樵拾",
  [":qiaoshi"] = "其他角色的结束阶段，若其手牌数等于你，你可以与其各摸一张牌。",
  ["yanyu"] = "燕语",
  [":yanyu"] = "出牌阶段，你可以重铸【杀】；出牌阶段结束时，若你于此阶段内重铸过两张或更多的【杀】，则你可以令一名男性角色摸两张牌。",
  ["#qiaoshi-invoke"] = "樵拾：你可以与 %dest 各摸一张牌",
  ["#yanyu_record"] = "燕语",
  ["#yanyu-draw"] = "燕语：你可以令一名男性角色摸两张牌",

  ["~xiahoushi"] = "愿有来世，不负前缘……",
  ["$qiaoshi1"] = "樵前情窦开，君后寻迹来。",
  ["$qiaoshi2"] = "樵心遇郎君，妾心涟漪生。",
  ["$yanyu1"] = "伴君一生不寂寞。",
  ["$yanyu2"] = "感君一回顾，思君朝与暮。",
}

local zhangyi = General(extension, "zhangyi", "shu", 4)
local wurong = fk.CreateActiveSkill{
  name = "wurong",
  anim_type = "offensive",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return not player:isKongcheng() and player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected)
    return false
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local fromCard = room:askForCard(player, 1, 1, false, self.name, false, ".", "#wurong-show")[1]
    local toCard = room:askForCard(target, 1, 1, false, self.name, false, ".", "#wurong-show")[1]
    player:showCards(fromCard)
    target:showCards(toCard)
    if Fk:getCardById(fromCard).trueName == "slash" and Fk:getCardById(toCard).name ~= "jink" then
      room:throwCard({fromCard}, self.name, player, player)
      room:damage{
        from = player,
        to = target,
        damage = 1,
        skillName = self.name,
      }
    end
    if Fk:getCardById(fromCard).trueName ~= "slash" and Fk:getCardById(toCard).name == "jink" then
      room:throwCard({fromCard}, self.name, player, player)
      local id = room:askForCardChosen(player, target, "he", self.name)
      room:obtainCard(player, id, false)
    end
  end,
}
local shizhi = fk.CreateFilterSkill{
  name = "shizhi",
  card_filter = function(self, to_select, player)
    return player:hasSkill(self) and player.hp == 1 and to_select.name == "jink" and
    table.contains(player.player_cards[Player.Hand], to_select.id)
  end,
  view_as = function(self, to_select)
    return Fk:cloneCard("slash", to_select.suit, to_select.number)
  end,
}
local shizhi_trigger = fk.CreateTriggerSkill{
  name = "#shizhi_trigger",
  refresh_events = {fk.HpChanged, fk.MaxHpChanged},
  can_refresh = function(self, event, target, player, data)
    return player == target and player:hasSkill(shizhi, true)
  end,
  on_refresh = function(self, event, target, player, data)
    player:filterHandcards()
  end,
}
shizhi:addRelatedSkill(shizhi_trigger)
zhangyi:addSkill(wurong)
zhangyi:addSkill(shizhi)
Fk:loadTranslationTable{
  ["zhangyi"] = "张嶷",
  ["#zhangyi"] = "通壮逾古",
  ["designer:zhangyi"] = "XYZ",
  ["illustrator:zhangyi"] = "livsinno",
  ["wurong"] = "怃戎",
  [":wurong"] = "出牌阶段限一次，你可以和一名其他角色同时展示一张手牌：若你展示的是【杀】且该角色不是【闪】，你弃置此【杀】，然后对其造成1点伤害；"..
  "若你展示的不是【杀】且该角色是【闪】，你弃置此牌，然后获得其一张牌。",
  ["shizhi"] = "矢志",
  [":shizhi"] = "锁定技，若你的体力值为1，你的【闪】视为【杀】。",
  ["#wurong-show"] = "怃戎：选择一张展示的手牌",

  ["$wurong1"] = "兵不血刃，亦可先声夺人。",
  ["$wurong2"] = "从则安之，犯则诛之。",
  ["~zhangyi"] = "大丈夫当战死沙场，马革裹尸而还。",
}

local quancong = General(extension, "quancong", "wu", 4)
local zhenshan = fk.CreateViewAsSkill{
  name = "zhenshan",
  pattern = ".|.|.|.|.|basic",
  interaction = function(self)
    local all_names = U.getAllCardNames("b")
    local names = U.getViewAsCardNames(Self, self.name, all_names)
    if #names == 0 then return end
    return U.CardNameBox {choices = names, all_names = all_names}
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self, cards)
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = self.name
    return card
  end,
  before_use = function(self, player)
    local room = player.room
    local targets = table.map(table.filter(room.alive_players, function(p)
      return (#p.player_cards[Player.Hand] < player:getHandcardNum()) end), Util.IdMapper)
    local tos = room:askForChoosePlayers(player, targets, 1, 1, "#zhenshan-choose", self.name, false)
    if #tos < 1 then return "" end
    local to = room:getPlayerById(tos[1])
    U.swapHandCards(room, player, player, to, self.name)
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 and
      table.find(Fk:currentRoom().alive_players, function(p) return p:getHandcardNum() < player:getHandcardNum() end)
  end,
  enabled_at_response = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryTurn) == 0 and
      table.find(Fk:currentRoom().alive_players, function(p) return p:getHandcardNum() < player:getHandcardNum() end)
  end,
}
quancong:addSkill(zhenshan)
Fk:loadTranslationTable{
  ["quancong"] = "全琮",
  ["#quancong"] = "慕势耀族",
  ["illustrator:quancong"] = "小小鸡仔",
  ["designer:quancong"] = "凌风自舞",

  ["zhenshan"] = "振赡",
  [":zhenshan"] = "每回合限一次，当你需要使用或打出一张基本牌时，你可以与一名手牌数少于你的角色交换手牌，若如此做，视为你使用或打出此牌。",
  ["#zhenshan-choose"] = "振赡：与一名手牌数少于你的角色交换手牌",

  ["$zhenshan1"] = "看我如何以无用之力换己所需，哈哈哈！",
  ["$zhenshan2"] = "民不足食，何以养军？",
  ["~quancong"] = "儿啊，好好报答吴王知遇之恩……",
}

local sunxiu = General(extension, "sunxiu", "wu", 3)
local yanzhu = fk.CreateActiveSkill{
  name = "yanzhu",
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected)
    return false
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id and not Fk:currentRoom():getPlayerById(to_select):isNude()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local cancelable = true
    if #target.player_cards[Player.Equip] == 0 then
      cancelable = false
    end
    if #room:askForDiscard(target, 1, 1, true, self.name, cancelable, ".", "#yanzhu-discard:"..player.id) == 0 and cancelable then
      room:obtainCard(player.id, target:getCardIds(Player.Equip), true, fk.ReasonGive, target.id)
      room:handleAddLoseSkills(player, "-yanzhu", nil, true, false)
      room:setPlayerMark(player, self.name, 1)
    end
  end,
}
local xingxue = fk.CreateTriggerSkill{
  name = "xingxue",
  anim_type = "support",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish
  end,
  on_cost = function(self, event, target, player, data)
    local n = player:hasSkill(yanzhu, true) and player.hp or player.maxHp
    local tos = player.room:askForChoosePlayers(player, table.map(player.room.alive_players, Util.IdMapper),
      1, n, "#xingxue-choose:::"..n, self.name, true)
    if #tos > 0 then
      self.cost_data = tos
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = table.simpleClone(self.cost_data)
    room:sortPlayersByAction(targets)
    for _, id in ipairs(targets) do
      local to = room:getPlayerById(id)
      if not to.dead then
        to:drawCards(1, self.name)
        if not (to.dead or to:isNude()) then
          local card = room:askForCard(to, 1, 1, true, self.name, false, ".", "#xingxue-card")
          room:moveCards({
            ids = card,
            from = id,
            toArea = Card.DrawPile,
            moveReason = fk.ReasonJustMove,
            skillName = self.name,
          })
        end
      end
    end
  end,
}
local zhaofu = fk.CreateAttackRangeSkill{
  name = "zhaofu$",
  within_func = function (self, from, to)
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      if p:hasSkill(self) and p:distanceTo(to) == 1 and from.kingdom == "wu" and from ~= p then
        return true
      end
    end
  end,
}
sunxiu:addSkill(yanzhu)
sunxiu:addSkill(xingxue)
sunxiu:addSkill(zhaofu)
Fk:loadTranslationTable{
  ["sunxiu"] = "孙休",
  ["#sunxiu"] = "弥殇的景君",
  ["designer:sunxiu"] = "顶尖对决&剑",
  ["illustrator:sunxiu"] = "XXX",
  ["yanzhu"] = "宴诛",
  [":yanzhu"] = "出牌阶段限一次，你可以令一名其他角色选择一项：1.弃置一张牌；2.交给你装备区内所有的牌，你失去〖宴诛〗并修改〖兴学〗为“X为你的体力上限”。",
  ["xingxue"] = "兴学",
  [":xingxue"] = "结束阶段，你可以令X名角色依次摸一张牌并将一张牌置于牌堆顶（X为你的体力值）。",
  ["zhaofu"] = "诏缚",
  [":zhaofu"] = "主公技，锁定技，与你距离为1的角色视为在其他吴势力角色的攻击范围内。",
  ["#yanzhu-discard"] = "宴诛：弃置一张牌，或点“取消”将所有装备交给 %src（若没装备则必须弃一张牌）",
  ["#xingxue-choose"] = "兴学：你可以令至多%arg名角色依次摸一张牌并将一张牌置于牌堆顶",
  ["#xingxue-card"] = "兴学：选择一张牌置于牌堆顶",

  ["$yanzhu1"] = "不诛此权臣，朕，何以治天下？",
  ["$yanzhu2"] = "大局已定，你还是放弃吧。",
  ["$xingxue1"] = "汝等都是国之栋梁。",
  ["$xingxue2"] = "文修武备，才是兴国之道。",
  ["~sunxiu"] = "崇文抑武，朕错了吗？",
}

local nos__zhuzhi = General(extension, "nos__zhuzhi", "wu", 4)
local nos__anguo = fk.CreateActiveSkill{
  name = "nos__anguo",
  anim_type = "support",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function()
    return false
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id and #Fk:currentRoom():getPlayerById(to_select).player_cards[Player.Equip] > 0
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local n = #table.filter(room:getOtherPlayers(target), function(p) return (target:inMyAttackRange(p)) end)
    local equip = room:askForCardChosen(player, target, "e", self.name)
    room:obtainCard(target, equip, true, fk.ReasonJustMove)
    if n > #table.filter(room:getOtherPlayers(target), function(p) return (target:inMyAttackRange(p)) end) then
      player:drawCards(1, self.name)
    end
  end,
}
nos__zhuzhi:addSkill(nos__anguo)
Fk:loadTranslationTable{
  ["nos__zhuzhi"] = "朱治",
  ["#nos__zhuzhi"] = "王事靡盬",
  ["designer:nos__zhuzhi"] = "May&Roy",
  ["illustrator:nos__zhuzhi"] = "心中一凛",
  ["nos__anguo"] = "安国",
  [":nos__anguo"] = "出牌阶段限一次，你可以选择其他角色场上的一张装备牌并令其获得之，然后若其攻击范围内的角色因此而变少，则你摸一张牌。",

  ["$nos__anguo1"] = "止干戈，休战事。",
  ["$nos__anguo2"] = "安邦定国，臣子分内之事。",
  ["~nos__zhuzhi"] = "集毕生之力，保国泰民安。",
}

local zhuzhi = General(extension, "zhuzhi", "wu", 4)
local function doAnguo(player, anguo_type, source)
  local room = player.room
  if anguo_type == "draw" then
    if table.every(room.alive_players, function (p) return p:getHandcardNum() >= player:getHandcardNum() end) then
      player:drawCards(1, "anguo")
      return true
    end
  elseif anguo_type == "recover" then
    if player:isWounded() and table.every(room.alive_players, function (p) return p.hp >= player.hp end) then
      room:recover({
        who = player,
        num = 1,
        recoverBy = source,
        skillName = "anguo",
      })
      return true
    end
  elseif anguo_type == "equip" then
    if table.every(room.alive_players, function (p)
      return #p.player_cards[Player.Equip] >= #player.player_cards[Player.Equip] end) then
      local cards = {}
      for _, id in ipairs(room.draw_pile) do
        local card = Fk:getCardById(id)
        if card.type == Card.TypeEquip and player:canUse(card) and not player:prohibitUse(card) then
          table.insert(cards, card)
        end
      end
      if #cards > 0 then
        room:useCard({
          from = player.id,
          tos = {{player.id}},
          card = table.random(cards),
        })
        return true
      end
    end
  end
  return false
end
local anguo = fk.CreateActiveSkill{
  name = "anguo",
  anim_type = "support",
  prompt = "#anguo-active",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local types = {"equip", "recover", "draw"}
    for i = 3, 1, -1 do
      if doAnguo(target, types[i], player) then
        table.removeOne(types, types[i])
        if target.dead then
          break
        end
      end
    end
    for i = #types, 1, -1 do
      if player.dead then break end
      doAnguo(player, types[i], player)
    end
  end,
}
zhuzhi:addSkill(anguo)
Fk:loadTranslationTable{
  ["zhuzhi"] = "朱治",
  ["#zhuzhi"] = "王事靡盬",
  ["illustrator:zhuzhi"] = "折原", -- 皮肤 气冲牛斗
  ["anguo"] = "安国",
  [":anguo"] = "出牌阶段限一次，你可以选择一名其他角色，令其依次执行：若其手牌数为全场最少，其摸一张牌；"..
  "体力值为全场最低，回复1点体力；装备区内牌数为全场最少，随机使用牌堆中一张装备牌。"..
  "然后若该角色有未执行的效果且你满足条件，你执行之。",

  ["#anguo-active"] = "发动 安国，选择一名其他角色",

  ["$anguo1"] = "止干戈，休战事。",
  ["$anguo2"] = "安邦定国，臣子分内之事。",
  ["~zhuzhi"] = "集毕生之力，保国泰民安。",
}

local gongsunyuan = General(extension, "gongsunyuan", "qun", 4)
local huaiyi = fk.CreateActiveSkill{
  name = "huaiyi",
  anim_type = "control",
  card_num = 0,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local cards = player.player_cards[Player.Hand]
    player:showCards(cards)
    local colors = {}
    for _, id in ipairs(cards) do
      if Fk:getCardById(id).color ~= Card.NoColor then
        table.insertIfNeed(colors, Fk:getCardById(id):getColorString())
      end
    end
    if #colors < 2 then return end
    local color = room:askForChoice(player, colors, self.name)
    local throw = {}
    for _, id in ipairs(cards) do
      if Fk:getCardById(id):getColorString() == color and not player:prohibitDiscard(Fk:getCardById(id)) then
        table.insert(throw, id)
      end
    end
    if #throw == 0 then return end
    room:throwCard(throw, self.name, player, player)
    if player.dead then return end
    local targets = room:askForChoosePlayers(player, table.map(table.filter(room:getOtherPlayers(player), function(p)
      return (not p:isNude()) end), Util.IdMapper), 1, #throw, "#huaiyi-choose:::"..tostring(#throw), self.name, true)
    if #targets > 0 then
      room:sortPlayersByAction(targets)
      local n = 0
      for _, p in ipairs(targets) do
        if player.dead then return end
        local to = room:getPlayerById(p)
        if not to:isNude() then
          local id = room:askForCardChosen(player, to, "he", self.name)
          n = n + 1
          room:moveCardTo(id, Card.PlayerHand, player, fk.ReasonPrey, self.name, nil, false, player.id)
        end
      end
      if n > 1 and not player.dead then
        room:loseHp(player, 1, self.name)
      end
    end
  end,
}
gongsunyuan:addSkill(huaiyi)
Fk:loadTranslationTable{
  ["gongsunyuan"] = "公孙渊",
  ["#gongsunyuan"] = "狡徒悬海",
  ["designer:gongsunyuan"] = "死水微澜",
  ["illustrator:gongsunyuan"] = "尼乐小丑",
  ["huaiyi"] = "怀异",
  [":huaiyi"] = "出牌阶段限一次，你可以展示所有手牌，若其中包含两种颜色，则你弃置其中一种颜色的牌，然后获得至多X名角色的各一张牌"..
  "（X为你以此法弃置的手牌数）。若你获得的牌大于一张，则你失去1点体力。",
  ["#huaiyi-choose"] = "怀异：你可以获得至多%arg名角色各一张牌",

  ["$huaiyi1"] = "此等小利，焉能安吾雄心？",
  ["$huaiyi2"] = "一生纵横，怎可对他人称臣！",
  ["~gongsunyuan"] = "天不容我公孙家……",
}

local guotupangji = General(extension, "guotupangji", "qun", 3)
local jigong = fk.CreateTriggerSkill{
  name = "jigong",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Play
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(2, self.name)
  end,

  refresh_events = {fk.Damage},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:usedSkillTimes(self.name, Player.HistoryPhase) > 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:addPlayerMark(player, "@jigong-turn", data.damage)
  end,
}
local jigong_maxcards = fk.CreateMaxCardsSkill{
  name = "#jigong_maxcards",
  fixed_func = function (self, player)
    if player:usedSkillTimes("jigong", Player.HistoryTurn) > 0 then
      return player:getMark("@jigong-turn")
    end
  end,
}
local shifei = fk.CreateViewAsSkill{
  name = "shifei",
  anim_type = "defensive",
  prompt = function ()
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      if p.phase ~= Player.NotActive then
        return "#shifei-viewas::" .. p.id
      end
    end
  end,
  pattern = "jink",
  card_num = 0,
  card_filter = Util.FalseFunc,
  before_use = function(self, player)
    local room = player.room
    local current = room.current
    if current:isAlive() then
      room:drawCards(current, 1, self.name)
      if current:isAlive() and player:isAlive() then
        local targets = {current.id}
        local x = current:getHandcardNum()
        local y = 0
        for _, p in ipairs(room:getOtherPlayers(current, false)) do
          y = p:getHandcardNum()
          if y > x then
            x = y
            targets = {}
          end
          if x == y then
            table.insert(targets, p.id)
          end
        end
        if x > 0 and (#targets > 1 or targets[1] ~= current.id) then
          local tos = room:askForChoosePlayers(player, targets, 1, 1, "#shifei-choose", self.name, false)
          local to = room:getPlayerById(tos[1])
          local id = room:askForCardChosen(player, to, "he", self.name)
          room:throwCard({id}, self.name, to, player)
          return
        end
      end
    end
    return self.name
  end,
  view_as = function(self, cards)
    local c = Fk:cloneCard("jink")
    c.skillName = self.name
    return c
  end,
  enabled_at_response = function (self, player)
    for _, p in ipairs(Fk:currentRoom().alive_players) do
      if p.phase ~= Player.NotActive then
        return true
      end
    end
  end,
}

jigong:addRelatedSkill(jigong_maxcards)
guotupangji:addSkill(jigong)
guotupangji:addSkill(shifei)
Fk:loadTranslationTable{
  ["guotupangji"] = "郭图逄纪",
  ["#guotupangji"] = "凶蛇两端",
  ["designer:guotupangji"] = "辰木",
  ["illustrator:guotupangji"] = "Aimer&Vwolf",
  ["jigong"] = "急攻",
  [":jigong"] = "出牌阶段开始时，你可以摸两张牌，然后你本回合的手牌上限等于你本阶段造成的伤害值。",
  ["shifei"] = "饰非",
  [":shifei"] = "当你需要使用或打出【闪】时，你可以令当前回合角色摸一张牌，然后若其手牌数不是全场唯一最多的，你弃置一名手牌全场最多的角色一张牌，"..
  "视为你使用或打出一张【闪】。",
  ["@jigong-turn"] = "急攻",
  ["#shifei-viewas"] = "是否使用 饰非，令%dest摸一张牌",
  ["#shifei-choose"] = "饰非：弃置全场手牌最多的一名角色的一张牌",

  ["$jigong1"] = "不惜一切代价，拿下此人！",
  ["$jigong2"] = "曹贼势颓，主公速击之。",
  ["$shifei1"] = "良谋失利，罪在先锋！",
  ["$shifei2"] = "计略周详，怎奈指挥不当。",
  ["~guotupangji"] = "大势已去，无力回天……",
}

return extension

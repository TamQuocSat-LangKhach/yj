local extension = Package("yjcm2012")
extension.extensionName = "yj"

Fk:loadTranslationTable{
  ["yjcm2012"] = "一将成名2012",
}
local U = require "packages/utility/utility"
local xunyou = General(extension, "xunyou", "wei", 3)
local qice = fk.CreateViewAsSkill{
  name = "qice",
  interaction = function()
    local names, all_names = {} , {}
    for _, id in ipairs(Fk:getAllCardIds()) do
      local card = Fk:getCardById(id)
      if card:isCommonTrick() and not card.is_derived then
        table.insertIfNeed(all_names, card.name)
        if Self:canUse(card) and not Self:prohibitUse(card) then
          table.insertIfNeed(names, card.name)
        end
      end
    end
    return UI.ComboBox {choices = names, all_choices = all_names}
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self, cards)
    local card = Fk:cloneCard(self.interaction.data)
    card:addSubcards(Self:getCardIds(Player.Hand))
    card.skillName = self.name
    return card
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
}
local zhiyu = fk.CreateTriggerSkill{
  name = "zhiyu",
  anim_type = "masochism",
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, self.name)
    local cards = player:getCardIds("h")
    player:showCards(cards)
    if data.from and not data.from.dead and not data.from:isKongcheng() and
      table.every(cards, function(id) return #cards == 0 or Fk:getCardById(id).color == Fk:getCardById(cards[1]).color end) then
      room:askForDiscard(data.from, 1, 1, false, self.name, false)
    end
  end,
}
xunyou:addSkill(qice)
xunyou:addSkill(zhiyu)
Fk:loadTranslationTable{
  ["xunyou"] = "荀攸",
  ["#xunyou"] = "曹魏的谋主",
  ["designer:xunyou"] = "淬毒",
  ["illustrator:xunyou"] = "魔鬼鱼",
  ["qice"] = "奇策",
  [":qice"] = "出牌阶段限一次，你可以将所有的手牌当任意一张非延时类锦囊牌使用。",
  ["zhiyu"] = "智愚",
  [":zhiyu"] = "每当你受到一次伤害后，你可以摸一张牌，然后展示所有手牌，若颜色均相同，伤害来源弃置一张手牌。",

  ["$qice1"] = "倾力为国，算无遗策。",
  ["$qice2"] = "奇策在此，谁与争锋？",
  ["$zhiyu1"] = "大勇若怯，大智如愚。",
  ["$zhiyu2"] = "愚者既出，智者何存？",
  ["~xunyou"] = "主公，臣下……先行告退……",
}

local caozhang = General(extension, "caozhang", "wei", 4)
local jiangchi = fk.CreateTriggerSkill{
  name = "jiangchi",
  mute = true,
  events = {fk.DrawNCards},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    local choices = {"jiangchi+1"}
    if data.n > 0 then
      table.insert(choices, "jiangchi-1")
    end
    local choice = player.room:askForChoice(player, choices, self.name)
    if choice == "jiangchi+1" then
      data.n = data.n + 1
      player.room:notifySkillInvoked(player, self.name, "defensive")
      player:broadcastSkillInvoke(self.name, 1)
    else
      player.room:notifySkillInvoked(player, self.name, "offensive")
      player:broadcastSkillInvoke(self.name, 2)
      data.n = data.n - 1
    end
    player.room:addPlayerMark(player, choice.."-turn", 1)
  end,
}
local jiangchi_targetmod = fk.CreateTargetModSkill{
  name = "#jiangchi_targetmod",
  residue_func = function(self, player, skill, scope)
    if player:hasSkill(self, true) and skill.trueName == "slash_skill" and player:getMark("jiangchi-1-turn") > 0 and
      scope == Player.HistoryPhase then
      return 1
    end
  end,
  distance_limit_func =  function(self, player, skill)
    if player:hasSkill(self, true) and skill.trueName == "slash_skill" and player:getMark("jiangchi-1-turn") > 0 then
      return 999
    end
  end,
}
local jiangchi_prohibit = fk.CreateProhibitSkill{
  name = "#jiangchi_prohibit",
  prohibit_use = function(self, player, card)
    return player:hasSkill(self, true) and player:getMark("jiangchi+1-turn") > 0 and card.trueName == "slash"
  end,
  prohibit_response = function(self, player, card)
    return player:hasSkill(self, true) and player:getMark("jiangchi+1-turn") > 0 and card.trueName == "slash"
  end,
}
jiangchi:addRelatedSkill(jiangchi_targetmod)
jiangchi:addRelatedSkill(jiangchi_prohibit)
caozhang:addSkill(jiangchi)
Fk:loadTranslationTable{
  ["caozhang"] = "曹彰",
  ["#caozhang"] = "黄须儿",
  ["designer:caozhang"] = "潜龙勿用",
  ["illustrator:caozhang"] = "Yi章",
  ["jiangchi"] = "将驰",
  [":jiangchi"] = "摸牌阶段，你可以选择一项：1.额外摸一张牌，此回合你不能使用或打出【杀】。2.少摸一张牌，此回合出牌阶段你使用【杀】无距离限制，"..
  "且你【杀】的使用上限+1。",
  ["jiangchi+1"] = "多摸一张牌，本回合不能使用或打出【杀】",
  ["jiangchi-1"] = "少摸一张牌，本阶段使用【杀】无距离限制且次数+1",

  ["$jiangchi1"] = "谨遵父训，不可逞匹夫之勇。",
  ["$jiangchi2"] = "吾定当身先士卒，振魏武雄风！",
  ["~caozhang"] = "子桓，你害我！",
}

local nos__wangyi = General(extension, "nos__wangyi", "wei", 3, 3, General.Female)
local nos__zhenlie = fk.CreateTriggerSkill{
  name = "nos__zhenlie",
  anim_type = "control",
  events = {fk.AskForRetrial},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local move1 = {
      ids = room:getNCards(1),
      toArea = Card.Processing,
      moveReason = fk.ReasonJustMove,
      skillName = self.name,
    }
    local move2 = {
      ids = {data.card:getEffectiveId()},
      toArea = Card.DiscardPile,
      moveReason = fk.ReasonJustMove,
      skillName = self.name,
    }
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
    return target == player and player:hasSkill(self) and player:isWounded() and
      (player.phase == Player.Start or player.phase == Player.Finish)
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
      local cards = room:getNCards(player:getLostHp())
      U.viewCards(player, cards, self.name)
      local tos = room:askForChoosePlayers(player, table.map(room.alive_players, Util.IdMapper), 1, 1, "#nos__miji-choose", self.name, false)
      room:moveCards({
        ids = cards,
        to = tos[1],
        toArea = Card.PlayerHand,
        moveReason = fk.ReasonJustMove,
      })
    end
  end,
}
nos__wangyi:addSkill(nos__zhenlie)
nos__wangyi:addSkill(nos__miji)
Fk:loadTranslationTable{
  ["nos__wangyi"] = "王异",
  ["#nos__wangyi"] = "决意的巾帼",
  ["designer:nos__wangyi"] = "VirgoPaladin", -- 罗森？
  ["illustrator:nos__wangyi"] = "木美人",
  ["nos__zhenlie"] = "贞烈",
  [":nos__zhenlie"] = "当你的判定牌生效前，你可以亮出牌堆顶的一张牌代替之。",
  ["nos__miji"] = "秘计",
  [":nos__miji"] = "准备阶段或结束阶段开始时，若你已受伤，你可以进行一次判定：若结果为黑色，你观看牌堆顶的X张牌（X为你已损失的体力值），"..
  "然后将这些牌交给一名角色。",
  ["#nos__miji-choose"] = "秘计：选择一名角色获得“秘计”牌",

  ["$nos__zhenlie1"] = "我，绝不屈服！",
  ["$nos__zhenlie2"] = "休要小看妇人志气！",
  ["$nos__miji1"] = "奇谋，只在绝境中诞生！",
  ["$nos__miji2"] = "我将尽我所能！",
  ["~nos__wangyi"] = "忠义已尽，死又何妨？",
}

local wangyi = General(extension, "wangyi", "wei", 3, 3, General.Female)
local zhenlie = fk.CreateTriggerSkill{
  name = "zhenlie",
  anim_type = "defensive",
  events = {fk.TargetConfirmed},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.from ~= player.id and
      (data.card:isCommonTrick() or data.card.trueName == "slash")
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:loseHp(player, 1, self.name)
    if player.dead then return end
    table.insertIfNeed(data.nullifiedTargets, player.id)
    local to = room:getPlayerById(data.from)
    if to.dead or to:isNude() then return end
    local id = room:askForCardChosen(player, to, "he", self.name)
    room:throwCard({id}, self.name, to, player)
  end,
}
local miji = fk.CreateTriggerSkill{
  name = "miji",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Finish and player:isWounded()
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = player:getLostHp()
    player:drawCards(n, self.name)
    if player:getHandcardNum() >= n and room:askForSkillInvoke(player, self.name, nil, "#miji-invoke:::"..n) then
      U.askForDistribution(player, player:getCardIds("h"), room:getOtherPlayers(player), self.name, n, n)
    end
  end,
}
wangyi:addSkill(zhenlie)
wangyi:addSkill(miji)
Fk:loadTranslationTable{
  ["wangyi"] = "王异",
  ["#wangyi"] = "决意的巾帼",
  ["designer:wangyi"] = "VirgoPaladin",
  ["illustrator:wangyi"] = "团扇子",
  ["zhenlie"] = "贞烈",
  [":zhenlie"] = "当你成为其他角色使用【杀】或普通锦囊牌的目标后，你可以失去1点体力使此牌对你无效，然后你弃置其一张牌。",
  ["miji"] = "秘计",
  [":miji"] = "结束阶段，你可以摸X张牌（X为你已损失的体力值），然后你可以将等量的手牌分配给其他角色。",
  ["miji_active"] = "秘计",
  ["#miji-invoke"] = "秘计：是否将 %arg 张手牌分配给其他角色",

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
    return target == player and player:hasSkill(self) and player:distanceTo(data.to) == 1 and
    data.card and data.card.trueName == "slash" and U.damageByCardEffect(player.room)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local judge = {
      who = player,
      reason = self.name,
      pattern = ".|.|^heart",
    }
    room:judge(judge)
    if judge.card.suit ~= Card.Heart then
      if not data.to.dead then
        room:changeMaxHp(data.to, -1)
      end
      return true
    end
  end,
}
nos__madai:addSkill("mashu")
nos__madai:addSkill(nos__qianxi)
Fk:loadTranslationTable{
  ["nos__madai"] = "马岱",
  ["#nos__madai"] = "临危受命",
  ["designer:nos__madai"] = "凌天翼",
  ["illustrator:nos__madai"] = "琛·美弟奇",
  ["nos__qianxi"] = "潜袭",
  [":nos__qianxi"] = "每当你使用【杀】对距离为1的目标角色造成伤害时，你可以进行一次判定，若判定结果不为<font color='red'>♥</font>，"..
  "你防止此伤害，改为令其减1点体力上限。",

  ["$nos__qianxi1"] = "伤其十指，不如断其一指！",
  ["$nos__qianxi2"] = "斩草除根，除恶务尽！",
  ["~nos__madai"] = "反骨贼已除，丞相放心……",
}

local madai = General(extension, "madai", "shu", 4)
local qianxi = fk.CreateTriggerSkill{
  name = "qianxi",
  anim_type = "control",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Start
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
    for _, p in ipairs(room.alive_players) do
      if player:distanceTo(p) == 1 then
        table.insert(targets, p.id)
      end
    end
    if #targets == 0 then return end
    local tos = room:askForChoosePlayers(player, targets, 1, 1, "#qianxi-choose:::"..judge.card:getColorString(), self.name, false)
    room:setPlayerMark(room:getPlayerById(tos[1]), "@qianxi-turn", judge.card:getColorString())
  end,
}
local qianxi_prohibit = fk.CreateProhibitSkill{
  name = "#qianxi_prohibit",
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
  ["#madai"] = "临危受命",
  ["illustrator:madai"] = "大佬荣",
  ["qianxi"] = "潜袭",
  [":qianxi"] = "准备阶段，你可以进行判定，然后令距离为1的一名角色本回合不能使用或打出与结果颜色相同的手牌。",
  ["#qianxi-choose"] = "潜袭：令一名角色本回合不能使用或打出%arg手牌",
  ["@qianxi-turn"] = "潜袭",

  ["$qianxi1"] = "喊什么喊？我敢杀你！",
  ["$qianxi2"] = "笑什么笑？叫你得意！",
  ["~madai"] = "我怎么会死在这里……",
}

local liaohua = General(extension, "liaohua", "shu", 4)
local dangxian = fk.CreateTriggerSkill{
  name = "dangxian",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseChanging},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and data.to == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    player:gainAnExtraPhase(Player.Play, true)
  end,
}
local fuli = fk.CreateTriggerSkill{
  name = "fuli",
  anim_type = "defensive",
  frequency = Skill.Limited,
  events = {fk.AskForPeaches},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.dying and player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local kingdoms = {}
    for _, p in ipairs(room:getAlivePlayers()) do
      table.insertIfNeed(kingdoms, p.kingdom)
    end
    room:recover({
      who = player,
      num = math.min(#kingdoms, player.maxHp) - player.hp,
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
  ["#liaohua"] = "历尽沧桑",
  ["designer:liaohua"] = "桃花僧",
  ["illustrator:liaohua"] = "天空之城",
  ["dangxian"] = "当先",
  [":dangxian"] = "锁定技，回合开始时，你执行一个额外的出牌阶段。",
  ["fuli"] = "伏枥",
  [":fuli"] = "限定技，当你处于濒死状态时，你可以将体力值回复至X点（X为现存势力数），然后将你的武将牌翻面。",

  ["$dangxian1"] = "先锋就由老夫来当！",
  ["$dangxian2"] = "看我先行破敌！",
  ["$fuli1"] = "今天是个拼命的好日子，哈哈哈哈！",
  ["$fuli2"] = "有老夫在，蜀汉就不会倒下！",
  ["~liaohua"] = "今后，就靠你们啦……",
}

local nos__guanxingzhangbao = General(extension, "nos__guanxingzhangbao", "shu", 4)
local nos__fuhun = fk.CreateTriggerSkill{
  name = "nos__fuhun",
  anim_type = "offensive",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Draw
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local ids = room:getNCards(2)
    room:moveCards({
      ids = ids,
      toArea = Card.Processing,
      moveReason = fk.ReasonJustMove,
      skillName = self.name,
    })
    room:delay(1000)
    local dummy = Fk:cloneCard("dilu")
    dummy:addSubcards(ids)
    room:obtainCard(player.id, dummy, true, fk.ReasonJustMove)
    if Fk:getCardById(ids[1]).color ~= Fk:getCardById(ids[2]).color then
      local skills = {}
      for _, skill in ipairs({"wusheng", "paoxiao"}) do
        if not player:hasSkill(skill, true) then
          table.insert(skills, skill)
        end
      end
      if #skills > 0 then
        room:handleAddLoseSkills(player, table.concat(skills, "|"))
        room.logic:getCurrentEvent():findParent(GameEvent.Turn):addCleaner(function()
          room:handleAddLoseSkills(player, "-"..table.concat(skills, "|-"))
        end)
      end
    end
    return true
  end,
}
nos__guanxingzhangbao:addSkill(nos__fuhun)
nos__guanxingzhangbao:addRelatedSkill("wusheng")
nos__guanxingzhangbao:addRelatedSkill("paoxiao")
Fk:loadTranslationTable{
  ["nos__guanxingzhangbao"] = "关兴张苞",
  ["#nos__guanxingzhangbao"] = "将门虎子",
  ["designer:nos__guanxingzhangbao"] = "诺思冥羽",
  ["illustrator:nos__guanxingzhangbao"] = "HOOO",
  ["nos__fuhun"] = "父魂",
  [":nos__fuhun"] = "摸牌阶段，你可以放弃摸牌，改为亮出牌堆顶的两张牌并获得之，若亮出的牌颜色不同，你获得技能〖武圣〗、〖咆哮〗，直到回合结束。",

  ["$nos__fuhun1"] = "不血父仇，誓不罢休！",
  ["$nos__fuhun2"] = "承父遗志，横扫叛贼！",
  ["$wusheng_nos__guanxingzhangbao"] = "蜀汉重任，后继有人！",
  ["$paoxiao_nos__guanxingzhangbao"] = "哼！",
  ["~nos__guanxingzhangbao"] = "吾得父亲之遗志，未袭父亲之神勇。",
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
local fuhun_delay = fk.CreateTriggerSkill{
  name = "#fuhun_delay",
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(fuhun) and target == player and data.card and table.contains(data.card.skillNames, "fuhun") and player.phase == Player.Play
  end,
  on_cost = Util.TrueFunc,
  on_trigger = function(self, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(fuhun.name)
    local skills = {}
    for _, skill in ipairs({"wusheng", "paoxiao"}) do
      if not player:hasSkill(skill, true) then
        table.insert(skills, skill)
      end
    end
    if #skills > 0 then
      room:handleAddLoseSkills(player, table.concat(skills, "|"))
      room.logic:getCurrentEvent():findParent(GameEvent.Turn):addCleaner(function()
        room:handleAddLoseSkills(player, "-"..table.concat(skills, "|-"))
      end)
    end
  end,
}
fuhun:addRelatedSkill(fuhun_delay)
guanxingzhangbao:addSkill(fuhun)
guanxingzhangbao:addRelatedSkill("wusheng")
guanxingzhangbao:addRelatedSkill("paoxiao")
Fk:loadTranslationTable{
  ["guanxingzhangbao"] = "关兴张苞",
  ["#guanxingzhangbao"] = "将门虎子",
  ["illustrator:guanxingzhangbao"] = "HOOO",

  ["fuhun"] = "父魂",
  [":fuhun"] = "你可以将两张手牌当【杀】使用或打出；当你于出牌阶段内以此法造成伤害后，本回合获得〖武圣〗和〖咆哮〗。",
  ["#fuhun_delay"] = "父魂",

  ["$fuhun1"] = "光复汉室，重任在肩！",
  ["$fuhun2"] = "将门虎子，承我父志！",
  ["$wusheng_guanxingzhangbao"] = "一夫当关，万夫莫当！",
  ["$paoxiao_guanxingzhangbao"] = "喝啊！",
  ["~guanxingzhangbao"] = "未能手刃仇敌，愧对先父。",
}

local chengpu = General(extension, "chengpu", "wu", 4)
local lihuo = fk.CreateTriggerSkill{
  name = "lihuo",
  events = {fk.AfterCardUseDeclared, fk.AfterCardTargetDeclared},
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if not (target == player and player:hasSkill(self)) then return false end
    if event == fk.AfterCardUseDeclared then
      return data.card.name == "slash"
    else
      return data.card.name == "fire__slash"
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if event == fk.AfterCardUseDeclared then
      return room:askForSkillInvoke(player, self.name, nil, "#lihuo-trans:::"..data.card:toLogString())
    else
      local current_targets = TargetGroup:getRealTargets(data.tos)
      local targets = {}
      for _, p in ipairs(room.alive_players) do
        if not table.contains(current_targets, p.id) and not player:isProhibited(p, data.card) and
            data.card.skill:modTargetFilter(p.id, current_targets, data.from, data.card, true) then
          table.insert(targets, p.id)
        end
      end
      if #targets == 0 then return false end
      local tos = player.room:askForChoosePlayers(player, targets, 1, 1, "#lihuo-choose:::"..data.card:toLogString(), self.name, true)
      if #tos > 0 then
        self.cost_data = tos
        return true
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.AfterCardUseDeclared then
      local card = Fk:cloneCard("fire__slash", data.card.suit, data.card.number)
      for k, v in pairs(data.card) do
        if card[k] == nil then
          card[k] = v
        end
      end
      if data.card:isVirtual() then
        card.subcards = data.card.subcards
      else
        card.id = data.card.id
      end
      card.skillNames = data.card.skillNames
      data.card = card
      data.extra_data = data.extra_data or {}
      data.extra_data.lihuo = data.extra_data.lihuo or {}
      table.insert(data.extra_data.lihuo, player.id)
    else
      local tos = self.cost_data
      player.room:sendLog{
        type = "#AddTargetsBySkill",
        from = player.id,
        to = tos,
        arg = self.name,
        arg2 = data.card:toLogString()
      }
      table.insert(data.tos, tos)
    end
  end,
}
local lihuo_record = fk.CreateTriggerSkill{
  name = "#lihuo_record",
  events = {fk.CardUseFinished},
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return not player.dead and data.damageDealt and data.extra_data and data.extra_data.lihuo and
    table.contains(data.extra_data.lihuo, player.id)
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    player.room:loseHp(player, 1, self.name)
  end,
}
lihuo:addRelatedSkill(lihuo_record)

local chunlao = fk.CreateTriggerSkill{
  name = "chunlao",
  anim_type = "support",
  expand_pile = "chengpu_chun",
  events = {fk.EventPhaseStart, fk.AskForPeaches},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.EventPhaseStart then
        return target == player and player.phase == Player.Finish and #player:getPile("chengpu_chun") == 0 and not player:isKongcheng()
      else
        return target.dying and #player:getPile("chengpu_chun") > 0 and not target:isProhibited(target, Fk:cloneCard("analeptic")) and not target:prohibitUse(Fk:cloneCard("analeptic"))
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local cards = {}
    if event == fk.EventPhaseStart then
      cards = room:askForCard(player, 1, player:getHandcardNum(), false, self.name, true, "slash", "#chunlao-cost")
    else
      cards = room:askForCard(player, 1, 1, false, self.name, true, ".|.|.|chengpu_chun|.|.", "#chunlao-invoke::"..target.id, "chengpu_chun")
    end
    if #cards > 0 then
      self.cost_data = cards
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.EventPhaseStart then
      player:addToPile("chengpu_chun", self.cost_data, true, self.name)
    else
      room:moveCards({
        from = player.id,
        ids = self.cost_data,
        toArea = Card.DiscardPile,
        moveReason = fk.ReasonPutIntoDiscardPile,
        skillName = self.name,
        specialName = self.name,
      })
      local analeptic = Fk:cloneCard("analeptic")
      room:useCard({
        card = analeptic,
        from = target.id,
        tos = {{target.id}},
        extra_data = {analepticRecover = true},
        skillName = self.name,
      })
    end
  end,
}
chengpu:addSkill(lihuo)
chengpu:addSkill(chunlao)
Fk:loadTranslationTable{
  ["chengpu"] = "程普",
  ["#chengpu"] = "三朝虎臣",
  ["cv:chengpu"] = "符冲",
  ["designer:chengpu"] = "Michael_Lee",
  ["illustrator:chengpu"] = "G.G.G.",
  ["lihuo"] = "疬火",
  [":lihuo"] = "当你使用普通【杀】时，你可以将此【杀】改为火【杀】，然后此【杀】结算结束后，若此【杀】造成过伤害，你失去1点体力；你使用火【杀】可以多选择一个目标。",
  ["chunlao"] = "醇醪",
  [":chunlao"] = "结束阶段开始时，若你的武将牌上没有牌，你可以将任意数量的【杀】置于你的武将牌上，称为“醇”；"..
  "当一名角色处于濒死状态时，若其为【酒】的合法目标，你可以将一张“醇”置入弃牌堆，视为该角色使用一张【酒】。",
  ["#lihuo-choose"] = "疬火：你可以为此%arg增加一个目标",
  ["#lihuo-trans"] = "疬火：可以将%arg改为火【杀】，若造成伤害，结算后你失去1点体力",
  ["chengpu_chun"] = "醇",
  ["#chunlao-cost"] = "醇醪：你可以将任意张【杀】置为“醇”",
  ["#chunlao-invoke"] = "醇醪：你可以将一张“醇”置入弃牌堆，视为 %dest 使用一张【酒】",
  ["#AddTargetsBySkill"] = "用于 %arg 的效果，%from 使用的 %arg2 增加了目标 %to",

  ["$lihuo1"] = "将士们，引火对敌！",
  ["$lihuo2"] = "和我同归于尽吧！",
  ["$chunlao1"] = "唉，帐中不可无酒啊！",
  ["$chunlao2"] = "无碍，且饮一杯！",
  ["~chengpu"] = "没，没有酒了……",
}

local bulianshi = General(extension, "bulianshi", "wu", 3, 3, General.Female)
local anxu = fk.CreateActiveSkill{
  name = "anxu",
  prompt = "#anxu-active",
  anim_type = "control",
  target_num = 2,
  card_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    if #selected > 1 or to_select == Self.id then return false end
    if #selected == 0 then
      return true
    elseif #selected == 1 then
      local target1 = Fk:currentRoom():getPlayerById(to_select)
      local target2 = Fk:currentRoom():getPlayerById(selected[1])
      return target1:getHandcardNum() ~= target2:getHandcardNum()
    else
      return false
    end
  end,
  on_use = function(self, room, effect)
    local target1 = room:getPlayerById(effect.tos[1])
    local target2 = room:getPlayerById(effect.tos[2])
    local from, to
    if target1:getHandcardNum() < target2:getHandcardNum() then
      from = target1
      to = target2
    else
      from = target2
      to = target1
    end
    local card = room:askForCardChosen(from, to, "h", self.name)
    room:obtainCard(from.id, card, true, fk.ReasonPrey)
    if Fk:getCardById(card).suit ~= Card.Spade then
      local player = room:getPlayerById(effect.from)
      if not player.dead then
        player:drawCards(1, self.name)
      end
    end
  end,
}
local zhuiyi = fk.CreateTriggerSkill{
  name = "zhuiyi",
  anim_type = "support",
  events = {fk.Death},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self, false, true)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.map(room.alive_players, Util.IdMapper)
    if data.damage and data.damage.from then
      table.removeOne(targets, data.damage.from.id)
    end
    local p = room:askForChoosePlayers(player, targets, 1, 1, "#zhuiyi-choose", self.name, true)
    if #p > 0 then
      self.cost_data = p[1]
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(self.cost_data)
    to:drawCards(3, self.name)
    if to:isWounded() and not to.dead then
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
  ["#bulianshi"] = "无冕之后",
  ["designer:bulianshi"] = "Anais&我是Kururu",
  ["illustrator:bulianshi"] = "勺子妞",
  ["anxu"] = "安恤",
  [":anxu"] = "出牌阶段限一次，你可以选择两名手牌数不相等的其他角色，"..
  "令其中手牌少的角色获得手牌多的角色一张手牌（正面朝上移动），若此牌的花色不为♠，你摸一张牌。",
  ["zhuiyi"] = "追忆",
  [":zhuiyi"] = "你死亡时，可以令一名其他角色（杀死你的角色除外）摸三张牌并回复1点体力。",
  ["#anxu-active"] = "发动 安恤，选择两名手牌数不相等的其他角色",
  ["#zhuiyi-choose"] = "追忆：你可以令一名角色摸三张牌并回复1点体力",

  ["$anxu1"] = "和鸾雍雍，万福攸同。",
  ["$anxu2"] = "君子乐胥，万邦之屏。",
  ["$zhuiyi1"] = "终其永怀，恋心殷殷。",
  ["$zhuiyi2"] = "妾心所系，如月之恒。",
  ["~bulianshi"] = "江之永矣，不可方思。",
}

local nos__handang = General(extension, "nos__handang", "wu", 4)
local nos__gongqi = fk.CreateViewAsSkill{
  name = "nos__gongqi",
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
local nos__gongqi_targetmod = fk.CreateTargetModSkill{
  name = "#nos__gongqi_targetmod",
  distance_limit_func =  function(self, player, skill, card)
    if table.contains(card.skillNames, "nos__gongqi") then
      return 999
    end
  end,
}
local nos__jiefan = fk.CreateTriggerSkill{
  name = "nos__jiefan",
  anim_type = "support",
  events = {fk.AskForPeaches, fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    if event == fk.AskForPeaches then
      return player:hasSkill(self) and target.dying and player.room.current and player.room.current ~= player
    else
      if target == player and data.card then
        local e = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
        if e then
          local use = e.data[1]
          return use.extra_data and use.extra_data.jiefan and use.extra_data.jiefan[1] == player.id
        end
      end
    end
  end,
  on_cost = function(self, event, target, player, data)
    if event == fk.AskForPeaches then
      self.cost_data = player.room:askForUseCard(player, "slash", "slash",
        "#nos__jiefan-slash:"..target.id..":"..player.room.current.id, true, {must_targets = {player.room.current.id}})
      return self.cost_data
    else
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.AskForPeaches then
      local use = self.cost_data
      use.extra_data = use.extra_data or {}
      use.extra_data.jiefan = {player.id, target.id}
      room:useCard(use)
    else
      local e = room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      if e then
        local use = e.data[1]
        local to = room:getPlayerById(use.extra_data.jiefan[2])
        if not to.dead then
          room:useVirtualCard("peach", nil, player, to, self.name)
        end
        return true
      end
    end
  end,
}
nos__gongqi:addRelatedSkill(nos__gongqi_targetmod)
nos__handang:addSkill(nos__gongqi)
nos__handang:addSkill(nos__jiefan)
Fk:loadTranslationTable{
  ["nos__handang"] = "韩当",
  ["#nos__handang"] = "石城侯",
  ["designer:nos__handang"] = "ByArt",
  ["illustrator:nos__handang"] = "DH",
  ["nos__gongqi"] = "弓骑",
  [":nos__gongqi"] = "你可以将一张装备牌当【杀】使用或打出；你以此法使用的【杀】无距离限制。",
  ["nos__jiefan"] = "解烦",
  [":nos__jiefan"] = "你的回合外，当一名角色处于濒死状态时，你可以对当前回合角色使用一张【杀】，此【杀】造成伤害时，你防止此伤害，"..
  "视为对该濒死角色使用了一张【桃】。",
  ["#nos__jiefan-slash"] = "解烦：你可以对 %dest 使用【杀】，若造成伤害，防止此伤害并视为对 %src 使用【桃】",

  ["$nos__gongqi1"] = "鼠辈，哪里走！",
  ["$nos__gongqi2"] = "吃我一箭！",
  ["$nos__jiefan1"] = "休想趁人之危！",
  ["$nos__jiefan2"] = "退后，这里交给我！",
  ["~nos__handang"] = "今后，只能靠你了。",
}

local handang = General(extension, "handang", "wu", 4)
local gongqi = fk.CreateActiveSkill{
  name = "gongqi",
  anim_type = "offensive",
  card_num = 1,
  target_num = 0,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and not player:isNude()
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  target_filter = Util.FalseFunc,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    room:throwCard(effect.cards, self.name, player, player)
    if player.dead then return end
    room:addPlayerMark(player, "gongqi-turn", 999)
    if Fk:getCardById(effect.cards[1]).type == Card.TypeEquip then
      local to = room:askForChoosePlayers(player, table.map(table.filter(room:getOtherPlayers(player), function(p)
        return not p:isNude() end), Util.IdMapper), 1, 1, "#gongqi-choose", self.name, true)
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
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  on_use = function(self, room, effect)
    local target = room:getPlayerById(effect.tos[1])
    for _, p in ipairs(room:getOtherPlayers(target)) do
      if p:inMyAttackRange(target) then
        if #room:askForDiscard(p, 1, 1, true, self.name, true, ".|.|.|.|.|weapon", "#jiefan-discard::"..target.id) == 0 then
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
  ["#handang"] = "石城侯",
  ["illustrator:handang"] = "XXX", -- 皮肤 从击敌寇
  ["gongqi"] = "弓骑",
  [":gongqi"] = "出牌阶段限一次，你可以弃置一张牌，此回合你的攻击范围无限。若你以此法弃置的牌为装备牌，你可以弃置一名其他角色的一张牌。",
  ["jiefan"] = "解烦",
  [":jiefan"] = "限定技，出牌阶段，你可以选择一名角色，然后令攻击范围内有该角色的所有角色各选择一项：1.弃置一张武器牌；2.令其摸一张牌。",
  ["#gongqi-choose"] = "弓骑：你可以弃置一名其他角色的一张牌",
  ["#jiefan-discard"] = "解烦：弃置一张武器牌，否则 %dest 摸一张牌",

  ["$gongqi1"] = "看我箭弩弓张，取你性命！",
  ["$gongqi2"] = "龙驹陷阵，神弓破敌！",
  ["$jiefan1"] = "公且放心，这里有我。",
  ["$jiefan2"] = "排愁消烦忧，祛害避凶邪。",
  ["~handang"] = "臣将战死，难为君王解忧了。",
}

local liubiao = General(extension, "liubiao", "qun", 4)
local zishou = fk.CreateTriggerSkill{
  name = "zishou",
  anim_type = "drawcard",
  events = {fk.DrawNCards},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self) and player.phase == Player.Draw and player:isWounded()
  end,
  on_use = function(self, event, target, player, data)
    data.n = data.n + player:getLostHp()
    player:skip(Player.Play)
  end,
}
local zongshi = fk.CreateMaxCardsSkill{
  name = "zongshi",
  correct_func = function(self, player)
    if player:hasSkill(self) then
      local kingdoms = {}
      for _, p in ipairs(Fk:currentRoom().alive_players) do
        table.insertIfNeed(kingdoms, p.kingdom)
      end
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
  ["#liubiao"] = "跨蹈汉南",
  ["designer:liubiao"] = "管乐",
  ["illustrator:liubiao"] = "关东煮",
  ["zishou"] = "自守",
  [":zishou"] = "摸牌阶段，你可以额外摸X张牌（X为你已损失的体力值），然后跳过你的出牌阶段。",
  ["zongshi"] = "宗室",
  [":zongshi"] = "锁定技，场上每有一种势力，你的手牌上限便+1。",

  ["$zishou1"] = "荆襄之地，固若金汤。",
  ["$zishou2"] = "江河霸主，何惧之有？",
  ["$zongshi1"] = "汉室百年，坚如磐石。",
  ["$zongshi2"] = "宗室子弟，尽收民心。",
  ["~liubiao"] = "优柔寡断，要不得啊。",
}

local huaxiong = General(extension, "huaxiong", "qun", 6)
local shiyong = fk.CreateTriggerSkill{
  name = "shiyong",
  mute = true,
  frequency = Skill.Compulsory,
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self) and data.card and data.card.trueName == "slash" then
      if data.card.color == Card.Red then
        return true
      end
      local e = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      if e then
        local use = e.data[1]
        return use.extra_data and use.extra_data.drankBuff
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local audio = 0
    if target == player and player:hasSkill(self) and data.card and data.card.trueName == "slash" then
      if data.card.color == Card.Red then
        audio = 2
      end
      local e = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      if e then
        local use = e.data[1]
        if use.extra_data and use.extra_data.drankBuff then
          if audio == 2 then
            audio = -1
          else
            audio = 1
          end
        end
      end
    end
    player.room:notifySkillInvoked(player, self.name, "negative")
    player:broadcastSkillInvoke(self.name, audio)
    player.room:changeMaxHp(player, -1)
  end,
}
huaxiong:addSkill(shiyong)
Fk:loadTranslationTable{
  ["huaxiong"] = "华雄",
  ["#huaxiong"] = "魔将",
  ["designer:huaxiong"] = "小立",
  ["illustrator:huaxiong"] = "地狱许",
  ["shiyong"] = "恃勇",
  [":shiyong"] = "锁定技，每当你受到一次红色【杀】或【酒】【杀】造成的伤害后，你减1点体力上限。",

  ["$shiyong1"] = "好大一股酒气啊！",
  ["$shiyong2"] = "好大一股杀气啊！",
  ["~huaxiong"] = "皮厚不挡刀啊……",
}

local zhonghui = General(extension, "zhonghui", "wei", 4)
local quanji = fk.CreateTriggerSkill{
  name = "quanji",
  anim_type = "masochism",
  events = {fk.Damaged},
  derived_piles = {"zhonghui_quan"},
  on_trigger = function(self, event, target, player, data)
    self.cancel_cost = false
    for i = 1, data.damage do
      if self.cancel_cost or player.dead then break end
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
    player:drawCards(1, self.name)
    if player:isKongcheng() then return end
    local card = room:askForCard(player, 1, 1, false, self.name, false, ".", "#quanji-card")
    player:addToPile("zhonghui_quan", card, true, self.name)
  end,
}
local quanji_maxcards = fk.CreateMaxCardsSkill{
  name = "#quanji_maxcards",
  correct_func = function(self, player)
    if player:hasSkill(self) then
      return #player:getPile("zhonghui_quan")
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
    return target == player and player:hasSkill(self) and
      player.phase == Player.Start and
      player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  can_wake = function(self, event, target, player, data)
    return #player:getPile("zhonghui_quan") > 2
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:changeMaxHp(player, -1)
    if player.dead then return end
    local choices = {"draw2"}
    if player:isWounded() then
      table.insert(choices, "recover")
    end
    local choice = room:askForChoice(player, choices, self.name)
    if choice == "draw2" then
      player:drawCards(2, self.name)
    else
      room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name
      })
    end
    room:handleAddLoseSkills(player, "paiyi", nil, true, false)
  end,
}
local paiyi = fk.CreateActiveSkill{
  name = "paiyi",
  anim_type = "control",
  card_num = 1,
  target_num = 1,
  expand_pile = "zhonghui_quan",
  can_use = function(self, player)
    return #player:getPile("zhonghui_quan") > 0 and player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Self:getPileNameOfId(to_select) == "zhonghui_quan"
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:moveCards({
      from = player.id,
      ids = effect.cards,
      toArea = Card.DiscardPile,
      moveReason = fk.ReasonPutIntoDiscardPile,
      skillName = self.name,
    })
    if target.dead then return end
    target:drawCards(2, self.name)
    if target:getHandcardNum() > player:getHandcardNum() then
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
  ["#zhonghui"] = "桀骜的野心家",
  ["illustrator:zhonghui"] = "雪君S",
  ["quanji"] = "权计",
  [":quanji"] = "每当你受到1点伤害后，你可以摸一张牌，然后将一张手牌置于武将牌上，称为“权”；每有一张“权”，你的手牌上限便+1。",
  ["zili"] = "自立",
  [":zili"] = "觉醒技，回合开始阶段开始时，若“权”的数量达到3或更多，你须减1点体力上限，然后回复1点体力或摸两张牌，并获得技能“排异”。",
  ["paiyi"] = "排异",
  [":paiyi"] = "出牌阶段，你可以将一张“权”置入弃牌堆，令一名角色摸两张牌，然后若该角色的手牌数大于你的手牌数，你对其造成1点伤害。每阶段限一次。",
  ["zhonghui_quan"] = "权",
  ["#quanji-card"] = "权计：将一张手牌置为“权”",

  ["$quanji1"] = "这仇，我记下了。",
  ["$quanji2"] = "先让你得意几天。",
  ["$zili1"] = "时机已到，今日起兵！",
  ["$zili2"] = "欲取天下，当在此时！",
  ["$paiyi1"] = "妨碍我的人，都得死！",
  ["$paiyi2"] = "此地容不下你！",
  ["~zhonghui"] = "伯约，让你失望了。",
}

return extension

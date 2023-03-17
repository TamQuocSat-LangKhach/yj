local extension = Package("yjcm2012")
extension.extensionName = "yj"

Fk:loadTranslationTable{
  ["yjcm2012"] = "一将成名2012",
}

--local xunyou = General(extension, "xunyou", "wei", 3)
--xunyou:addSkill(zhiyu)
Fk:loadTranslationTable{
  ["xunyou"] = "荀攸",
  ["qice"] = "奇策",
  [":qice"] = "出牌阶段，你可以将所有的手牌（至少一张）当做任意一张非延时类锦囊牌使用。每阶段限一次。",
  ["zhiyu"] = "智愚",
  [":zhiyu"] = "每当你受到一次伤害后，你可以摸一张牌，然后展示所有手牌，若颜色均相同，伤害来源弃置一张手牌。",
}

--local caozhang = General(extension, "caozhang", "wei", 4)
local jiangchi = fk.CreateTriggerSkill{
  name = "jiangchi",
  anim_type = "drawcard",
  events = {fk.DrawNCards},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self.name) and player.phase == Player.Draw
  end,
  on_use = function(self, event, target, player, data)
    local choices = {"jiangchi+1", "jiangchi-1"}
    local choice = player.room:askForChoice(player, choices, self.name)
    if choice == "jiangchi+1" then
      data.n = data.n + 1
    else
      data.n = data.n - 1
    end
    player.room:addPlayerMark(player, "@" .. choice)
  end,

  refresh_events = {fk.EventPhaseStart},
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.NotActive
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@jiangchi+1", 0)
    player.room:setPlayerMark(player, "@jiangchi-1", 0)
  end,
}
local jiangchi_buff = fk.CreateTargetModSkill{
  name = "#jiangchi_buff",
  residue_func = function(self, player, skill, scope)
    if skill.trueName == "slash_skill" and player:getMark("@jiangchi-1") > 0 and scope == Player.HistoryPhase then
      return 1
    end
  end,
  distance_limit_func =  function(self, player, skill)
    if skill.trueName == "slash_skill" and player:getMark("@jiangchi-1") > 0 then
      return 999
    end
  end,
}
jiangchi:addRelatedSkill(jiangchi_buff)
--caozhang:addSkill(jiangchi)
Fk:loadTranslationTable{
  ["caozhang"] = "曹彰",
  ["jiangchi"] = "将驰",
  [":jiangchi"] = "摸牌阶段摸牌时，你可以选择一项：1.额外摸一张牌，若如此做，你不能使用或打出【杀】，直到回合结束。2.少摸一张牌，若如此做，出牌阶段你使用【杀】无距离限制，且你可以额外使用一张【杀】，直到回合结束。",
  ["jiangchi+1"] = "额外摸一张牌",
  ["jiangchi-1"] = "少摸一张牌",
  ["@jiangchi+1"] = "将驰：多摸",
  ["@jiangchi-1"] = "将驰：少摸",
}

local wangyi = General(extension, "wangyi", "wei", 3, 3, General.Female)
local zhenlie = fk.CreateTriggerSkill{
  name = "zhenlie",
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
local miji = fk.CreateTriggerSkill{
  name = "miji",
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
      local to = room:askForChoosePlayers(player, table.map(room:getAlivePlayers(), function(p) return p.id end), 1, 1, "#miji-choose", self.name)[1]
      --TODO: cancelable, default choice...
      to = room:getPlayerById(to)
      to:drawCards(player.maxHp - player.hp, self.name)  --waiting for preview function...
    end
  end,
}
wangyi:addSkill(zhenlie)
wangyi:addSkill(miji)
Fk:loadTranslationTable{
  ["wangyi"] = "王异",
  ["zhenlie"] = "贞烈",
  [":zhenlie"] = "当你的判定牌生效前，你可以亮出牌堆顶的一张牌代替之。",
  ["miji"] = "秘计",
  [":miji"] = "回合开始阶段或回合结束阶段开始时，若你已受伤，你可以进行一次判定，若判定结果为黑色，你观看牌堆顶的X张牌（X为你已损失的体力值），然后将这些牌交给一名角色。",
  ["#miji-choose"] = "选择一名角色获得“秘计”牌",
}

local madai = General(extension, "madai", "shu", 4)
local qianxi = fk.CreateTriggerSkill{
  name = "qianxi",
  anim_type = "offensive",
  events = {fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
      return target == player and player:hasSkill(self.name) and data.card.trueName == "slash" and player:distanceTo(data.to) == 1
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local tar = data.to
    local judge = {
      who = tar,
      reason = self.name,
      pattern = ".|.|spade,club,diamond",
    }
    room:judge(judge)
    if judge.card.suit ~= Card.Heart then
      room:changeMaxHp(tar, -1)
      return true
    end
  end
}
madai:addSkill("mashu")
madai:addSkill(qianxi)
Fk:loadTranslationTable{
  ["madai"] = "马岱",
  ["qianxi"] = "潜袭",
  [":qianxi"] = "每当你使用【杀】对距离为1的目标角色造成伤害时，你可以进行一次判定，若判定结果不为♥，你防止此伤害，改为令其减1点体力上限。",
}

--local liaohua = General(extension, "liaohua", "shu", 4)
--liaohua:addSkill("mashu")
Fk:loadTranslationTable{
  ["liaohua"] = "廖化",
  ["dangxian"] = "当先",
  [":dangxian"] = "锁定技，回合开始时，你执行一个额外的出牌阶段。",
  ["fuli"] = "伏枥",
  [":fuli"] = "限定技，当你处于濒死状态时，你可以将体力值回复至X点（X为现存势力数），然后将你的武将牌翻面。",
}

--local guanxingzhangbao = General(extension, "guanxingzhangbao", "shu", 4)
--guanxingzhangbao:addSkill("mashu")
Fk:loadTranslationTable{
  ["guanxingzhangbao"] = "关兴张苞",
  ["fuhun"] = "父魂",
  [":fuhun"] = "摸牌阶段，你可以放弃摸牌，改为亮出牌堆顶的两张牌并获得之，若亮出的牌颜色不同，你获得技能“武圣”、“咆哮”，直到回合结束。",
}

--local chengpu = General(extension, "chengpu", "wu", 4)
--chengpu:addSkill("wusheng")
Fk:loadTranslationTable{
  ["chengpu"] = "程普",
  ["lihuo"] = "疬火",
  [":lihuo"] = "你可以将一张普通【杀】当火【杀】使用，若此法使用的【杀】造成了伤害，在此【杀】结算后你失去1点体力；你使用火【杀】时，可以额外选择一个目标。",
  ["chunlao"] = "醇醪",
  [":chunlao"] = "回合结束阶段开始时，若你的武将牌上没有牌，你可以将任意数量的【杀】置于你的武将牌上，称为“醇”；当一名角色处于濒死状态时，你可以将一张“醇”置入弃牌堆，视为该角色使用一张【酒】。",
}

--local bulianshi = General(extension, "bulianshi", "wu", 3, 3, General.Female)
--bulianshi:addSkill("xingshang")
Fk:loadTranslationTable{
  ["bulianshi"] = "步练师",
  ["anxu"] = "安恤",
  [":anxu"] = "出牌阶段，你可以选择两名手牌数不相等的其他角色，令其中手牌少的角色获得手牌多的角色一张手牌并展示之，若此牌不为♠，你摸一张牌。每阶段限一次。",
  ["zhuiyi"] = "追忆",
  [":zhuiyi"] = "你死亡时，可以令一名其他角色（杀死你的角色除外）摸三张牌并回复1点体力。",
}

--local handang = General(extension, "handang", "wu", 4)
local gongqi = fk.CreateViewAsSkill{
  name = "gongqi",
  anim_type = "offensive",
  pattern = "slash",
  card_filter = function(self, to_select, selected)
    if #selected == 1 then return false end
    return Fk:getCardById(to_select).type == Card.TypeEquip
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then
      return nil
    end
    local c = Fk:cloneCard("slash")
    c:addSubcard(cards[1])
    return c
  end,
}
local gongqiTargetMod = fk.CreateTargetModSkill{
  name = "#gongqiTargetMod",
  distance_limit_func =  function(self, player, skill)
    if player:hasSkill(self.name) then  --FIXME
      return 999
    end
  end,
}
gongqi:addRelatedSkill(gongqiTargetMod)
--handang:addSkill(gongqi)
Fk:loadTranslationTable{
  ["handang"] = "韩当",
  ["gongqi"] = "弓骑",
  [":gongqi"] = "你可以将一张装备牌当【杀】使用或打出；你以此法使用的【杀】无距离限制。",
  ["jiefan"] = "解烦",
  [":jiefan"] = "你的回合外，当一名角色处于濒死状态时，你可以对当前回合角色使用一张【杀】，此【杀】造成伤害时，你防止此伤害，视为对该濒死角色使用了一张【桃】。",
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
liubiao:addSkill(zishou)
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
    return target == player and target:hasSkill(self.name) and not target.dead and
    data.card.trueName == "slash" and data.card.color == Card.Red  --FIXME: drank damage
  end,
  on_use = function(self, event, target, player, data)
    player.room:changeMaxHp(player, -1)
  end
}
huaxiong:addSkill(shiyong)
Fk:loadTranslationTable{
  ["huaxiong"] = "华雄",
  ["shiyong"] = "恃勇",
  [":shiyong"] = "锁定技，每当你受到一次红色【杀】或【酒】【杀】造成的伤害后，你减1点体力上限。",
}

--local zhonghui = General(extension, "zhonghui", "wei", 4)
--zhonghui:addSkill("jianxiong")
Fk:loadTranslationTable{
  ["zhonghui"] = "钟会",
  ["quanji"] = "权计",
  [":quanji"] = "每当你受到1点伤害后，你可以摸一张牌，然后将一张手牌置于武将牌上，称为“权”；每有一张“权”，你的手牌上限便+1。",
  ["zili"] = "自立",
  [":zili"] = "觉醒技，回合开始阶段开始时，若“权”的数量达到3或更多，你须减1点体力上限，然后回复1点体力或摸两张牌，并获得技能“排异”。",
  ["paiyi"] = "排异",
  [":paiyi"] = "出牌阶段，你可以将一张“权”置入弃牌堆，令一名角色摸两张牌，然后若该角色的手牌数大于你的手牌数，你对其造成1点伤害。每阶段限一次。",
}

return extension

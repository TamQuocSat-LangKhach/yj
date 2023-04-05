local extension = Package("yjcm2011")
extension.extensionName = "yj"

Fk:loadTranslationTable{
  ["yjcm2011"] = "一将成名2011",
}

--local caozhi = General(extension, "caozhi", "wei", 3)
--caozhi:addSkill(jiushi)
Fk:loadTranslationTable{
  ["caozhi"] = "曹植",
  ["luoying"] = "落英",
  [":luoying"] = "当其他角色的♣牌，因弃牌或判定而进入弃牌堆时，你可以获得之。",
  ["jiushi"] = "酒诗",
  [":jiushi"] = "若你的武将牌正面朝上，你可以（在合理的时机）将你的武将牌翻面来视为使用一张【酒】。当你的武将牌背面朝上时你受到伤害，你可在伤害结算后将之翻回正面。",
}

local yujin = General(extension, "yujin", "wei", 4)
local yizhong = fk.CreateTriggerSkill{
  name = "yizhong",
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  events = {fk.PreCardEffect},
  can_trigger = function(self, event, target, player, data)
    return player.id == data.to and player:hasSkill(self.name) and data.card.trueName == "slash" and data.card.color == Card.Black and player:getEquipment(Card.SubtypeWeapon) == nil
  end,
  on_use = function()
    return true
  end,
}
yujin:addSkill(yizhong)
Fk:loadTranslationTable{
  ["yujin"] = "于禁",
  ["yizhong"] = "毅重",
  [":yizhong"] = "锁定技，当你没有装备防具时，黑色的【杀】对你无效。",
}

local zhangchunhua = General(extension, "zhangchunhua", "wei", 3, 3, General.Female)
local jueqing = fk.CreateTriggerSkill{
  name = "jueqing",
  anim_type = "offensive",
  frequency = Skill.Compulsory,
  events = {fk.DamageCaused},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name)
  end,
  on_use = function(self, event, target, player, data)
    player.room:loseHp(data.to, data.damage, self.name)
    return true
  end,
}
local shangshi = fk.CreateTriggerSkill{
  name = "shangshi",
  anim_type = "drawcard",
  events = {fk.HpChanged, fk.MaxHpChanged, fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) and #player.player_cards[Player.Hand] < player:getLostHp() then
      if event == fk.AfterCardsMove then
        return true
      else
        return target == player
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(player:getLostHp() - #player.player_cards[Player.Hand], self.name)
  end,
}
zhangchunhua:addSkill(jueqing)
zhangchunhua:addSkill(shangshi)
Fk:loadTranslationTable{
  ["zhangchunhua"] = "张春华",
  ["jueqing"] = "绝情",
  [":jueqing"] = "锁定技，你造成的伤害均视为体力流失。",
  ["shangshi"] = "伤逝",
  [":shangshi"] = "除弃牌阶段外，每当你的手牌数小于你已损失的体力值时，可立即将手牌数补至等同于你已损失的体力值。",
}

local fazheng = General(extension, "fazheng", "shu", 3)
local enyuan = fk.CreateTriggerSkill{
  name = "enyuan",
  mute = true,
  anim_type = "masochism",
  frequency = Skill.Compulsory,
  events = {fk.HpRecover ,fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(self.name) then
      if event ==  fk.HpRecover then
        return data.recoverBy ~= nil and data.recoverBy ~= player.id and not player.room:getPlayerById(data.recoverBy).dead
      else
        return data.from ~= nil and data.from ~= player and not data.from.dead
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event ==  fk.HpRecover then
      room:getPlayerById(data.recoverBy):drawCards(data.num)
    else
      if data.from:isKongcheng() then
        room:loseHp(data.from, 1, self.name)
      else
        local card = room:askForCard(data.from, 1, 1, false, self.name, true, ".|.|heart|hand|.|.")
        if #card > 0 then
          room:obtainCard(player, Fk:getCardById(cards[1]), true, fk.ReasonGive)
        else
          room:loseHp(data.from, 1, self.name)
        end
      end
    end
  end,
}
local xuanhuo = fk.CreateActiveSkill{
  name = "xuanhuo",
  anim_type = "control",
  target_num = 1,
  card_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) == 0 and not player:isKongcheng()
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:getCardById(to_select).suit == Card.Heart and Fk:currentRoom():getCardArea(to_select) ~= Player.Equip
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:obtainCard(target, Fk:getCardById(effect.cards[1]), false, fk.ReasonGive)
    local card = room:askForCardChosen(player, target, "he", self.name)
    room:obtainCard(player.id, card, false, fk.ReasonPrey)
    local to
    local tos = room:askForChoosePlayers(player, table.map(room:getOtherPlayers(target), function(p) return p.id end), 1, 1, "#xuanhuo-choose", self.name)
    if #tos > 0 then
      to = tos[1]
    else
      to = player.id
    end
    if to ~= player.id then
      room:obtainCard(to, card, false, fk.ReasonGive)
    end
  end,
}
fazheng:addSkill(enyuan)
fazheng:addSkill(xuanhuo)
Fk:loadTranslationTable{
  ["fazheng"] = "法正",
  ["enyuan"] = "恩怨",
  [":enyuan"] = "锁定技，其他角色每令你回复1点体力，该角色摸一张牌；其他角色每对你造成一次伤害，须给你一张♥手牌，否则该角色失去1点体力。",
  ["xuanhuo"] = "眩惑",
  [":xuanhuo"] = "出牌阶段，你可将一张♥手牌交给一名其他角色，然后，你获得该角色的一张牌并立即交给除该角色外的其他角色。每回合限一次。",
  ["#xuanhuo-choose"] = "眩惑：选择获得这张牌的角色",
}

--local masu = General(extension, "masu", "shu", 3)
local huilei = fk.CreateTriggerSkill{
  name = "huilei",
  anim_type = "control",
  events = {fk.Death},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name, false, true)

  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
  end,
}
Fk:loadTranslationTable{
  ["masu"] = "马谡",
  ["xinzhan"] = "心战",
  [":xinzhan"] = "出牌阶段，若你的手牌数大于你的体力上限，你可以观看牌堆顶的三张牌，然后展示其中任意数量的♥牌并获得之，其余以任意顺序置于牌堆顶。每回合限一次。",
  ["huilei"] = "挥泪",
  [":huilei"] = "锁定技，杀死你的角色立即弃置所有牌。",
}

local xushu = General(extension, "xushu", "shu", 3)
local wuyan = fk.CreateTriggerSkill{
  name = "wuyan",
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  events = {fk.PreCardEffect},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self.name) and data.card.type == Card.TypeTrick and data.card.sub_type ~= Card.SubtypeDelayedTrick and data.card.name ~= "nullification" then
      if player.id == data.from then
        return player.id ~= data.to
      end
      if player.id == data.to then
        return player.id ~= data.from
      end
    end
  end,
  on_use = function()
    return true
  end,
}
local jujian = fk.CreateActiveSkill{
  name = "jujian",
  anim_type = "support",
  target_num = 1,
  min_card_num = 1,
  max_card_num = 3,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) == 0 and not player:isNude()
  end,
  card_filter = function(self, to_select, selected)
    return #selected < 3
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:throwCard(effect.cards, self.name, player, player)
    room:drawCards(target, #effect.cards, self.name)
    if player:isWounded() and #effect.cards == 3 then
      for _, id in ipairs(effect.cards) do
        if Fk:getCardById(id).type ~= Fk:getCardById(effect.cards[1]).type then
          return
        end
      end
      room:recover({
        who = player,
        num = 1,
        recoverBy = player,
        skillName = self.name
      })
    end
  end
}
xushu:addSkill(wuyan)
xushu:addSkill(jujian)
Fk:loadTranslationTable{
  ["xushu"] = "徐庶",
  ["wuyan"] = "无言",
  [":wuyan"] = "锁定技，你使用的非延时类锦囊对其他角色无效；其他角色使用的非延时类锦囊对你无效。",
  ["jujian"] = "举荐",
  [":jujian"] = "出牌阶段，你可以弃至多三张牌，然后让一名其他角色摸等量的牌，若你以此法弃牌不少于三张且均为同一类别，你回复1点体力。每回合限一次。",
}

--local lingtong = General(extension, "lingtong", "wu", 4)
Fk:loadTranslationTable{
  ["lingtong"] = "凌统",
  ["xuanfeng"] = "旋风",
  [":xuanfeng"] = "每当你失去一次装备区里的牌时，你可以执行下列两项中的一下：1.视为对任意一名其他角色使用一张【杀】（此【杀】不计入每回合的使用限制）；2.对与你距离1以内的一名其他角色造成1点伤害。",
}

--local wuguotai = General(extension, "wuguotai", "wu", 3, 3, General.Female)
Fk:loadTranslationTable{
  ["wuguotai"] = "吴国太",
  ["ganlu"] = "甘露",
  [":ganlu"] = "出牌阶段，你可以选择两名角色，交换他们装备区里的所有牌，以此法交换的装备牌数量不能超过X（X为你已损失体力值）。每回合限一次。",
  ["buyi"] = "补益",
  [":buyi"] = "当有角色进入濒死状态时，你可以展示该角色的一张手牌：若此牌不为基本牌，则该角色弃掉这张牌并回复1点体力。",
}

local xusheng = General(extension, "xusheng", "wu", 4)
local pojun = fk.CreateTriggerSkill{
  name = "pojun",
  anim_type = "control",
  events = {fk.Damage},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and data.card ~= nil and data.card.trueName == "slash" and not data.to.dead
  end,
  on_use = function(self, event, target, player, data)
    data.to:drawCards(math.min(data.to.hp, 5))
    data.to:turnOver()
  end
}
xusheng:addSkill(pojun)
Fk:loadTranslationTable{
  ["xusheng"] = "徐盛",
  ["pojun"] = "破军",
  [":pojun"] = "你每使用【杀】造成一次伤害，可令受到该伤害的角色摸X张牌，X为该角色当前的体力值（X最多为5），然后该角色将其武将牌翻面。",
}

Fk:loadTranslationTable{
  ["gaoshun"] = "高顺",
  ["xianzhen"] = "陷阵",
  [":xianzhen"] = "出牌阶段，你可以与一名角色拼点，若你赢，你获得以下技能直到回合结束：无视与该角色的距离及其防具牌；可对该角色使用任意数量的【杀】。若你没赢，你不能使用【杀】直到回合结束。每回合限一次。",
  ["jinjiu"] = "禁酒",
  [":jinjiu"] = "锁定技，你的【酒】均视为【杀】。",
}

local chengong = General(extension, "chengong", "qun", 3)
local mingce = fk.CreateActiveSkill{
  name = "mingce",
  anim_type = "support",
  target_num = 1,
  card_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name) == 0 and not player:isKongcheng()
  end,
  card_filter = function(self, to_select, selected)
    return #selected == 0 and (Fk:getCardById(to_select).trueName == "slash" or Fk:getCardById(to_select).type == Card.TypeEquip)
  end,
  target_filter = function(self, to_select, selected)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    room:obtainCard(target, Fk:getCardById(effect.cards[1]), false, fk.ReasonGive)
    local targets = {}
    for _, p in ipairs(room:getOtherPlayers(target)) do
      if target:inMyAttackRange(p) then  --TODO: target filter
        table.insert(targets, p.id)
      end
    end
    if #targets == 0 then
      target:drawCards(1, self.name)
    else
      local tos = room:askForChoosePlayers(player, targets, 1, 1, "#mingce-choose", self.name)
      local to
      if #tos > 0 then
        to = tos[1]
      else
        to = targets[math.random(1, #targets)]
      end
      local choice = room:askForChoice(target, {"mingce_slash", "draw1"}, self.name)
      if choice == "mingce_slash" then
        local slash = Fk:cloneCard("slash")
        room:useCard({
          card = slash,
          from = target.id,
          tos = {{to}},
        })
      else
        target:drawCards(1, self.name)
      end
    end
  end,
}
local zhichi = fk.CreateTriggerSkill{
  name = "zhichi",
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  events = {fk.Damaged},
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(self.name) and player.phase == Player.NotActive
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@zhichi", 1)
  end,

  refresh_events = {fk.PreCardEffect, fk.EventPhaseStart},
  can_refresh = function(self, event, target, player, data)
    if player:hasSkill(self.name, true) then
      if event == fk.PreCardEffect then
        return player.id == data.to and (data.card.trueName == "slash" or (data.card.type == Card.TypeTrick and data.card.sub_type ~= Card.SubtypeDelayedTrick))
      else
        return target.phase == Player.NotActive
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    if event == fk.PreCardEffect then
      return true
    else
      player.room:setPlayerMark(player, "@zhichi", 0)
    end
  end,
}
chengong:addSkill(mingce)
chengong:addSkill(zhichi)
Fk:loadTranslationTable{
  ["chengong"] = "陈宫",
  ["mingce"] = "明策",
  [":mingce"] = "出牌阶段，你可以给其他任一角色一张装备牌或【杀】，该角色进行二选一：1.视为对其攻击范围内的另一名由你指定的角色使用一张【杀】；2.摸一张牌。每回合限一次。",
  ["zhichi"] = "智迟",
  [":zhichi"] = "锁定技，你的回合外，你每受到一次伤害，任何【杀】或非延时类锦囊对你无效，直到该回合结束。",
  ["#mingce-choose"] = "明策：选择视为使用【杀】的目标",
  ["@zhichi"] = "智迟",
}

return extension

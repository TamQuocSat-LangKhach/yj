local nos__enyuan = fk.CreateSkill {
  name = "nos__enyuan"
}

Fk:loadTranslationTable{
  ['nos__enyuan'] = '恩怨',
  ['#nos__enyuan-give'] = '恩怨：你需交给 %src 一张<font color=>♥</font>手牌，否则失去1点体力',
  [':nos__enyuan'] = '锁定技，其他角色每令你回复1点体力，该角色摸一张牌；其他角色每对你造成一次伤害，须给你一张<font color=>♥</font>手牌，否则该角色失去1点体力。',
  ['$nos__enyuan1'] = '得人恩果千年记。',
  ['$nos__enyuan2'] = '滴水之恩，涌泉相报。',
  ['$nos__enyuan3'] = '谁敢得罪我？',
  ['$nos__enyuan4'] = '睚眦之怨，无不报复。',
}

nos__enyuan:addEffect(fk.HpRecover, {
  mute = true,
  anim_type = "masochism",
  frequency = Skill.Compulsory,
  can_trigger = function(skill, event, target, player, data)
    if target == player and player:hasSkill(nos__enyuan.name) then
      return data.recoverBy and data.recoverBy ~= player and not data.recoverBy.dead
    end
  end,
  on_use = function(skill, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(nos__enyuan.name, math.random(1,2))
    room:notifySkillInvoked(player, nos__enyuan.name, "support")
    data.recoverBy:drawCards(data.num, nos__enyuan.name)
  end,
})

nos__enyuan:addEffect(fk.Damaged, {
  mute = true,
  anim_type = "masochism",
  frequency = Skill.Compulsory,
  can_trigger = function(skill, event, target, player, data)
    if target == player and player:hasSkill(nos__enyuan.name) then
      return data.from and data.from ~= player and not data.from.dead
    end
  end,
  on_use = function(skill, event, target, player, data)
    local room = player.room
    player:broadcastSkillInvoke(nos__enyuan.name, math.random(3,4))
    room:notifySkillInvoked(player, nos__enyuan.name)
    room:doIndicate(player.id, {data.from.id})
    if data.from:isKongcheng() then
      room:loseHp(data.from, 1, nos__enyuan.name)
    else
      local card = room:askToCards(data.from, {
        min_num = 1,
        max_num = 1,
        include_equip = false,
        pattern = ".|.|heart|hand|.|.",
        prompt = "#nos__enyuan-give:" .. player.id,
        skill_name = nos__enyuan.name,
      })
      if #card > 0 then
        room:obtainCard(player, card[1], true, fk.ReasonGive, data.from.id, nos__enyuan.name)
      else
        room:loseHp(data.from, 1, nos__enyuan.name)
      end
    end
  end,
})

return nos__enyuan
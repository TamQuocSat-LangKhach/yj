local miji = fk.CreateSkill {
  name = "miji"
}

Fk:loadTranslationTable{
  ['miji'] = '秘计',
  ['#miji-invoke'] = '秘计：是否将 %arg 张手牌分配给其他角色',
  [':miji'] = '结束阶段，你可以摸X张牌（X为你已损失的体力值），然后你可以将等量的手牌分配给其他角色。',
  ['$miji1'] = '此计，可歼敌精锐！',
  ['$miji2'] = '此举，可破敌之围！'
}

miji:addEffect(fk.EventPhaseStart, {
  can_trigger = function(skill, event, target, player)
    return target == player and player:hasSkill(skill.name) and player.phase == Player.Finish and player:isWounded()
  end,
  on_use = function(skill, event, target, player)
    local room = player.room
    local n = player:getLostHp()
    player:drawCards(n, miji.name)
    if player:getHandcardNum() >= n and room:askToSkillInvoke(player, { skill_name = miji.name, prompt = "#miji-invoke:::" .. n }) then
      room:askToYiji(player, {
        cards = player:getCardIds("h"),
        targets = room:getOtherPlayers(player),
        skill_name = miji.name,
        minNum = n,
        maxNum = n
      })
    end
  end,
})

return miji
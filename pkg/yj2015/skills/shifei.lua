local shifei = fk.CreateSkill {
  name = "shifei"
}

Fk:loadTranslationTable{
  ['shifei'] = '饰非',
  ['#shifei-viewas'] = '是否使用 饰非，令%dest摸一张牌',
  ['#shifei-choose'] = '饰非：弃置全场手牌最多的一名角色的一张牌',
  [':shifei'] = '当你需要使用或打出【闪】时，你可以令当前回合角色摸一张牌，然后若其手牌数不是全场唯一最多的，你弃置一名手牌全场最多的角色一张牌，视为你使用或打出一张【闪】。',
  ['$shifei1'] = '良谋失利，罪在先锋！',
  ['$shifei2'] = '计略周详，怎奈指挥不当。',
}

shifei:addEffect('viewas', {
  anim_type = "defensive",
  prompt = function(skill, player)
    for _, p in ipairs(Fk:currentRoom().alive_players) do
    if p.phase ~= Player.NotActive then
      return "#shifei-viewas::" .. p.id
    end
    end
  end,
  pattern = "jink",
  card_num = 0,
  card_filter = Util.FalseFunc,
  before_use = function(skill, player)
    local room = player.room
    local current = room.current
    if current:isAlive() then
    room:drawCards(current, 1, skill.name)
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
      local tos = room:askToChoosePlayers(player, {
        targets = Fk:getPlayerByIds(targets),
        min_num = 1,
        max_num = 1,
        prompt = "#shifei-choose",
        skill_name = skill.name,
        cancelable = false
      })
      local to = tos[1]
      local id = room:askToChooseCard(player, {
        target = to,
        flag = "he",
        skill_name = skill.name
      })
      room:throwCard({id}, skill.name, to, player)
      return
      end
    end
    end
    return skill.name
  end,
  view_as = function(skill, player, cards)
    local c = Fk:cloneCard("jink")
    c.skillName = skill.name
    return c
  end,
  enabled_at_response = function (skill, player)
    for _, p in ipairs(Fk:currentRoom().alive_players) do
    if p.phase ~= Player.NotActive then
      return true
    end
    end
  end,
})

return shifei
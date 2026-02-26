local ziqu = fk.CreateSkill{
  name = "xh__ziqu",
}

Fk:loadTranslationTable{
  ["xh__ziqu"] = "资取",
  [":xh__ziqu"] = "限定技，当你对对手造成伤害时，你可以防止此伤害，令其展示所有手牌并交给你一张点数最大的牌，然后你回复1点体力或摸两张牌。",
  
  ["#xh__ziqu-invoke"] = "资取：是否防止对 %dest 造成的伤害，改为令其展示所有手牌并交给你一张点数最大的牌？",
  ["#xh__ziqu-give"] = "资取：你需要交给 %src 一张点数最大的牌",
  ["#xh__ziqu-choose"] = "资取：你需要选择回复1点体力或摸两张牌",
  
  ["$xh__ziqu1"] = "兵马已动，尔等速将粮草缴来。",
  ["$xh__ziqu2"] = "留财不留命，留命不留财。",
}

ziqu:addEffect(fk.DetermineDamageCaused, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(ziqu.name) and player ~= data.to and
      not table.contains(player:getTableMark(ziqu.name), data.to.id)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = ziqu.name,
      prompt = "#xh__ziqu-invoke::"..data.to.id,
    }) then
      event:setCostData(self, {tos = {data.to}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    data:preventDamage()
    room:addTableMark(player, ziqu.name, data.to.id)
    
    -- 展示对手所有手牌
    local handcards = data.to:getCardIds("he")
    room:showCards(data.to, handcards, player)
    
    -- 交给玩家一张点数最大的牌
    if not data.to:isNude() then
      local max_card = nil
      for _, id in ipairs(handcards) do
        local card = Fk:getCardById(id)
        if not max_card or card.number > Fk:getCardById(max_card).number then
          max_card = id
        end
      end
      -- 向玩家交出最大点数的牌
      local card = room:askToCards(data.to, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = ziqu.name,
        pattern = tostring(Exppattern{ id = {max_card} }),
        prompt = "#xh__ziqu-give:"..player.id,
        cancelable = false,
      })
      room:obtainCard(player, card, true, fk.ReasonGive, data.to, ziqu.name)
    end
    
    -- 选择回复体力或摸牌
    local choice = room:askToChoice(player, {
      choices = {"回复1点体力", "摸两张牌"},
      skill_name = ziqu.name,
      prompt = "#xh__ziqu-choose",
    })
    if choice == "回复1点体力" then
      player:recover(1, ziqu.name)
    elseif choice == "摸两张牌" then
      player:drawCards(2, ziqu.name)
    end
  end,
})

return ziqu
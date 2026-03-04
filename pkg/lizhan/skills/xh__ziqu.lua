local ziqu = fk.CreateSkill{
  name = "xh__ziqu",
  frequency = Skill.Limited,
  limit_mark = "@@xh__ziqu",
}

Fk:loadTranslationTable{
  ["xh__ziqu"] = "资取",
  [":xh__ziqu"] = "限定技，当你对对手造成伤害时，你可以防止此伤害，令其展示所有手牌并交给你一张点数最大的牌，然后你回复1点体力或摸两张牌。",

  ["@@xh__ziqu"] = "资取",

  ["#xh__ziqu-invoke"] = "资取：是否防止对 %dest 造成的伤害，改为令其展示所有手牌并交给你一张点数最大的牌？",
  ["#xh__ziqu-give"] = "资取：你需交给 %src 一张点数最大的手牌",
  ["#xh__ziqu-choose"] = "资取：请选择回复1点体力或摸两张牌",
  ["xh__ziqu_recover"] = "回复1点体力",
  ["xh__ziqu_draw"] = "摸两张牌",

  ["$xh__ziqu1"] = "兵马已动，尔等速将粮草缴来。",
  ["$xh__ziqu2"] = "留财不留命，留命不留财。",
}

-- 修复点1：补齐限定技初始标记为1，避免无法触发
ziqu:addEffect(fk.TurnStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player
      and player:hasSkill(ziqu.name)
      and player:usedSkillTimes(ziqu.name, Player.HistoryGame) == 0
      and player:getMark("@@xh__ziqu") == 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@xh__ziqu", 1)
    room:updateAllLimitSkillUI(player)
  end,
})

ziqu:addEffect(fk.DetermineDamageCaused, {
  anim_type = "control",

  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if not player:hasSkill(ziqu.name) then return false end
    if player:getMark("@@xh__ziqu") == 0 then return false end
    if not data or not data.to or data.to == player then return false end
    if data.damage <= 0 then return false end
    return true
  end,

  on_cost = function(self, event, target, player, data)
    local room = player.room
    return room:askToSkillInvoke(player, {
      skill_name = ziqu.name,
      prompt = "#xh__ziqu-invoke:::" .. data.to.id,
    })
  end,

  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = data.to
    local skillName = ziqu.name

    -- 防止伤害
    data:preventDamage()

    -- 消耗限定技
    room:setPlayerMark(player, "@@xh__ziqu", 0)
    room:updateAllLimitSkillUI(player)

    if to.dead then return end

    -- 修复点2：正确使用 showCards 的参数形式
    local handcards = to:getCardIds("h")
    if handcards and #handcards > 0 then
      room:showCards(handcards, to)

      local max_num = -1
      for _, id in ipairs(handcards) do
        local c = Fk:getCardById(id)
        if c.number > max_num then
          max_num = c.number
        end
      end

      local candidates = {}
      for _, id in ipairs(handcards) do
        local c = Fk:getCardById(id)
        if c.number == max_num then
          table.insert(candidates, id)
        end
      end

      local give_ids
      if #candidates == 1 then
        give_ids = { candidates[1] }
      else
        give_ids = room:askToCards(to, {
          min_num = 1,
          max_num = 1,
          include_equip = false,
          skill_name = skillName,
          pattern = tostring(Exppattern{ id = candidates }),
          prompt = "#xh__ziqu-give:" .. player.id,
          cancelable = false,
        })
      end

      if give_ids and #give_ids > 0 and not player.dead then
        room:obtainCard(player, give_ids, true, fk.ReasonGive, to, skillName)
      end
    else
      -- 没有手牌也视为展示为空即可，不强制调用 showCards
    end

    if player.dead then return end

    local choice = room:askToChoice(player, {
      choices = { "xh__ziqu_recover", "xh__ziqu_draw" },
      skill_name = skillName,
      prompt = "#xh__ziqu-choose",
    })

    if choice == "xh__ziqu_recover" then
      player:recover(1, skillName)
    else
      player:drawCards(2, skillName)
    end
  end,
})

return ziqu
local yaohu = fk.CreateSkill {
  name = "xh__yaohu",
}

Fk:loadTranslationTable{
  ["xh__yaohu"] = "邀虎",
  [":xh__yaohu"] = "每轮限一次，你的回合开始时，你须选择场上一个势力。被你选择势力的其他角色出牌阶段开始时，其获得你的一张“生”，然后其直到本阶段结束时，若其使用伤害牌指定你为目标时，须交给你两张牌，否则取消之。",
  
  ["#xh__yaohu-choice"] = "邀虎：选择你要“邀虎”的势力",
  ["@xh__yaohu"] = "邀虎",
  ["#xh__yaohu-slash"] = "邀虎：你需对 %dest 使用一张【杀】，否则本阶段使用伤害牌指定 %src 为目标时需交给其两张牌",
  ["#xh__yaohu-give"] = "邀虎：你需交给 %src 两张牌，否则其取消此%arg",
  
  ["$xh__yaohu1"] = "益州疲敝，还望贤兄相助。",
  ["$xh__yaohu2"] = "内讨米贼，外拒强曹，璋无宗兄万万不可啊。",
}

yaohu:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(yaohu.name) and player.phase == Player.Start
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- 选择场上一个势力
    local kingdoms = {}
    for _, p in ipairs(room.alive_players) do
      table.insertIfNeed(kingdoms, p.kingdom)
    end
    local choice = room:askToChoice(player, {
      choices = kingdoms,
      skill_name = yaohu.name,
      prompt = "#xh__yaohu-choice",
    })
    -- 设置标记，标记当前选择的势力
    room:setPlayerMark(player, "@yaohu", choice)
  end,
})

yaohu:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(yaohu.name) and target ~= player and target.phase == Player.Play and not target.dead and
      player:getMark("@yaohu") == target.kingdom and #player:getPile("liuzhang_sheng") > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- 将“生”给目标角色
    local id = room:askToChooseCard(target, {
      target = player,
      flag = "he",
      skill_name = yaohu.name,
    })
    room:obtainCard(target, id, true, fk.ReasonPrey, target, yaohu.name)
    if player.dead or target.dead then return end

    -- 让目标角色使用伤害牌时的处理
    local targets = table.filter(room:getOtherPlayers(player, false), function(p)
      return target:inMyAttackRange(p)
    end)
    if #targets == 0 then
      room:addTableMark(target, "@@yaohu-phase", player.id)
    else
      local to = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 1,
        targets = targets,
        skill_name = yaohu.name,
        prompt = "#xh__yaohu-slash::"..player.id,
        cancelable = false,
        no_indicate = true,
      })[1]
      room:doIndicate(target, {to})
      -- 伤害牌使用时的处理
      local use = room:askToUseCard(target, {
        skill_name = yaohu.name,
        pattern = "slash",
        prompt = "#xh__yaohu-slash:"..player.id..":"..to.id,
        extra_data = {
          exclusive_targets = {to.id},
          bypass_times = true,
        }
      })
      if use then
        use.extraUse = true
        room:useCard(use)
      else
        room:addTableMark(target, "@@yaohu-phase", player.id)
      end
    end
  end,
})

yaohu:addEffect(fk.TargetSpecifying, {
  anim_type = "defensive",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    return data.to == player and table.contains(target:getTableMark("@@yaohu-phase"), player.id) and
      data.card.is_damage_card and not data.cancelled
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if #target:getCardIds("he") < 2 then
      data:cancelCurrentTarget()
    else
      local cards = room:askToCards(target, {
        min_num = 2,
        max_num = 2,
        include_equip = true,
        skill_name = yaohu.name,
        prompt = "#xh__yaohu-give:"..player.id.."::"..data.card:toLogString(),
        cancelable = true,
      })
      if #cards == 2 then
        room:obtainCard(player, cards, false, fk.ReasonGive, target, yaohu.name)
      else
        data:cancelCurrentTarget()
      end
    end
  end,
})

return yaohu
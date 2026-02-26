local neifa = fk.CreateSkill{
  name = "neifa",
}

Fk:loadTranslationTable{
  ["neifa"] = "内伐",
  [":neifa"] = "出牌阶段开始时，你可以摸一张牌，然后弃置一张牌并选择一项：1.此阶段你不能使用锦囊牌且【杀】的使用次数+1；2.此阶段你不能使用基本牌，使用普通锦囊牌指定目标后你可以摸一张牌；3.此阶段你使用装备牌后，可以弃置对手一张牌。",
  
  ["@neifa-turn"] = "内伐",
  ["neifa_choice1"] = "不能使用锦囊牌，且【杀】的使用次数+1",
  ["neifa_choice2"] = "不能使用基本牌，使用普通锦囊牌后可以摸一张牌",
  ["neifa_choice3"] = "使用装备牌后，可以弃置对手一张牌",
  ["#neifa-choose"] = "内伐：请选择一个选项",

  ["$neifa1"] = "自相恩残，相煎何急。",
  ["$neifa2"] = "同室内伐，贻笑外人。",
}

neifa:addEffect(fk.EventPhaseStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(neifa.name) and player.phase == Player.Play
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- 选择项
    local choices = {"neifa_choice1", "neifa_choice2", "neifa_choice3"}
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = neifa.name,
    })
    
    -- 玩家弃置一张牌
    local card = room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = neifa.name,
      prompt = "#neifa-discard",
      cancelable = false,
      skip = true,
    })
    room:throwCard(card, neifa.name, player, player)

    -- 处理玩家选择的效果
    if choice == "neifa_choice1" then
      -- 不能使用锦囊牌且【杀】的使用次数+1
      room:addPlayerMark(player, MarkEnum.SlashResidue.."-phase", 1)
      player:getTableMark("@neifa-turn") -- 标记玩家选择的效果
    elseif choice == "neifa_choice2" then
      -- 不能使用基本牌，使用普通锦囊牌后可以摸一张牌
      room:setPlayerMark(player, "@neifa-turn", "non_basic_char")
    elseif choice == "neifa_choice3" then
      -- 使用装备牌后，可以弃置对手一张牌
      room:setPlayerMark(player, "@neifa-turn", "equip_char")
    end
  end,
})

neifa:addEffect(fk.CardUsing, {
  anim_type = "drawcard",
  is_delay_effect = true,
  can_trigger = function(self, event, target, player, data)
    if not player.dead and target == player and data.card.type == Card.TypeEquip then
      return player:usedEffectTimes(self.name, Player.HistoryTurn) < 2
    end
    return false
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    -- 如果选了“使用装备牌后弃置对手一张牌”，则弃置对方一张牌
    local room = player.room
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player),
      skill_name = neifa.name,
      prompt = "#neifa-choose",
      cancelable = false,
    })[1]
    local card = room:askToChooseCard(player, {
      target = to,
      flag = "h",
      skill_name = neifa.name,
    })
    room:throwCard(card, neifa.name, to, player)
  end,
})

-- 更新【杀】的使用次数
neifa:addEffect("prohibit", {
  prohibit_use = function(self, player, card)
    local mark = player:getTableMark("@neifa-turn")
    if card:isCommonTrick() then
      return table.contains(mark, "non_basic_char")
    end
    return false
  end,
})

return neifa
-- SPDX-License-Identifier: GPL-3.0-or-later
-- 张济 - 掠命技能
-- 出牌阶段限一次，你可以令一名装备区的牌数小于你的其他角色声明一个点数，
-- 然后你进行判定，若结果的点数与其声明的：相同，你对其造成2点伤害；不同，其交给你一张手牌。

local lueling = fk.CreateSkill {
  name = "xh__lueling",
}

Fk:loadTranslationTable {
  ["xh__lueling"] = "掠命",
  [":xh__lueling"] = "出牌阶段限一次，你可以令一名装备区的牌数小于你的其他角色声明一个点数，"..
    "然后你进行判定，若结果的点数与其声明的：相同，你对其造成2点伤害；不同，其交给你一张手牌。",

  ["#xh__lueling-target"] = "掠命：选择一名装备区牌数小于你的角色",
  ["#xh__lueling-declare"] = "掠命：声明一个点数",

  ["$xh__lueling1"] = "掠命之威，谁敢不从！",
  ["$xh__lueling2"] = "命悬一线，掠命为生！",
}

lueling:addEffect("active", {
  mute = true,
  prompt = "#xh__lueling-target",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(lueling.name, Player.HistoryPhase) == 0 and
      #player:getCardIds("e") > 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected > 0 then return false end
    return to_select ~= player and #to_select:getCardIds("e") < #player:getCardIds("e")
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]

    room:notifySkillInvoked(player, lueling.name, "offensive", {target})
    player:broadcastSkillInvoke(lueling.name)

    -- 声明一个点数
    local numbers = {}
    for i = 1, 13 do
      table.insert(numbers, tostring(i))
    end
    
    local declared_num = room:askToChoice(target, {
      choices = numbers,
      skill_name = lueling.name,
      prompt = "#xh__lueling-declare",
      detailed = false,
    })
    
    local declared = tonumber(declared_num)
    
    -- 判定
    local judge = room:judge{
      who = player,
      reason = lueling.name,
    }
    
    if judge.card.number == declared then
      -- 相同：造成2点伤害
      room:damage{
        from = player,
        to = target,
        damage = 2,
        skillName = lueling.name,
      }
    else
      -- 不同：交给你一张手牌
      if not target:isKongcheng() then
        local id = room:askToCards(target, {
          min_num = 1,
          max_num = 1,
          include_equip = false,
          skill_name = lueling.name,
          pattern = ".",
          prompt = "选择一张手牌交给" .. player.name,
          cancelable = false,
        })
        room:moveCardTo(id[1], Player.Hand, player, fk.ReasonGive, lueling.name, nil, false, target.id)
      end
    end
  end,
})

return lueling

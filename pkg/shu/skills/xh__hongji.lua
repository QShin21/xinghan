-- SPDX-License-Identifier: GPL-3.0-or-later
-- 张世平 - 鸿济技能
-- 每轮各限一次，每名角色的准备阶段，若其手牌数为全场最多/最少，
-- 你可以令其于本回合下个摸牌/出牌阶段结束后执行一次额外的摸牌/出牌阶段。

local hongji = fk.CreateSkill {
  name = "xh__hongji",
}

Fk:loadTranslationTable {
  ["xh__hongji"] = "鸿济",
  [":xh__hongji"] = "每轮各限一次，每名角色的准备阶段，若其手牌数为全场最多/最少，"..
    "你可以令其于本回合下个摸牌/出牌阶段结束后执行一次额外的摸牌/出牌阶段。",

  ["#xh__hongji-most"] = "鸿济：令 %dest 执行额外的摸牌阶段",
  ["#xh__hongji-least"] = "鸿济：令 %dest 执行额外的出牌阶段",
  ["@@xh__hongji_extra_draw"] = "鸿济摸牌",
  ["@@xh__hongji_extra_play"] = "鸿济出牌",

  ["$xh__hongji1"] = "鸿济天下，惠及苍生！",
  ["$xh__hongji2"] = "济世救人，义不容辞！",
}

hongji:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(hongji.name) then return false end
    if target.phase ~= Player.Start then return false end
    
    -- 检查是否已使用过
    local used_most = player:getMark("@@hongji_most_used") or 0
    local used_least = player:getMark("@@hongji_least_used") or 0
    if used_most >= 1 and used_least >= 1 then return false end
    
    -- 计算手牌数最多和最少的角色
    local handcard_nums = {}
    for _, p in ipairs(player.room.alive_players) do
      table.insert(handcard_nums, p:getHandcardNum())
    end
    local max_num = math.max(table.unpack(handcard_nums))
    local min_num = math.min(table.unpack(handcard_nums))
    
    local target_num = target:getHandcardNum()
    if target_num == max_num and used_most < 1 then return true end
    if target_num == min_num and used_least < 1 then return true end
    
    return false
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local handcard_nums = {}
    for _, p in ipairs(room.alive_players) do
      table.insert(handcard_nums, p:getHandcardNum())
    end
    local max_num = math.max(table.unpack(handcard_nums))
    local min_num = math.min(table.unpack(handcard_nums))
    
    local target_num = target:getHandcardNum()
    local used_most = player:getMark("@@hongji_most_used") or 0
    local used_least = player:getMark("@@hongji_least_used") or 0
    
    local choices = {}
    if target_num == max_num and used_most < 1 then
      table.insert(choices, "most")
    end
    if target_num == min_num and used_least < 1 then
      table.insert(choices, "least")
    end
    
    if #choices == 0 then return false end
    
    local choice
    if #choices == 1 then
      choice = choices[1]
    else
      choice = room:askToChoice(player, {
        choices = {"most", "least"},
        skill_name = hongji.name,
        prompt = "选择一项效果",
        detailed = false,
      })
    end
    
    event:setCostData(self, {choice = choice})
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = event:getCostData(self).choice
    
    if choice == "most" then
      room:addPlayerMark(player, "@@hongji_most_used", 1)
      room:addPlayerMark(target, "@@hongji_extra_draw", 1)
    else
      room:addPlayerMark(player, "@@hongji_least_used", 1)
      room:addPlayerMark(target, "@@hongji_extra_play", 1)
    end
  end,
})

-- 额外摸牌阶段
hongji:addEffect(fk.EventPhaseEnd, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Draw and
      player:getMark("@@hongji_extra_draw") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@hongji_extra_draw", 0)
    
    -- 执行额外的摸牌阶段
    player:drawCards(2, hongji.name)
  end,
})

-- 额外出牌阶段
hongji:addEffect(fk.EventPhaseEnd, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target == player and player.phase == Player.Play and
      player:getMark("@@hongji_extra_play") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@hongji_extra_play", 0)
    
    -- 执行额外的出牌阶段（简化处理：摸一张牌）
    player:drawCards(1, hongji.name)
  end,
})

-- 轮次结束清除标记
hongji:addEffect(fk.RoundEnd, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:getMark("@@hongji_most_used") > 0 or player:getMark("@@hongji_least_used") > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@hongji_most_used", 0)
    room:setPlayerMark(player, "@@hongji_least_used", 0)
  end,
})

return hongji

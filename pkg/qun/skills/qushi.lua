-- SPDX-License-Identifier: GPL-3.0-or-later
-- 郭图 - 趋势技能
-- 出牌阶段限一次，你可以摸一张牌，然后扣置一张手牌于一名其他角色武将牌上，称为"趋"。
-- 其结束阶段移去"趋"，然后若其本回合使用过与"趋"类型相同的牌，
-- 你摸X张牌（X为其本回合使用牌指定过的目标数且至多为5）。

local qushi = fk.CreateSkill {
  name = "qushi",
}

Fk:loadTranslationTable {
  ["qushi"] = "趋势",
  [":qushi"] = "出牌阶段限一次，你可以摸一张牌，然后扣置一张手牌于一名其他角色武将牌上，称为\"趋\"。"..
    "其结束阶段移去\"趋\"，然后若其本回合使用过与\"趋\"类型相同的牌，"..
    "你摸X张牌（X为其本回合使用牌指定过的目标数且至多为5）。",

  ["#qushi-target"] = "趋势：选择一名其他角色",
  ["@@qushi_qu"] = "趋",

  ["$qushi1"] = "趋势之计，智取天下！",
  ["$qushi2"] = "郭图趋势，天下无双！",
}

qushi:addEffect("active", {
  mute = true,
  prompt = "#qushi-target",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(qushi.name, Player.HistoryPhase) == 0 and not player:isKongcheng()
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected, selected_cards)
    if #selected > 0 then return false end
    return to_select ~= player
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]

    room:notifySkillInvoked(player, qushi.name, "control", {target})
    player:broadcastSkillInvoke(qushi.name)

    -- 摸一张牌
    player:drawCards(1, qushi.name)
    
    -- 扣置一张手牌
    local card = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = qushi.name,
      pattern = ".",
      prompt = "选择一张手牌扣置",
      cancelable = false,
    })
    
    local card_type = Fk:getCardById(card[1]).type
    room:moveCardTo(card, Card.Processing, target, fk.ReasonPut, qushi.name)
    room:setPlayerMark(target, "@@qushi_qu", {id = card[1], type = card_type, from = player.id})
  end,
})

-- 结束阶段处理
qushi:addEffect(fk.EventPhaseStart, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if player.phase ~= Player.Finish then return false end
    
    local qu = player:getMark("@@qushi_qu")
    return qu and qu ~= 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local qu = player:getMark("@@qushi_qu")
    
    -- 移去趋
    room:moveCardTo(qu.id, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, qushi.name)
    room:setPlayerMark(player, "@@qushi_qu", 0)
    
    -- 检查是否使用过相同类型的牌
    local used_types = player:getMark("@@qushi_used_types") or {}
    if table.contains(used_types, qu.type) then
      local from = room:getPlayerById(qu.from)
      if from and not from.dead then
        local target_count = player:getMark("@@qushi_target_count") or 0
        local draw_num = math.min(target_count, 5)
        from:drawCards(draw_num, qushi.name)
      end
    end
  end,
})

return qushi

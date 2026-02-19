-- SPDX-License-Identifier: GPL-3.0-or-later
-- 段煨 - 狼灭技能
-- 对手的结束阶段，你可以选择一项：
-- 1.若其本回合使用过两张或更多同类型的牌，你弃置一张牌并摸两张牌；
-- 2.若其本回合造成了2点或更多伤害，你弃置一张牌对其造成1点伤害。

local langmie = fk.CreateSkill {
  name = "langmie",
}

Fk:loadTranslationTable {
  ["langmie"] = "狼灭",
  [":langmie"] = "对手的结束阶段，你可以选择一项："..
    "1.若其本回合使用过两张或更多同类型的牌，你弃置一张牌并摸两张牌；"..
    "2.若其本回合造成了2点或更多伤害，你弃置一张牌对其造成1点伤害。",

  ["#langmie-invoke"] = "狼灭：选择一项效果",
  ["langmie_draw"] = "弃置一张牌并摸两张牌",
  ["langmie_damage"] = "弃置一张牌对其造成1点伤害",
  ["@@langmie_card_types"] = "狼灭牌类型",
  ["@@langmie_damage_count"] = "狼灭伤害计数",

  ["$langmie1"] = "狼灭之威，势不可挡！",
  ["$langmie2"] = "段煨狼灭，天下无双！",
}

langmie:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target == player or not player:hasSkill(langmie.name) then return false end
    if target.phase ~= Player.Finish then return false end
    if player:isNude() then return false end
    
    local card_types = target:getMark("@@langmie_card_types") or {}
    local damage_count = target:getMark("@@langmie_damage_count") or 0
    
    -- 检查是否满足条件
    local has_same_type = false
    for _, count in pairs(card_types) do
      if count >= 2 then
        has_same_type = true
        break
      end
    end
    
    return has_same_type or damage_count >= 2
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    
    local card_types = target:getMark("@@langmie_card_types") or {}
    local damage_count = target:getMark("@@langmie_damage_count") or 0
    
    local choices = {}
    
    -- 检查同类型牌
    local has_same_type = false
    for _, count in pairs(card_types) do
      if count >= 2 then
        has_same_type = true
        break
      end
    end
    if has_same_type then
      table.insert(choices, "langmie_draw")
    end
    
    -- 检查伤害
    if damage_count >= 2 then
      table.insert(choices, "langmie_damage")
    end
    
    if #choices == 0 then return false end
    
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = langmie.name,
      prompt = "#langmie-invoke",
      detailed = false,
    })
    
    event:setCostData(self, {choice = choice, to = target})
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = event:getCostData(self).choice
    local to = event:getCostData(self).to
    
    -- 弃置一张牌
    local id = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = langmie.name,
      pattern = ".",
      prompt = "选择一张牌弃置",
      cancelable = false,
    })
    room:throwCard(id, langmie.name, player, player)
    
    if choice == "langmie_draw" then
      player:drawCards(2, langmie.name)
    else
      room:damage{
        from = player,
        to = to,
        damage = 1,
        skillName = langmie.name,
      }
    end
  end,
})

-- 记录使用的牌类型
langmie:addEffect(fk.CardUsing, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target and target.phase == Player.Play and data.card
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card_types = target:getMark("@@langmie_card_types") or {}
    
    local type_name = data.card.type
    card_types[type_name] = (card_types[type_name] or 0) + 1
    
    room:setPlayerMark(target, "@@langmie_card_types", card_types)
  end,
})

-- 记录造成的伤害
langmie:addEffect(fk.Damage, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target and target.phase == Player.Play
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local damage_count = target:getMark("@@langmie_damage_count") or 0
    room:setPlayerMark(target, "@@langmie_damage_count", damage_count + 1)
  end,
})

-- 回合结束清除标记
langmie:addEffect(fk.TurnEnd, {
  mute = true,
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@langmie_card_types") ~= 0 or player:getMark("@@langmie_damage_count") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@langmie_card_types", 0)
    room:setPlayerMark(player, "@@langmie_damage_count", 0)
  end,
})

return langmie

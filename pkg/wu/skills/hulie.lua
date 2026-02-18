-- SPDX-License-Identifier: GPL-3.0-or-later
-- 孙坚 - 虎烈技能
-- 每回合各限一次，你使用【杀】或【决斗】仅指定一名角色为目标后，
-- 你可令此牌伤害+1，此牌结算后若其体力值小于你，其视为对你使用一张【杀】。

local hulie = fk.CreateSkill {
  name = "hulie",
}

Fk:loadTranslationTable {
  ["hulie"] = "虎烈",
  [":hulie"] = "每回合各限一次，你使用【杀】或【决斗】仅指定一名角色为目标后，"..
    "你可令此牌伤害+1，此牌结算后若其体力值小于你，其视为对你使用一张【杀】。",

  ["#hulie-invoke"] = "虎烈：令此牌伤害+1",
  ["@@hulie_slash"] = "虎烈杀",
  ["@@hulie_duel"] = "虎烈决斗",

  ["$hulie1"] = "虎烈之威，势不可挡！",
  ["$hulie2"] = "江东猛虎，谁敢争锋！",
}

hulie:addEffect(fk.TargetSpecifying, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(hulie.name) then return false end
    
    local card = data.card
    if not card then return false end
    if card.trueName ~= "slash" and card.trueName ~= "duel" then return false end
    
    -- 检查是否仅指定一名目标
    if #data.use.tos ~= 1 then return false end
    
    -- 检查本回合是否已发动
    local mark = card.trueName == "slash" and "@@hulie_slash" or "@@hulie_duel"
    if player:getMark(mark) > 0 then return false end
    
    return true
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = hulie.name,
      prompt = "#hulie-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = data.card
    
    -- 标记已发动
    local mark = card.trueName == "slash" and "@@hulie_slash" or "@@hulie_duel"
    room:setPlayerMark(player, mark, data.use.tos[1])
    
    -- 伤害+1
    data.extra_data = data.extra_data or {}
    data.extra_data.hulie_damage = true
  end,
})

-- 伤害+1
hulie:addEffect(fk.DamageCaused, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(hulie.name) then return false end
    if not data.card then return false end
    return data.extra_data and data.extra_data.hulie_damage
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + 1
  end,
})

-- 结算后检查
hulie:addEffect(fk.CardUseFinished, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    
    local card = data.card
    if not card then return false end
    if card.trueName ~= "slash" and card.trueName ~= "duel" then return false end
    
    local mark = card.trueName == "slash" and "@@hulie_slash" or "@@hulie_duel"
    local target_id = player:getMark(mark)
    
    return target_id and target_id > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = data.card
    local mark = card.trueName == "slash" and "@@hulie_slash" or "@@hulie_duel"
    local target_id = player:getMark(mark)
    
    room:setPlayerMark(player, mark, 0)
    
    local target = room:getPlayerById(target_id)
    if target and not target.dead and target.hp < player.hp then
      local slash = Fk:cloneCard("slash")
      slash.skillName = hulie.name
      room:useCard{
        from = target.id,
        tos = {player.id},
        card = slash,
      }
    end
  end,
})

return hulie

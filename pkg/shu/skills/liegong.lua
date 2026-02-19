-- SPDX-License-Identifier: GPL-3.0-or-later
-- 黄忠 - 烈弓技能
-- 你使用【杀】可选择在此【杀】点数距离内的对手为目标。
-- 当你使用【杀】指定目标后，你可以根据下列条件执行相应的效果：
-- 1.若你的手牌数大于等于其手牌数，该角色不能使用【闪】；
-- 2.若你的体力值小于等于其体力值，此【杀】对其伤害+1。

local liegong = fk.CreateSkill {
  name = "liegong",
}

Fk:loadTranslationTable {
  ["liegong"] = "烈弓",
  [":liegong"] = "你使用【杀】可选择在此【杀】点数距离内的对手为目标。"..
    "当你使用【杀】指定目标后，你可以根据下列条件执行相应的效果："..
    "1.若你的手牌数大于等于其手牌数，该角色不能使用【闪】；"..
    "2.若你的体力值小于等于其体力值，此【杀】对其伤害+1。",

  ["#liegong-effect"] = "烈弓：选择执行的效果",
  ["liegong_no_jink"] = "令其不能使用闪",
  ["liegong_damage"] = "令此杀伤害+1",

  ["$liegong1"] = "烈弓射日，百步穿杨！",
  ["$liegong2"] = "老当益壮，不减当年！",
}

-- 扩大杀的目标范围
liegong:addEffect("targetmod", {
  distance_limit_func = function(self, player, skill, card, to)
    if player:hasSkill(liegong.name) and card and card.trueName == "slash" then
      return card.number
    end
    return 0
  end,
})

liegong:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target ~= player or not player:hasSkill(liegong.name) then return false end
    if not data.card or data.card.trueName ~= "slash" then return false end
    return true
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local to = room:getPlayerById(data.to)
    
    local choices = {}
    
    -- 手牌数条件
    if player:getHandcardNum() >= to:getHandcardNum() then
      table.insert(choices, "liegong_no_jink")
    end
    
    -- 体力值条件
    if player.hp <= to.hp then
      table.insert(choices, "liegong_damage")
    end
    
    if #choices == 0 then return false end
    
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = liegong.name,
      prompt = "#liegong-effect",
      detailed = false,
    })
    
    event:setCostData(self, {choice = choice, to = to})
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = event:getCostData(self).choice
    local to = event:getCostData(self).to
    
    if choice == "liegong_no_jink" then
      room:addPlayerMark(to, "@@liegong_no_jink", 1)
    else
      data.extra_data = data.extra_data or {}
      data.extra_data.liegong_damage = true
    end
  end,
})

-- 不能使用闪
liegong:addEffect(fk.CardEffecting, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:getMark("@@liegong_no_jink") > 0 and
      data.card and data.card.trueName == "slash"
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    if data.responseTo then
      data.responseTo = nil
    end
  end,
})

-- 伤害+1
liegong:addEffect(fk.DamageCaused, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if not data.card or data.card.trueName ~= "slash" then return false end
    return data.extra_data and data.extra_data.liegong_damage
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.damage = data.damage + 1
  end,
})

-- 回合结束清除标记
liegong:addEffect(fk.TurnEnd, {
  mute = true,
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@liegong_no_jink") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@liegong_no_jink", 0)
  end,
})

return liegong

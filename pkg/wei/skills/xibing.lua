-- SPDX-License-Identifier: GPL-3.0-or-later
-- 华歆 - 息兵技能
-- 每回合限一次，当一名其他角色在其出牌阶段内使用黑色【杀】或黑色普通锦囊牌指定唯一角色为目标后，
-- 你可令该角色将手牌摸至当前体力值（至多摸至五张）。若其因此摸牌，则其本回合不能再使用牌。

local xibing = fk.CreateSkill {
  name = "xibing",
}

Fk:loadTranslationTable {
  ["xibing"] = "息兵",
  [":xibing"] = "每回合限一次，当一名其他角色在其出牌阶段内使用黑色【杀】或黑色普通锦囊牌指定唯一角色为目标后，"..
    "你可令该角色将手牌摸至当前体力值（至多摸至五张）。若其因此摸牌，则其本回合不能再使用牌。",

  ["#xibing-invoke"] = "息兵：令 %dest 摸牌至体力值",
  ["@@xibing_no_use"] = "息兵",

  ["$xibing1"] = "息兵止战，休养生息！",
  ["$xibing2"] = "兵者不祥之器，不得已而用之！",
}

xibing:addEffect(fk.TargetConfirmed, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(xibing.name) then return false end
    if target == player then return false end
    if target.phase ~= Player.Play then return false end
    if player:usedEffectTimes(xibing.name, Player.HistoryTurn) > 0 then return false end

    local card = data.card
    if not card then return false end

    -- 检查是否为黑色杀或黑色普通锦囊牌
    if card.color ~= Card.Black then return false end
    if card.trueName ~= "slash" and card.type ~= Card.TypeTrick then return false end

    -- 检查是否指定唯一目标
    if #data.use.tos ~= 1 then return false end

    return true
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = xibing.name,
      prompt = "#xibing-invoke::" .. target.id,
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    -- 计算摸牌数
    local hp = target.hp
    local handcard_num = target:getHandcardNum()
    local max_draw = math.min(5, hp) - handcard_num

    if max_draw > 0 then
      target:drawCards(max_draw, xibing.name)

      -- 设置不能使用牌标记
      room:setPlayerMark(target, "@@xibing_no_use", 1)
    end
  end,
})

-- 不能使用牌
xibing:addEffect(fk.CardUsing, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return target:getMark("@@xibing_no_use") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.cancel = true
  end,
})

-- 回合结束清除标记
xibing:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@xibing_no_use") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@xibing_no_use", 0)
  end,
})

return xibing

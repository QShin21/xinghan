-- SPDX-License-Identifier: GPL-3.0-or-later
-- 刘备(蜀) - 仁望技能
-- 当对手于其出牌阶段内对你使用【杀】或普通锦囊牌时，若你不是此阶段第一次成为上述牌的目标，
-- 则你可以弃置其一张牌。

local renwang = fk.CreateSkill {
  name = "xh__renwang",
}

Fk:loadTranslationTable {
  ["xh__renwang"] = "仁望",
  [":xh__renwang"] = "当对手于其出牌阶段内对你使用【杀】或普通锦囊牌时，若你不是此阶段第一次成为上述牌的目标，"..
    "则你可以弃置其一张牌。",

  ["#xh__renwang-invoke"] = "仁望：你可以弃置 %dest 一张牌",
  ["@@xh__renwang_target_count"] = "仁望目标计数",

  ["$xh__renwang1"] = "仁望天下，德服四方！",
  ["$xh__renwang2"] = "以德服人，不战而屈人之兵！",
}

renwang:addEffect(fk.TargetConfirmed, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(renwang.name) then return false end
    if target == player then return false end  -- 对手使用
    if target.phase ~= Player.Play then return false end
    
    local card = data.card
    if not card then return false end
    
    -- 检查是否为杀或普通锦囊牌
    if card.trueName ~= "slash" and card.type ~= Card.TypeTrick then return false end
    
    -- 检查是否为第二次成为目标
    local count = player:getMark("@@renwang_target_count") or 0
    if count < 1 then return false end
    
    return true
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = renwang.name,
      prompt = "#xh__renwang-invoke::" .. target.id,
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    
    if not target:isNude() then
      local id = room:askToChooseCard(player, {
        target = target,
        flag = "he",
        skill_name = renwang.name,
      })
      room:throwCard(id, renwang.name, target, player)
    end
  end,
})

-- 记录成为目标次数
renwang:addEffect(fk.TargetConfirmed, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if not data.card then return false end
    
    local card = data.card
    if card.trueName ~= "slash" and card.type ~= Card.TypeTrick then return false end
    
    return true
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local count = player:getMark("@@renwang_target_count") or 0
    room:setPlayerMark(player, "@@renwang_target_count", count + 1)
  end,
})

-- 阶段结束清除标记
renwang:addEffect(fk.EventPhaseEnd, {
  can_trigger = function(self, event, target, player, data)
    return player:getMark("@@renwang_target_count") ~= 0 and
      player.phase == Player.Play
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@renwang_target_count", 0)
  end,
})

return renwang

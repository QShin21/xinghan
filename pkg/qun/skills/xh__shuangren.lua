-- SPDX-License-Identifier: GPL-3.0-or-later
-- 纪灵 - 双刃技能
-- 出牌阶段开始时，你可以与一名角色拼点：若你赢，你视为对与其势力相同的一至两名角色（若为两名，则须包含该角色）使用一张【杀】；
-- 若你没赢，你此阶段不能使用【杀】。

local shuangren = fk.CreateSkill {
  name = "xh__shuangren",
}

Fk:loadTranslationTable {
  ["xh__shuangren"] = "双刃",
  [":xh__shuangren"] = "出牌阶段开始时，你可以与一名角色拼点：若你赢，你视为对与其势力相同的一至两名角色（若为两名，则须包含该角色）使用一张【杀】；"..
    "若你没赢，你此阶段不能使用【杀】。",

  ["#xh__shuangren-target"] = "双刃：选择一名角色进行拼点",
  ["@@xh__shuangren_no_slash"] = "双刃禁止杀",

  ["$xh__shuangren1"] = "双刃齐出，势不可挡！",
  ["$xh__shuangren2"] = "纪灵在此，谁敢争锋！",
}

shuangren:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shuangren.name) and
      player.phase == Player.Play and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function(p)
      return p ~= player and not p:isKongcheng()
    end)
    
    if #targets == 0 then return false end
    
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = shuangren.name,
      prompt = "#xh__shuangren-target",
      cancelable = true,
    })
    
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    
    local pindian = room:pindian({player, to}, shuangren.name)
    
    if pindian.results[player].winner then
      -- 赢了：对同势力角色使用杀
      local kingdom = to.kingdom
      local same_kingdom = table.filter(room.alive_players, function(p)
        return p.kingdom == kingdom
      end)
      
      -- 选择1-2名角色
      local targets = room:askToChoosePlayers(player, {
        min_num = 1,
        max_num = 2,
        targets = same_kingdom,
        skill_name = shuangren.name,
        prompt = "选择1-2名同势力角色",
        cancelable = false,
      })
      
      -- 如果选2名，必须包含to
      if #targets == 2 and not table.contains(targets, to) then
        targets = {to}
      end
      
      local slash = Fk:cloneCard("slash")
      slash.skillName = shuangren.name
      
      room:useCard{
        from = player.id,
        tos = table.map(targets, function(p) return p.id end),
        card = slash,
      }
    else
      -- 输了：此阶段不能使用杀
      room:setPlayerMark(player, "@@shuangren_no_slash", 1)
    end
  end,
})

-- 不能使用杀
shuangren:addEffect("prohibit", {
  is_prohibited = function(self, from, to, card)
    if from:getMark("@@shuangren_no_slash") > 0 and card.trueName == "slash" then
      return true
    end
    return false
  end,
})

-- 回合结束清除标记
shuangren:addEffect(fk.TurnEnd, {
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player:getMark("@@shuangren_no_slash") > 0
  end,
  on_use = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@shuangren_no_slash", 0)
  end,
})

return shuangren

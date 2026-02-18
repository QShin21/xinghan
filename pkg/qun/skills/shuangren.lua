-- SPDX-License-Identifier: GPL-3.0-or-later
-- 纪灵 - 双刃技能
-- 出牌阶段开始时，你可以与一名角色拼点：
-- 若你赢，你视为对与其势力相同的一至两名角色（若为两名，则须包含该角色）使用一张【杀】；
-- 若你没赢，你此阶段不能使用【杀】。

local shuangren = fk.CreateSkill {
  name = "shuangren",
}

Fk:loadTranslationTable {
  ["shuangren"] = "双刃",
  [":shuangren"] = "出牌阶段开始时，你可以与一名角色拼点："..
    "若你赢，你视为对与其势力相同的一至两名角色（若为两名，则须包含该角色）使用一张【杀】；"..
    "若你没赢，你此阶段不能使用【杀】。",

  ["#shuangren-choose"] = "双刃：选择一名角色进行拼点",
  ["#shuangren-target"] = "双刃：选择一至两名与 %dest 同势力的角色使用【杀】",
  ["@@shuangren_no_slash"] = "双刃",

  ["$shuangren1"] = "双刃出鞘，必见血光！",
  ["$shuangren2"] = "双刀合璧，天下无敌！",
}

shuangren:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(shuangren.name) and
      player.phase == Player.Play and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room

    local targets = table.filter(room:getOtherPlayers(player), function(p)
      return not p:isKongcheng()
    end)

    if #targets == 0 then return false end

    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = shuangren.name,
      prompt = "#shuangren-choose",
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

    -- 拼点
    local pindian = room:pindian({player, to}, shuangren.name)

    if pindian.results[player].winner then
      -- 赢了：对同势力角色使用杀
      local kingdom = to.kingdom
      local targets = table.filter(room:getOtherPlayers(player), function(p)
        return p.kingdom == kingdom
      end)

      if #targets > 0 then
        local slash_targets = room:askToChoosePlayers(player, {
          min_num = 1,
          max_num = 2,
          targets = targets,
          skill_name = shuangren.name,
          prompt = "#shuangren-target::" .. to.id,
          cancelable = false,
        })

        -- 若为两名，须包含该角色
        if #slash_targets == 2 and not table.contains(slash_targets, to) then
          slash_targets = {to}
        end

        local slash = Fk:cloneCard("slash")
        slash.skillName = shuangren.name

        room:useCard{
          from = player.id,
          tos = table.map(slash_targets, function(p) return p.id end),
          card = slash,
        }
      end
    else
      -- 输了：此阶段不能使用杀
      room:setPlayerMark(player, "@@shuangren_no_slash", 1)
    end
  end,
})

-- 不能使用杀
shuangren:addEffect(fk.CardUsing, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if not data.card or data.card.trueName ~= "slash" then return false end
    return player:getMark("@@shuangren_no_slash") > 0
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data.cancel = true
  end,
})

-- 回合结束清除标记
shuangren:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  can_refresh = function(self, event, target, player, data)
    return player:getMark("@@shuangren_no_slash") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@shuangren_no_slash", 0)
  end,
})

return shuangren

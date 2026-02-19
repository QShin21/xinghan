-- SPDX-License-Identifier: GPL-3.0-or-later
-- 曹仁 - 励战技能
-- 结束阶段，你可以令任意名已受伤角色摸一张牌。

local lizhan = fk.CreateSkill {
  name = "xh__lizhan",
}

Fk:loadTranslationTable {
  ["xh__lizhan"] = "励战",
  [":xh__lizhan"] = "结束阶段，你可以令任意名已受伤角色摸一张牌。",

  ["#xh__lizhan-choose"] = "励战：选择任意名已受伤角色摸一张牌",

  ["$xh__lizhan1"] = "励战之士，奋勇杀敌！",
  ["$xh__lizhan2"] = "身先士卒，鼓舞军心！",
}

lizhan:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xh__lizhan.name) and
      player.phase == Player.Finish
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room

    local targets = table.filter(room.alive_players, function(p)
      return p:isWounded()
    end)

    if #targets == 0 then return false end

    local tos = room:askToChoosePlayers(player, {
      min_num = 0,
      max_num = #targets,
      targets = targets,
      skill_name = xh__lizhan.name,
      prompt = "#lizhan-choose",
      cancelable = true,
    })

    if #tos > 0 then
      event:setCostData(self, {tos = tos})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local tos = event:getCostData(self).tos

    for _, p in ipairs(tos) do
      if not p.dead then
        p:drawCards(1, xh__lizhan.name)
      end
    end
  end,
})

return lizhan

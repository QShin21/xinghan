-- SPDX-License-Identifier: GPL-3.0-or-later
-- 田丰 - 死谏技能
-- 当你失去手牌后，若你没有手牌，你可以弃置一名其他角色的一张牌。

local sijian = fk.CreateSkill {
  name = "xh__sijian",
}

Fk:loadTranslationTable {
  ["xh__sijian"] = "死谏",
  [":xh__sijian"] = "当你失去手牌后，若你没有手牌，你可以弃置一名其他角色的一张牌。",

  ["#xh__sijian-invoke"] = "死谏：你可以弃置一名其他角色的一张牌",

  ["$xh__sijian1"] = "死谏君王，虽死无悔！",
  ["$xh__sijian2"] = "忠言逆耳，死谏不悔！",
}

sijian:addEffect(fk.AfterCardsMove, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(sijian.name) then return false end
    if not player:isKongcheng() then return false end

    -- 检查是否因失去牌而变成空手牌
    for _, move in ipairs(data) do
      if move.from == player.id and move.toArea ~= Player.Hand then
        return true
      end
    end
    return false
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player), function(p)
      return not p:isNude()
    end)

    if #targets == 0 then return false end

    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = sijian.name,
      prompt = "#xh__sijian-invoke",
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

    local id = room:askToChooseCard(player, {
      target = to,
      flag = "he",
      skill_name = sijian.name,
    })
    room:throwCard(id, sijian.name, to, player)
  end,
})

return sijian

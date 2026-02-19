-- SPDX-License-Identifier: GPL-3.0-or-later
-- 张辽 - 突袭技能
-- 摸牌阶段，你可以少摸任意张牌，然后获得等量名有手牌的其他角色的各一张手牌。

local tuxi = fk.CreateSkill {
  name = "xh__tuxi",
}

Fk:loadTranslationTable {
  ["xh__tuxi"] = "突袭",
  [":xh__tuxi"] = "摸牌阶段，你可以少摸任意张牌，然后获得等量名有手牌的其他角色的各一张手牌。",

  ["#xh__tuxi-choose"] = "突袭：选择要少摸的牌数",
  ["#xh__tuxi-target"] = "突袭：选择 %arg 名有手牌的角色，获得其各一张手牌",
  ["#xh__tuxi-card"] = "突袭：选择 %dest 的一张手牌",

  ["$xh__tuxi1"] = "哼，没想到吧！",
  ["$xh__tuxi2"] = "拿来吧！",
}

tuxi:addEffect(fk.DrawNCards, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    if target == player and player:hasSkill(xh__tuxi.name) and data.num > 0 then
      local room = player.room
      return table.find(room:getOtherPlayers(player), function(p)
        return not p:isKongcheng()
      end)
    end
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room

    -- 获取有手牌的其他角色数量
    local targets = table.filter(room:getOtherPlayers(player), function(p)
      return not p:isKongcheng()
    end)

    if #targets == 0 then return false end

    -- 选择少摸的牌数
    local max_num = math.min(data.num, #targets)
    local choices = {}
    for i = 1, max_num do
      table.insert(choices, tostring(i))
    end

    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = xh__tuxi.name,
      prompt = "#tuxi-choose",
      detailed = false,
    })

    if choice then
      local num = tonumber(choice)
      event:setCostData(self, {num = num})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local num = event:getCostData(self).num

    -- 少摸牌
    data.num = data.num - num

    -- 选择目标
    local targets = table.filter(room:getOtherPlayers(player), function(p)
      return not p:isKongcheng()
    end)

    local chosen = room:askToChoosePlayers(player, {
      min_num = num,
      max_num = num,
      targets = targets,
      skill_name = xh__tuxi.name,
      prompt = "#tuxi-target::" .. num,
      cancelable = false,
    })

    -- 获得每个目标的一张手牌
    for _, p in ipairs(chosen) do
      if not p:isKongcheng() then
        local id = room:askToChooseCard(player, {
          target = p,
          flag = "h",
          skill_name = xh__tuxi.name,
        })
        room:moveCardTo(id, Player.Hand, player, fk.ReasonPrey, xh__tuxi.name, nil, false, p.id)
      end
    end
  end,
})

return tuxi

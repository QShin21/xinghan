-- SPDX-License-Identifier: GPL-3.0-or-later
-- 董卓 - 横征技能
-- 准备阶段，若你的体力值为1或你没有手牌，你可以获得一名其他角色区域里的一张牌。

local hengzheng = fk.CreateSkill {
  name = "xh__hengzheng",
}

Fk:loadTranslationTable {
  ["xh__hengzheng"] = "横征",
  [":xh__hengzheng"] = "准备阶段，若你的体力值为1或你没有手牌，你可以获得一名其他角色区域里的一张牌。",

  ["#xh__hengzheng-invoke"] = "横征：获得一名其他角色区域里的一张牌",

  ["$xh__hengzheng1"] = "天下之大，何人敢不从！",
  ["$xh__hengzheng2"] = "顺我者昌，逆我者亡！",
}

hengzheng:addEffect(fk.EventPhaseStart, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xh__hengzheng.name) and
      player.phase == Player.Start and
      (player.hp == 1 or player:isKongcheng())
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room:getOtherPlayers(player), function(p)
      return not p:isAllNude()
    end)

    if #targets == 0 then return false end

    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = xh__hengzheng.name,
      prompt = "#hengzheng-invoke",
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
      flag = "hej",
      skill_name = xh__hengzheng.name,
    })

    room:moveCardTo(id, Player.Hand, player, fk.ReasonPrey, xh__hengzheng.name, nil, false, to.id)
  end,
})

return hengzheng

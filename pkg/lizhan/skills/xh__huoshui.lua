local huoshui = fk.CreateSkill {
  name = "xh__huoshui",
}

Fk:loadTranslationTable{
  ["xh__huoshui"] = "祸水",
  [":xh__huoshui"] = "准备阶段，你可以令一名手牌数小于等于你已损失的体力值的其他角色执行你选择的效果（至少执行1项，最多执行X项，X为你已损失的体力值且至少为1）：1.本回合非锁定技失效；2.交给你1张手牌；3.弃置装备区里的所有牌。",
  
  ["#xh__huoshui-choose"] = "祸水：你需要选择一项效果：<br>1.本回合非锁定技失效；2.交给你一张手牌；3.弃置装备区里的所有牌",
  ["xh__huoshui_tip1"] = "非锁定技失效",
  ["xh__huoshui_tip2"] = "交出手牌",
  ["xh__huoshui_tip3"] = "弃置装备",
  ["#xh__huoshui-give"] = "祸水：你需交给 %src 一张手牌",

  ["$xh__huoshui1"] = "呵呵，走不动了嘛。",
  ["$xh__huoshui2"] = "别走了，再玩一会儿嘛。",
}

Fk:addTargetTip{
  name = "xh__huoshui",
  target_tip = function(self, player, to_select, selected, selected_cards, card, selectable)
    if table.contains(selected, to_select) then
      return "xh__huoshui_tip"..table.indexOf(selected, to_select)
    end
  end,
}

huoshui:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(huoshui.name) and player.phase == Player.Start and
      #player.room:getOtherPlayers(player, false) > 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local lost_hp = math.max(1, player:getLostHp())
    local tos = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = room:getOtherPlayers(player, false),
      skill_name = huoshui.name,
      prompt = "#xh__huoshui-choose:::"..lost_hp,
      cancelable = true,
      target_tip_name = huoshui.name,
    })
    if #tos > 0 then
      event:setCostData(self, {tos = tos, lost_hp = lost_hp})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local tos = event:getCostData(self).tos
    local lost_hp = event:getCostData(self).lost_hp

    local choices = {} -- 存储玩家的选择
    for i = 1, lost_hp do
      local choice = room:askToChoice(player, {
        choices = {
          "xh__huoshui_tip1", -- 非锁定技失效
          "xh__huoshui_tip2", -- 交给你1张手牌
          "xh__huoshui_tip3", -- 弃置装备区里的所有牌
        },
        skill_name = huoshui.name,
        prompt = "#xh__huoshui-choose:::"..i.."/"..lost_hp,
        cancelable = true,
      })
      table.insert(choices, choice)
    end

    local p = tos[1]
    for i = 1, #choices do
      if not p.dead then
        if choices[i] == "xh__huoshui_tip1" then
          -- 1.本回合非锁定技失效
          room:setPlayerMark(p, MarkEnum.UncompulsoryInvalidity.."-turn", 1)
        elseif choices[i] == "xh__huoshui_tip2" then
          -- 2.交给你1张手牌
          if not player.dead and not p:isKongcheng() then
            local cards = room:askToCards(p, {
              min_num = 1,
              max_num = 1,
              include_equip = false,
              skill_name = huoshui.name,
              prompt = "#xh__huoshui-give:"..player.id,
              cancelable = false,
            })
            room:moveCardTo(cards, Card.PlayerHand, player, fk.ReasonGive, huoshui.name, nil, false, p)
          end
        elseif choices[i] == "xh__huoshui_tip3" then
          -- 3.弃置装备区里的所有牌
          p:throwAllCards("e", huoshui.name)
        end
      end
    end
  end,
})

return huoshui
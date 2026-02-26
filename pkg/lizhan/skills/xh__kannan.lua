local kannan = fk.CreateSkill {
  name = "xh__kannan",
}

Fk:loadTranslationTable{
  ["xh__kannan"] = "戡难",
  [":xh__kannan"] = "出牌阶段限一次，你可以与一名你于此阶段内未以此法选择过的角色拼点。若你赢，你使用的下一张【杀】伤害值基数+1，且你于此阶段内不能发动此技能；若其赢，其使用的下一张【杀】伤害值基数+1。",
  ["#xh__kannan"] = "戡难：与一名角色拼点，赢的角色使用下一张【杀】伤害+1",
  ["@xh__kannan"] = "戡难",
  ["$xh__kannan1"] = "俊才之杰，材匪戡难。",
  ["$xh__kannan2"] = "戡，克也，难，攻之。",
}

-- 记录拼点结果，影响下一张杀的伤害
kannan:addEffect("active", {
  anim_type = "control",
  prompt = "#xh__kannan",
  card_num = 0,
  target_num = 1,
  times = function (self, player)
    return player.hp - player:usedSkillTimes(kannan.name, Player.HistoryPhase)
  end,
  can_use = function(self, player)
    return player:usedSkillTimes(kannan.name, Player.HistoryPhase) < player.hp
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and player:canPindian(to_select) and
      not table.contains(player:getTableMark("xh__kannan-phase"), to_select.id)
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:addTableMark(player, "xh__kannan-phase", target.id)  -- 标记已拼点角色
    local pindian = player:pindian({target}, kannan.name)
    
    -- 拼点结果
    if pindian.results[target].winner == player then
      -- 胜者：玩家的下一张【杀】伤害+1
      if not player.dead then
        room:addPlayerMark(player, "@xh__kannan", 1)
        room:invalidateSkill(player, kannan.name, "-phase")  -- 禁止本回合再次使用技能
      end
    elseif pindian.results[target].winner == target then
      -- 败者：对方的下一张【杀】伤害+1
      if not target.dead then
        room:addPlayerMark(target, "@xh__kannan", 1)
      end
    end
  end,
})

-- 影响伤害：根据拼点结果，调整【杀】的伤害
kannan:addEffect(fk.PreCardUse, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@xh__kannan") > 0 and data.card.trueName == "slash"
  end,
  on_refresh = function(self, event, target, player, data)
    data.additionalDamage = (data.additionalDamage or 0) + player:getMark("@xh__kannan")  -- 加伤害
    player.room:setPlayerMark(player, "@xh__kannan", 0)  -- 清除标记
  end,
})

return kannan
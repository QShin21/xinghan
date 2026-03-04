local kannan = fk.CreateSkill {
  name = "xh__kannan",
}

Fk:loadTranslationTable{
  ["xh__kannan"] = "戡难",
  [":xh__kannan"] = "每回合限一次，出牌阶段你可以与一名你于此阶段内未以此法选择过的角色拼点。若你赢，你使用的下一张【杀】伤害值基数+1，且你于此阶段内不能发动此技能；若其赢，其使用的下一张【杀】伤害值基数+1。",
  ["#xh__kannan"] = "戡难：与一名角色拼点，赢的角色使用下一张【杀】伤害+1",
  ["@xh__kannan"] = "戡难",
  ["$xh__kannan1"] = "俊才之杰，材匪戡难。",
  ["$xh__kannan2"] = "戡，克也，难，攻之。",
}

kannan:addEffect("active", {
  anim_type = "control",
  prompt = "#xh__kannan",
  card_num = 0,
  target_num = 1,

  -- 每回合仅一次
  times = 1,
  can_use = function(self, player)
    return player.phase == Player.Play and
      player:usedSkillTimes(kannan.name, Player.HistoryTurn) == 0
  end,

  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0 and player:canPindian(to_select) and
      not table.contains(player:getTableMark("xh__kannan-phase"), to_select.id)
  end,

  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    room:addTableMark(player, "xh__kannan-phase", target.id)

    local pindian = player:pindian({target}, kannan.name)

    if pindian.results[target].winner == player then
      if not player.dead then
        room:addPlayerMark(player, "@xh__kannan", 1)
        room:invalidateSkill(player, kannan.name, "-phase")
      end
    elseif pindian.results[target].winner == target then
      if not target.dead then
        room:addPlayerMark(target, "@xh__kannan", 1)
      end
    end
  end,
})

kannan:addEffect(fk.PreCardUse, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@xh__kannan") > 0 and data.card.trueName == "slash"
  end,
  on_refresh = function(self, event, target, player, data)
    data.additionalDamage = (data.additionalDamage or 0) + player:getMark("@xh__kannan")
    player.room:setPlayerMark(player, "@xh__kannan", 0)
  end,
})

return kannan
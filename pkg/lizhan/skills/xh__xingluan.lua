local xingluan = fk.CreateSkill{
  name = "xh__xingluan",
}

Fk:loadTranslationTable{
  ["xh__xingluan"] = "兴乱",
  [":xh__xingluan"] = "出牌阶段限一次，当你使用仅指定一个目标的牌结算完毕后，你可以将牌堆顶六张牌置入弃牌堆，然后从弃牌堆中选择一张点数为6且上个回合未选择的牌名的牌获得。",
  ["#xh__xingluan-invoke"] = "兴乱：你可以将牌堆顶六张牌置入弃牌堆，然后从弃牌堆获得一张点数为6且上回合未选牌名的牌",
  ["#xh__xingluan-pick"] = "兴乱：请选择要获得的牌",

  ["$xh__xingluan1"] = "大兴兵争，长安当乱。",
  ["$xh__xingluan2"] = "勇猛兴军，乱世当立。",
}

local LAST_MARK = "xh__xingluan_last"
local THIS_MARK = "xh__xingluan_this"

local function getCardTrueName(id)
  local c = Fk:getCardById(id)
  if not c then return nil end
  return c.trueName or c.name
end

xingluan:addEffect(fk.TurnStart, {
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(xingluan.name)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room

    local t = player:getTableMark(THIS_MARK)
    room:setPlayerMark(player, THIS_MARK, 0)

    if t and #t > 0 then
      room:setPlayerMark(player, LAST_MARK, 0)
      room:addTableMark(player, LAST_MARK, t[1])
    else
      room:setPlayerMark(player, LAST_MARK, 0)
    end
  end,
})

xingluan:addEffect(fk.CardUseFinished, {
  anim_type = "control",

  can_trigger = function(self, event, target, player, data)
    if target ~= player then return false end
    if not player:hasSkill(xingluan.name) then return false end
    if player.phase ~= Player.Play then return false end
    if player:usedSkillTimes(xingluan.name, Player.HistoryPhase) > 0 then return false end
    if not data or not data.tos then return false end
    return #data.tos == 1
  end,

  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = xingluan.name,
      prompt = "#xh__xingluan-invoke",
    })
  end,

  on_use = function(self, event, target, player, data)
    local room = player.room
    local skillName = xingluan.name

    local top6 = room:getNCards(6, "top")
    if top6 and #top6 > 0 then
      room:moveCardTo(top6, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, skillName, nil, true, player)
    end

    local last_tbl = player:getTableMark(LAST_MARK)
    local last_name = nil
    if last_tbl and #last_tbl > 0 then
      last_name = last_tbl[1]
    end

    local candidates = {}
    for _, id in ipairs(room.discard_pile) do
      local c = Fk:getCardById(id)
      if c and c.number == 6 then
        local tn = c.trueName or c.name
        if not last_name or tn ~= last_name then
          table.insert(candidates, id)
        end
      end
    end

    if #candidates == 0 or player.dead then
      return
    end

    -- 优化：先把所有可选牌展示出来，再让玩家选择
    room:showCards(candidates, player)

    local chosen_id
    if #candidates == 1 then
      chosen_id = candidates[1]
    else
      local map = {}
      local choices = {}
      for _, id in ipairs(candidates) do
        local c = Fk:getCardById(id)
        local key = tostring(id) .. ":" .. c:toLogString()
        map[key] = id
        table.insert(choices, key)
      end
      local pick = room:askToChoice(player, {
        choices = choices,
        skill_name = skillName,
        prompt = "#xh__xingluan-pick",
        cancelable = false,
      })
      chosen_id = map[pick]
    end

    if not chosen_id or player.dead then return end
    room:obtainCard(player, chosen_id, true, fk.ReasonGetFromDiscard, player, skillName)

    local tn = getCardTrueName(chosen_id)
    room:setPlayerMark(player, THIS_MARK, 0)
    if tn then
      room:addTableMark(player, THIS_MARK, tn)
    end
  end,
})

return xingluan
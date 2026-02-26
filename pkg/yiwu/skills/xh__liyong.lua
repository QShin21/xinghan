local liyong = fk.CreateSkill{
  name = "xh__liyong",
  tags = { Skill.Switch },
}

Fk:loadTranslationTable{
  ["xh__liyong"] = "历勇",
  [":xh__liyong"] = "转换技，出牌阶段每项限一次，阳：你可以将一张本回合你未使用过的花色的牌当【决斗】使用；阴：你可以从弃牌堆中获得一张你本回合使用过的花色的牌，令一名角色视为对你使用一张【决斗】。",

  ["#xh__liyong-yang"] = "历勇：将一张本回合未使用过花色的牌当【决斗】使用",
  ["#xh__liyong-yin"] = "历勇：从弃牌堆获得一张本回合用过花色的牌，令一名角色视为对你使用【决斗】",

  ["$xh__liyong1"] = "今日，我虽死，却未辱武安之名！",
  ["$xh__liyong2"] = "我受文举恩义，今当以死报之！",
}

local function suitStr(card)
  if not card or card.suit == Card.NoSuit then return nil end
  local s = card:getSuitString(true)
  if not s or s == "log_nosuit" then return nil end
  return s
end

local function usedSuits(player)
  return player:getTableMark("xh__liyong_suits-turn") or {}
end

local function addUsedSuit(room, player, s)
  if s then
    room:addTableMarkIfNeed(player, "xh__liyong_suits-turn", s)
  end
end

local function getSubcardIds(card)
  if not card then return {} end
  if type(card.subcards) == "table" then return card.subcards end
  if card.getSubcards then
    local ok, subs = pcall(function() return card:getSubcards() end)
    if ok and type(subs) == "table" then return subs end
  end
  return {}
end

local function recordUsedSuitsFromCard(room, player, card)
  if not room or not player or not card then return end

  local s = suitStr(card)
  if s then
    addUsedSuit(room, player, s)
    return
  end

  for _, id in ipairs(getSubcardIds(card)) do
    local c = Fk:getCardById(id)
    local ss = suitStr(c)
    if ss then
      addUsedSuit(room, player, ss)
    end
  end
end

local function recordUsedSuitsFromIds(room, player, ids)
  if not ids then return end
  for _, id in ipairs(ids) do
    local c = Fk:getCardById(id)
    local s = suitStr(c)
    if s then
      addUsedSuit(room, player, s)
    end
  end
end

local function hasAnyYangOption(player)
  local room = player.room
  local used = usedSuits(player)
  local others = room:getOtherPlayers(player, false)
  if #others == 0 then return false end

  for _, id in ipairs(player:getCardIds("h")) do
    local c = Fk:getCardById(id)
    local s = suitStr(c)
    if s and not table.contains(used, s) then
      local duel = Fk:cloneCard("duel")
      duel.skillName = "xh__liyong"
      duel:addSubcard(id)
      if player:canUse(duel) then
        for _, p in ipairs(others) do
          if not p.dead and player:canUseTo(duel, p) then
            return true
          end
        end
      end
    end
  end
  return false
end

local function hasAnyYinOption(player)
  local room = player.room
  local used = usedSuits(player)
  if #used == 0 then return false end

  local eligible = {}
  for _, id in ipairs(room.discard_pile) do
    local c = Fk:getCardById(id)
    local s = suitStr(c)
    if s and table.contains(used, s) then
      table.insert(eligible, id)
    end
  end
  if #eligible == 0 then return false end

  local duel = Fk:cloneCard("duel")
  for _, p in ipairs(room:getOtherPlayers(player, false)) do
    if not p.dead and p:canUseTo(duel, player, { bypass_distances = true, bypass_times = true }) then
      return true
    end
  end
  return false
end

liyong:addEffect("active", {
  anim_type = "switch",
  min_card_num = 0,
  max_card_num = 1,
  min_target_num = 1,
  max_target_num = 1,

  prompt = function(self, player)
    return "#xh__liyong-" .. player:getSwitchSkillState(liyong.name, false, true)
  end,

  can_use = function(self, player)
    if player.phase ~= Player.Play then return false end
    local state = player:getSwitchSkillState(liyong.name, false)
    if state == fk.SwitchYang then
      return player:getMark("xh__liyong_yang-phase") == 0 and hasAnyYangOption(player)
    else
      return player:getMark("xh__liyong_yin-phase") == 0 and hasAnyYinOption(player)
    end
  end,

  card_filter = function(self, player, to_select, selected)
    if player:getSwitchSkillState(liyong.name, false) ~= fk.SwitchYang then return false end
    if #selected ~= 0 then return false end
    if player.room:getCardArea(to_select) ~= Card.PlayerHand then return false end

    local c = Fk:getCardById(to_select)
    local s = suitStr(c)
    if not s then return false end
    if table.contains(usedSuits(player), s) then return false end

    local duel = Fk:cloneCard("duel")
    duel.skillName = liyong.name
    duel:addSubcard(to_select)
    return player:canUse(duel) and player:getMark("xh__liyong_yang-phase") == 0
  end,

  target_filter = function(self, player, to_select, selected, selected_cards)
    local state = player:getSwitchSkillState(liyong.name, false)
    if state == fk.SwitchYang then
      if #selected_cards ~= 1 then return false end
      local duel = Fk:cloneCard("duel")
      duel.skillName = liyong.name
      duel:addSubcards(selected_cards)
      return duel.skill:targetFilter(player, to_select, selected, {}, duel)
    else
      if #selected ~= 0 then return false end
      if to_select == player then return false end
      local duel = Fk:cloneCard("duel")
      return to_select:canUseTo(duel, player, { bypass_distances = true, bypass_times = true })
    end
  end,

  feasible = function(self, player, selected, selected_cards)
    local state = player:getSwitchSkillState(liyong.name, false)
    if state == fk.SwitchYang then
      if #selected_cards ~= 1 then return false end
      local duel = Fk:cloneCard("duel")
      duel.skillName = liyong.name
      duel:addSubcards(selected_cards)
      return duel.skill:feasible(player, selected, {}, duel)
    else
      return #selected_cards == 0 and #selected == 1
    end
  end,

  on_use = function(self, room, effect)
    local player = effect.from
    local state = player:getSwitchSkillState(liyong.name, true)

    if state == fk.SwitchYang then
      room:setPlayerMark(player, "xh__liyong_yang-phase", 1)

      -- 修复点：阳面用子卡当【决斗】时，把该子卡花色计入“本回合已用花色”
      recordUsedSuitsFromIds(room, player, effect.cards)

      room:sortByAction(effect.tos)
      room:useVirtualCard("duel", effect.cards, player, effect.tos, liyong.name)
    else
      room:setPlayerMark(player, "xh__liyong_yin-phase", 1)

      local used = usedSuits(player)
      local eligible = table.filter(room.discard_pile, function(id)
        local c = Fk:getCardById(id)
        local s = suitStr(c)
        return s and table.contains(used, s)
      end)

      if #eligible > 0 then
        local getId = table.random(eligible)
        room:obtainCard(player, getId, true, fk.ReasonJustMove, player, liyong.name)
      end

      local src = effect.tos[1]
      if not player.dead and src and not src.dead then
        room:useVirtualCard("duel", nil, src, player, liyong.name, true)
      end
    end
  end,
})

-- 修复点：记录“本回合使用过的花色”时，虚拟牌也要从子卡提取花色
liyong:addEffect(fk.AfterCardUseDeclared, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:hasSkill(liyong.name, true) and
      player.room.current == player and data.card ~= nil
  end,
  on_refresh = function(self, event, target, player, data)
    recordUsedSuitsFromCard(player.room, player, data.card)
  end,
})

-- 修复点：中途获得技能时回溯本回合已用花色，也要兼容虚拟牌的子卡
local function collectSuitsFromCard(card, out)
  if not card then return end
  local s = suitStr(card)
  if s then table.insertIfNeed(out, s) end
  for _, id in ipairs(getSubcardIds(card)) do
    local c = Fk:getCardById(id)
    local ss = suitStr(c)
    if ss then table.insertIfNeed(out, ss) end
  end
end

liyong:addAcquireEffect(function(self, player, is_start)
  if player.room.current == player then
    local room = player.room
    local mark = {}
    room.logic:getEventsOfScope(GameEvent.UseCard, 1, function(e)
      local use = e.data
      if use.from == player and use.card then
        collectSuitsFromCard(use.card, mark)
      end
    end, Player.HistoryTurn)
    if #mark > 0 then
      room:setPlayerMark(player, "xh__liyong_suits-turn", mark)
    end
  end
end)

return liyong
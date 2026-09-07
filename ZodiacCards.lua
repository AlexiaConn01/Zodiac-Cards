--- STEAMODDED HEADER
--- MOD_NAME: Zodiac Cards
--- MOD_ID: ZodiacCards
--- MOD_AUTHOR: [AlexiaConn01]
--- MOD_DESCRIPTION: Adds a new consumable type based on star signs. 
--- MOD_VERSION: 1.0.0
--- MOD_SITE: 

-- you can have shared helper functions
function shakecard(self) --visually shake a card
    G.E_MANAGER:add_event(Event({
        func = function()
            self:juice_up(0.5, 0.5)
            return true
        end
    }))
end


SMODS.Atlas { key = 'Decks', path = 'Decks.png', px = 71, py = 95 }
SMODS.Atlas { key = 'Sleeves', path = 'Sleeves.png', px = 73, py = 95 }
SMODS.Atlas { key = 'modconsumable', path = 'modconsumable.png', px = 71, py = 95 }
SMODS.Atlas { key = 'Boosters', path = 'Boosters.png', px = 71, py = 95 }
SMODS.Atlas { key = 'Tags', path = 'Tags.png', px = 34, py = 34 }
SMODS.Atlas { key = 'Vouchers', path = 'Vouchers.png', px = 71, py = 95 }
SMODS.Atlas { key = 'Jokers', path = 'Jokers.png', px = 71, py = 95 }

local zodiac_cards_mod = SMODS.current_mod




function return_JokerValues() -- not used, just here to demonstrate how you could return values from a joker
    if context.joker_main and context.cardarea == G.jokers then
        return {
            chips = self.ability.extra.chips,       -- these are the 3 possible scoring effects any joker can return.
            mult = self.ability.extra.mult,         -- adds mult (+)
            x_mult = self.ability.extra.x_mult,     -- multiplies existing mult (*)
            card = self,                            -- under which card to show the message
            colour = G.C.CHIPS,                     -- colour of the message, Balatro has some predefined colours, (Balatro/globals.lua)
            message = localize('k_upgrade_ex'),     -- this is the message that will be shown under the card when it triggers.
            extra = { focus = self, message = localize('k_upgrade_ex') }, -- another way to show messages, not sure what's the difference.
        }
    end
end

local msg_dictionary={
    -- do note that when using messages such as: 
    -- message = localize{type='variable',key='a_xmult',vars={current_xmult}},
    -- that the key 'a_xmult' will use provided values from vars={} in that order to replace #1#, #2# etc... in the localization file.

    a_chips="+#1#",
    a_chips_minus="-#1#",
    a_hands="+#1# Hands",
    a_handsize="+#1# Hand Size",
    a_handsize_minus="-#1# Hand Size",
    a_mult="+#1# Mult",
    a_mult_minus="-#1# Mult",
    a_remaining="#1# Remaining",
    a_sold_tally="#1#/#2# Sold",
    a_xmult="X#1# Mult",
    a_xmult_minus="-X#1# Mult",
}    

local mod_name = 'Zodiac Cards' -- Put your mod name here!

SMODS.Joker {
	key = "horoscope",
	atlas = 'Jokers', 
	pos = { x = 0, y = 0 },
	config = { extra = { chips = 50, chip_mod = 50 } },
	unlocked = true, 
	discovered = true,
	rarity = 3,
	cost = 10,
	loc_vars = function(self, config, card)
		return { vars = { self.config.extra.chips } }
	end,
	calculate = function(self, context, config, card)
		if context.joker_main then 
			return {
				chips = card.ability.extra.chips
			}
		end
		if context.using_consumeable then
			if context.consumeable.ability.set == "Zodiac" then
				card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod
				return{
				extra = {focus = self, message = localize("k_upgrade_ex")},
				card = self,
				colour = G.C.CHIPS
				}
			end
		end
	end
}

zodiac_deck = SMODS.Back {
    key = "zodiac_deck",
    atlas = 'Decks',
    pos = { x = 0, y = 0 },
    config = { vouchers = {'v_retrograde','v_perfect_syzygy'} },
    unlocked = true,
    loc_args = {localize{type = 'name_text', key = 'v_retrograde', set = 'Voucher'}, localize{type = 'name_text', key = 'v_perfect_syzygy', set = 'Voucher'}},
    loc_vars = function(self, config, card)
        return { vars = { self.config.vouchers.v_retrograde, self.config.vouchers.v_perfect_syzygy } }
    end,
    apply = function(self)
	G.GAME.joker_rate = 0
	G.GAME.planet_rate = 0
	G.GAME.tarot_rate = 0
	G.GAME.zodiac_rate = 1e100
    end,
}

if CardSleeves then
    CardSleeves.Sleeve {
        key = 'zodiac_sleeve',
        atlas = 'Sleeves',
        pos = {x=0,y=0},
        unlocked = true,
        unlock_condition = { deck = 'b_zodiac_deck', stake = 1 },	
	loc_vars = function(self)
        local key, vars
        if self.get_current_deck_key() == "b_zodiac_deck" then
            key = self.key .. "_alt"
        else
            key = self.key
            self.config = { vouchers = { "v_retrograde", "v_perfect_syzygy" }, joker_rate = 0, planet_rate = 0, tarot_rate = 0, zodiac_rate = 1e100 }
            vars = { self.config.vouchers.v_retrograde, self.config.vouchers.v_perfect_syzygy }
        end
        return { key = key, vars = vars }
    end,
	apply = function(self)
		if self.get_current_deck_key() == "b_zodiac_deck" then
			G.E_MANAGER:add_event(Event({
				func = (function()
					add_tag(Tag('tag_horoscope_tag'))
					play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
					play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
				return true
            end)
        }))
		end
	end,
    }
end




SMODS.Shader {
    key = 'gold_leaf_shader',
    path = 'gold_leaf_shader.fs',
}

SMODS.Shader {
    key = 'holofoil_shader',
    path = 'holofoil_shader.fs',
}

SMODS.Shader {
    key = 'prismatic_shader',
    path = 'prismatic_shader.fs',
}

SMODS.Shader {
    key = 'diamond_shader',
    path = 'diamond_shader.fs',
}


SMODS.Edition {
    key = 'gold_leaf',
    shader = 'gold_leaf_shader',
    atlas = 'Joker',
    pos = { x = 0, y = 0 },
    config = { p_dollars = 3 },
 	loc_txt = {
		label = "Gold Leaf",
	},
    apply_to_float = true,
    calculate = function(self, card, context)
		if context.pre_joker or (context.main_scoring and context.cardarea == G.play) then
			return { dollars = 3 }
		end
    end
}

SMODS.Edition {
    key = 'holofoil',
    shader = 'holofoil_shader',
    atlas = 'Joker',
    pos = { x = 0, y = 0 },
    config = { extra = { chips = 25, mult = 5 } },
 	loc_txt = {
		label = "Holofoil",
	},
    apply_to_float = true,
    calculate = function(self, card, context)
		if context.pre_joker or (context.main_scoring and context.cardarea == G.play) then
			return { chips = 25, mult = 5 }
		end
    end
}

SMODS.Edition {
    key = 'prismatic',
    shader = 'prismatic_shader',
    atlas = 'Joker',
    pos = { x = 0, y = 0 },
    config = { extra = { chips = 30, x_mult = 1.25 } },
 	loc_txt = {
		label = "Prismatic",
	},
    apply_to_float = true,
    calculate = function(self, card, context)
		if context.pre_joker or (context.main_scoring and context.cardarea == G.play) then
			return { chips = 30, x_mult = 1.25 }
		end
	end
}

SMODS.Edition {
    key = 'diamond',
    shader = 'diamond_shader',
    atlas = 'Joker',
    pos = { x = 0, y = 0 },
    config = { extra = { p_dollars = 2, mult = 8 } },
 	loc_txt = {
		label = "Diamond",
	},
    apply_to_float = true,
    calculate = function(self, card, context)
		if context.pre_joker or (context.main_scoring and context.cardarea == G.play) then
			return { mult = 8, dollars = 2, }
		end
	end
}


  SMODS.ConsumableType({
    key = "Zodiac",
    primary_colour = HEX("22014a"),
    secondary_colour = HEX("22014a"),
    collection_rows = { 3, 3 },
    shop_rate = 0.0,
    loc_txt = {},
    default = "c_aries",
    can_stack = true,
    can_divide = true,
  })

  G.C.SECONDARY_SET.Zodiac = HEX("22014a")


  SMODS.Booster({
    key = "zodiac_normal",
    kind = "Zodiac",
    atlas = "Boosters",
    display_size = { w = 71, h = 95 },
    pos = { x = 0, y = 0 },
    config = { extra = 2, choose = 1 },
    draw_hand = false,
    cost = 4,
    weight = 0.9,
    unlocked = true,
    discovered = true,
    create_card = function(self, card)
      local n_card = create_card("Zodiac", G.pack_cards, nil, nil, true, true, nil, "zodiac")
      return n_card
    end,
    ease_background_colour = function(self)
      ease_colour(G.C.DYN_UI.MAIN, G.C.SECONDARY_SET.Zodiac)
      ease_background_colour({ new_colour = G.C.SECONDARY_SET.Zodiac, special_colour = G.C.BLACK, contrast = 2 })
    end,
    loc_vars = function(self, info_queue, card)
      return { vars = { card.config.center.config.choose, card.ability.extra } }
    end,
    group_key = "k_zodiac_pack",
  })

  SMODS.Booster({
    key = "zodiac_jumbo",
    kind = "Zodiac",
    atlas = "Boosters",
    display_size = { w = 71, h = 95 },
    pos = { x = 1, y = 0 },
    config = { extra = 4, choose = 1 },
    draw_hand = false,
    cost = 6,
    weight = 0.7,
    unlocked = true,
    discovered = true,
    create_card = function(self, card)
      local n_card = create_card("Zodiac", G.pack_cards, nil, nil, true, true, nil, "zodiac")
      return n_card
    end,
    ease_background_colour = function(self)
      ease_colour(G.C.DYN_UI.MAIN, G.C.SECONDARY_SET.Zodiac)
      ease_background_colour({ new_colour = G.C.SECONDARY_SET.Zodiac, special_colour = G.C.BLACK, contrast = 2 })
    end,
    loc_vars = function(self, info_queue, card)
      return { vars = { card.config.center.config.choose, card.ability.extra } }
    end,
    group_key = "k_zodiac_pack",
  })

  SMODS.Booster({
    key = "zodiac_mega",
    kind = "Zodiac",
    atlas = "Boosters",
    display_size = { w = 71, h = 95 },
    pos = { x = 2, y = 0 },
    config = { extra = 4, choose = 2 },
    draw_hand = false,
    cost = 8,
    weight = 0.5,
    unlocked = true,
    discovered = true,
    create_card = function(self, card)
      local n_card = create_card("Zodiac", G.pack_cards, nil, nil, true, true, nil, "zodiac")
      return n_card
    end,
    ease_background_colour = function(self)
      ease_colour(G.C.DYN_UI.MAIN, G.C.SECONDARY_SET.Zodiac)
      ease_background_colour({ new_colour = G.C.SECONDARY_SET.Zodiac, special_colour = G.C.BLACK, contrast = 2 })
    end,
    loc_vars = function(self, info_queue, card)
      return { vars = { card.config.center.config.choose, card.ability.extra } }
    end,
    group_key = "k_zodiac_pack",
  })

SMODS.Voucher {
    key = 'retrograde',
    loc_txt = {},
    atlas = 'Vouchers', 
    pos = { x = 0, y = 0 },
    cost = 10,
    discovered = false,
    unlocked = true,
    redeem = function(self, card)
	G.GAME.zodiac_rate = 2
    end,
}
SMODS.Voucher {
    key = 'perfect_syzygy',
    loc_txt = {},
    atlas = 'Vouchers', 
    pos = { x = 1, y = 0 },
    cost = 10,
    discovered = false,
    unlocked = true,
    requires = {'v_retrograde'},
    redeem = function(self, card)
	G.GAME.zodiac_rate = 8
    end,
}


SMODS.Tag {
    key = 'horoscope_tag',
    loc_txt = {},
    min_ante = 1,
    atlas = 'Tags', 
    pos = { x = 0, y = 0 },
    config = { type = "new_blind_choice" },
	loc_vars = function(self, info_queue)
		info_queue[#info_queue + 1] = { set = "Other", key = "p_zodiac_mega", specific_vars = { 2, 4 } }
		return { vars = {} }
	end,
	apply = function(self, tag, context)
		if context.type == "new_blind_choice" then
			tag:yep("+", G.C.SECONDARY_SET.Zodiac, function()
				local key = "p_zodiac_mega"
				local card = Card(
					G.play.T.x + G.play.T.w / 2 - G.CARD_W * 1.27 / 2,
					G.play.T.y + G.play.T.h / 2 - G.CARD_H * 1.27 / 2,
					G.CARD_W * 1.27,
					G.CARD_H * 1.27,
					G.P_CARDS.empty,
					G.P_CENTERS[key],
					{ bypass_discovery_center = true, bypass_discovery_ui = true }
				)
				card.cost = 0
				card.from_tag = true
				G.FUNCS.use_card({ config = { ref_table = card } })
				card:start_materialize()
				return true
			end)
			tag.triggered = true
			return true
		end
	end,
}



SMODS.Sound({
	key = "music_zodiac",
	path = "music_zodiac.ogg",
	select_music_track = function()
		return 
			(
				(
					G.pack_cards
					and G.pack_cards.cards
					and G.pack_cards.cards[1]
					and G.pack_cards.cards[1].ability.set == "Zodiac"
				) 
			)
	end,
})


SMODS.Consumable {
    set = 'Zodiac',
    key = 'aries',
    atlas = 'modconsumable',
    pos = { x = 0, y = 0 },
    soul_pos = { x = 1, y = 0 },
    can_use = function(self, card)
      return true
    end,
    use = function(self, card)
	G.hand:change_size(1)
    end,
}
SMODS.Consumable {
    set = 'Zodiac',
    key = 'taurus',
    atlas = 'modconsumable',
    pos = { x = 2, y = 0 },
    soul_pos = { x = 3, y = 0 },
    can_use = function(self, card)
      return true
    end,
    use = function(self, card)
	G.GAME.round_resets.discards = G.GAME.round_resets.discards + 1
        ease_discard(1)
    end,
}
SMODS.Consumable {
    set = 'Zodiac',
    key = 'gemini',
    atlas = 'modconsumable',
    pos = { x = 4, y = 0 },
    soul_pos = { x = 5, y = 0 },
    can_use = function(self, card)
      return true
    end,
    use = function(self, card)
	G.GAME.round_resets.hands = G.GAME.round_resets.hands + 1
        ease_hands_played(1)
    end,
}
SMODS.Consumable {
    set = 'Zodiac',
    key = 'cancer',
    atlas = 'modconsumable',
    pos = { x = 0, y = 1 },
    soul_pos = { x = 1, y = 1 },
    can_use = function(self, card)
      return true
    end,
    use = function(self, card)
	G.GAME.interest_cap = G.GAME.interest_cap + 5
    end,
}
SMODS.Consumable {
    set = 'Zodiac',
    key = 'leo',
    atlas = 'modconsumable',
    pos = { x = 2, y = 1 },
    soul_pos = { x = 3, y = 1 },
    can_use = function(self, card)
      return true
    end,
    use = function(self, card)
	change_shop_size(1)
    end,
}
SMODS.Consumable {
    set = 'Zodiac',
    key = 'libra',
    atlas = 'modconsumable',
    pos = { x = 4, y = 1 },
    soul_pos = { x = 5, y = 1 },
    can_use = function(self, card)
      return true
    end,
    use = function(self, card)
	G.consumeables.config.card_limit = G.consumeables.config.card_limit + 1
    end,
}
SMODS.Consumable {
    set = 'Zodiac',
    key = 'aquarius',
    atlas = 'modconsumable',
    pos = { x = 0, y = 2 },
    soul_pos = { x = 1, y = 2 },
	loc_vars = function(self, info_queue)
		info_queue[#info_queue + 1] = { set = "Other", key = "e_gold_leaf", specific_vars = { 3 } }
		return { vars = {} }
	end,
    can_use = function(self, card)
	if #G.jokers.cards > 0 then
			for k, v in pairs(G.jokers.cards) do
				if not v.edition then
					return true
				end
			end
	end
    end,
    use = function(self, card)
	local affectable = {}
			for k, v in pairs(G.jokers.cards) do
				if not v.edition then
					table.insert(affectable, v)

				end
			end
	local affected = #affectable > 0 and pseudorandom_element(affectable, pseudoseed('affect')) or nil
	affected:set_edition({gold_leaf = true}, true)
    end,
}
SMODS.Consumable {
    set = 'Zodiac',
    key = 'pisces',
    atlas = 'modconsumable',
    pos = { x = 2, y = 2 },
    soul_pos = { x = 3, y = 2 },
	loc_vars = function(self, info_queue)
		info_queue[#info_queue + 1] = { set = "Other", key = "e_holofoil", specific_vars = { 25, 5 } }
		return { vars = {} }
	end,
    can_use = function(self, card)
	if #G.jokers.cards > 0 then
			for k, v in pairs(G.jokers.cards) do
				if not v.edition then
					return true
				end
			end
	end
    end,
    use = function(self, card)
	local affectable = {}
			for k, v in pairs(G.jokers.cards) do
				if not v.edition then
					table.insert(affectable, v)

				end
			end
	local affected = #affectable > 0 and pseudorandom_element(affectable, pseudoseed('affect')) or nil
	affected:set_edition({holofoil = true}, true)
    end,
}
SMODS.Consumable {
    set = 'Zodiac',
    key = 'sagittarius',
    atlas = 'modconsumable',
    pos = { x = 4, y = 2 },
    soul_pos = { x = 5, y = 2 },
	loc_vars = function(self, info_queue)
		info_queue[#info_queue + 1] = { set = "Other", key = "e_prismatic", specific_vars = { 30, 1.25 } }
		return { vars = {} }
	end,
    can_use = function(self, card)
	if #G.jokers.cards > 0 then
			for k, v in pairs(G.jokers.cards) do
				if not v.edition then
					return true
				end
			end
	end
    end,
    use = function(self, card)
	local affectable = {}
			for k, v in pairs(G.jokers.cards) do
				if not v.edition then
					table.insert(affectable, v)

				end
			end
	local affected = #affectable > 0 and pseudorandom_element(affectable, pseudoseed('affect')) or nil
	affected:set_edition({prismatic = true}, true)
    end,
}
SMODS.Consumable {
    set = 'Zodiac',
    key = 'scorpio',
    atlas = 'modconsumable',
    pos = { x = 0, y = 3 },
    soul_pos = { x = 1, y = 3 },
	loc_vars = function(self, info_queue)
		info_queue[#info_queue + 1] = { set = "Other", key = "e_diamond", specific_vars = { 2, 8 } }
		return { vars = {} }
	end,
    can_use = function(self, card)
	if #G.jokers.cards > 0 then
			for k, v in pairs(G.jokers.cards) do
				if not v.edition then
					return true
				end
			end
	end
    end,
    use = function(self, card)
	local affectable = {}
			for k, v in pairs(G.jokers.cards) do
				if not v.edition then
					table.insert(affectable, v)

				end
			end
	local affected = #affectable > 0 and pseudorandom_element(affectable, pseudoseed('affect')) or nil
	affected:set_edition({diamond = true}, true)
    end,
}
SMODS.Consumable {
    set = 'Zodiac',
    key = 'virgo',
    atlas = 'modconsumable',
    pos = { x = 2, y = 3 },
    soul_pos = { x = 3, y = 3 },
	loc_vars = function(self, info_queue)
		info_queue[#info_queue + 1] = G.P_CENTERS.e_polychrome
		return { vars = {} }
	end,
    can_use = function(self, card)
	if #G.jokers.cards > 0 then
			for k, v in pairs(G.jokers.cards) do
				if not v.edition then
					return true
				end
			end
	end
    end,
    use = function(self, card)
	local affectable = {}
			for k, v in pairs(G.jokers.cards) do
				if not v.edition then
					table.insert(affectable, v)

				end
			end
	local affected = #affectable > 0 and pseudorandom_element(affectable, pseudoseed('affect')) or nil
	affected:set_edition({polychrome = true}, true)
    end,
}
SMODS.Consumable {
    set = 'Zodiac',
    key = 'capricorn',
    atlas = 'modconsumable',
    pos = { x = 4, y = 3 },
    soul_pos = { x = 5, y = 3 },
	loc_vars = function(self, info_queue)
		info_queue[#info_queue + 1] = G.P_CENTERS.e_negative
		return { vars = {} }
	end,
    can_use = function(self, card)
	if #G.jokers.cards > 0 then
			for k, v in pairs(G.jokers.cards) do
				if not v.edition then
					return true
				end
			end
	end
    end,
    use = function(self, card)
	local affectable = {}
			for k, v in pairs(G.jokers.cards) do
				if not v.edition then
					table.insert(affectable, v)

				end
			end
	local affected = #affectable > 0 and pseudorandom_element(affectable, pseudoseed('affect')) or nil
	affected:set_edition({negative = true}, true)
    end,
}
SMODS.Consumable {
    set = 'Zodiac',
    key = 'ophiuchus',
    atlas = 'modconsumable',
    pos = { x = 0, y = 4 },
    soul_pos = { x = 1, y = 4 },
    hidden = true,
    soul_set = 'Zodiac',
    soul_rate = 0.003,
    can_use = function(self, card)
      return true
    end,
    use = function(self, card)
	G.GAME.round_resets.hands = G.GAME.round_resets.hands - 1
        ease_hands_played(-1)
	G.GAME.round_resets.discards = G.GAME.round_resets.discards - 1
        ease_discard(-1)
	G.hand:change_size(-1)
	G.GAME.interest_cap = G.GAME.interest_cap - 5
	G.consumeables.config.card_limit = G.consumeables.config.card_limit - 1
	change_shop_size(-1)
	G.jokers.config.card_limit = G.jokers.config.card_limit + 1
    end,
}




function SMODS.INIT.ZodiacCards()
    --localization for the info queue key
    G.localization.descriptions.Other["your_key"] = {
        name = "Example",
        text = {
            "TEXT L1",
            "TEXT L2",
            "TEXT L3"
        }
    }
    init_localization()
end

---@class Window : Class
---@field         point       Vector2      # Widget draw point.
---@field         scale       Vector2|nil  # Widget draw scale. Temporary.
---@field         color       Color|nil    # Widget draw color. Temporary.
---@field         no_board    boolean      # Widget no-board flag. Temporary.
---@field         no_glyph    boolean      # Widget no-glyph flag. Temporary.
---@field         input       table        # Input table. (index: widget index, which: input device kind, block: dis-allow input, temporarily)
---@field private asset       Asset        # Asset cache.
---@field private mouse       Vector2      # Mouse point.
---@field private frame       number       # Window frame time.
---@field private index       number       # Widget index.
---@field private index_board number       # Widget index, for board/pad navigation (different from `index`.)
---@field private focus       number       # Widget focus index. For indicating which widget is currently in "focus".
---@field private cache       Cache[]      # Widget cache.
---@field private user        User         # User.
---@field private zoom        number       # Window/camera zoom factor.
---@field private view        Vector2      # Window view-port scale.
---@field private lock        boolean      # Lock widget input.
---@field         new         fun(self: Window, user: User, asset: Asset): Window
Window                   = Class:class_extend("Window")
---@enum TextAlign
Window.TEXT_ALIGN        = {
    CENTER = 1,
    R_MOST = 2
}
---@private
Window.FONT_SCALE        = 16.0
---@private
Window.FONT_SPACE        = 0.0
---@private
Window.WIDGET_SCALE      = Vector2:new(256.0, 16.0)
---@private
Window.WIDGET_SPACE      = Vector2:new(2.0, 0.01)
---@private
Window.WIDGET_SCALE_AUTO = Vector2:new(0.0, Window.WIDGET_SCALE.y)
---@format disable-next
Window.INPUT       = {
    ACCEPT = Input:new(INPUT.BOARD.ENTER,  INPUT.MOUSE.LEFT,  INPUT.PAD.R_DOWN),
    RETURN = Input:new(INPUT.BOARD.ESCAPE, INPUT.MOUSE.RIGHT, INPUT.PAD.R_RIGHT),
    ESCAPE = Input:new(INPUT.BOARD.ESCAPE, nil,               INPUT.PAD.MIDDLE_RIGHT),
    MOVE_A = Input:new(INPUT.BOARD.UP,     nil,               INPUT.PAD.L_UP),
    MOVE_B = Input:new(INPUT.BOARD.DOWN,   nil,               INPUT.PAD.L_DOWN),
    SIDE_A = Input:new(INPUT.BOARD.LEFT,   nil,               INPUT.PAD.L_LEFT),
    SIDE_B = Input:new(INPUT.BOARD.RIGHT,  nil,               INPUT.PAD.L_RIGHT),
    TAB_A  = Input:new(INPUT.BOARD.Q,      INPUT.MOUSE.SIDE,  INPUT.PAD.L_TRIGGER_1),
    TAB_B  = Input:new(INPUT.BOARD.E,      INPUT.MOUSE.EXTRA, INPUT.PAD.R_TRIGGER_1),
    HOLD   = Input:new(INPUT.BOARD.L_CONTROL),
    COPY   = Input:new(INPUT.BOARD.C),
    PASTE  = Input:new(INPUT.BOARD.V),
    ERASE  = Input:new(INPUT.BOARD.BACKSPACE),
}
---@private
Window.GLYPH             = {
    BUTTON = {
        {
            Window.INPUT.MOVE_A,
            Window.INPUT.MOVE_B,
            "BROWSE",
            Window.INPUT.ACCEPT,
            "ACCEPT"
        },
        {
            Window.INPUT.ACCEPT,
            "ACCEPT"
        },
        {
            Window.INPUT.MOVE_A,
            Window.INPUT.MOVE_B,
            "BROWSE",
            Window.INPUT.ACCEPT,
            "ACCEPT"
        }
    },
    TOGGLE = {
        {
            Window.INPUT.MOVE_A,
            Window.INPUT.MOVE_B,
            "BROWSE",
            Window.INPUT.ACCEPT,
            "TOGGLE"
        },
        {
            Window.INPUT.ACCEPT,
            "TOGGLE"
        },
        {
            Window.INPUT.MOVE_A,
            Window.INPUT.MOVE_B,
            "BROWSE",
            Window.INPUT.ACCEPT,
            "TOGGLE"
        }
    },
    SLIDER_FOCUS = {
        {
            Window.INPUT.MOVE_A,
            Window.INPUT.MOVE_B,
            "BROWSE",
            Window.INPUT.SIDE_A,
            Window.INPUT.SIDE_B,
            "MODIFY"
        },
        {},
        {
            Window.INPUT.MOVE_A,
            Window.INPUT.MOVE_B,
            "BROWSE",
            Window.INPUT.SIDE_A,
            Window.INPUT.SIDE_B,
            "MODIFY"
        }
    },
    SLIDER = {
        {
            Window.INPUT.MOVE_A,
            Window.INPUT.MOVE_B,
            "BROWSE",
            Window.INPUT.SIDE_A,
            Window.INPUT.SIDE_B,
            "MODIFY"
        },
        {
            Window.INPUT.ACCEPT,
            "MODIFY"
        },
        {
            Window.INPUT.MOVE_A,
            Window.INPUT.MOVE_B,
            "BROWSE",
            Window.INPUT.SIDE_A,
            Window.INPUT.SIDE_B,
            "MODIFY"
        }
    },
    SWITCH = {
        {
            Window.INPUT.MOVE_A,
            Window.INPUT.MOVE_B,
            "BROWSE",
            Window.INPUT.SIDE_A,
            Window.INPUT.SIDE_B,
            "MODIFY"
        },
        {
            Window.INPUT.ACCEPT,
            "MODIFY"
        },
        {
            Window.INPUT.MOVE_A,
            Window.INPUT.MOVE_B,
            "BROWSE",
            Window.INPUT.SIDE_A,
            Window.INPUT.SIDE_B,
            "MODIFY"
        }
    },
    RECORD_FOCUS = {
        {
            Window.INPUT.RETURN,
            "RETURN"
        },
        {
            Window.INPUT.RETURN,
            "RETURN"
        },
        {
            Window.INPUT.RETURN,
            "RETURN"
        }
    },
    RECORD = {
        {
            Window.INPUT.MOVE_A,
            Window.INPUT.MOVE_B,
            "BROWSE",
            Window.INPUT.ACCEPT,
            "MODIFY"
        },
        {
            Window.INPUT.ACCEPT,
            "MODIFY"
        },
        {
            Window.INPUT.MOVE_A,
            Window.INPUT.MOVE_B,
            "BROWSE",
            Window.INPUT.ACCEPT,
            "MODIFY"
        }
    },
    INPUT = {
        {
            Window.INPUT.MOVE_A,
            Window.INPUT.MOVE_B,
            "BROWSE",
            Window.INPUT.ACCEPT,
            "MODIFY"
        },
        {
            Window.INPUT.ACCEPT,
            "MODIFY"
        },
        pad = {
            Window.INPUT.MOVE_A,
            Window.INPUT.MOVE_B,
            "BROWSE",
            Window.INPUT.ACCEPT,
            "MODIFY"
        }
    }
}

function Window:instance(user, asset)
    self.point       = Vector2:new(8.0, 8.0)
    self.point_min   = Vector2:zero()
    self.point_max   = Vector2:zero()
    self.asset       = asset
    self.mouse       = Vector2:zero()
    self.frame       = 0.0
    self.index       = -1
    self.index_board = -1
    self.input       = { which = INPUT.DEVICE.BOARD, index = 0, lock = false }
    self.cache       = {}
    self.user        = user
    self.zoom        = user:get_zoom()
    self.view        = Vector2:zero()
    self.lock        = false
    self.grow_x      = false

    --[[]]

    self.asset:set_font("video/font.ttf", Window.FONT_SCALE * 2.0 * self.zoom, {
        { 32,  127 },
        { 128, 255 }
    })
    self.asset:set_texture("video/button.png")
    self.asset:set_sound("audio/click-a.ogg")
    self.asset:set_sound("audio/click-b.ogg")
    self.asset:set_sound("audio/switch-a.ogg")
    self.asset:set_sound("audio/switch-b.ogg")
    self.asset:set_sound("audio/tap-a.ogg")
    self.asset:set_sound("audio/tap-b.ogg")
end

---Initialize a draw session.
---@param call function # Draw call.
function Window:draw(call)
    if not self.input.block then
        local delta          = Vector2:clone(flak.input.mouse.get_delta())
        local board_activity = flak.input.board.get_last_press()
        local mouse_activity = flak.input.mouse.get_last_press() or delta:length() > 0.0
        local pad_activity   = flak.input.pad.get_last_press(0)

        if board_activity then
            if flak.input.mouse.is_hidden() then
                flak.input.mouse.show_cursor(true)
            end

            self.input.which = INPUT.DEVICE.BOARD
        elseif mouse_activity then
            if flak.input.mouse.is_hidden() then
                flak.input.mouse.show_cursor(true)
            end

            self.input.which = INPUT.DEVICE.MOUSE
        elseif pad_activity then
            if not flak.input.mouse.is_hidden() then
                flak.input.mouse.show_cursor(false)
            end

            self.input.which = INPUT.DEVICE.PAD
        end
    else
        self.input.block = false
    end

    --[[]]

    flak.screen.draw_2D(function()
        call()

        --[[]]

        if self.front then
            self.point:set(8.0, 8.0)

            self.lock = not true
            self:front()

            if self.front then
                self.lock = true
            end
        else
            self.lock = not true
        end
    end, Camera2D:new(Vector2.ZERO, Vector2.ZERO, 0.0, self.zoom))

    --[[]]

    if not self.focus then
        if Window.INPUT.MOVE_A:is_press(self.input.which, nil, true) then
            self.input.index = ((self.input.index - 1) % (self.index_board + 1))
        elseif Window.INPUT.MOVE_B:is_press(self.input.which, nil, false) then
            self.input.index = ((self.input.index + 1) % (self.index_board + 1))
        end
    end

    local zoom  = self.user:get_zoom()
    local view  = flak.window.get_window_scale()
    local mouse = flak.input.mouse.get_point()

    if not (zoom == self.zoom) then
        self.asset:clear(self.asset.font, "video/font.ttf")
        self.asset:set_font("video/font.ttf", Window.FONT_SCALE * 2.0 * zoom, {
            { 32,  127 },
            { 128, 255 }
        })
    end

    self.point:set(8.0, 8.0)
    self.point_min:set(0.0, 0.0)
    self.point_max:set(0.0, 0.0)
    self.zoom = zoom
    self.view:set(
        view.x * (1.0 / self.zoom),
        view.y * (1.0 / self.zoom)
    )
    self.mouse:set(
        mouse.x * (1.0 / self.zoom),
        mouse.y * (1.0 / self.zoom)
    )
    self.draw_return = false
    self.frame       = flak.window.get_frame_time()
    self.index       = -1
    self.index_board = -1
end

---Draw a button widget.
---@param  label string # Widget label.
---@return Cache cache  # Widget cache.
function Window:button(label)
    local font  = self.asset:get_font("video/font.ttf")
    local box   = self:get_box(Window.WIDGET_SCALE_AUTO, font, label)
    local cache = Cache:get(self, label, box)

    if label and self:is_visible(box) then
        font:draw(label, self.point, Window.FONT_SCALE, Window.FONT_SPACE, cache:get_color(self))
    end

    self:glyph(cache, Window.GLYPH.BUTTON)

    --[[]]

    self:point_grow(box)

    return cache
end

---Draw a button (image) widget.
---@param  path  string # Widget image path.
---@return Cache cache  # Widget cache.
function Window:button_image(path)
    local image, _, scale = self.asset:set_texture(path)
    local box             = self:get_box(Window.WIDGET_SCALE)
    local cache           = Cache:get(self, path, box)

    if self:is_visible(box) then
        image:draw(Box2:new(0.0, 0.0, scale.x, scale.y), box, Vector2.ZERO, 0.0, cache:get_color(self))
    end

    self:glyph(cache, Window.GLYPH.BUTTON)

    --[[]]

    self:point_grow(box)

    return cache
end

---Draw a toggle widget.
---@param  label   string  # Widget label.
---@param  value   boolean # Widget value.
---@return boolean value   # Widget value.
---@return Cache   cache   # Widget cache.
function Window:toggle(label, value)
    local font  = self.asset:get_font("video/font.ttf")
    local box_a = self:get_box(Window.WIDGET_SCALE)
    local box_b = self:get_box(Vector2:new(Window.WIDGET_SCALE.y, Window.WIDGET_SCALE.y))
    local cache = Cache:get(self, label, box_a)

    if self:is_visible(box_a) then
        if value then
            flak.screen.draw_box_2(box_b, Vector2:zero(), 0.0, Color:g())
        end

        font:draw(label, self.point + Vector2:new(box_b.s_x + 4.0, 0.0), Window.FONT_SCALE, Window.FONT_SPACE,
            cache:get_color(self))

        --[[]]

        if cache.click then
            value        = not value
            cache.change = true
        end
    end

    self:glyph(cache, Window.GLYPH.TOGGLE)

    --[[]]

    self.point.y = self.point.y + box_a.s_y + Window.WIDGET_SPACE.y

    return value, cache
end

---Draw a slider widget.
---@param  label  string    # Widget label.
---@param  value  number    # Widget value.
---@param  min    number    # Minimum boundary for value.
---@param  max    number    # Maximum boundary for value.
---@param  step   number    # Step value.
---@return number value     # Widget value.
---@return Cache  cache     # Widget cache.
function Window:slider(label, value, min, max, step)
    local font   = self.asset:get_font("video/font.ttf")
    local box    = self:get_box(Window.WIDGET_SCALE)
    local cache  = Cache:get(self, label, box)
    local former = value

    if self:is_visible(box) then
        local input = value

        if self.input.which == INPUT.DEVICE.MOUSE then
            if cache.focus then
                input = math.percentage_from_value(self.mouse.x, box.p_x, box.p_x + box.s_x)
                input = math.value_from_percentage(math.clamp(input, 0.0, 1.0), min, max)
                input = math.snap(input, step)

                if Window.INPUT.ACCEPT:is_release(self.input.which) then
                    self:set_focus(false)
                    value = input
                end
            else
                if cache.click then
                    self:set_focus(true)
                end
            end
        else
            if cache.side_a then
                value = value - step
            elseif cache.side_b then
                value = value + step
            end
        end

        value = math.clamp(value, min, max)

        cache.change = not (value == former)

        --[[]]

        local scale = font:measure(string.format("%.2f", input), Window.FONT_SCALE, Window.FONT_SPACE)

        font:draw(label, self.point + Vector2:new(box.s_x + 4.0, 0.0), Window.FONT_SCALE,
            Window.FONT_SPACE,
            cache:get_color(self))
        font:draw(string.format("%.2f", input), self.point + Vector2:new((box.s_x - scale.x) * 0.5, 0.0),
            Window.FONT_SCALE,
            Window.FONT_SPACE,
            cache:get_color(self))
    end

    self:glyph(cache, cache.focus and Window.GLYPH.SLIDER_FOCUS or Window.GLYPH.SLIDER)

    --[[]]

    self.point.y = self.point.y + box.s_y + Window.WIDGET_SPACE.y

    return value, cache
end

---Draw a switch widget.
---@param  label  string    # Widget label.
---@param  value  number    # Widget value.
---@param  choice string[]  # Widget value pool.
---@return number value     # Widget value.
---@return Cache  cache     # Widget cache.
function Window:switch(label, value, choice)
    local font   = self.asset:get_font("video/font.ttf")
    local box    = self:get_box(Window.WIDGET_SCALE)
    local cache  = Cache:get(self, label, box)
    local entry  = choice[value]
    local scale  = font:measure(entry, Window.FONT_SCALE, Window.FONT_SPACE)
    local former = value

    if self:is_visible(box) then
        font:draw(label, self.point + Vector2:new(box.s_x + 4.0, 0.0), Window.FONT_SCALE,
            Window.FONT_SPACE,
            cache:get_color(self))
        font:draw(entry, self.point + Vector2:new((box.s_x - scale.x) * 0.5, 0.0), Window.FONT_SCALE,
            Window.FONT_SPACE,
            cache:get_color(self))

        --[[]]

        if self.input.which == INPUT.DEVICE.MOUSE then
            if cache.click then
                value = value + 1
            end

            value = value % (#choice + 1)
        else
            if cache.side_a then
                value = value - 1
            elseif cache.side_b then
                value = value + 1
            end
        end

        value = math.clamp(value, 1, #choice)

        cache.change = not (value == former)
    end

    self:glyph(cache, Window.GLYPH.SWITCH)

    --[[]]

    self.point.y = self.point.y + box.s_y + Window.WIDGET_SPACE.y

    return value, cache
end

---Draw a text-record widget.
---@param  label  string # Widget label.
---@param  value  string # Widget value.
---@return string value  # Widget value.
---@return Cache  cache  # Widget cache.
function Window:record(label, value, focus)
    local font   = self.asset:get_font("video/font.ttf")
    local box    = self:get_box(Window.WIDGET_SCALE)
    local cache  = Cache:get(self, label, box)
    local former = value

    if focus then
        cache.hover = focus
        cache.focus = focus
    end

    if self:is_visible(box) then
        local point = 0.0

        if cache.focus then
            if cache.click or Window.INPUT.RETURN:is_press(self.input.which) or Window.INPUT.ESCAPE:is_press(self.input.which) then
                self:set_focus(false)
            end

            if Window.INPUT.HOLD:is_down(self.input.which) then
                if Window.INPUT.COPY:is_press(self.input.which) then
                    flak.input.board.set_clip_board(value)
                elseif Window.INPUT.PASTE:is_press(self.input.which) then
                    local clip         = flak.input.board.get_clip_board()
                    value              = string.insert(value, cache.record_caret, clip)
                    cache.record_caret = cache.record_caret + #clip
                elseif Window.INPUT.ERASE:is_press(self.input.which) then
                    local record_caret = cache.record_caret

                    for x = record_caret, 0, -1 do
                        local character = string.sub(value, x, x)

                        if not (x == record_caret) and string.is_symbol(character) then
                            break
                        end

                        value              = string.remove(value)
                        cache.record_caret = cache.record_caret - 1
                    end
                elseif cache.side_a then
                    local record_caret = cache.record_caret

                    for x = record_caret, 0, -1 do
                        local character = string.sub(value, x, x)

                        if not (x == record_caret) and string.is_symbol(character) then
                            break
                        end

                        cache.record_caret = cache.record_caret - 1
                    end
                elseif cache.side_b then
                    local record_caret = cache.record_caret + 1

                    for x = record_caret, #value do
                        local character = string.sub(value, x, x)

                        if not (x == record_caret) and string.is_symbol(character) then
                            break
                        end

                        cache.record_caret = cache.record_caret + 1
                    end
                end
            else
                local character = flak.input.board.get_last_character()

                if cache.record_caret > 0 and Window.INPUT.ERASE:is_press(self.input.which) then
                    value              = string.remove(value, cache.record_caret)
                    cache.record_caret = cache.record_caret - 1
                elseif cache.side_a then
                    cache.record_caret = cache.record_caret - 1
                elseif cache.side_b then
                    cache.record_caret = cache.record_caret + 1
                elseif character then
                    while character do
                        value              = string.insert(value, cache.record_caret, character)
                        cache.record_caret = cache.record_caret + 1
                        character          = flak.input.board.get_last_character()
                    end
                end
            end

            cache.record_caret = math.clamp(cache.record_caret, 0, #value)
            local shift = font:measure(string.sub(value, 0, cache.record_caret), Window.FONT_SCALE, Window.FONT_SPACE)
            point = math.min(box.s_x - shift.x - 4.0, 0.0)

            flak.screen.draw_box_2(Box2:new(self.point.x + shift.x + point, self.point.y, 2.0, Window.WIDGET_SCALE.y))
        else
            if cache.click then
                self:set_focus(true)
            end
        end

        cache.change = not (value == former)

        --[[]]

        font:draw(label, self.point + Vector2:new(box.s_x + 4.0, 0.0), Window.FONT_SCALE, Window.FONT_SPACE,
            cache:get_color(self))

        if self.area then
            local area = Box2:new(
                box.p_x,
                self.area.p_y,
                box.s_x,
                self.area.s_y
            ) * self.zoom

            flak.screen.draw_scissor(function()
                font:draw(value, self.point + Vector2:new(point, 0.0), Window.FONT_SCALE, Window.FONT_SPACE,
                    cache:get_color(self))
            end, area)

            flak.screen.draw_scissor_begin(self.area * self.zoom)
        else
            flak.screen.draw_scissor(function()
                font:draw(value, self.point + Vector2:new(point, 0.0), Window.FONT_SCALE, Window.FONT_SPACE,
                    cache:get_color(self))
            end, box * self.zoom)
        end
    end

    self:glyph(cache, cache.focus and Window.GLYPH.RECORD_FOCUS or Window.GLYPH.RECORD)

    --[[]]

    self.point.y = self.point.y + box.s_y + Window.WIDGET_SPACE.y

    return value, cache
end

---Draw an action widget.
---@param  label string # Widget label.
---@param  value action # Widget value.
---@return Cache cache  # Widget cache.
function Window:action(label, value)
    local font  = self.asset:get_font("video/font.ttf")
    local box   = self:get_box(Window.WIDGET_SCALE)
    local cache = Cache:get(self, label, box)

    if self:is_visible(box) then
        font:draw(label, self.point + Vector2:new(box.s_x + 4.0, 0.0), Window.FONT_SCALE, Window.FONT_SPACE,
            cache:get_color(self))
        value:draw(self.asset, self.user, nil, self.point + Vector2:new(box.s_x, box.s_y) * 0.5, true)

        --[[]]

        if cache.focus then
            if self.input.which == INPUT.DEVICE.BOARD then
                local board = flak.input.board.get_last_press()

                if board then
                    if not (board == INPUT.BOARD.ESCAPE) then
                        if value.board == board then
                            value.board = nil
                        else
                            value.board = board
                        end
                    end

                    self:set_focus(false)
                end
            elseif self.input.which == INPUT.DEVICE.MOUSE then
                local mouse = flak.input.mouse.get_last_press()

                if mouse then
                    if value.mouse == mouse then
                        value.mouse = nil
                    else
                        value.mouse = mouse
                    end

                    self:set_focus(false)
                end
            else
                local pad = flak.input.pad.get_last_press(0)

                if pad then
                    if not (pad == INPUT.PAD.MIDDLE_RIGHT) then
                        if value.pad == pad then
                            value.pad = nil
                        else
                            value.pad = pad
                        end
                    end

                    self:set_focus(false)
                end
            end
        else
            if cache.click then
                self:set_focus(true)
            end
        end
    end

    if not cache.focus then
        self:glyph(cache, Window.GLYPH.INPUT)
    else
        local glyph_other = nil
        local glyph_input = {
            value,
            "INPUT_DETACH",
        }

        if not (self.input.which == INPUT.DEVICE.MOUSE) then
            glyph_other = {
                "(...)",
                "INPUT_ATTACH",
                Window.INPUT.ESCAPE,
                "RETURN",
            }
        else
            glyph_other = {
                "(...)",
                "INPUT_ATTACH"
            }
        end

        if self.input.which == INPUT.DEVICE.BOARD and value.board then table.join(glyph_input, glyph_other, true, true) end
        if self.input.which == INPUT.DEVICE.MOUSE and value.mouse then table.join(glyph_input, glyph_other, true, true) end
        if self.input.which == INPUT.DEVICE.PAD and value.pad then table.join(glyph_input, glyph_other, true, true) end

        self:glyph(cache, {
            glyph_other,
            glyph_other,
            glyph_other
        })
    end

    --[[]]

    self.point.y = self.point.y + box.s_y + Window.WIDGET_SPACE.y

    return cache
end

---Draw a scroll widget.
---@param  scale Vector2  # Scroll scale.
---@param  call  function # Draw call.
---@return Cache cache    # Widget cache.
function Window:scroll(label, scale, call)
    self.area     = self:get_box(scale)
    local cache   = Cache:get(self, label, self.area, true, true)

    local area_x  = self.area.s_x
    local area_y  = self.area.s_y
    local point_x = self.point.x
    local point_y = self.point.y
    local delta   = cache.hover and flak.input.mouse.get_wheel() or Vector2.ZERO

    flak.screen.draw_box_2(self.area, Vector2:zero(), 0.0, Color:scalar(33, 127))

    local scroll_x = cache.scroll_scale.x >= 0.0
    local scroll_y = cache.scroll_scale.y >= 0.0

    if scroll_x or scroll_y then
        local lock_scroll_y = false

        if scroll_x then
            self.area.s_y      = self.area.s_y - 20.0
            local scroll_scale = self.area.s_x *
                math.clamp(self.area.s_x / (self.area.s_x + cache.scroll_scale.x), 0.0, 1.0)
            local scroll_scale = math.max(scroll_scale, 0.25)
            local scroll_point = 1.0 -
                math.clamp((cache.scroll_scale.x + cache.scroll.x) / cache.scroll_scale.x, 0.0, 1.0)
            local scroll_point = self.area.p_x + (self.area.s_x - scroll_scale) * scroll_point
            local scroll_where = Box2:new(
                scroll_point,
                self.area.p_y + self.area.s_y + 4.0,
                scroll_scale,
                16.0
            )
            local scroll_total = Box2:new(
                self.area.p_x,
                self.area.p_y + self.area.s_y + 4.0,
                self.area.s_x,
                16.0
            )

            if not self.lock and not self.input.block and not cache.focus_scroll_y then
                local scroll_color = Color.GRAY

                if self.input.which == INPUT.DEVICE.MOUSE then
                    if cache.focus then
                        scroll_color     = Color.WHITE

                        local percent    = math.percentage_from_value(self.mouse.x, scroll_total.p_x,
                            scroll_total.p_x + scroll_total.s_x)
                        local percent    = math.clamp(percent, 0.0, 1.0)
                        self.scroll_to_x = percent

                        if Window.INPUT.ACCEPT:is_release(self.input.which) then
                            cache.focus_scroll_x = nil
                            lock_scroll_y        = true
                            self:set_focus(false)
                        end
                    else
                        if scroll_total:is_point_inside(self.mouse) then
                            scroll_color = Color.WHITE

                            if Window.INPUT.ACCEPT:is_press(self.input.which) then
                                cache.focus_scroll_x = true
                                self:set_focus(true)
                            end
                        end
                    end
                end

                flak.screen.draw_box_2(scroll_where, nil, nil, scroll_color)

                if self.scroll_to_x then
                    cache.scroll.x = -cache.scroll_scale.x * self.scroll_to_x
                    self.scroll_to = nil
                else
                    local difference = (self.area.s_x + cache.scroll_scale.x)

                    if not (difference == 0.0) then
                        local difference = 1.0 - (self.area.s_x / difference)
                        cache.scroll.x = math.clamp(cache.scroll.x + delta.x * difference * Window.WIDGET_SCALE.x,
                            -cache.scroll_scale.x, 0.0)
                    end
                end
            end
        end

        if scroll_y then
            self.area.s_x      = self.area.s_x - 20.0
            local scroll_scale = self.area.s_y *
                math.clamp(self.area.s_y / (self.area.s_y + cache.scroll_scale.y), 0.0, 1.0)
            local scroll_scale = math.max(scroll_scale, 0.25)
            local scroll_point = 1.0 -
                math.clamp((cache.scroll_scale.y + cache.scroll.y) / cache.scroll_scale.y, 0.0, 1.0)
            local scroll_point = self.area.p_y + (self.area.s_y - scroll_scale) * scroll_point
            local scroll_where = Box2:new(
                self.area.p_x + self.area.s_x + 4.0,
                scroll_point,
                16.0,
                scroll_scale
            )
            local scroll_total = Box2:new(
                self.area.p_x + self.area.s_x + 4.0,
                self.area.p_y,
                16.0,
                self.area.s_y
            )

            if not self.lock and not self.input.block and not cache.focus_scroll_x and not lock_scroll_y then
                local scroll_color = Color.GRAY

                if self.input.which == INPUT.DEVICE.MOUSE then
                    if cache.focus then
                        scroll_color     = Color.WHITE

                        local percent    = math.percentage_from_value(self.mouse.y, scroll_total.p_y,
                            scroll_total.p_y + scroll_total.s_y)
                        local percent    = math.clamp(percent, 0.0, 1.0)
                        self.scroll_to_y = percent

                        if Window.INPUT.ACCEPT:is_release(self.input.which) then
                            cache.focus_scroll_y = nil
                            self:set_focus(false)
                        end
                    else
                        if scroll_total:is_point_inside(self.mouse) then
                            scroll_color = Color.WHITE

                            if Window.INPUT.ACCEPT:is_press(self.input.which) then
                                cache.focus_scroll_y = true
                                self:set_focus(true)
                            end
                        end
                    end
                end

                flak.screen.draw_box_2(scroll_where, nil, nil, scroll_color)

                if self.scroll_to_y then
                    cache.scroll.y = -cache.scroll_scale.y * self.scroll_to_y
                    self.scroll_to_y = nil
                else
                    local difference = (self.area.s_y + cache.scroll_scale.y)

                    if not (difference == 0.0) then
                        local difference = 1.0 - (self.area.s_y / difference)
                        cache.scroll.y = math.clamp(cache.scroll.y + delta.y * difference * Window.WIDGET_SCALE.y,
                            -cache.scroll_scale.y, 0.0)
                    end
                end
            end
        end

        self.hover = nil
        self.point.x = point_x + cache.scroll.x
        self.point.y = point_y + cache.scroll.y

        self.point_min:set(0.0, 0.0)
        self.point_max:set(0.0, 0.0)

        flak.screen.draw_scissor(function() call(cache.scroll) end, self.area * self.zoom)

        if scroll_x and not (self.input.which == INPUT.DEVICE.MOUSE) and self.hover then
            if not self.hover:is_box_inside_total(self.area) then
                local scroll = point_x + cache.scroll.x + self.area.s_x - self.hover.p_x - self.hover.s_x

                if scroll >= 0.0 then
                    cache.scroll.x = point_x + cache.scroll.x - self.hover.p_x
                else
                    cache.scroll.x = point_x + cache.scroll.x + self.area.s_x - self.hover.p_x - self.hover.s_x
                end
            end
        end

        if scroll_y and not (self.input.which == INPUT.DEVICE.MOUSE) and self.hover then
            if not self.hover:is_box_inside_total(self.area) then
                local scroll = point_y + cache.scroll.y + self.area.s_y - self.hover.p_y - self.hover.s_y

                if scroll >= 0.0 then
                    cache.scroll.y = point_y + cache.scroll.y - self.hover.p_y
                else
                    cache.scroll.y = point_y + cache.scroll.y + self.area.s_y - self.hover.p_y - self.hover.s_y
                end
            end
        end
    else
        self.point_min:set(0.0, 0.0)
        self.point_max:set(0.0, 0.0)

        flak.screen.draw_scissor(function() call(cache.scroll) end, self.area * self.zoom)
    end

    cache.scroll_scale.x = self.point_max.x - cache.scroll.x - point_x - self.area.s_x
    cache.scroll_scale.y = self.point_max.y - cache.scroll.y - point_y - self.area.s_y

    --[[]]


    -- TO-DO does this work correctly with horizontal grow?
    self.point.x = point_x
    self.point.y = point_y + area_y
    self.area = nil

    return cache
end

---Draw a tab widget.
---@param label string # Widget label.
function Window:tab(label, choice)
    local font    = self.asset:get_font("video/font.ttf")
    local cache   = Cache:get(self, label, nil, true, true)
    local shift_a = 0.0
    local shift_b = 0.0

    for i = 1, #choice do
        local entry = choice[i]
        shift_a = shift_a + font:measure(entry, Window.FONT_SCALE, Window.FONT_SPACE).x + 16.0
    end

    shift_a = shift_a * 0.5

    --[[]]

    self.point.x = self.point.x - shift_a
    local box    = self:get_box(Vector2:new(shift_a * 2.0, Window.WIDGET_SCALE.y))
    self.point.x = self.point.x + shift_a

    if self:is_visible(box) then
        local window_point = Vector2:clone(self.point)

        for i = 1, #choice do
            local entry   = choice[i]
            local point   = window_point + Vector2:new(shift_b - shift_a, 0.0)
            local scale   = font:measure(entry, Window.FONT_SCALE, Window.FONT_SPACE)

            self.point    = point
            self.scale    = scale
            self.no_board = true

            if (i - 1) == cache.tab_index then
                self.color = Color.WHITE
            end

            if self:button(entry).click then
                cache.tab_index = i - 1
            end

            shift_b = shift_b + scale.x + 16.0
        end

        self.point = window_point

        Window.INPUT.TAB_A:draw(self.asset, self.user, self.input.which,
            self.point - Vector2:new(shift_a + 12.0, 6.0 * -1.0), true)
        Window.INPUT.TAB_B:draw(self.asset, self.user, self.input.which, self.point + Vector2:new(shift_a, 6.0), true)

        --[[]]

        if not self.focus then
            if Window.INPUT.TAB_A:is_press(self.input.which) then
                self.input.index = 0
                cache.tab_index  = (cache.tab_index - 1) % #choice
                self.asset:get_sound("audio/switch-a.ogg"):play()
            elseif Window.INPUT.TAB_B:is_press(self.input.which) then
                self.input.index = 0
                cache.tab_index  = (cache.tab_index + 1) % #choice
                self.asset:get_sound("audio/switch-a.ogg"):play()
            end
        end
    end

    --[[]]

    self.point.y = self.point.y + Window.FONT_SCALE

    return cache.tab_index, cache
end

-- Draw a box widget.
---@param box   Box2  # Widget box.
---@param color Color # Widget color.
function Window:box(box, color)
    box:set_scale(self:get_scale(box:get_scale()))
    flak.screen.draw_box_2(box, nil, nil, color)
end

---Draw a label widget.
---@param label  string    # Widget label.
---@param align? TextAlign # Widget label alignment.
function Window:label(label, align)
    local font = self.asset:get_font("video/font.ttf")
    local view = Box2:new(
        self.point.x,
        self.point.y,
        self.area and self.area.s_x or 0.0,
        self.area and math.huge or 0.0
    )
    local measure = self.area and font:measure_wrap(label, view, Window.FONT_SCALE, Window.FONT_SPACE) or
        font:measure(label, Window.FONT_SCALE, Window.FONT_SPACE)
    local box = self:get_box(measure)

    if self:is_visible(box) then
        if self.area then
            if align then
                font:draw(label, self.point - Vector2:new(measure.x, 0.0), Window.FONT_SCALE, Window.FONT_SPACE,
                    self:get_color(Color.WHITE))
            else
                font:draw_wrap(label, view, Window.FONT_SCALE, Window.FONT_SPACE, self:get_color(Color.WHITE))
            end
        else
            if align then
                local measure = Vector2:new(measure.x, 0.0) * (align == Window.TEXT_ALIGN.CENTER and 0.5 or 1.0)
                font:draw(label, self.point - measure, Window.FONT_SCALE, Window.FONT_SPACE,
                    self:get_color(Color.WHITE))
            else
                font:draw(label, self.point, Window.FONT_SCALE, Window.FONT_SPACE, self:get_color(Color.WHITE))
            end
        end
    end

    self:point_grow(box)
end

---Draw a image widget.
---@param path string # Widget image path.
function Window:image(path)
    local image, _, scale = self.asset:set_texture(path)
    local box             = self:get_box(Window.WIDGET_SCALE)

    if self:is_visible(box) then
        image:draw(Box2:new(0.0, 0.0, scale.x, scale.y), box, Vector2.ZERO, 0.0, self:get_color(Color.WHITE))
    end

    self:point_grow(box)
end

---Temporarily set the draw point and restore it after.
---@param point Vector2  # Draw point.
---@param call  function # Draw call.
function Window:child(point, scale, color, call)
    local point_x   = self.point.x
    local point_y   = self.point.y
    self.point      = point or self.point
    self.scale_keep = scale
    self.color_keep = color

    call()

    if point then
        self.point:set(point_x, point_y)
    end

    self.scale_keep = nil
    self.color_keep = nil
end

---Grow each widget on the X-axis.
---@param call function # Draw call.
function Window:grow_x_axis(call)
    self.point_max:set(0.0, 0.0)

    local point_x = self.point.x
    self.grow_x   = true

    call()

    self.grow_x  = not true
    self.point.x = point_x
    self.point.y = self.point_max.y
end

---Draw a board/mouse/pad glyph footer.
---@param cache Cache # Cache.
---@param glyph table # Glyph array. glyph[1] must be the board entry, glyph[2] for the mouse, glyph[3] for the pad.
function Window:glyph(cache, glyph)
    if cache.hover and not self:get_no_glyph() then
        local label = self.asset:get_font("video/font.ttf")
        local which = glyph[self.input.which]
        local point = Vector2:new(8.0, self.view.y - 24.0)

        if not which then
            return
        end

        if self.area then
            flak.screen.draw_scissor_close()
        end

        for i = 1, #which do
            local entry = which[i]

            if type(entry) == "table" then
                point.x = point.x + entry:draw(
                    self.asset,
                    self.user,
                    self.input.which,
                    point
                ) + 2.0
            else
                entry = self.user:get_text(entry)
                local measure = label:measure(entry, Window.FONT_SCALE, Window.FONT_SPACE)
                label:draw(entry, point, Window.FONT_SCALE, Window.FONT_SPACE, Color.WHITE)
                point.x = point.x + measure.x + 2.0
            end
        end

        if self.draw_return then
            point.x = point.x + Window.INPUT.RETURN:draw(self.asset, self.user, self.input.which, point) + 2.0

            local entry = self.user:get_text("RETURN")
            label:draw(entry, point, Window.FONT_SCALE, Window.FONT_SPACE, Color.WHITE)
        end

        if self.area then
            flak.screen.draw_scissor_begin(self.area * self.zoom)
        end
    end
end

---Clear all window cache.
function Window:clear()
    self.input.index = 0
    table.clear(self.cache)
end

---Set the always-on-front draw call, which will prevent input on the non-front draw call to go through.
---@param call function # Draw call.
function Window:set_front(call)
    self.front       = call
    self.input.index = 0
    self.input.block = true
end

---Lock and hide the mouse.
---@param lock boolean # Lock and hide.
function Window:set_mouse_lock(lock)
    if not (self.input.which == INPUT.DEVICE.PAD) then
        self.input.which = INPUT.DEVICE.MOUSE
        self.input.block = true
        flak.input.mouse.lock_cursor(lock)
    end
end

---Check if the return action has been set off.
---@return boolean check # Check.
function Window:is_return()
    if not self.focus and not self.lock then
        self.draw_return = true

        if Window.INPUT.RETURN:is_press(self.input.which) then
            self.asset:get_sound("audio/switch-a.ogg"):play()
            return true
        end
    end

    return false
end

---Check if the escape action has been set off.
---@return boolean check # Check.
function Window:is_escape()
    if not self.focus and not self.lock then
        if Window.INPUT.ESCAPE:is_press(self.input.which) then
            self.asset:get_sound("audio/switch-a.ogg"):play()
            return true
        end
    end

    return false
end

--[[--------------------------------------------------------------------------------]]

---Move the draw point cursor.
---@param box Box2 # Widget box.
---@private
function Window:point_grow(box)
    if self.grow_x then
        self.point.x = self.point.x + box.s_x + Window.WIDGET_SPACE.x
    else
        self.point.y = self.point.y + box.s_y + Window.WIDGET_SPACE.y
    end
end

---Get the widget box.
---@param  default Vector2 # Default scale value.
---@param  font?   Font    # Widget font.
---@param  text?   string  # Widget text.
---@return Box2    box
---@private
function Window:get_box(default, font, text)
    local scale = self:get_scale(default, font, text)

    local point_x = self.point.x
    local point_y = self.point.y

    local box = Box2:new(
        point_x,
        point_y,
        scale.x,
        scale.y
    )

    if self.user.debug.window then
        flak.screen.draw_box_2(box, nil, nil, Color.R:alpha(0.5))
    end

    if point_x <= self.point_min.x then self.point_min.x = point_x end
    if point_y <= self.point_min.y then self.point_min.y = point_y end
    if point_x + scale.x >= self.point_max.x then self.point_max.x = point_x + scale.x end
    if point_y + scale.y >= self.point_max.y then self.point_max.y = point_y + scale.y end

    return box
end

---Get the widget scale.
---@param  default Vector2 # Default value.
---@return Vector2 scale
---@private
function Window:get_scale(default, font, text)
    local scale = self.scale or self.scale_keep
    self.scale  = nil
    scale       = scale and scale or default
    scale       = Vector2:clone(scale)

    scale.x     = scale.x < 0.0 and self.view.x + scale.x or scale.x
    scale.y     = scale.y < 0.0 and self.view.y + scale.y or scale.y

    if math.in_range(scale.x, 0.0, 1.0) then
        scale.x = self.view.x * scale.x
    end

    if math.in_range(scale.y, 0.0, 1.0) then
        scale.y = self.view.y * scale.y
    end

    if (scale.x == 0.0 or scale.y == 0.0) then
        if font and text then
            local measure = font:measure(text, Window.FONT_SCALE, Window.FONT_SPACE)

            scale.x = scale.x == 0.0 and measure.x or scale.x
            scale.y = scale.y == 0.0 and measure.y or scale.y
        end
    end

    return scale
end

---Get the widget color.
---@param  default Color # Default value.
---@return Color   color
---@private
function Window:get_color(default)
    local color = self.color or self.color_keep
    self.color  = nil

    return color or default
end

---Get the widget no-board/pad flag.
---@param  default boolean  # Default value.
---@return boolean no_board
---@private
function Window:get_no_board(default)
    local no_board = self.no_board
    self.no_board  = false

    return no_board or default
end

---Get the widget no-glyph flag.
---@param  default boolean  # Default value.
---@return boolean no_glyph
---@private
function Window:get_no_glyph()
    local no_glyph = self.no_glyph
    self.no_glyph  = false

    return no_glyph
end

---Set the widget focus.
---@param focus boolean # Focus state.
---@private
function Window:set_focus(focus)
    self.focus = focus and self.index
end

---Check if a widget is visible.
---@param  box     Box2    # Widget box.
---@return boolean visible
---@private
function Window:is_visible(box)
    if not self.area then
        return true
    end

    return self.area:is_box_inside(box)
end

--[[--------------------------------------------------------------------------------]]

---@class Cache : Class
---@field private alpha        number
---@field private scroll       Vector2
---@field private record_caret number
---@field private scroll_scale Vector2
---@field private scroll_index number
---@field private tab_index    number
---@field private noise        number
---@field private sound        boolean
---@field         focus        boolean
---@field         hover        boolean
---@field         click        boolean
---@field         side_a       boolean
---@field         side_b       boolean
---@field         change       boolean
---@field private no_board     boolean
---@field private new          fun(self: Cache): Cache
Cache = Class:class_extend("Cache")

function Cache:instance()
    self.alpha        = 0.0
    self.scroll       = Vector2:zero()
    self.record_caret = 0
    self.scroll_scale = Vector2:zero()
    self.scroll_index = 0
    self.tab_index    = 0
    self.noise        = 0.0
    self.sound        = false
    self.focus        = false
    self.hover        = false
    self.click        = false
    self.side_a       = false
    self.side_b       = false
    self.change       = false
    self.no_board     = false
end

---Get a widget cache.
---@param  window   Window  # Window.
---@param  label    string  # Cache hash index.
---@param  box?     Box2    # Box for hit detection with mouse.
---@param  no_board boolean # Disallow board/pad input.
---@param  no_sound boolean # Disallow any sound play-back.
---@return Cache    cache
---@private
function Cache:get(window, label, box, no_board, no_sound)
    -- Get the no-board/pad flag.
    local no_board = window:get_no_board(no_board)

    -- If input lock isn't set...
    if not window.lock then
        window.index = window.index + 1

        -- Increment the board/pad indexable widget count.
        if not no_board then
            window.index_board = window.index_board + 1
        end
    end

    --[[]]

    -- Get the widget label and corresponding cache.
    local i_label = (label or "") .. window.index
    local i_cache = window.cache[i_label]

    -- Create it if it doesn't exist.
    if not i_cache then
        i_cache = Cache:new()
        window.cache[i_label] = i_cache
    end

    i_cache.no_board = not box or no_board

    --[[]]

    -- If we have a bound-box...
    if box then
        -- Check if we're the focus widget.
        i_cache.focus = (window.focus and window.focus == window.index)

        if i_cache.focus then
            -- Always mark hover as true on focus.
            i_cache.hover = true
        else
            -- If the window doesn't have a focus-widget, input lock isn't set, and
            if not window.focus and not window.lock and not window.input.block then
                if window.input.which == INPUT.DEVICE.MOUSE then
                    -- If there's no local area view-port (like a scroll widget), or the mouse pointer is inside of it...
                    if (not window.area) or window.area:is_point_inside(window.mouse) then
                        -- Test intersection.
                        i_cache.hover = box:is_point_inside(window.mouse)
                    else
                        i_cache.hover = false
                    end

                    -- Set the board/pad widget index from the current widget.
                    if i_cache.hover then
                        window.input.index = window.index_board
                    end
                elseif not no_board then
                    -- If the B/P widget index is the same as our index, mark as hover.
                    i_cache.hover = window.input.index == window.index_board
                end
            end
        end

        -- Update.
        i_cache.click  = i_cache.hover and Window.INPUT.ACCEPT:is_press(window.input.which)
        i_cache.side_a = i_cache.hover and Window.INPUT.SIDE_A:is_press(window.input.which, nil, true, true)
        i_cache.side_b = i_cache.hover and Window.INPUT.SIDE_B:is_press(window.input.which, nil, not true, true)
        i_cache.noise  = math.max(i_cache.noise - window.frame, 0.0)

        -- Play sound.
        if not no_sound and (i_cache.click or i_cache.side_a or i_cache.side_b) and i_cache.noise <= 0.0 then
            window.asset:get_sound("audio/switch-a.ogg"):play()
            i_cache.noise = 0.1
        end

        if i_cache.hover then
            if not i_cache.sound and not no_sound and i_cache.noise <= 0.0 then
                window.asset:get_sound("audio/click-b.ogg"):play()
                i_cache.sound = true
                i_cache.noise = 0.1
            end

            window.hover  = box
            i_cache.alpha = i_cache.alpha + window.frame * 8.0
        else
            i_cache.sound = false
            i_cache.alpha = i_cache.alpha - window.frame * 8.0
        end

        i_cache.alpha  = math.clamp(i_cache.alpha, 0.25, 1.0)
        i_cache.change = false
    end

    return i_cache
end

---Get the cache color, with respect to cache hover and focus.
---@param  window Window # Window.
---@return Color  color
---@private
function Cache:get_color(window)
    local color = nil

    if window.focus then
        if window.focus == window.index then
            color = Color.WHITE
        else
            color = Color:scalar(33, 255)
        end
    else
        color = Color.WHITE
    end

    if window.color then
        return window:get_color(Color.WHITE)
    end

    return color:interpolate(Color.GRAY, 1.0 - self.alpha)
end

---@class Input : Class
---@field board   input_board
---@field mouse   input_mouse
---@field pad     input_pad
---@field press   boolean
---@field down    boolean
---@field release boolean
---@field up      boolean
---@field new     fun(self: Input, board?: input_board, mouse?: input_board, pad?: input_pad): Input
Input              = Class:class_extend("Input")
Input.MASK_PRESS   = bit.lshift(1, 0)
Input.MASK_DOWN    = bit.lshift(1, 1)
Input.MASK_RELEASE = bit.lshift(1, 2)

function Input:instance(board, mouse, pad)
    self.board = board
    self.mouse = mouse
    self.pad   = pad
    self.time  = 0
    self.axis  = false
    self.data  = 0
end

---Draw the input.
---@param  asset  Asset       # Asset.
---@param  user   User         # User.
---@param  input? input_device # Active input device. Can be an addition of two (INPUT.DEVICE.BOARD + INPUT.DEVICE.MOUSE will draw the board and mouse glyph).
---@param  point  Vector2      # Point on screen to draw the input.
---@param  center boolean      # Center the input on screen.
---@return number shift        # Off-set amount.
function Input:draw(asset, user, input, point, center)
    local texture, _, _, sheet = asset:get_texture("video/button.png")
    local font                 = asset:get_font("video/font.ttf")
    local shift                = 0.0
    local board                = self.board and (not input or bit.binary_and(input, INPUT.DEVICE.BOARD))
    local mouse                = self.mouse and (not input or bit.binary_and(input, INPUT.DEVICE.MOUSE))
    local pad                  = self.pad and (not input or bit.binary_and(input, INPUT.DEVICE.PAD))
    local point                = Vector2:clone(point)
    local text                 = nil
    local measure              = nil

    --[[ Measure the actual size of the glyph set on screen. ]]

    if board then
        text    = INPUT.BOARD[self.board]
        measure = font:measure(text, 16.0, 1.0)
        shift   = measure.x + 12.0
    end

    if mouse then
        shift = shift + 20.0
    end

    if pad then
        shift = pad and shift + 20.0
    end

    --[[ Center the input on screen. ]]

    if center then
        point.x = point.x - shift * 0.5
        point.y = point.y - 8.0
    end

    --[[ Draw. ]]

    if board then
        flak.screen.draw_box_2(
            Box2:new(point.x, point.y, measure.x + 8.0, 16.0)
        )

        font:draw(
            text,
            point + Vector2:new(4.0, 0.0),
            16.0,
            1.0,
            Color.BLACK
        )

        point.x = point.x + measure.x + 12.0
    end

    if mouse then
        local mouse_sheet = sheet["MOUSE_" .. INPUT.MOUSE[self.mouse]]

        if mouse_sheet then
            texture:draw(
                Box2:new(mouse_sheet.p_x, mouse_sheet.p_y, mouse_sheet.s_x, mouse_sheet.s_y),
                Box2:new(point.x, point.y, 16.0, 16.0),
                Vector2.ZERO,
                0.0,
                Color.WHITE
            )
        else
            mouse_sheet = sheet["MOUSE_BLANK"]

            texture:draw(
                Box2:new(mouse_sheet.p_x, mouse_sheet.p_y, mouse_sheet.s_x, mouse_sheet.s_y),
                Box2:new(point.x, point.y, 16.0, 16.0),
                Vector2.ZERO,
                0.0,
                Color.WHITE
            )

            local measure = font:measure(self.mouse, 8.0, 1.0)
            font:draw(
                self.mouse,
                point + Vector2:new((16.0 - measure.x) * 0.5, 8.0),
                8.0,
                1.0,
                Color.WHITE
            )
        end

        point.x = point.x + 20.0
    end

    if pad then
        local sheet = sheet["PAD_" .. user.video.glyph .. "_" .. INPUT.PAD[self.pad]]

        texture:draw(
            Box2:new(sheet.p_x, sheet.p_y, sheet.s_x, sheet.s_y),
            Box2:new(point.x, point.y, 16.0, 16.0),
            Vector2.ZERO,
            0.0,
            Color.WHITE
        )
    end

    return shift
end

---Convinience function for drawing an input.
---@param menu  Menu     # Menu.
---@param point Vector2 # Point on screen to draw the input.
function Input:draw_menu(menu, point)
    self:draw(
        menu.window.asset,
        menu.user,
        menu.window.input.which == INPUT.DEVICE.PAD and INPUT.DEVICE.PAD or (INPUT.DEVICE.BOARD + INPUT.DEVICE.MOUSE),
        point,
        true
    )
end

---Poll the input state.
---@param device input_device # Active input device.
---@param index? number       # Game-pad index.
function Input:poll(device, index)
    local press   = self:is_press()
    local down    = false
    local release = self:is_release()

    if device == INPUT.DEVICE.PAD then
        if self.pad and index then
            press     = (press or flak.input.pad.is_press(index, self.pad)) and Input.MASK_PRESS or 0
            down      = (down or flak.input.pad.is_down(index, self.pad)) and Input.MASK_DOWN or 0
            release   = (release or flak.input.pad.is_release(index, self.pad)) and Input.MASK_RELEASE or 0

            self.data = press + down + release
        end
    else
        if self.board then
            press   = (press or flak.input.board.is_press(self.board))
            down    = (down or flak.input.board.is_down(self.board))
            release = (release or flak.input.board.is_release(self.board))
        end

        if self.mouse then
            press   = (press or flak.input.mouse.is_press(self.mouse))
            down    = (down or flak.input.mouse.is_down(self.mouse))
            release = (release or flak.input.mouse.is_release(self.mouse))
        end

        press     = press and Input.MASK_PRESS or 0
        down      = down and Input.MASK_DOWN or 0
        release   = release and Input.MASK_RELEASE or 0

        self.data = press + down + release
    end
end

---Get the input state (press).
---@param  input?  input_device # Active input device. If nil, will use the poll state for the action, otherwise, it will query the current state.
---@param  index?  number       # Game-pad index.
---@param  stick?  boolean      # Game-pad stick direction.
---@param  x_axis? boolean      # Game-pad X-axis.
---@return boolean state        # Input state.
function Input:is_press(input, index, stick, x_axis)
    if input then
        index = index or 0

        if input == INPUT.DEVICE.PAD then
            if self.pad then
                local push = flak.input.pad.is_press(index, self.pad)
                local down = flak.input.pad.is_down(index, self.pad)

                if not (stick == nil) then
                    local value = flak.input.pad.get_axis_state(index, x_axis and 0 or 1)
                    local which = false

                    if stick then
                        if value <= -0.5 then
                            which = true
                        end
                    else
                        if value >= 0.5 then
                            which = true
                        end
                    end

                    down = down or which

                    if which then
                        if not self.axis then
                            push      = true
                            self.axis = true
                        end
                    else
                        self.axis = false
                    end
                end

                if down then
                    self.time = self.time + flak.window.get_frame_time() * 2.0
                else
                    self.time = 0.0
                end

                if self.time >= 1.00 then
                    self.time = 0.95
                    return true
                end

                return push
            end
        else
            return
                (self.board and (flak.input.board.is_press(self.board) or flak.input.board.is_press_repeat(self.board))) or
                (self.mouse and (flak.input.mouse.is_press(self.mouse)))
        end
    end

    return bit.binary_and(self.data, Input.MASK_PRESS)
end

---Get the poll input state (down).
---@param  input?  input_device # Active input device. If nil, will use the poll state for the action, otherwise, it will query the current state.
---@param  index?  number       # Game-pad index.
---@return boolean state        # Input state.
function Input:is_down(input, index)
    if input then
        index = index or 0

        if input == INPUT.DEVICE.PAD then
            return self.pad and flak.input.pad.is_down(index, self.pad)
        else
            return
                (self.board and flak.input.board.is_down(self.board)) or
                (self.mouse and flak.input.mouse.is_down(self.mouse))
        end
    end

    return bit.binary_and(self.data, Input.MASK_DOWN)
end

---Get the poll input state (release).
---@param  input?  input_device # Active input device. If nil, will use the poll state for the action, otherwise, it will query the current state.
---@param  index?  number       # Game-pad index.
---@return boolean state        # Input state.
function Input:is_release(input, index)
    if input then
        index = index or 0

        if input == INPUT.DEVICE.PAD then
            return self.pad and flak.input.pad.is_release(index, self.pad)
        else
            return
                (self.board and flak.input.board.is_release(self.board)) or
                (self.mouse and flak.input.mouse.is_release(self.mouse))
        end
    end

    return bit.binary_and(self.data, Input.MASK_RELEASE)
end

---Get the poll input state (up).
---@param  input?  input_device # Active input device. If nil, will use the poll state for the action, otherwise, it will query the current state.
---@param  index?  number       # Game-pad index.
---@return boolean state        # Input state.
function Input:is_up(input, index)
    if input then
        index = index or 0

        if input == INPUT.DEVICE.PAD then
            return self.pad and flak.input.pad.is_up(index, self.pad)
        else
            return
                (self.board and flak.input.board.is_up(self.board)) or
                (self.mouse and flak.input.mouse.is_up(self.mouse))
        end
    end

    return not bit.binary_and(self.data, Input.MASK_PRESS)
end

---Clear the input poll state.
function Input:clear()
    if self:is_down() then
        self.data = Input.MASK_DOWN
    else
        self.data = 0
    end
end

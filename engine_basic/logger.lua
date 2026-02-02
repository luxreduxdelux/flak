---@class Logger : Class
---@field private asset   Asset
---@field private buffer  table
---@field private history table
---@field private suggest table
---@field private command table
---@field private scroll  boolean
---@field         active  boolean
---@field private record  string
---@field private window  Window
---@field private user    User
---@field         new     fun(self: Logger, user: User, asset: Asset): Logger
Logger            = Class:class_extend("Logger")
---@private
Logger.FONT_SCALE = 16.0
---@private
Logger.FONT_SPACE = 0.0
---@private
Logger.LINE_BOX   = 8.0
---@private
Logger.LINE_PAD   = Vector2:new(8.0, 8.0)
---@private
Logger.LINE_TIME  = 4.0
---@private
Logger.LINE_COUNT = 256.0
---@private
Logger.FONT_COLOR = Color.WHITE
---@format disable-next
---@private
Logger.INPUT     = {
    ACCEPT    = Input:new(INPUT.BOARD.ENTER,  INPUT.MOUSE.LEFT),
    RETURN    = Input:new(INPUT.BOARD.ESCAPE, INPUT.MOUSE.RIGHT),
    TOGGLE    = Input:new(INPUT.BOARD.F1),
    SUGGEST   = Input:new(INPUT.BOARD.TAB),
}

---Create a new text logger.
---@param  user   User   # User.
---@return Logger logger # Logger.
function Logger:instance(user, asset)
    self.asset   = asset
    self.buffer  = {}
    self.command = {}
    self.history = {}
    self.suggest = {}
    self.scroll  = false
    self.active  = false
    self.record  = ""
    self.window  = Window:new(user, asset)
    self.user    = user

    --[[]]

    self.asset:set_font("video/font.ttf", Logger.FONT_SCALE * 2.0 * user:get_zoom(), {
        { 32,  127 },
        { 128, 255 }
    })

    --[[]]

    print_original    = print
    local print_local = print

    -- Override the global print function to re-direct to this logger's text buffer instead.
    print             = function(text, pretty, kind)
        local text = pretty and format(text) or text
        local line = string.tokenize(text, "\n")

        --Iterate through each line for the purpose of just optimizing text culling.
        for i = 1, #line do
            local text = line[i]
            local line = Line:new(text, kind or Line.KIND.HISTORY, i == 1)

            if #self.buffer == Logger.LINE_COUNT then
                table.remove(self.buffer, 1)
            end

            table.insert(self.buffer, line)
        end

        self.scroll = true
    end

    --[[]]

    self:attach_command("wipe", function()
        self.buffer = {}
    end)
    self:attach_command("help", function()
        for key, _ in next, self.command do
            print(key)
        end
    end)
    self:attach_command("frame_rate_set", function(text)
        local rate = tonumber(text[2])

        if rate then
            Game.user.video.rate = rate
            flak.window.set_frame_rate(rate)
        else
            print("frame_rate_set {number}", false, Line.KIND.FAILURE)
        end
    end)
end

---Draw the text logger.
function Logger:draw()
    if Logger.INPUT.TOGGLE:is_press(self.window.input.which) then
        if not self.active then
            self.hidden = flak.input.mouse.is_hidden()
        end

        self.active = not self.active
        self.scroll = true
        self.record = ""
        table.clear(self.suggest)

        if not self.active and self.hidden then
            self.window:set_mouse_lock(true)
        end
    end

    if self.active then
        self:draw_active()
    else
        self:draw_hidden()
    end
end

---Attach a new command.
---@param name string   # command name.
---@param call function # command call.
function Logger:attach_command(name, call)
    self.command[name] = call
end

--[[----------------------------------------------------------------]]

---Draw the text logger (active).
---@private
function Logger:draw_active()
    if self.window:is_escape() or self.window:is_return() then
        self.active = false

        if not self.active and self.hidden then
            self.window:set_mouse_lock(true)
        end
    end

    self.window:draw(function()
        self:buffer_draw()
        self:suggest_draw()

        if Logger.INPUT.SUGGEST:is_press(self.window.input.which) then
            self:suggest_scroll()
        end

        if Window.INPUT.MOVE_A:is_press(self.window.input.which) then
            self:history_scroll(true)
        end

        if Window.INPUT.MOVE_B:is_press(self.window.input.which) then
            self:history_scroll(false)
        end
    end)
end

---Draw the text logger (hidden).
---@private
function Logger:draw_hidden()
    local font  = self.asset:get_font("video/font.ttf")
    local time  = flak.window.get_time()
    local scale = flak.window.get_render_scale()
    local count = #self.buffer

    local box   = Box2:new(Logger.LINE_PAD.x, Logger.LINE_PAD.y,
        scale.x - Logger.LINE_PAD.x * 2.0, Logger.LINE_PAD.y + scale.y)

    flak.screen.draw_2D(function()
        -- For each entry in the text buffer...
        for i = 1, count do
            local entry = self.buffer[count - i + 1]

            if i > 4 or time - entry.time >= Logger.LINE_TIME then
                break
            end

            -- Draw text, and push text off-set down by the amount given by draw_wrap.
            box.p_y = box.p_y +
                font:draw_wrap(entry.text, box, Logger.FONT_SCALE, Logger.FONT_SPACE, Logger.FONT_COLOR).y
        end

        if self.user.debug.frame_rate then
            flak.screen.draw_box_2(Box2:new(8.0, 8.0, 48.0, Logger.FONT_SCALE), nil, nil, Color.BLACK)
            font:draw(flak.window.get_frame_rate(), Vector2:new(8.0, 8.0), Logger.FONT_SCALE, Logger.FONT_SPACE,
                Color.WHITE)
        end
    end, Camera2D:new(Vector2.ZERO, Vector2.ZERO, 0.0, self.user:get_zoom()))
end

---Draw the text buffer.
---@private
function Logger:buffer_draw()
    if self.scroll then
        self.window.scroll_to_y = 1.0
        self.scroll = false
    end

    self.window:box(Box2:new(0.0, 0.0, 1.0, 0.5), Color.BLACK:alpha(0.75))
    self.window.point = Vector2:zero()
    self.window:scroll("buffer", Vector2:new(1.0, self.window.view.y * 0.5 - 16.0),
        function()
            for i = 1, #self.buffer do
                local entry = self.buffer[i]

                self.window.color = entry.color
                self.window:label(entry.text)
            end
        end
    )

    --[[]]

    self.window.scale    = Vector2:new(1.0, Window.WIDGET_SCALE.y)
    self.window.no_glyph = true
    -- TO-DO fucking fix focus bug already JFC
    self.record, cache   = self.window:record("", self.record)
    if cache.focus and cache.click and not string.is_empty(self.record) then
        self:command_decode(self.record)
        self.record = ""
        table.clear(self.suggest)
    end

    if cache.change then
        self:suggest_build()
    end

    self.window:glyph(cache, {
        [1] = {
            Window.INPUT.MOVE_A,
            Window.INPUT.MOVE_B,
            "HISTORY",
            Logger.INPUT.SUGGEST,
            "SUGGEST",
            Window.INPUT.ACCEPT,
            "ACCEPT"
        }
    })
end

---Scroll the history buffer.
---@param direction boolean # True to scroll "up", false to scroll "down".
---@private
function Logger:history_scroll(direction)
    local index_a    = direction and #self.history or 1
    local index_b    = direction and 1 or #self.history
    local index_step = direction and -1 or 1

    if not table.is_empty(self.history) then
        local index = 0

        for i = index_a, index_b, index_step do
            local value = self.history[i]

            if value == self.record then
                index = i
                break
            end
        end

        if self.history[index + index_step] then
            self.record = self.history[index + index_step]
        else
            self.record = self.history[index_a]
        end

        cache.record_caret = #self.record
    end
end

---Draw the suggest buffer.
---@private
function Logger:suggest_draw()
    if not table.is_empty(self.suggest) then
        self.window:scroll("suggest", Vector2:new(1.0, self.window.view.y * 0.5 - 32.0),
            function()
                for i = 1, #self.suggest do
                    local entry = self.suggest[i]

                    self.window:box(
                        Box2:new(0.0, self.window.point.y, 1.0, Window.WIDGET_SCALE.y),
                        Color.BLACK:alpha(0.75))

                    self.window.scale = Vector2:new(1.0, Window.WIDGET_SCALE.y)
                    self.window.no_board = true
                    if self.window:button(entry.text).click then
                        cache.record_caret = #entry.text
                        self.record = entry.text
                    end

                    if entry.info then
                        local prior = Vector2:clone(self.window.point)
                        self.window.point = Vector2:new(self.window.area.s_x,
                            self.window.point.y - Window.WIDGET_SCALE.y)
                        self.window:label(entry.info, Window.TEXT_ALIGN.R_MOST)
                        self.window.point = prior
                    end
                end
            end
        )
    end
end

---Scroll the suggest buffer.
---@private
function Logger:suggest_scroll()
    if not table.is_empty(self.suggest) then
        local index = 0

        for i = 1, #self.suggest do
            local value = self.suggest[i]

            if value.text == self.record then
                index = i
                break
            end
        end

        if self.suggest[index + 1] then
            self.record = self.suggest[index + 1].text
        else
            self.record = self.suggest[1].text
        end

        cache.record_caret = #self.record
    end
end

---Build the suggest buffer.
---@private
function Logger:suggest_build()
    table.clear(self.suggest)

    if not string.is_empty(self.record) then
        for key, _ in next, self.command do
            if string.is_head(key, self.record) then
                table.insert(self.suggest, {
                    text = key,
                    info = "command"
                })
            end
        end

        local token = string.tokenize(self.record, ".")

        if string.is_tail(self.record, ".") then
            table.insert(token, "")
        end

        local where = _G

        for i = 1, #token - 1 do
            local part = token[i]

            if where[part] then
                where = where[part]
            else
                return {}
            end
        end

        local last_part = token[#token]

        if type(where) == "table" then
            for key, value in next, where do
                if string.is_head(key, last_part) then
                    local path = ""

                    for i = 1, #token - 1 do
                        path = i == 1 and token[i] or path .. "." .. token[i]
                    end

                    if path == "" then
                        path = key
                    else
                        path = path .. "." .. key
                    end

                    local info   = "lua"
                    local access = Logger:table_index(_G, path)

                    if not (access == nil) then
                        info = type(access)
                    end

                    table.insert(self.suggest, {
                        text = path,
                        info = info
                    })
                end
            end
        end
    end
end

---Decode a text string into a command, and run it, or interpret the text as a Lua value to print, or Lua code to execute.
---@param text string # command name, Lua value name or Lua code.
---@private
function Logger:command_decode(text)
    -- Insert the text into the buffer as an user-command line.
    table.insert(self.buffer, Line:new(text, Line.KIND.COMMAND, true))

    -- Insert the text into the buffer, only if the previous command is different from this command.
    if not (self.history[#self.history] == text) then
        table.insert(self.history, text)
    end

    --[[]]

    local which = {}
    local token = string.tokenize(self.record, " ")

    for i = 1, #token do
        local entry = string.tokenize(token[i], "\"")
        table.insert(which, entry[1])
    end

    local command = self.command[which[1]]

    -- If there's a command for this text, run it.
    if command then
        command(which)
    else
        local access = self:table_index(_G, text)

        -- If the text is a valid Lua path (e.g. Game.user.video.scale), print it.
        if not (access == nil) then
            print(access, true)
        else
            -- Load the string as Lua code.
            local chunk, error = loadstring(text, "logger")

            if error then
                -- Print parse error.
                print(error, false, Line.KIND.FAILURE)
            else
                local success, error = pcall(chunk)

                if not success then
                    -- Print logic error.
                    print(error, false, Line.KIND.FAILURE)
                end
            end
        end
    end
end

---Check if a string is a valid Lua index into a table. (e.g. "foo.xyz.abc" is foo["xyz"]["abc"].)
---@param  value table  # Table.
---@param  index string # Index.
---@return any   value
function Logger:table_index(value, index)
    local token  = string.tokenize(index, ".")
    local result = value

    if type(result) == "table" then
        for i = 1, #token do
            local key = token[i]

            if result then
                result = result[key]
            else
                break
            end
        end
    end

    return result
end

--[[----------------------------------------------------------------]]

---@class Line : Class
---@field private text  string
---@field private time  number
---@field private color Color
---@field private new   fun(self: Line, text: string, kind: LineKind): Line
Line = Class:class_extend("Line")
---@enum LineKind
Line.KIND = {
    HISTORY = 0,
    COMMAND = 1,
    SUCCESS = 2,
    WARNING = 3,
    FAILURE = 4,
}
---@private
Line.COLOR = {
    [Line.KIND.HISTORY] = Color.WHITE,
    [Line.KIND.COMMAND] = Color.GRAY,
    [Line.KIND.SUCCESS] = Color.G,
    [Line.KIND.WARNING] = Color:new(0, 127, 127, 255),
    [Line.KIND.FAILURE] = Color.R,
}

function Line:instance(text, kind, time)
    local time_window = flak.window.get_time()
    self.text         = time and string.format("(%.2f) %s", time_window, text) or text
    self.time         = time_window
    self.color        = Line.COLOR[kind]
end

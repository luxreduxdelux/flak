bit = require("bit")
require("table.clear")

INPUT = {
    ---@enum input_device
    DEVICE = {
        BOARD = 1,
        MOUSE = 2,
        PAD   = 4,
    },
    ---@enum input_board
    BOARD = {
        NULL         = 0,
        APOSTROPHE   = 39,
        COMMA        = 44,
        MINUS        = 45,
        PERIOD       = 46,
        SLASH        = 47,
        ZERO         = 48,
        ONE          = 49,
        TWO          = 50,
        THREE        = 51,
        FOUR         = 52,
        FIVE         = 53,
        SIX          = 54,
        SEVEN        = 55,
        EIGHT        = 56,
        NINE         = 57,
        SEMICOLON    = 59,
        EQUAL        = 61,
        A            = 65,
        B            = 66,
        C            = 67,
        D            = 68,
        E            = 69,
        F            = 70,
        G            = 71,
        H            = 72,
        I            = 73,
        J            = 74,
        K            = 75,
        L            = 76,
        M            = 77,
        N            = 78,
        O            = 79,
        P            = 80,
        Q            = 81,
        R            = 82,
        S            = 83,
        T            = 84,
        U            = 85,
        V            = 86,
        W            = 87,
        X            = 88,
        Y            = 89,
        Z            = 90,
        L_BRACKET    = 91,
        BACKSLASH    = 92,
        R_BRACKET    = 93,
        GRAVE        = 96,
        SPACE        = 32,
        ESCAPE       = 256,
        ENTER        = 257,
        TAB          = 258,
        BACKSPACE    = 259,
        INSERT       = 260,
        DELETE       = 261,
        RIGHT        = 262,
        LEFT         = 263,
        DOWN         = 264,
        UP           = 265,
        PAGE_UP      = 266,
        PAGE_DOWN    = 267,
        HOME         = 268,
        END          = 269,
        CAPS_LOCK    = 280,
        SCROLL_LOCK  = 281,
        NUMBER_LOCK  = 282,
        PRINT_SCREEN = 283,
        PAUSE        = 284,
        F1           = 290,
        F2           = 291,
        F3           = 292,
        F4           = 293,
        F5           = 294,
        F6           = 295,
        F7           = 296,
        F8           = 297,
        F9           = 298,
        F10          = 299,
        F11          = 300,
        F12          = 301,
        L_SHIFT      = 340,
        L_CONTROL    = 341,
        L_ALTERNATE  = 342,
        L_SUPER      = 343,
        R_SHIFT      = 344,
        R_CONTROL    = 345,
        R_ALTERNATE  = 346,
        R_SUPER      = 347,
        KB_MENU      = 348,
        PAD_0        = 320,
        PAD_1        = 321,
        PAD_2        = 322,
        PAD_3        = 323,
        PAD_4        = 324,
        PAD_5        = 325,
        PAD_6        = 326,
        PAD_7        = 327,
        PAD_8        = 328,
        PAD_9        = 329,
        PAD_DECIMAL  = 330,
        PAD_DIVIDE   = 331,
        PAD_MULTIPLY = 332,
        PAD_SUBTRACT = 333,
        PAD_ADD      = 334,
        PAD_ENTER    = 335,
        PAD_EQUAL    = 336,
        BACK         = 4,
        MENU         = 5,
        VOLUME_UP    = 24,
        VOLUME_DOWN  = 25,
        [0]          = "NULL",
        [39]         = "'",
        [44]         = ",",
        [45]         = "-",
        [46]         = ".",
        [47]         = "/",
        [48]         = "0",
        [49]         = "1",
        [50]         = "2",
        [51]         = "3",
        [52]         = "4",
        [53]         = "5",
        [54]         = "6",
        [55]         = "7",
        [56]         = "8",
        [57]         = "9",
        [59]         = ";",
        [61]         = "=",
        [65]         = "A",
        [66]         = "B",
        [67]         = "C",
        [68]         = "D",
        [69]         = "E",
        [70]         = "F",
        [71]         = "G",
        [72]         = "H",
        [73]         = "I",
        [74]         = "J",
        [75]         = "K",
        [76]         = "L",
        [77]         = "M",
        [78]         = "N",
        [79]         = "O",
        [80]         = "P",
        [81]         = "Q",
        [82]         = "R",
        [83]         = "S",
        [84]         = "T",
        [85]         = "U",
        [86]         = "V",
        [87]         = "W",
        [88]         = "X",
        [89]         = "Y",
        [90]         = "Z",
        [91]         = "[",
        [92]         = "\\",
        [93]         = "]",
        [96]         = "`",
        [32]         = "Space",
        [256]        = "Escape",
        [257]        = "Return",
        [258]        = "Tab",
        [259]        = "Backspace",
        [260]        = "Insert",
        [261]        = "Delete",
        [262]        = "Right",
        [263]        = "Left",
        [264]        = "Down",
        [265]        = "Up",
        [266]        = "Page Up",
        [267]        = "Page Down",
        [268]        = "Home",
        [269]        = "End",
        [280]        = "Shift Lock",
        [281]        = "Scroll Lock",
        [282]        = "Number Lock",
        [283]        = "Print Screen",
        [284]        = "Pause",
        [290]        = "F1",
        [291]        = "F2",
        [292]        = "F3",
        [293]        = "F4",
        [294]        = "F5",
        [295]        = "F6",
        [296]        = "F7",
        [297]        = "F8",
        [298]        = "F9",
        [299]        = "F10",
        [300]        = "F11",
        [301]        = "F12",
        [340]        = "L. Shift",
        [341]        = "L. Control",
        [342]        = "L. Alternate",
        [343]        = "L. Super",
        [344]        = "R. Shift",
        [345]        = "R. Control",
        [346]        = "R. Alternate",
        [347]        = "R. Super",
        [348]        = "Board Menu",
        [320]        = "Key-Pad 0",
        [321]        = "Key-Pad 1",
        [322]        = "Key-Pad 2",
        [323]        = "Key-Pad 3",
        [324]        = "Key-Pad 4",
        [325]        = "Key-Pad 5",
        [326]        = "Key-Pad 6",
        [327]        = "Key-Pad 7",
        [328]        = "Key-Pad 8",
        [329]        = "Key-Pad 9",
        [330]        = "Key-Pad Decimal",
        [331]        = "Key-Pad Divide",
        [332]        = "Key-Pad Multiply",
        [333]        = "Key-Pad Subtract",
        [334]        = "Key-Pad Add",
        [335]        = "Key-Pad Enter",
        [336]        = "Key-Pad Equal",
        [4]          = "Back",
        [5]          = "Menu",
        [24]         = "Volume Up",
        [25]         = "Volume Down"
    },
    ---@enum input_mouse
    MOUSE = {
        LEFT    = 0,
        RIGHT   = 1,
        MIDDLE  = 2,
        SIDE    = 3,
        EXTRA   = 4,
        FORWARD = 5,
        BACK    = 6,
        [0]     = "LEFT",
        [1]     = "RIGHT",
        [2]     = "MIDDLE",
        [3]     = "SIDE",
        [4]     = "EXTRA",
        [5]     = "FORWARD",
        [6]     = "BACK"
    },
    ---@enum input_pad
    PAD = {
        UNKNOWN      = 0,
        L_UP         = 1,
        L_RIGHT      = 2,
        L_DOWN       = 3,
        L_LEFT       = 4,
        R_UP         = 5,
        R_RIGHT      = 6,
        R_DOWN       = 7,
        R_LEFT       = 8,
        L_TRIGGER_1  = 9,
        L_TRIGGER_2  = 10,
        R_TRIGGER_1  = 11,
        R_TRIGGER_2  = 12,
        MIDDLE_LEFT  = 13,
        MIDDLE       = 14,
        MIDDLE_RIGHT = 15,
        L_THUMB      = 16,
        R_THUMB      = 17,
        [0]          = "UNKNOWN",
        [1]          = "L_UP",
        [2]          = "L_RIGHT",
        [3]          = "L_DOWN",
        [4]          = "L_LEFT",
        [5]          = "R_UP",
        [6]          = "R_RIGHT",
        [7]          = "R_DOWN",
        [8]          = "R_LEFT",
        [9]          = "L_TRIGGER_1",
        [10]         = "L_TRIGGER_2",
        [11]         = "R_TRIGGER_1",
        [12]         = "R_TRIGGER_2",
        [13]         = "MIDDLE_LEFT",
        [14]         = "MIDDLE",
        [15]         = "MIDDLE_RIGHT",
        [16]         = "L_THUMB",
        [17]         = "R_THUMB"
    },
}

---@enum PathKind
PATH_KIND = {
    FILE          = 0,
    FOLDER        = 1,
    SYMBOLIC_LINK = 2
}

---@enum ConnectionStatus
CONNECTION_STATUS = {
    READY    = 0,
    LOAD     = 1,
    OFF_LINE = 2
}

---@enum SystemKind
SYSTEM_KIND = {
    LINUX   = 0,
    WINDOWS = 1,
    MAC_OS  = 2,
    ANDROID = 3,
    I_OS    = 4,
    OTHER   = 5
}

---@enum MessageKind
MESSAGE_KIND = {
    INFO    = 0,
    WARNING = 1,
    FAILURE = 2,
}

---@enum ChannelKind
CHANNEL_KIND = {
    UNRELIABLE     = 0,
    RELIABLE_ORDER = 1,
    RELIABLE       = 2,
}

--[[----------------------------------------------------------------]]

---Convert a path string into a compatible OS path string.
---@param  value  string # Path string.
---@return string value  # Path string (compatible with current OS).
function string.system_path(value)
    if flak.data.get_system() == SYSTEM_KIND.WINDOWS then
        return string.search_change(value, "/", "\\")
    else
        return value
    end
end

---Insert a target string into a source string.
---@param  value  string # Source string.
---@param  index  number # Insertion index for target string.
---@param  insert string # Target string.
---@return string value
function string.insert(value, index, insert)
    return string.sub(value, 0, index) .. insert .. string.sub(value, index + 1)
end

---Remove a character from a string.
---@param  value  string # String.
---@param  index? number # Character index to remove. If nil, will remove the last character.
---@return string value
function string.remove(value, index)
    if index then
        return string.sub(value, 0, index - 1) .. string.sub(value, index + 1)
    end

    return string.sub(value, 0, #value - 1)
end

---Search and change a string for another.
---@param  value  string # Value.
---@param  search string # Search string.
---@param  change string # Change string.
---@return string value
function string.search_change(value, search, change)
    local value = string.gsub(value, search, change)
    return value
end

---Tokenize a string with a given delimiter.
---@param  value    string   # Value.
---@param  token    string   # Token list string (example: ".:").
---@return string[] tokenize # Token list.
function string.tokenize(value, token)
    local result = {}

    for token in string.gmatch(value, "[^" .. token .. "]+") do
        table.insert(result, token)
    end

    return result
end

---Trim the head of a string with another.
---@param  value string # Value.
---@param  head  string # Head string.
---@return string value
function string.trim_head(value, head)
    return string.sub(value, #head + 1)
end

---Trim the tail of a string with another.
---@param  value string # Value.
---@param  tail  string # Tail string.
---@return string value
function string.trim_tail(value, tail)
    return string.sub(value, 0, -(#tail + 1))
end

---Check if a string's head is equal to another.
---@param  value string # Value.
---@param  head  string # Head string.
---@return boolean check
function string.is_head(value, head)
    return string.sub(value, 0, #head) == head
end

---Check if a string's tail is equal to another.
---@param  value string # Value.
---@param  tail  string # Tail string.
---@return boolean check
function string.is_tail(value, tail)
    return string.sub(value, #value - #tail + 1) == tail
end

---Check if a string is alphabetical.
---@param  value   string # String.
---@return boolean string
function string.is_string(value)
    for token in string.gmatch(value, "%a") do
        return true
    end

    return false
end

---Check if a string is numerical.
---@param  value   string # String.
---@return boolean number
function string.is_number(value)
    for token in string.gmatch(value, "%d") do
        return true
    end

    return false
end

---Check if a string is symbolic.
---@param  value   string # String.
---@return boolean symbol
function string.is_symbol(value)
    return not (string.is_string(value) or string.is_number(value))
end

---Check if a string is empty.
---@param  value   string # Value.
---@return boolean check  # True if empty, false otherwise.
function string.is_empty(value)
    return #value == 0
end

--[[----------------------------------------------------------------]]

---Clone a table and every table value within it.
---@param  value   table # Table to clone.
---@param  result? table # Private.
---@return table   clone # Table clone.
function table.clone(value, result)
    if not result then
        result = {}
    end

    for k, v in next, value do
        if type(v) == "table" then
            result[k] = table.clone(v)
        else
            result[k] = v
        end
    end

    local meta = getmetatable(value)

    if meta then
        setmetatable(result, meta)
    end

    return result
end

---Copy every key/value from one table to another. Will not clone any table value.
---@param source  table   # Source table.
---@param target  table   # Source table.
---@param recurse boolean # Recursively walk source table.
---@param meta    boolean # Apply source table's metatable to the target table.
function table.copy(source, target, recurse, meta)
    for k, v in next, source do
        if type(v) == "table" then
            if recurse then
                table.copy(v, target[k], recurse, meta)
            else
                target[k] = v
            end
        else
            target[k] = v
        end
    end

    if meta then
        local meta = getmetatable(source)

        if meta then
            setmetatable(target, meta)
        end
    end
end

---Insert a value in a table, only if it isn't already present in the table.
---@param value  table # Set table.
---@param object any   # Set table object.
function table.insert_set(value, object)
    if not table.is_in_set(value, object) then
        table.insert(value, object)
    end
end

---Remove an object from a table.
---@param value  table   # Table to remove the value from.
---@param object any     # Value to remove.
---@param order  boolean # Keep original table order, or swap the last element in place of the value.
function table.remove_object(value, object, order)
    for i, entry in next, value do
        if entry == object then
            if type(i) == "number" then
                if order then
                    table.remove(value, i)
                else
                    table.remove_last(value, i)
                end
            else
                value[i] = nil
            end

            return
        end
    end
end

---Remove an object from a table, swapping the last element in place of the object.
---@param value table  # Table to remove the value from.
---@param index number # Value index.
function table.remove_last(value, index)
    local count = #value
    value[index] = value[count]
    value[count] = nil
end

---Recursively walk every table and re-apply its metatable, within a table.
---@param value table # Table to re-apply metatable to.
function table.meta(value)
    table.walk(value, function(value)
        if value.__class then
            local meta = _G[value.__class]

            if meta then
                setmetatable(value, meta)
            end
        end
    end)
end

---Recursively walk every table, within a table.
---@param value table             # Table to recursively walk.
---@param call  fun(value: table) # Call-back function.
---@param loop  table?            # Private.
function table.walk(value, call, loop)
    if not loop then
        loop = {}
    end

    if table.is_in_set(loop, value) then
        return
    end

    if type(value) == "table" then
        table.insert(loop, value)

        if type(value) == "table" then
            call(value)
        end

        for key, entry in next, value do
            if type(entry) == "table" then
                table.walk(entry, call, loop)
            end
        end
    end
end

--Add each key/value pair from one table into another.
---@param source  table   # Source table.
---@param target  table   # Target table.
---@param insert  boolean # Do array insertion, rather than hash insertion.
---@param reverse boolean # Do array insertion, in reverse.
function table.join(source, target, insert, reverse)
    if insert then
        if reverse then
            local count = #source

            for i = 1, count do
                table.insert(target, 1, source[count - i + 1])
            end
        else
            local count = #target

            for i = 1, #source do
                target[count + i] = source[i]
            end
        end
    else
        for key, entry in next, source do
            target[key] = entry
        end
    end
end

---Pick a random choice out of a table array.
---@param  value   table  # Table array.
---@param  chance? table  # Table array, must be the same size as value, containing the "weight" or "chance" of the object at value[index].
---@return any     choice # Table choice.
function table.random(value, chance)
    local count = #value

    if count == 0 then
        return nil
    end

    if count == 1 then
        return value[1]
    end

    while true do
        local index = math.round(math.random_range(1, count))

        if not chance or math.random() <= chance[index] then
            return value[index]
        end
    end
end

---Check a deep table equality between table A and table B.
---@param  a       any # Table A.
---@param  b       any # Table B.
---@return boolean equal
function table.is_equal(a, b)
    if a == b then
        return true
    end

    if not (type(a) == "table" and type(b) == "table") then
        return a == b
    end

    for k, v in next, a do
        if not table.is_equal(v, b[k]) then
            return false
        end
    end

    for k, _ in next, b do
        if a[k] == nil then
            return false
        end
    end

    return true
end

---Check if the table is empty.
---@param  value   table # Table to check.
---@return boolean check # True if table is empty, false otherwise.
function table.is_empty(value)
    return #value == 0
end

---Check if a value is the value to any key within the table.
---@param  value   table # Table to search.
---@param  object  any   # Value to locate.
---@return boolean find  # True if value is in set, false otherwise.
function table.is_in_set(value, object)
    for _, entry in next, value do
        if entry == object then
            return true
        end
    end

    return false
end

--[[----------------------------------------------------------------]]

---Perform DDA grid traversal.
---@param source Vector2                      # Source point.
---@param target Vector2                      # Target point.
---@param grid   number                       # Grid size.
---@param call   fun(point: Vector2): boolean # Cell call-back.
function math.grid_traversal(source, target, grid, call)
    local source_x       = source.x / grid
    local source_y       = source.y / grid
    local target_x       = target.x / grid
    local target_y       = target.y / grid
    local direction_x    = target_x - source_x
    local direction_y    = target_y - source_y
    local point_source_x = math.floor(source_x)
    local point_source_y = math.floor(source_y)
    local point_target_x = math.floor(target_x)
    local point_target_y = math.floor(target_y)
    local step_x         = direction_x > 0 and 1 or -1
    local step_y         = direction_y > 0 and 1 or -1
    local delta_x        = not (direction_x == 0) and math.abs(1 / direction_x) or math.huge
    local delta_y        = not (direction_y == 0) and math.abs(1 / direction_y) or math.huge
    local max_x          = direction_x > 0 and (math.floor(source_x) + 1 - source_x) * delta_x
        or (source_x - math.floor(source_x)) * delta_x
    local max_y          = direction_y > 0 and (math.floor(source_y) + 1 - source_y) * delta_y
        or (source_y - math.floor(source_y)) * delta_y
    local point          = Vector2:zero()

    while true do
        point:set(point_source_x, point_source_y)

        if call(point) then
            break
        end

        flak.screen.draw_box_2(
            Box2:new(point_source_x * grid, point_source_y * grid, grid, grid),
            Vector2:zero(),
            0.0,
            Color.WHITE:alpha(0.5)
        )

        if point_source_x == point_target_x and point_source_y == point_target_y then
            break
        end

        if max_x < max_y then
            max_x = max_x + delta_x
            point_source_x = point_source_x + step_x
        elseif max_y < max_x then
            max_y = max_y + delta_y
            point_source_y = point_source_y + step_y
        else
            max_x = max_x + delta_x
            max_y = max_y + delta_y
            point_source_x = point_source_x + step_x
            point_source_y = point_source_y + step_y
        end
    end
end

---Clamp a value within a given range boundary.
---@param  value  number # Value.
---@param  a      number # Range (lower bound).
---@param  b      number # Range (upper bound).
---@return number value
function math.clamp(value, a, b)
    if value < a then
        return a
    end

    if value > b then
        return b
    end

    return value
end

---Snap a value to a grid.
---@param  value  number # Value.
---@param  grid   number # Grid size.
---@return number value
function math.snap(value, grid)
    return math.round(value / grid) * grid
end

---Round a value to the nearest integer, be it below or above .5.
---@param  value  number # Value.
---@return number value
function math.round(value)
    return math.floor(value + 0.5)
end

---Calculate linear interpolation between A and B.
---@param  value  number # Interpolation value, or "t". Goes from 0.0 to 1.0.
---@param  a      number # "A" value.
---@param  b      number # "B" value.
---@return number value
function math.interpolate(value, a, b)
    return a + (b - a) * value
end

---Get a percentage from a value.
---@param  value  number # Value.
---@param  a      number # Range (lower bound).
---@param  b      number # Range (upper bound).
---@return number value
function math.percentage_from_value(value, a, b)
    return (value - a) / (b - a)
end

---Get a value from a percentage.
---@param  value  number # Value. Goes from 0.0 to 1.0
---@param  a      number # Range (lower bound).
---@param  b      number # Range (upper bound).
---@return number value
function math.value_from_percentage(value, a, b)
    return value * (b - a) + a
end

---Easing function (in-out quad).
---@param  value number # Value. Goes from 0.0 to 1.0.
---@return number value
function math.ease_in_out_quad(value)
    return value < 0.5 and 2.0 * value * value or 1.0 - (-2 * value + 2.0) ^ 2.0 / 2.0
end

---Easing function (out bounce).
---@param  value number # Value. Goes from 0.0 to 1.0.
---@return number value
function math.ease_out_bounce(value)
    local n = 7.5625
    local d = 2.75

    if value < 1.0 / d then
        return n * value * value
    elseif value < 2.0 / d then
        value = value - 1.5 / d
        return n * value * value + 0.75
    elseif value < 2.5 / d then
        value = value - 2.25 / d
        return n * value * value + 0.9375
    else
        value = value - 2.625 / d
        return n * value * value + 0.984375
    end
end

---Convert a degree value to a radian value.
---@param  value number # Degree value.
---@return number value # Radian value.
function math.degree_to_radian(value)
    return (value * math.pi) / 180.0
end

---Convert a radian value to a degree value.
---@param  value number # Radian value.
---@return number value # Degree value.
function math.radian_to_degree(value)
    return (value * 180.0) / math.pi
end

---Pick a random value within a range.
---@param  a      number # Range (lower bound).
---@param  b      number # Range (upper bound).
---@return number value
function math.random_range(a, b)
    return math.random() * (b - a) + a
end

---Check if a number is within range.
---@param  value   number # Number.
---@param  a       number # Range (lower bound).
---@param  b       number # Range (upper bound).
---@return boolean check
function math.in_range(value, a, b)
    return value >= a and value <= b
end

---Calculate a fade in effect.
---@param  value      number # Number, or time into the fade.
---@param  fade_a_min number # Fade A (lower bound).
---@param  fade_a_max number # Fade A (upper bound).
---@param  fade_b_min number # Fade B (lower bound).
---@param  fade_b_max number # Fade B (upper bound).
---@return number value
function math.fade(value, fade_a_min, fade_a_max, fade_b_min, fade_b_max)
    if value <= fade_a_min then
        return 0.0
    elseif math.in_range(value, fade_a_min, fade_a_max) then
        return math.ease_in_out_quad(math.percentage_from_value(value, fade_a_min, fade_a_max))
    elseif math.in_range(value, fade_a_max, fade_b_min) then
        return 1.0
    elseif math.in_range(value, fade_b_min, fade_b_max) then
        return 1.0 - math.ease_in_out_quad(math.percentage_from_value(value, fade_b_min, fade_b_max))
    elseif value >= fade_b_max then
        return 0.0
    end
end

---Get the sign of a number.
---@param  value  number # Number.
---@return number sign
function math.sign(value)
    return value >= 0.0 and 1.0 or -1.0
end

---Check if a number is even.
---@param  value   number # Number.
---@return boolean even
function math.is_even(value)
    return (bit.band(value, 1) == 0)
end

---Check if a number is invalid (NaN or an infinite value).
---@param value number # Number.
function math.is_invalid(value)
    ---@format disable-next
    return not (value == value)
        or value ==  math.huge
        or value == -math.huge
end

---Check if a number is an integer.
---@param  value   number  # Number.
---@return boolean integer
function math.is_integer(value)
    return value % 1 == 0
end

--[[----------------------------------------------------------------]]

---Check if a bit at a given index is set.
---@param  value number # Value.
---@param  index number # Index.
---@result boolean check
function bit.get_at(value, index)
    local mask = bit.lshift(1, index)

    return not (bit.band(value, mask) == 0)
end

---Perform a bitwise AND operation.
---@param  a number # L-hand value.
---@param  b number # R-hand value.
---@result boolean check
function bit.binary_and(a, b)
    return not (bit.band(a, b) == 0)
end

--[[----------------------------------------------------------------]]

---@class Class
---@field private __class string
---@field private __super string
Class = {}
---@private
Class.__index = Class

---@private
function Class:new(...)
    local object = setmetatable({ __class = self.__class }, self)

    local stack = {}
    local class = self

    while class do
        if rawget(class, "instance") then
            table.insert(stack, 1, class.instance)
        end

        class = class.__super
    end

    for i = 1, #stack do
        local instance = stack[i]
        instance(object, ...)
    end

    return object
end

---Extend a class (inheritance).
---@param  class string # Class type-name.
---@return table value
function Class:class_extend(class)
    local object = { __class = class, __super = self }
    object.__index = object

    return setmetatable(object, self)
end

---Check if we are of a certain class.
---@param class Class # Class.
function Class:class_is(class)
    return self.__class == class.__class
end

---Get the meta-table.
---@return table meta # Meta-table.
function Class:class_meta()
    return getmetatable(self)
end

---Load data from a given table.
---@param value table # Table.
function Class:class_from(value)
    table.copy(value, self)
    table.meta(self)
end

--[[----------------------------------------------------------------]]

---@class Queue : Class
---@field table table
---@field new   fun(self: Queue): Queue
Queue = Class:class_extend("Queue")

function Queue:instance()
    self.table = {}
end

---Free a value from the queue.
---@return any value
function Queue:free()
    return table.remove(self.table, 1)
end

---Push a value onto the queue.
---@param value any # Value to push.
function Queue:push(value)
    table.insert(self.table, value)
end

---Peek a value from the queue.
---@return any value
function Queue:peek()
    return self.table[1]
end

---Check if the queue is empty.
---@return boolean empty
function Queue:is_empty()
    return table.is_empty(self.table)
end

--[[----------------------------------------------------------------]]

---@class Stack : Class
---@field table table
---@field new   fun(self: Stack): Stack
Stack = Class:class_extend("Stack")

function Stack:instance()
    self.table = {}
end

---Free a value from the stack.
---@return any value
function Stack:free()
    return table.remove(self.table, #self.table)
end

---Push a value onto the stack.
---@param value any # Value to push.
function Stack:push(value)
    table.insert(self.table, value)
end

---Peek a value from the stack.
---@return any value
function Stack:peek()
    return self.table[#self.table]
end

---Check if the queue is empty.
---@return boolean empty
function Stack:is_empty()
    return table.is_empty(self.table)
end

--[[----------------------------------------------------------------]]

---@class Vector2 : Class
---@field x   number
---@field y   number
---@field new fun(self: Vector2, x: number, y: number): Vector2
Vector2 = Class:class_extend("Vector2")

function Vector2:instance(x, y)
    self.x = x
    self.y = y
end

Vector2.ZERO = Vector2:new(0.0, 0.0)
Vector2.ONE  = Vector2:new(1.0, 1.0)
Vector2.X    = Vector2:new(1.0, 0.0)
Vector2.Y    = Vector2:new(0.0, 1.0)

---Set the value of the vector.
---@param x number | Vector2 # X component.
---@param y number           # Y component.
function Vector2:set(x, y)
    if type(x) == "table" then
        self.x = x.x
        self.y = x.y
    else
        self.x = x
        self.y = y
    end
end

---Clone a vector.
---@param  value    Vector2 # Vector to clone.
---@return Vector2 clone    # Clone.
function Vector2:clone(value)
    return Vector2:new(value.x, value.y)
end

---Get a "zero" vector.
---@return Vector2 vector # Vector.
function Vector2:zero()
    return Vector2:new(0.0, 0.0)
end

---Get a "one" vector.
---@return Vector2 vector # Vector.
function Vector2:one()
    return Vector2:new(1.0, 1.0)
end

---Get an "X" vector.
---@return Vector2 vector # Vector.
function Vector2:x()
    return Vector2:new(1.0, 0.0)
end

---Get an "Y" vector.
---@return Vector2 vector # Vector.
function Vector2:y()
    return Vector2:new(0.0, 1.0)
end

---Get a scalar vector, with every component set to the scalar value.
---@param  scalar   number # Scalar value.
---@return Vector2 vector # Vector.
function Vector2:scalar(scalar)
    return Vector2:new(scalar, scalar)
end

---Get the length of the vector.
---@return number length # Length.
function Vector2:length()
    return math.sqrt(self.x * self.x + self.y * self.y)
end

---Get the normal of the vector.
---@return Vector2 vector # Vector.
function Vector2:normal()
    local length = self:length()

    if not (length == 0) then
        length = 1.0 / length
        return Vector2:new(self.x * length, self.y * length)
    else
        return Vector2:zero()
    end
end

---Calculate the dot product against another vector.
---@param  value  Vector2 # Vector to calculate dot product against.
---@return number dot      # Dot product.
function Vector2:dot(value)
    return (self.x * value.x) + (self.y * value.y)
end

---Snap the vector to a grid.
---@param  grid    number  # Grid size.
---@param  floor?  boolean # Use `math.floor` instead of `math.snap`.
---@return Vector2 vector  # Vector.
function Vector2:snap(grid, floor)
    if floor then
        return Vector2:new(
            math.floor(self.x / grid) * grid,
            math.floor(self.y / grid) * grid
        )
    end

    return Vector2:new(math.snap(self.x, grid), math.snap(self.y, grid))
end

---Get the angle of the vector.
---@return number angle # Angle.
function Vector2:angle()
    return math.atan2(self.y, self.x)
end

---@operator add(Vector2): Vector2
function Vector2:__add(other)
    return Vector2:new(self.x + other.x, self.y + other.y)
end

---@operator sub(Vector2): Vector2
function Vector2:__sub(other)
    return Vector2:new(self.x - other.x, self.y - other.y)
end

---@operator mul(any): Vector2
function Vector2:__mul(other)
    if type(self) == "number" then
        return Vector2:new(self * other.x, self * other.y)
    else
        return Vector2:new(other * self.x, other * self.y)
    end
end

---@operator unm(): Vector2
function Vector2:__unm()
    return Vector2:new(-self.x, -self.y)
end

function Vector2:__eq(other)
    return self.x == other.x and self.y == other.y
end

function Vector2:__tostring()
    return string.format("{ x = %s, y = %s }", self.x, self.y)
end

--[[----------------------------------------------------------------]]

---@class Ray : Class
---@field source Vector2
---@field target Vector2
---@field new    fun(self: Ray, source: Vector2, target: Vector2): Ray
Ray = Class:class_extend("Ray")

function Ray:instance(source, target)
    self.source = source
    self.target = target
end

---Clone a ray.
---@param  value Ray   # Ray to clone.
---@return Ray   clone # Clone.
function Ray:clone(value)
    return Ray:new(Vector2:clone(value.source), Vector2:clone(value.target))
end

--[[----------------------------------------------------------------]]

---@class Color : Class
---@field r   number
---@field g   number
---@field b   number
---@field a   number
---@field new fun(self: Color, r: number, g: number, b: number, a: number): Color
Color = Class:class_extend("Color")

function Color:instance(r, g, b, a)
    self.r = r
    self.g = g
    self.b = b
    self.a = a
end

Color.WHITE = Color:new(255, 255, 255, 255)
Color.BLACK = Color:new(0, 0, 0, 255)
Color.R = Color:new(255, 0, 0, 255)
Color.G = Color:new(0, 255, 0, 255)
Color.B = Color:new(0, 0, 255, 255)
Color.GRAY = Color:new(127, 127, 127, 255)

---Get a "white" color.
---@return Color color # Color.
function Color:white()
    return Color:new(255, 255, 255, 255)
end

---Get a "black" color.
---@return Color color # Color.
function Color:black()
    return Color:new(0, 0, 0, 255)
end

---Get an "R-channel" color.
---@return Color color # Color.
function Color:r()
    return Color:new(255, 0, 0, 255)
end

---Get a "G-channel" color.
---@return Color color # Color.
function Color:g()
    return Color:new(0, 255, 0, 255)
end

---Get a "B-channel" color.
---@return Color color # Color.
function Color:b()
    return Color:new(0, 0, 255, 255)
end

---Get a scalar color, with every component except the A-channel set to the scalar value.
---@param  scalar number # Scalar value.
---@param  alpha  number # A-channel value.
---@return Color  color  # Color.
function Color:scalar(scalar, alpha)
    return Color:new(scalar, scalar, scalar, alpha)
end

---Interpolate a color with another one.
---@param  value  Color  # Color to interpolate with.
---@param  amount number # Interpolation amount.
---@return Color  color  # Color.
function Color:interpolate(value, amount)
    return Color:new(
        math.round(math.interpolate(amount, self.r, value.r)),
        math.round(math.interpolate(amount, self.g, value.g)),
        math.round(math.interpolate(amount, self.b, value.b)),
        math.round(math.interpolate(amount, self.a, value.a))
    )
end

---Get a color with a given A-channel value, from 0.0 to 1.0.
---@param  alpha number # A-channel value.
---@return Color color  # Color.
function Color:alpha(alpha)
    return Color:new(self.r, self.g, self.b, math.round(math.clamp(alpha, 0.0, 1.0) * 255.0))
end

--[[----------------------------------------------------------------]]

---@class ray_check
---@field point    Vector2
---@field where    Vector2
---@field distance number
ray_check = {}

---@class Box2
---@field p_x number
---@field p_y number
---@field s_x number
---@field s_y number
---@field new fun(self: Box2, p_x: number, p_y: number, s_x: number, s_y: number): Box2
Box2 = Class:class_extend("Box2")

function Box2:instance(p_x, p_y, s_x, s_y)
    self.p_x = p_x
    self.p_y = p_y
    self.s_x = s_x
    self.s_y = s_y
end

---Set the value of the box.
---@param p_x number | Box2 # Point X component.
---@param p_y number        # Point Y component.
---@param s_x number        # Scale X component.
---@param s_y number        # Scale Y component.
function Box2:set(p_x, p_y, s_x, s_y)
    if type(p_x) == "table" then
        self.p_x = p_x.p_x
        self.p_y = p_x.p_y
        self.s_x = p_x.s_x
        self.s_y = p_x.s_y
    else
        self.p_x = p_x
        self.p_y = p_y
        self.s_x = s_x
        self.s_y = s_y
    end
end

---Clone a box.
---@param  value Box2 # Box to clone.
---@return Box2 clone # Clone.
function Box2:clone(value)
    return Box2:new(value.p_x, value.p_y, value.s_x, value.s_y)
end

---Get a "zero" box.
---@return Box2 box # Box.
function Box2:zero()
    return Box2:new(0.0, 0.0, 0.0, 0.0)
end

---Intersection test between a box and a point.
---@param  point   Vector2 # Point to check against.
---@return boolean check    # Intersection result.
function Box2:is_point_inside(point)
    return
        (point.x >= self.p_x and point.x <= self.p_x + self.s_x) and
        (point.y >= self.p_y and point.y <= self.p_y + self.s_y)
end

---Total/partial intersection test between a box and a box.
---@param  box     Box2 # Box to check against.
---@return boolean check # Intersection result.
function Box2:is_box_inside(box)
    return
        (self.p_x <= (box.p_x + box.s_x) and (self.p_x + self.s_x) >= box.p_x) and
        (self.p_y <= (box.p_y + box.s_y) and (self.p_y + self.s_y) >= box.p_y)
end

---Total intersection test between a box and a box.
---@param  box     Box2 # Box to check against.
---@return boolean check # Intersection result. True if `self` is fully inside of `box`.
function Box2:is_box_inside_total(box)
    local self_max_x = self.p_x + self.s_x
    local self_max_y = self.p_y + self.s_y
    local box_max_x = box.p_x + box.s_x
    local box_max_y = box.p_y + box.s_y

    return box.p_x <= self.p_x and box.p_y <= self.p_y and box_max_x >= self_max_x and box_max_y >= self_max_y
end

---Intersection test between a box and a ray. The ray's `target` will be taken as a direction vector.
---@param  ray       Ray   # Ray to check against.
---@return ray_check check # Intersection result.
function Box2:is_ray_inside(ray)
    local ray_check = {}

    local min_x = self.p_x
    local min_y = self.p_y
    local max_x = self.p_x + self.s_x
    local max_y = self.p_y + self.s_y

    local insideBox = (ray.source.x > min_x)
        and (ray.source.x < max_x)
        and (ray.source.y > min_y)
        and (ray.source.y < max_y)

    if insideBox then
        ray.target = ray.target * -1.0
    end

    local direction_x = 1.0 / ray.target.x
    local direction_y = 1.0 / ray.target.y

    local ray_min_x = (min_x - ray.source.x) * direction_x
    local ray_max_x = (max_x - ray.source.x) * direction_x
    local ray_min_y = (min_y - ray.source.y) * direction_y
    local ray_max_y = (max_y - ray.source.y) * direction_y
    local t_min = math.max(math.min(ray_min_x, ray_max_x), math.min(ray_min_y, ray_max_y))
    local t_max = math.min(math.max(ray_min_x, ray_max_x), math.max(ray_min_y, ray_max_y))

    if not ((t_max < 0) or (t_min > t_max)) then
        ray_check.length   = t_min
        ray_check.point    = ray.source + ray.target * ray_check.length

        ray_check.normal.x = (min_x + max_x) * 0.5
        ray_check.normal.y = (min_y + max_y) * 0.5
        ray_check.normal   = ray_check.point - ray_check.normal
        ray_check.normal   = ray_check.normal * 2.00 * 1.01
        ray_check.normal.x = ray_check.normal.x / (max_x - min_x)
        ray_check.normal.y = ray_check.normal.y / (max_y - min_y)
        ray_check.normal.x = math.modf(ray_check.normal.x)
        ray_check.normal.y = math.modf(ray_check.normal.y)

        ray_check.normal   = ray_check.normal:normal()

        if insideBox then
            ray.target       = ray.target * -1.0
            ray_check.length = ray_check.length * -1.0
            ray_check.normal = ray_check.normal * -1.0
        end

        return ray_check
    end
end

---Box cast against a box.
---@param  box       Box2  # Box to check against.
---@return ray_check check # Intersection result.
function Box2:cast(box, where)
    local box_clone = Box2:clone(box)

    box_clone.p_x = box_clone.p_x - self.s_x * 0.5
    box_clone.p_y = box_clone.p_y - self.s_y * 0.5
    box_clone.s_x = box_clone.s_x + self.s_x
    box_clone.s_y = box_clone.s_y + self.s_y

    local point = self:get_center()
    local intersection = box_clone:is_ray_inside(ray:new(point, where - point))

    flak.screen.draw_box_2(box_clone, nil, nil, Color:g():alpha(0.5))

    if intersection then
        intersection.point = intersection.point - self:get_scale() * 0.5
    end

    return intersection
end

---Calculate the minimum translation vector.
---@param  box     Box2   # Box to calculate M.T.V. against.
---@return Vector2 vector # M.T.V. result.
function Box2:minimum_vector(box)
    local self_max_x = self.p_x + self.s_x
    local self_max_y = self.p_y + self.s_y
    local box_max_x = box.p_x + box.s_x
    local box_max_y = box.p_y + box.s_y
    local overlap_x = math.min(self_max_x, box_max_x) - math.max(self.p_x, box.p_x)
    local overlap_y = math.min(self_max_y, box_max_y) - math.max(self.p_y, box.p_y)

    if overlap_x <= 0 or overlap_y <= 0 then
        return Vector2:zero()
    end

    local center_a_x = (self.p_x + self_max_x) * 0.5
    local center_a_y = (self.p_y + self_max_y) * 0.5
    local center_b_x = (box.p_x + box_max_x) * 0.5
    local center_b_y = (box.p_y + box_max_y) * 0.5

    if overlap_x < overlap_y then
        if center_a_x < center_b_x then
            return Vector2:new(overlap_x * -1.0, 0.0)
        else
            return Vector2:new(overlap_x, 0.0)
        end
    else
        if center_a_y < center_b_y then
            return Vector2:new(0.0, overlap_y * -1.0)
        else
            return Vector2:new(0.0, overlap_y)
        end
    end
end

---Create a new box from a given point and scale vector.
---@param  point Vector2 # Point.
---@param  scale Vector2 # Scale.
---@return Box2 Box2    # 2-dimensional box.
function Box2:vector(point, scale)
    return Box2:new(point.x, point.y, scale.x, scale.y)
end

---Add a given value to the box's point value.
---@param point Vector2 # Point.
function Box2:add_point(point)
    return Box2:new(self.p_x + point.x, self.p_y + point.y, self.s_x, self.s_y)
end

---Add a given value to the box's scale value.
---@param scale Vector2 # Scale.
function Box2:add_scale(scale)
    return Box2:new(self.p_x, self.p_y, self.s_x + scale.x, self.s_y + scale.y)
end

---Get the box's point value as a vector.
---@return Vector2 point # Box point.
function Box2:get_point()
    return Vector2:new(self.p_x, self.p_y)
end

---Get the box's scale value as a vector.
---@return Vector2 scale # Box scale.
function Box2:get_scale()
    return Vector2:new(self.s_x, self.s_y)
end

---Get the box's center.
---@return Vector2 point # Box center.
function Box2:get_center()
    return Vector2:new(self.p_x + self.s_x * 0.5, self.p_y + self.s_y * 0.5)
end

---Set the box's point value as a vector.
---@param point Vector2 # Point.
function Box2:set_point(point)
    self.p_x = point.x
    self.p_y = point.y
end

---Set the box's scale value as a vector.
---@param scale Vector2 # Scale.
function Box2:set_scale(scale)
    self.s_x = scale.x
    self.s_y = scale.y
end

---@operator mul(any): Box2
function Box2:__mul(other)
    return Box2:new(
        self.p_x * other,
        self.p_y * other,
        self.s_x * other,
        self.s_y * other
    )
end

--[[----------------------------------------------------------------]]

---@class Camera2D : Class
---@field point Vector2
---@field shift Vector2
---@field angle number
---@field zoom  number
---@field new   fun(self: Camera2D, point: Vector2, shift: Vector2, angle: number, zoom: number): Camera2D
Camera2D = Class:class_extend("Camera2D")

function Camera2D:instance(point, shift, angle, zoom)
    self.point = point
    self.shift = shift
    self.angle = angle
    self.zoom = zoom
end

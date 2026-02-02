---@class Asset : Class
---@field texture table
---@field font    table
---@field sound   table
---@field music   table
---@field path    table
---@field new     fun(self: Asset, load_list: table): Asset
Asset = Class:class_extend("Asset")
Asset.SHEET_POST_FIX = "_sheet.lua"

function Asset:instance(load_list)
    self.texture = {}
    self.font    = {}
    self.sound   = {}
    self.music   = {}
    self.path    = {}

    -- For each folder in the load list...
    for i = 1, #load_list do
        local path = load_list[i]
        local kind = flak.data.get_kind(path)

        if kind then
            -- Path is a file/archive.
            if kind == PATH_KIND.FILE then
                local archive = flak.archive.new(path)

                local file_list = archive:get_list()

                -- For each file in the folder...
                for i = 1, #file_list do
                    local entry = file_list[i]

                    if not string.is_tail(entry, "/") then
                        self.path[entry] = AssetEntry:new(entry, archive)
                    end
                end
            else
                -- Scan folder recursively.
                local file_list = flak.data.get_list(path, true)

                -- For each file in the folder...
                for i = 1, #file_list do
                    local entry = file_list[i]

                    if flak.data.get_kind(entry) == PATH_KIND.FILE then
                        -- Get the "virtual" path ("data/foo.png" -> "foo.png").
                        local path = string.sub(entry, #path + 2)

                        if not string.is_head(path, ".") then
                            -- ...and set it as the key to the "physical" path ("foo.png" -> "data/foo.png")
                            self.path[path] = AssetEntry:new(entry)
                        end
                    end
                end
            end
        end
    end
end

---Get a full list of every file in a given directory.
---@param  path     string    # Path to directory.
---@param  recurse  boolean   # Recurse directory search.
---@return string[] file_list # Table array of every file in given directory.
function Asset:get_file_list(path, recurse)
    path = string.system_path(path)

    local result = {}

    for virtual_path, _ in next, self.path do
        if string.sub(virtual_path, 0, #path) == path then
            local local_path = string.sub(virtual_path, #path + 1)

            if recurse or not string.find(local_path, "/") then
                table.insert(result, virtual_path)
            end
        end
    end

    -- Table sorting is done to prevent any kind of order-dependant issue.
    table.sort(result)

    return result
end

---Get the data of a file.
---@param  path   string  # Path to file.
---@param  binary boolean # Interpret the file data as UTF-8 string data, or as a MessagePack file.
---@return any    data    # File data.
function Asset:get_file(path, binary)
    local pick = self:get(self.path, path)

    if pick.from then
        return pick.from:get_file(pick.path, binary)
    else
        return flak.data.get_file(pick.path, binary)
    end
end

---Get the data of a file and interpret it as Lua source code.
---@param  path string # Path to file.
---@return any  result
function Asset:get_code(path)
    return loadstring(self:get_file(path))()
end

---Get a texture asset.
---@param  path      string     # Path to asset.
---@return Texture   texture    # Handle to asset.
---@return number    identifier # Texture identifier.
---@return Vector2   scale      # Texture scale.
---@return table|nil sheet      # Texture sheet table.
function Asset:get_texture(path)
    local asset = self:get(self.texture, path)

    return asset[1], asset[2], asset[3], asset[4]
end

---Set a texture asset.
---@param  path      string     # Path to asset.
---@return Texture   texture    # Handle to asset.
---@return number    identifier # Texture identifier.
---@return Vector2   scale      # Texture scale.
---@return table|nil sheet      # Texture sheet table.
function Asset:set_texture(path)
    path = string.system_path(path)

    if not self.texture[path] then
        local texture    = self:set(self.texture, flak.texture.new, flak.texture.new_archive, path)
        local sheet      = nil
        local sheet_path = string.sub(path, 0, -5) .. Asset.SHEET_POST_FIX
        local identifier = texture:get_identifier()
        local scale      = texture:get_scale()

        -- If there's a texture sheet at the given path...
        if self.path[sheet_path] then
            -- Load it, and store it alongside the texture.
            sheet = self:get_code(sheet_path)
            self.texture[path] = { texture, identifier, scale, sheet }
        else
            self.texture[path] = { texture, identifier, scale }
        end

        return texture, identifier, scale, sheet
    else
        return self.texture[path][1], self.texture[path][2], self.texture[path][3], self.texture[path][4]
    end
end

---Get a font asset.
---@param  path string # Path to asset.
---@return Font font   # Handle to asset.
function Asset:get_font(path)
    return self:get(self.font, path)
end

---Set a font asset.
---@param  path              string # Path to asset.
---@param  scale             number # Font scale.
---@param  code_point_range? table  # Font code point range.
---@return Font              font   # Handle to asset.
function Asset:set_font(path, scale, code_point_range)
    return self:set(self.font, flak.font.new, flak.font.new_archive, path, scale, code_point_range)
end

---Get a sound asset.
---@param  path  string # Path to asset.
---@return Sound sound  # Handle to asset.
function Asset:get_sound(path)
    return self:get(self.sound, path)
end

---Set a sound asset.
---@param  path  string # Path to asset.
---@return Sound sound  # Handle to asset.
function Asset:set_sound(path, count)
    return self:set(self.sound, flak.sound.new, flak.sound.new_archive, path, count)
end

---Get a music asset.
---@param  path  string # Path to asset.
---@return Music music  # Handle to asset.
function Asset:get_music(path)
    return self:get(self.music, path)
end

---Set a music asset.
---@param  path  string # Path to asset.
---@return Music music  # Handle to asset.
function Asset:set_music(path)
    return self:set(self.music, flak.music.new, flak.music.new_archive, path)
end

---Clear an asset entry.
---@param asset table  # Asset table (e.g. asset.texture, asset.sound, etc.)
---@param path  string # Path to asset.
function Asset:clear(asset, path)
    path = string.system_path(path)

    asset[path] = nil
end

--[[----------------------------------------------------------------]]

---Get an asset entry.
---@param  asset table  # Asset table (e.g. asset.texture, asset.sound, etc.)
---@param  path  string # Path to asset.
---@return any   asset
---@private
function Asset:get(asset, path)
    path = string.system_path(path)

    return asset[path] or error(string.format("Asset:get(): No asset \"%s\" found.", path))
end

---Set an asset entry.
---@param  asset         table  # Asset table (e.g. asset.texture, asset.sound, etc.)
---@param  call          string # Function call (to retrieve a file from the file-system).
---@param  call_archive  string # Function call (to retrieve a file from the archive).
---@param  path          string # Path to asset.
---@return any           asset
---@private
function Asset:set(asset, call, call_archive, path, ...)
    path = string.system_path(path)

    -- Don't load the same asset twice.
    if not asset[path] then
        local entry = self.path[path]

        if entry then
            local entry_path = entry.path
            local entry_from = entry.from

            if entry_from then
                asset[path] = call_archive(entry_path, entry_from, ...)
            else
                asset[path] = call(entry_path, ...)
            end
        else
            error(string.format("Could not find asset \"%s\".", path))
        end
    end

    return asset[path]
end

--[[----------------------------------------------------------------]]

---@class AssetEntry : Class
---@field path    string
---@field from    Archive|nil
---@field new     fun(self: AssetEntry, path: string, from?: Archive): AssetEntry
AssetEntry = Class:class_extend("AssetEntry")

function AssetEntry:instance(path, from)
    self.path = path
    self.from = from
end

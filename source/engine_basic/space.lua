---@class Space : Class
---@field scale   Vector2
---@field grid    number
---@field hash    Entity[]
---@field entity  Entity[]
---@field new     fun(self: Space, scale: Vector2, grid: number): Space
Space = Class:class_extend("Space")

function Space:instance(scale, grid)
    self.scale  = scale
    self.grid   = grid
    self.hash   = {}
    self.entity = {}
end

---Draw the state.
function Space:draw()
    local point = Vector2:zero()
    local box   = Box2:zero()

    for i, entry in next, self.hash do
        point:set(
            math.floor(i % self.scale.x),
            math.floor(i / self.scale.x)
        )

        flak.screen.draw_box_2(
            Box2:new(point.x * self.grid, point.y * self.grid, self.grid, self.grid),
            Vector2:zero(),
            0.0,
            Color:r():alpha(0.5)
        )
    end

    for i, entity in next, self.entity do
        flak.screen.draw_box_2(
            Box2:new(entity.point.x, entity.point.y, entity.scale.x, entity.scale.y),
            Vector2:zero(),
            0.0,
            Color:g():alpha(0.5)
        )
    end
end

---Update the state.
function Space:main()
    table.clear(self.hash)

    for i = 1, #self.entity do
        self:entity_insert(self.entity[i])
    end
end

---Attach an entity.
---@param entity Entity # Entity to attach.
function Space:entity_attach(entity)
    table.insert(self.entity, entity)
    self:entity_insert(entity)
end

---Detach an entity.
---@param entity Entity # Entity to detach.
function Space:entity_detach(entity)
    table.remove_object(self.entity, entity, false)
    self:main()
end

---Query the spatial hash grid with a 2D ray.
---@param  ray          Ray       # Ray to query with.
---@param  skip         Entity?   # Entity skip.
---@param  mask         Mask?     # Entity mask.
---@return Entity[]|nil collision # Entity collision table.
function Space:query_ray(ray, skip, mask)
    local entry_ray = ray:new(ray.source, ray.target - ray.source)
    local entry_box = Box2:zero()
    local result    = nil

    math.grid_traversal(ray.source, ray.target, self.grid, function(point)
        local cell = self.hash[(point.y * self.scale.x) + point.x]

        if cell then
            for i = 1, #cell do
                local entity = cell[i]

                if not skip or not (skip == entity) then
                    if not mask or (mask and not (bit.band(mask.target, entity.mask.source) == 0)) then
                        entry_box:set(entity.point.x, entity.point.y, entity.scale.x, entity.scale.y)

                        if entry_box:is_ray_inside(entry_ray) then
                            if result then
                                table.insert_set(result, entity)
                            else
                                result = { entity }
                            end
                        end
                    end
                end
            end
        end
    end)

    return result
end

---Query the spatial hash grid with a 2D box.
---@param  box          Box2      # Box to query with.
---@param  skip         Entity?   # Entity skip.
---@param  mask         Mask?     # Entity mask.
---@return Entity[]|nil collision # Entity collision table.
function Space:query_box(box, skip, mask)
    local entry_box = Box2:zero()
    local min_x     = math.floor(box.p_x / self.grid)
    local max_x     = math.floor((box.p_x + box.s_x - 0.01) / self.grid)
    local min_y     = math.floor(box.p_y / self.grid)
    local max_y     = math.floor((box.p_y + box.s_y - 0.01) / self.grid)
    local result    = nil

    for x = min_x, max_x do
        for y = min_y, max_y do
            local cell = self.hash[(y * self.scale.x) + x]

            if cell then
                for i = 1, #cell do
                    local entity = cell[i]

                    if not skip or not (skip == entity) then
                        if not mask or (mask and not (bit.band(mask.target, entity.mask.source) == 0)) then
                            entry_box:set(entity.point.x, entity.point.y, entity.scale.x, entity.scale.y)

                            if entry_box:is_box_inside(box) then
                                if result then
                                    table.insert_set(result, entity)
                                else
                                    result = { entity }
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return result
end

--[[----------------------------------------------------------------]]

---Insert entity into the spatial hash grid.
---@param entity Entity # Entity to insert.
---@private
function Space:entity_insert(entity)
    local min_x = math.floor(entity.point.x / self.grid)
    local max_x = math.floor((entity.point.x + entity.scale.x - 0.01) / self.grid)
    local min_y = math.floor(entity.point.y / self.grid)
    local max_y = math.floor((entity.point.y + entity.scale.y - 0.01) / self.grid)

    for x = min_x, max_x do
        for y = min_y, max_y do
            local cell = self.hash[(y * self.scale.x) + x]

            if cell then
                table.insert(cell, entity)
            else
                self.hash[(y * self.scale.x) + x] = { entity }
            end
        end
    end
end

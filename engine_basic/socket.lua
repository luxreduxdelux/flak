---@class Socket : Class
---@field connection Server|Client
---@field new     fun(self: Socket, server: boolean, address: string, user_data?: table): Socket
Socket = Class:class_extend("Socket")

function Socket:instance(server, address, user_data)
    local tokenize   = string.tokenize(address, ".:")
    local address_a  = tonumber(tokenize[1])
    local address_b  = tonumber(tokenize[2])
    local address_c  = tonumber(tokenize[3])
    local address_d  = tonumber(tokenize[4])
    local port       = tonumber(tokenize[5])
    local connection = server and flak.network.new_server or flak.network.new_client

    self.server      = server
    self.connection  = connection(address_a, address_b, address_c, address_d, port, server and 4 or user_data)
    self.error       = false
end

---Update the socket state.
function Socket:main()
    if self.server then
        local message_list, enter_list, leave_list = self.connection:update(1.0 / 60.0)

        for i = 1, #message_list do
            local entry   = message_list[i]
            local client  = entry[1] + 2
            local packet  = entry[2]

            local kind    = packet[1]
            local data    = packet[2]

            local handler = self[kind]

            if handler then
                handler(self, client, kind, data)
            else
                error("Packet without function: " .. kind)
            end
        end

        if enter_list then
            for i = 1, #enter_list do
                local entry     = enter_list[i]
                local user_data = self.connection:get_client_user_data(entry)
                self:socket_enter(entry + 2, user_data)
            end
        end

        if leave_list then
            for i = 1, #leave_list do
                local entry = leave_list[i]
                self:socket_leave(entry + 2)
            end
        end
    else
        if not self.error then
            local success, result = pcall(self.connection.update, self.connection, (1.0 / 60.0))

            if success then
                for i = 1, #result do
                    local packet  = result[i]
                    local kind    = packet[1]
                    local data    = packet[2]

                    local handler = self[kind]

                    if handler then
                        handler(self, kind, data)
                    else
                        error("Packet without function: " .. kind)
                    end
                end
            else
                self.error = true
            end
        end
    end
end

---Send a message.
---@param kind table # Packet kind.
---@param data table # Packet data.
function Socket:set(kind, data)
    self.connection:set({
        kind.index,
        data,
    }, kind.channel)
end

---*Server only.* Send a message to a specific client.
---@param kind   table  # Packet kind.
---@param data   table  # Packet data.
---@param client number # Client identifier.
function Socket:set_client(kind, data, client)
    self.connection:set_client({
        kind.index,
        data,
    }, kind.channel, client - 2)
end

---*Server only.* Send a message to a every client, except a specific client.
---@param kind   table  # Packet kind.
---@param data   table  # Packet data.
---@param client number # Client identifier.
function Socket:set_except(kind, data, client)
    self.connection:set_client_except({
        kind.index,
        data,
    }, kind.channel, client - 2)
end

---*Server only*. Disconnect a specific client.
---@param client number # Client identifier.
function Socket:disconnect_client(client)
    self.connection:disconnect(client - 2)
end

---Disconnect.
function Socket:disconnect()
    if self.server then
        self.connection:disconnect_all()
    else
        self.connection:disconnect()
    end
end

---Get the connection's round-trip time.
---@return number round
function Socket:get_round_trip_time()
    if self.server then
        return 0.0
    else
        return self.connection:get_round_trip_time()
    end
end

---Get the connection status.
---@return number status
function Socket:get_status()
    if self.error then
        return 2
    end

    return self.server and 0 or self.connection:get_status()
end

---Get the connection client identifier.
---@return number status
function Socket:get_identifier()
    return self.server and 1 or self.connection:get_identifier() + 2
end

---Verify data from a packet.
---@param  client      number # Client ID.
---@param  packet      packet # Packet.
---@param  key         string # Packet data key.
---@param  value_type? string # Packet data value type.
---@return boolean     check  # True if verification check was successful.
function Socket:verify(client, packet, key, value_type)
    local value = packet.data[key]

    if not value then
        self:disconnect_with_reason(client,
            string.format("Missing key \"%s\" for packet \"%s\".",
                key, packet.kind)
        )
        return false
    end

    if value_type and not (type(value) == value_type) then
        self:disconnect_with_reason(client,
            string.format("Invalid value for key \"%s\" for packet \"%s\", got type \"%s\", was expecting type \"%s\".",
                key, packet.kind, type(value), value_type)
        )
        return false
    end

    return true
end

---@class packet
---@field kind string
---@field data table
packet = {}

---Verify number data from a packet.
---@param  client  number # Client ID.
---@param  packet  packet # Packet.
---@param  key     string # Packet data key.
---@param  range?  table  # Range table. [1] is min, [2] is max.
---@return boolean check  # True if verification check was successful.
function Socket:verify_number(client, packet, key, range)
    local value = packet.data[key]

    if self:verify(packet, key, "number", client) then
        return false
    end

    if range and not math.in_range(value, range[1], range[2]) then
        -- disconnect client
        self:disconnect_with_reason(client,
            string.format(
                "Number value out of range for key \"%s\" for packet \"%s\", got value \"%s\", was expecting to be in range %s-%s.",
                key, packet.kind, value, range[1], range[2])
        )
        return false
    end

    return value
end

function Socket:verify_string(client, packet, key, allow_empty)
    local value = packet.data[key]

    if self:verify(packet, key, "string", client) then
        return false
    end

    if not allow_empty and string.is_empty(value) then
        self:disconnect_with_reason(client,
            string.format(
                "String value for key \"%s\" for packet \"%s\", is empty, was expecting it to not be.",
                key, packet.kind, value)
        )
        return false
    end

    return value
end

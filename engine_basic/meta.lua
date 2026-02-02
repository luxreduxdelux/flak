---@meta

---@class flak
flak = {}

---Calculate the scale of text.
---@param text string # Text to evaluate.
---@param scale number # Scale of text to evaluate.
---@param space number # Space of text to evaluate.
---@return Vector2 scale # Scale of text.
function Font:measure(text, scale, space) end

---Input (board) API.
flak.input.board = {}

---Serialize a Lua value as string.
---@param data any # Lua value to serialize as string.
---@param pretty boolean # Pretty serialization.
---@return string data # Value as string.
function flak.data.into_string(data, pretty) end

---Disconnect a specific client.
function Server:disconnect() end

---Show a message dialog.
---@param kind MessageKind # Message kind.
---@param name string # Message window name.
---@param text string # Message window text.
---@param button_a string # Message window button text (A).
---@param button_b? string # Message window button text (B).
---@param button_c? string # Message window button text (C).
---@return string button # Text of the button that was hit.
function flak.window.dialog_message(kind, name, text, button_a, button_b, button_c) end

---Create a new client.
---@param address_a number # Segment 1 of IPV4 address.
---@param address_b number # Segment 2 of IPV4 address.
---@param address_c number # Segment 3 of IPV4 address.
---@param address_d number # Segment 4 of IPV4 address.
---@param port number # Address port.
---@param user_data table # User data.
---@return Client client # Client resource.
function flak.network.new_client(address_a, address_b, address_c, address_d, port, user_data) end

---Data API.
flak.data = {}

---Initialize a 2D draw session.
---@param call function # Draw function.
---@param camera Camera2D # 2D camera.
function flak.screen.draw_2D(call, camera) end

---Set the pitch of the sound.
---@param pitch number # Pitch value.
---@param alias? number # Alias index.
function Sound:set_pitch(pitch, alias) end

---Input (mouse) API.
flak.input.mouse = {}

---Get the last key character press.
---@return number|nil character # Key character.
function flak.input.board.get_last_character() end

---Get the name of a game-pad.
---@param index number # Game-pad index.
---@return string name # Game-pad name.
function flak.input.pad.get_name(index) end

---Get the alias count.
---@return number count # Alias count.
function Sound:get_alias_count() end

---Initialize a draw session.
---@param call function # Draw function.
function TextureTarget:begin(call) end

---Update music.
function Music:update() end

---Initialize a scissor clip draw session.
---@param call function # Draw function.
---@param area Box2 # Draw area.
function flak.screen.draw_scissor(call, area) end

---Update the client.
---@param delta number # Time delta.
---@return table message_list # Table array, containing every message.
function Client:update(delta) end

---Resume sound.
---@param alias? number # Alias index.
function Sound:resume(alias) end

---Get the state (release) of a mouse button.
---@param code number # Mouse button code.
---@return boolean state # Mouse button state.
function flak.input.mouse.is_release(code) end

---Get the exit state of the window.
---@return boolean state # Exit state.
function flak.window.is_exit() end

---Get the state (up) of a key.
---@param code number # Key code.
---@return boolean state # Key state.
function flak.input.board.is_up(code) end

---Wipe the frame-buffer.
---@param color Color # Color to wipe the frame-buffer with.
function flak.screen.wipe(color) end

---Set the volume of the music.
---@param volume number # Volume value.
function Music:set_volume(volume) end

---Get the last mouse button press.
---@return number|nil code # Mouse button code.
function flak.input.mouse.get_last_press() end

---Window API.
flak.window = {}

---Project a screen point to a world point.
---@param point Vector2 # Screen point.
---@param camera Camera2D # 2D camera.
function flak.screen.get_screen_to_world(point, camera) end

---Disconnect from the server.
function Client:disconnect() end

---Get a full list of every file in the archive.
---@return table file_list # Table array of every file in the archive.
function Archive:get_list() end

---Perform a batch draw.
---@param buffer cdata # Texture batch buffer pointer.
---@param length number # Texture batch length.
function flak.texture.draw_batch(buffer, length) end

---Get the current play state.
---@param alias? number # Alias index.
---@return boolean state # Current play state.
function Sound:is_play(alias) end

---Get the state (up) of a game-pad button.
---@param index number # Game-pad index.
---@param code number # Game-pad button code.
---@return boolean state # Game-pad button state.
function flak.input.pad.is_up(index, code) end

---Sound API.
flak.sound = {}

---Create a new Archive resource.
---@param path string # Path to archive.
---@return Archive archive # Archive resource.
function flak.archive.new(path) end

---Stop sound.
---@param alias? number # Alias index.
function Sound:stop(alias) end

---Get the connection status to the server.
---@return ConnectionStatus status # Connection status.
function Client:get_status() end

---Get the current screen scale.
---@return Vector2 scale # Screen scale.
function flak.window.get_screen_scale() end

---Texture class.
---@class Texture
Texture = {}

---Get the state (release) of a key.
---@param code number # Key code.
---@return boolean state # Key state.
function flak.input.board.is_release(code) end

---Get the current time.
---@return number time # Current time.
function flak.window.get_time() end

---Send a message to the server.
---@param message table # Message to send.
---@param channel ChannelKind # Message channel.
function Client:set(message, channel) end

---Draw text with text wrap.
---@param text string # Text to draw.
---@param box_2 Box2 # Constraint area of text to draw.
---@param scale number # Scale of text to draw.
---@param space number # Space of text to draw.
---@param color Color # Color of text to draw.
---@return Vector2 scale # Scale of text.
function Font:draw_wrap(text, box_2, scale, space, color) end

---Set the data of a file.
---@param path string # Path to file.
---@param data any # Data to write to file.
---@param binary boolean # Interpret the file data as UTF-8 string data, or as a MessagePack file.
function flak.data.set_file(path, data, binary) end

---Set the current window scale.
---@param scale Vector2 # Window scale.
function flak.window.set_window_scale(scale) end

---Get the client's unique identifier.
---@return number identifier # Client identifier.
function Client:get_identifier() end

---Get the point of the mouse cursor on-screen.
---@return Vector2 point # Mouse cursor point.
function flak.input.mouse.get_point() end

---Project a world point to a screen point.
---@param point Vector2 # World point.
---@param camera Camera2D # 2D camera.
function flak.screen.get_world_to_screen(point, camera) end

---Get the state (down) of a game-pad button.
---@param index number # Game-pad index.
---@param code number # Game-pad button code.
---@return boolean state # Game-pad button state.
function flak.input.pad.is_down(index, code) end

---Draw a 2D line.
---@param source Vector2 # Source of the 2D line.
---@param target Vector2 # Target of the 2D line.
---@param thick? number # Thickness of the 2D line.
---@param color? Color # Color of the 2D line.
function flak.screen.draw_line(source, target, thick, color) end

---Create a new Texture resource from an archive.
---@param path string # Path to texture.
---@param archive Archive # Archive to load the asset from.
---@return Texture texture # Texture resource.
function flak.texture.new_archive(path, archive) end

---Get the state (down) of a mouse button.
---@param code number # Mouse button code.
---@return boolean state # Mouse button state.
function flak.input.mouse.is_down(code) end

---Get texture scale.
---@return Vector2 scale # Texture scale.
function TextureTarget:get_scale() end

---Sound class.
---@class Sound
Sound = {}

---Get the focus state.
---@return boolean state # Focus state.
function flak.window.is_focus() end

---Get the frame rate.
---@return number rate # Target frame rate.
function flak.window.get_frame_rate() end

---Archive class.
---@class Archive
Archive = {}

---Resume music.
function Music:resume() end

---Get the state (press) of a game-pad button.
---@param index number # Game-pad index.
---@param code number # Game-pad button code.
---@return boolean state # Game-pad button state.
function flak.input.pad.is_press(index, code) end

---Create a new Font resource.
---@param path string # Path to font.
---@param scale number # Font scale.
---@param range? number # Font code-point range.
---@return Font font # Font resource.
function flak.font.new(path, scale, range) end

---Get texture identifier.
---@return number identifier # Texture identifier.
function Texture:get_identifier() end

---Create a new render-target texture resource.
---@param scale Vector2 # Render-target texture scale.
---@return TextureTarget texture_target # Render-target texture resource.
function flak.texture_target.new(scale) end

---Create a new Font resource from an archive.
---@param path string # Path to font.
---@param archive Archive # Archive to load the asset from.
---@param scale number # Font scale.
---@param range? number # Font code-point range.
---@return Font font # Font resource.
function flak.font.new_archive(path, archive, scale, range) end

---Texture (render-target) class.
---@class TextureTarget
TextureTarget = {}

---Calculate the scale of text, with text wrap.
---@param text string # Text to evaluate.
---@param box_2 Box2 # Constraint area of text to draw.
---@param scale number # Scale of text to evaluate.
---@param space number # Space of text to evaluate.
---@return Vector2 scale # Scale of text.
function Font:measure_wrap(text, box_2, scale, space) end

---Get the current time.
---@return number hour # Hour.
---@return number minute # Minute.
---@return number second # Second.
function flak.data.get_time() end

---Draw a 2D box.
---@param box_2 Box2 # 2D box to draw.
---@param point? Vector2 # Point of the 2D box.
---@param angle? number # Angle of the 2D box.
---@param color? Color # Color of the 2D box.
function flak.screen.draw_box_2(box_2, point, angle, color) end

---Initialize a draw session.
---@param call function # Draw function.
function flak.screen.draw(call) end

---Get the frame time.
---@return number time # Frame time.
function flak.window.get_frame_time() end

---Get the data of a file.
---@param path string # Path to file.
---@param binary boolean # Interpret the file data as UTF-8 string data, or as a MessagePack file.
---@return any data # File data.
function flak.data.get_file(path, binary) end

---Deserialize a string as a Lua value.
---@param data string # String to deserialize as value.
---@return any data # String as value.
function flak.data.from_string(data) end

---Network API.
flak.network = {}

---Get the current master volume.
---@return number volume # Master volume.
function flak.sound.get_master_volume() end

---Get the state (press) of a key.
---@param code number # Key code.
---@return boolean state # Key state.
function flak.input.board.is_press(code) end

---Get the axis state of a game-pad.
---@param index number # Game-pad index.
---@param axis number # Game-pad axis.
---@return number count # Game-pad axis state.
function flak.input.pad.get_axis_state(index, axis) end

---Get the last key press.
---@return number|nil code # Key code.
function flak.input.board.get_last_press() end

---Check if the window scale is different from the previous frame.
---@return boolean resize # True if the window scale is different.
function flak.window.is_scale_new() end

---Get the full-screen state of the window.
---@return boolean state # Full-screen state.
function flak.window.is_full_screen() end

---Music API.
flak.music = {}

---Font class.
---@class Font
Font = {}

---Set the volume of the sound.
---@param volume number # Volume value.
---@param alias? number # Alias index.
function Sound:set_volume(volume, alias) end

---Get the last game-pad button press.
---@param index number # Game-pad index.
---@return number|nil code # Game-pad button code.
function flak.input.pad.get_last_press(index) end

---Disconnect every client.
function Server:disconnect_all() end

---Check the kind of a path.
---@param path string # Path.
---@return PathKind|nil kind # Path kind.
function Archive:get_kind(path) end

---Font API.
flak.font = {}

---Get the current date.
---@return number day # Day.
---@return number month # Month.
---@return number year # Year.
function flak.data.get_date() end

---Get the scroll wheel delta of the mouse.
---@return Vector2 delta # Mouse wheel delta.
function flak.input.mouse.get_wheel() end

---Get the current time.
---@return number time # Current time.
function Music:get_time() end

---Client class.
---@class Client
Client = {}

---Get the state (press-repeat) of a key.
---@param code number # Key code.
---@return boolean state # Key state.
function flak.input.board.is_press_repeat(code) end

---Play music.
function Music:play() end

---Set the pan of the sound.
---@param pan number # Pan value.
---@param alias? number # Alias index.
function Sound:set_pan(pan, alias) end

---Update the server.
---@param delta number # Time delta.
---@return table message_list # Table array, containing every message.
---@return table enter_list # Table array, containing every new connection.
---@return table leave_list # Table array, containing every new disconnection.
function Server:update(delta) end

---Draw texture.
---@param source Box2 # Source of texture to draw.
---@param target Box2 # Target of texture to draw.
---@param point Vector2 # Point of texture to draw.
---@param angle number # Angle of texture to draw.
---@param color Color # Color of texture to draw.
function Texture:draw(source, target, point, angle, color) end

---Get the state (release) of a game-pad button.
---@param index number # Game-pad index.
---@param code number # Game-pad button code.
---@return boolean state # Game-pad button state.
function flak.input.pad.is_release(index, code) end

---Get the clip-board text.
---@return string text # Clip-board text.
function flak.input.board.get_clip_board() end

---Get the state (press) of a mouse button.
---@param code number # Mouse button code.
---@return boolean state # Mouse button state.
function flak.input.mouse.is_up(code) end

---Get the current OS kind.
---@return SystemKind system # System kind.
function flak.data.get_system() end

---Set the clip-board text.
---@param text string # Clip-board text.
function flak.input.board.set_clip_board(text) end

---Get the delta of the mouse.
---@return Vector2 delta # Mouse delta.
function flak.input.mouse.get_delta() end

---Input (pad) API.
flak.input.pad = {}

---Send a message to every client.
---@param message table # Message to send.
---@param channel ChannelKind # Message channel.
function Server:set(message, channel) end

---Set the pitch of the music.
---@param pitch number # Pitch value.
function Music:set_pitch(pitch) end

---Manually begin a scissor clip draw session. Use `draw_scissor` whenever possible.
---@param area Box2 # Draw area.
function flak.screen.draw_scissor_begin(area) end

---Set the frame sync.
---@param sync boolean # Frame sync.
function flak.window.set_frame_sync(sync) end

---Set the exit key.
---@param code? number # Exit key. If nil, no key will cause the window's exit state to enable.
function flak.window.set_exit_key(code) end

---Texture API.
flak.texture = {}

---Get the state (down) of a key.
---@param code number # Key code.
---@return boolean state # Key state.
function flak.input.board.is_down(code) end

---Lock, or unlock, the mouse cursor.
---@param lock boolean # Lock/unlock mouse cursor.
function flak.input.mouse.lock_cursor(lock) end

---Draw texture.
---@param source Box2 # Source of texture to draw.
---@param target Box2 # Target of texture to draw.
---@param point Vector2 # Point of texture to draw.
---@param angle number # Angle of texture to draw.
---@param color Color # Color of texture to draw.
function TextureTarget:draw(source, target, point, angle, color) end

---Play sound.
---@param alias? number # Alias index.
function Sound:play(alias) end

---Send a message to every client, except a specific client.
---@param message table # Message to send.
---@param channel ChannelKind # Message channel.
---@param client number # Specific client.
function Server:set_client_except(message, channel, client) end

---Get the user-data for a specific client.
function Server:get_client_user_data() end

---Set the time of the music.
---@param time number # Time value.
function Music:set_time(time) end

---Check if the mouse cursor is hidden.
---@return boolean hidden # Hidden state.
function flak.input.mouse.is_hidden() end

---Create a new Sound resource.
---@param path string # Path to sound.
---@param count? number # Sound alias copy count.
---@return Sound sound # Sound resource.
function flak.sound.new(path, count) end

---Draw text.
---@param text string # Text to draw.
---@param point Vector2 # Point of text to draw.
---@param scale number # Scale of text to draw.
---@param space number # Space of text to draw.
---@param color Color # Color of text to draw.
function Font:draw(text, point, scale, space, color) end

---Set the pan of the music.
---@param pan number # Pan value.
function Music:set_pan(pan) end

---Get the current window scale.
---@return Vector2 scale # Window scale.
function flak.window.get_window_scale() end

---Set a vibration on a game-pad.
---@param index number # Game-pad index.
---@param motor_a number # Game-pad motor (A) vibration scale.
---@param motor_b number # Game-pad motor (B) vibration scale.
---@param time number # Vibration duration.
function flak.input.pad.set_vibration(index, motor_a, motor_b, time) end

---Stop music.
function Music:stop() end

---Music class.
---@class Music
Music = {}

---Create a new Music resource.
---@param path string # Path to music.
---@return Music music # Music resource.
function flak.music.new(path) end

---Pause sound.
---@param alias? number # Alias index.
function Sound:pause(alias) end

---Create a new server.
---@param address_a number # Segment 1 of IPV4 address.
---@param address_b number # Segment 2 of IPV4 address.
---@param address_c number # Segment 3 of IPV4 address.
---@param address_d number # Segment 4 of IPV4 address.
---@param port number # Address port.
---@param client_count number # Maximum client count.
---@return Server server # Server resource.
function flak.network.new_server(address_a, address_b, address_c, address_d, port, client_count) end

---Set the point of the mouse cursor on-screen.
---@param point Vector2 # Mouse cursor point.
function flak.input.mouse.set_point(point) end

---Create a new texture resource.
---@param path string # Path to texture.
---@return Texture texture # Texture resource.
function flak.texture.new(path) end

---Get the total length.
---@return number length # Total length.
function Music:get_length() end

---Pause music.
function Music:pause() end

---Set the current master volume. Will affect both sound and music.
---@param volume number # Master volume.
function flak.sound.set_master_volume(volume) end

---Get texture scale.
---@return Vector2 scale # Texture scale.
function Texture:get_scale() end

---Draw a 2D box, with edge-rounding.
---@param box_2 Box2 # 2D box to draw.
---@param round number # Edge round scale of the 2D box.
---@param count number # Edge count of the 2D box.
---@param color? Color # Color of the 2D box.
function flak.screen.draw_box_2_round(box_2, round, count, color) end

---Screen API.
flak.screen = {}

---Check if a game-pad is active.
---@param index number # Game-pad index.
---@return boolean active # Game-pad activity.
function flak.input.pad.is_active(index) end

---Input API.
flak.input = {}

---Get the current play state.
---@return boolean state # Current play state.
function Music:is_play() end

---Get the axis count of a game-pad.
---@param index number # Game-pad index.
---@return number count # Game-pad axis count.
function flak.input.pad.get_axis_count(index) end

---Send a message to a specific client.
---@param message table # Message to send.
---@param channel ChannelKind # Message channel.
---@param client number # Specific client.
function Server:set_client(message, channel, client) end

---Show, or hide, the mouse cursor.
---@param show boolean # Show/hide mouse cursor.
function flak.input.mouse.show_cursor(show) end

---Check the kind of a path.
---@param path string # Path.
---@return PathKind|nil kind # Path kind.
function flak.data.get_kind(path) end

---Manually close a scissor clip draw session. Use `draw_scissor` whenever possible.
function flak.screen.draw_scissor_close() end

---Get the data of a file.
---@param path string # Path to file.
---@param binary boolean # Return the value as binary, or as a string.
---@return table|string data # File data.
function Archive:get_file(path, binary) end

---Texture (render-target) API.
flak.texture_target = {}

---Get the current render scale.
---@return Vector2 scale # Render state.
function flak.window.get_render_scale() end

---Get the state (press) of a mouse button.
---@param code number # Mouse button code.
---@return boolean state # Mouse button state.
function flak.input.mouse.is_press(code) end

---Set the frame rate.
---@param rate number # Frame rate.
function flak.window.set_frame_rate(rate) end

---Archive API.
flak.archive = {}

---Get a full list of every file in a given directory.
---@param path string # Path to directory.
---@param recurse boolean # Recurse directory search.
---@return table file_list # Table array of every file in given directory.
function flak.data.get_list(path, recurse) end

---Create a new Sound resource from an archive.
---@param path string # Path to sound.
---@param archive Archive # Archive to load the asset from.
---@param count? number # Sound alias copy count.
---@return Sound sound # Sound resource.
function flak.sound.new_archive(path, archive, count) end

---Toggle between full-screen and window mode.
function flak.window.toggle_full_screen() end

---Server class.
---@class Server
Server = {}


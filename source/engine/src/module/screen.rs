use super::general::*;
use engine_macro::*;

//================================================================

use mlua::prelude::*;
use raylib::prelude::ffi;

//================================================================

#[rustfmt::skip]
#[module(name = "screen", info = "Screen API.")]
pub fn set_global(lua: &mlua::Lua, global: &mlua::Table) -> anyhow::Result<()> {
    let screen = lua.create_table()?;

    screen.set("wipe", lua.create_function(self::wipe)?)?;
    screen.set("draw", lua.create_function(self::draw)?)?;

    //================================================================

    screen.set("draw_2D",                lua.create_function(self::draw_2D)?)?;
    screen.set("draw_2D_begin",          lua.create_function(self::draw_2D_begin)?)?;
    screen.set("draw_2D_close",          lua.create_function(self::draw_2D_close)?)?;
    screen.set("draw_scissor",           lua.create_function(self::draw_scissor)?)?;
    screen.set("draw_scissor_begin",     lua.create_function(self::draw_scissor_begin)?)?;
    screen.set("draw_scissor_close",     lua.create_function(self::draw_scissor_close)?)?;
    screen.set("draw_box_2",             lua.create_function(self::draw_box_2)?)?;
    screen.set("draw_box_2_round",       lua.create_function(self::draw_box_2_round)?)?;
    screen.set("draw_box_2_shade",       lua.create_function(self::draw_box_2_shade)?)?;
    screen.set("draw_line_2D",           lua.create_function(self::draw_line_2D)?)?;
    screen.set("draw_circle",            lua.create_function(self::draw_circle)?)?;
    screen.set("get_screen_to_world_2D", lua.create_function(self::get_screen_to_world_2D)?)?;
    screen.set("get_world_to_screen_2D", lua.create_function(self::get_world_to_screen_2D)?)?;

    //================================================================

    screen.set("draw_3D",                lua.create_function(self::draw_3D)?)?;
    screen.set("draw_grid",              lua.create_function(self::draw_grid)?)?;
    screen.set("draw_cube",              lua.create_function(self::draw_cube)?)?;
    screen.set("draw_line_3D",           lua.create_function(self::draw_line_3D)?)?;
    screen.set("draw_box_3",             lua.create_function(self::draw_box_3)?)?;
    screen.set("get_world_to_screen_3D", lua.create_function(self::get_world_to_screen_3D)?)?;
    screen.set("set_depth_test",         lua.create_function(self::set_depth_test)?)?;

    //================================================================

    global.set("screen", screen)?;

    Ok(())
}

#[function(
    from = "screen",
    info = "Wipe the frame-buffer.",
    parameter(
        name = "color",
        info = "Color to wipe the frame-buffer with.",
        kind = "Color"
    )
)]
fn wipe(lua: &mlua::Lua, color: mlua::Value) -> mlua::Result<()> {
    unsafe {
        let color = Color::try_from(lua, color)?;

        ffi::ClearBackground(color.into());

        Ok(())
    }
}

#[function(
    from = "screen",
    info = "Initialize a draw session.",
    parameter(name = "call", info = "Draw function.", kind = "function")
)]
fn draw(_: &mlua::Lua, call: mlua::Function) -> mlua::Result<()> {
    unsafe {
        ffi::BeginDrawing();
        let call = call.call::<()>(());
        ffi::EndDrawing();

        call
    }
}

//================================================================

#[allow(non_snake_case)]
#[function(
    from = "screen",
    info = "Initialize a 2D draw session.",
    parameter(name = "call", info = "Draw function.", kind = "function"),
    parameter(name = "camera", info = "2D camera.", kind = "Camera2D")
)]
fn draw_2D(lua: &mlua::Lua, (call, camera): (mlua::Function, mlua::Value)) -> mlua::Result<()> {
    unsafe {
        let camera = Camera2D::try_from(lua, camera)?;

        ffi::BeginMode2D(camera.into());
        let call = call.call::<()>(());
        ffi::EndMode2D();

        call
    }
}

// TO-DO documentation
#[allow(non_snake_case)]
fn draw_2D_begin(lua: &mlua::Lua, camera: mlua::Value) -> mlua::Result<()> {
    unsafe {
        let camera = Camera2D::try_from(lua, camera)?;

        ffi::BeginMode2D(camera.into());

        Ok(())
    }
}

// TO-DO documentation
#[allow(non_snake_case)]
fn draw_2D_close(_: &mlua::Lua, _: ()) -> mlua::Result<()> {
    unsafe {
        ffi::EndMode2D();

        Ok(())
    }
}

#[function(
    from = "screen",
    info = "Initialize a scissor clip draw session.",
    parameter(name = "call", info = "Draw function.", kind = "function"),
    parameter(name = "area", info = "Draw area.", kind = "Box2")
)]
fn draw_scissor(lua: &mlua::Lua, (call, area): (mlua::Function, mlua::Value)) -> mlua::Result<()> {
    unsafe {
        let area = Box2::try_from(lua, area)?;

        ffi::BeginScissorMode(
            area.p_x as i32,
            area.p_y as i32,
            area.s_x as i32,
            area.s_y as i32,
        );
        let call = call.call::<()>(());
        ffi::EndScissorMode();

        call
    }
}

#[function(
    from = "screen",
    info = "Manually begin a scissor clip draw session. Use `draw_scissor` whenever possible.",
    parameter(name = "area", info = "Draw area.", kind = "Box2")
)]
fn draw_scissor_begin(lua: &mlua::Lua, area: mlua::Value) -> mlua::Result<()> {
    unsafe {
        let area = Box2::try_from(lua, area)?;

        ffi::BeginScissorMode(
            area.p_x as i32,
            area.p_y as i32,
            area.s_x as i32,
            area.s_y as i32,
        );

        Ok(())
    }
}

#[function(
    from = "screen",
    info = "Manually close a scissor clip draw session. Use `draw_scissor` whenever possible."
)]
fn draw_scissor_close(_: &mlua::Lua, _: ()) -> mlua::Result<()> {
    unsafe {
        ffi::EndScissorMode();

        Ok(())
    }
}

#[function(
    from = "screen",
    info = "Draw a 2D box.",
    parameter(name = "box_2", info = "2D box to draw.", kind = "Box2"),
    parameter(name = "point", info = "Point of the 2D box.", kind = "Vector2"),
    parameter(name = "angle", info = "Angle of the 2D box.", kind = "number"),
    parameter(name = "color", info = "Color of the 2D box.", kind = "Color")
)]
fn draw_box_2(
    lua: &mlua::Lua,
    (box_2, point, angle, color): (mlua::Value, mlua::Value, f32, mlua::Value),
) -> mlua::Result<()> {
    unsafe {
        let box_2 = Box2::try_from(lua, box_2)?;
        let point = Vector2::try_from(lua, point)?;
        let color = Color::try_from(lua, color)?;

        ffi::DrawRectanglePro(box_2.into(), point.into(), angle, color.into());

        Ok(())
    }
}

#[function(
    from = "screen",
    info = "Draw a 2D box, with edge-rounding.",
    parameter(name = "box_2", info = "2D box to draw.", kind = "Box2"),
    parameter(
        name = "round",
        info = "Edge round scale of the 2D box.",
        kind = "number",
    ),
    parameter(name = "count", info = "Edge count of the 2D box.", kind = "number"),
    parameter(name = "color", info = "Color of the 2D box.", kind = "Color")
)]
fn draw_box_2_round(
    lua: &mlua::Lua,
    (box_2, round, count, color): (mlua::Value, f32, i32, mlua::Value),
) -> mlua::Result<()> {
    unsafe {
        let box_2 = Box2::try_from(lua, box_2)?;
        let color = Color::try_from(lua, color)?;

        ffi::DrawRectangleRounded(box_2.into(), round, count, color.into());

        Ok(())
    }
}

#[function(
    from = "screen",
    info = "Draw a 2D box, with shading.",
    parameter(name = "box_2", info = "2D box to draw.", kind = "Box2"),
    parameter(name = "color_a", info = "(0, 0) color.", kind = "Color"),
    parameter(name = "color_b", info = "(0, 1) color.", kind = "Color"),
    parameter(name = "color_c", info = "(1, 0) color.", kind = "Color"),
    parameter(name = "color_d", info = "(1, 1) color.", kind = "Color")
)]
fn draw_box_2_shade(
    lua: &mlua::Lua,
    (box_2, color_a, color_b, color_c, color_d): (
        mlua::Value,
        mlua::Value,
        mlua::Value,
        mlua::Value,
        mlua::Value,
    ),
) -> mlua::Result<()> {
    unsafe {
        let box_2 = Box2::try_from(lua, box_2)?;
        let color_a = Color::try_from(lua, color_a)?;
        let color_b = Color::try_from(lua, color_b)?;
        let color_c = Color::try_from(lua, color_c)?;
        let color_d = Color::try_from(lua, color_d)?;

        ffi::DrawRectangleGradientEx(
            box_2.into(),
            color_a.into(),
            color_b.into(),
            color_c.into(),
            color_d.into(),
        );

        Ok(())
    }
}

#[function(
    from = "screen",
    info = "Draw a 2D line.",
    parameter(name = "source", info = "Source of the 2D line.", kind = "Vector2"),
    parameter(name = "target", info = "Target of the 2D line.", kind = "Vector2"),
    parameter(name = "thick", info = "Thickness of the 2D line.", kind = "number",),
    parameter(name = "color", info = "Color of the 2D line.", kind = "Color",)
)]
#[allow(nonstandard_style)]
fn draw_line_2D(
    lua: &mlua::Lua,
    (source, target, thick, color): (mlua::Value, mlua::Value, f32, mlua::Value),
) -> mlua::Result<()> {
    unsafe {
        let source = Vector2::try_from(lua, source)?;
        let target = Vector2::try_from(lua, target)?;
        let color = Color::try_from(lua, color)?;

        ffi::DrawLineEx(source.into(), target.into(), thick, color.into());

        Ok(())
    }
}

#[function(
    from = "screen",
    info = "Draw a 2D circle.",
    parameter(name = "point", info = "Point of the 2D circle.", kind = "Vector2"),
    parameter(name = "scale", info = "Scale of the 2D circle.", kind = "number",),
    parameter(name = "color", info = "Color of the 2D line.", kind = "Color",)
)]
fn draw_circle(
    lua: &mlua::Lua,
    (point, scale, color): (mlua::Value, f32, mlua::Value),
) -> mlua::Result<()> {
    unsafe {
        let point = Vector2::try_from(lua, point)?;
        let color = Color::try_from(lua, color)?;

        ffi::DrawCircleV(point.into(), scale, color.into());

        Ok(())
    }
}

#[function(
    from = "screen",
    info = "Project a 2D world point to a screen point.",
    parameter(name = "point", info = "World point.", kind = "Vector2"),
    parameter(name = "camera", info = "2D camera.", kind = "Camera2D"),
    result(name = "point", info = "Screen point.", kind = "Vector2")
)]
#[allow(nonstandard_style)]
fn get_world_to_screen_2D(
    lua: &mlua::Lua,
    (point, camera): (mlua::Value, mlua::Value),
) -> mlua::Result<mlua::Value> {
    unsafe {
        let point = Vector2::try_from(lua, point)?;
        let camera = Camera2D::try_from(lua, camera)?;

        lua.to_value(&Vector2::from(ffi::GetWorldToScreen2D(
            point.into(),
            camera.into(),
        )))
    }
}

#[function(
    from = "screen",
    info = "Project a screen point to a world point.",
    parameter(name = "point", info = "Screen point.", kind = "Vector2"),
    parameter(name = "camera", info = "2D camera.", kind = "Camera2D"),
    result(name = "point", info = "World point.", kind = "Vector2")
)]
#[allow(nonstandard_style)]
fn get_screen_to_world_2D(
    lua: &mlua::Lua,
    (point, camera): (mlua::Value, mlua::Value),
) -> mlua::Result<mlua::Value> {
    unsafe {
        let point = Vector2::try_from(lua, point)?;
        let camera = Camera2D::try_from(lua, camera)?;

        lua.to_value(&Vector2::from(ffi::GetScreenToWorld2D(
            point.into(),
            camera.into(),
        )))
    }
}

//================================================================

#[allow(non_snake_case)]
#[function(
    from = "screen",
    info = "Initialize a 3D draw session.",
    parameter(name = "call", info = "Draw function.", kind = "function"),
    parameter(name = "camera", info = "3D camera.", kind = "Camera3D")
)]
fn draw_3D(lua: &mlua::Lua, (call, camera): (mlua::Function, mlua::Value)) -> mlua::Result<()> {
    unsafe {
        let camera = Camera3D::try_from(lua, camera)?;

        ffi::BeginMode3D(camera.into());
        let call = call.call::<()>(());
        ffi::EndMode3D();

        call
    }
}

#[function(
    from = "screen",
    info = "Draw a 3D grid.",
    parameter(name = "slice", info = "Grid slice count.", kind = "number"),
    parameter(name = "space", info = "Grid space.", kind = "number")
)]
fn draw_grid(_: &mlua::Lua, (slice, space): (i32, f32)) -> mlua::Result<()> {
    unsafe {
        ffi::DrawGrid(slice, space);

        Ok(())
    }
}

#[function(
    from = "screen",
    info = "Draw a 3D cube.",
    parameter(name = "point", info = "Cube point.", kind = "Vector3"),
    parameter(name = "scale", info = "Cube scale.", kind = "Vector3"),
    parameter(name = "color", info = "Cube color.", kind = "Color")
)]
fn draw_cube(
    lua: &mlua::Lua,
    (point, scale, color): (mlua::Value, mlua::Value, mlua::Value),
) -> mlua::Result<()> {
    unsafe {
        let point = Vector3::try_from(lua, point)?;
        let scale = Vector3::try_from(lua, scale)?;
        let color = Color::try_from(lua, color)?;

        ffi::DrawCubeV(point.into(), scale.into(), color.into());

        Ok(())
    }
}

#[function(
    from = "screen",
    info = "Draw a 3D line.",
    parameter(name = "point_a", info = "Line point (A).", kind = "Vector3"),
    parameter(name = "point_b", info = "Line point (B).", kind = "Vector3"),
    parameter(name = "color", info = "Line color.", kind = "Color")
)]
#[allow(nonstandard_style)]
fn draw_line_3D(
    lua: &mlua::Lua,
    (point_a, point_b, color): (mlua::Value, mlua::Value, mlua::Value),
) -> mlua::Result<()> {
    unsafe {
        let point_a = Vector3::try_from(lua, point_a)?;
        let point_b = Vector3::try_from(lua, point_b)?;
        let color = Color::try_from(lua, color)?;

        ffi::DrawLine3D(point_a.into(), point_b.into(), color.into());

        Ok(())
    }
}

#[function(
    from = "screen",
    info = "Draw a 3D box.",
    parameter(name = "box_3", info = "3D box to draw.", kind = "Box3"),
    parameter(name = "color", info = "Color of the 3D box.", kind = "Color",)
)]
fn draw_box_3(lua: &mlua::Lua, (box_3, color): (mlua::Value, mlua::Value)) -> mlua::Result<()> {
    unsafe {
        let box_3: Box3 = lua.from_value(box_3)?;
        let color: Color = Color::try_from(lua, color)?;

        ffi::DrawBoundingBox(box_3.into(), color.into());

        Ok(())
    }
}

#[function(
    from = "screen",
    info = "Project a 3D world point to a screen point.",
    parameter(name = "point", info = "World point.", kind = "Vector3"),
    parameter(name = "camera", info = "2D camera.", kind = "Camera2D"),
    result(name = "point", info = "Screen point.", kind = "Vector2")
)]
#[allow(nonstandard_style)]
fn get_world_to_screen_3D(
    lua: &mlua::Lua,
    (point, camera): (mlua::Value, mlua::Value),
) -> mlua::Result<mlua::Value> {
    unsafe {
        let point = Vector3::try_from(lua, point)?;
        let camera = Camera3D::try_from(lua, camera)?;

        lua.to_value(&Vector2::from(ffi::GetWorldToScreen(
            point.into(),
            camera.into(),
        )))
    }
}

fn set_depth_test(_: &mlua::Lua, value: bool) -> mlua::Result<()> {
    unsafe {
        if value {
            ffi::rlEnableDepthTest();
        } else {
            ffi::rlDisableDepthTest();
        }

        Ok(())
    }
}

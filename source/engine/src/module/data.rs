use crate::{ScriptData, module::general::*};
use engine_macro::*;

//================================================================

use chrono::prelude::*;
use mlua::prelude::*;
use serde_json::Value;

//================================================================

#[rustfmt::skip]
#[module(name = "data", info = "Data API.")]
pub fn set_global(lua: &mlua::Lua, global: &mlua::Table) -> anyhow::Result<()> {
    let data = lua.create_table()?;

    data.set("get_list",           lua.create_function(self::get_list)?)?;
    data.set("get_file",           lua.create_function(self::get_file)?)?;
    data.set("set_file",           lua.create_function(self::set_file)?)?;
    data.set("get_kind",           lua.create_function(self::get_kind)?)?;
    data.set("into_string",        lua.create_function(self::into_string)?)?;
    data.set("from_string",        lua.create_function(self::from_string)?)?;
    data.set("get_system",         lua.create_function(self::get_system)?)?;
    data.set("get_argument_list",  lua.create_function(self::get_argument_list)?)?;
    data.set("get_path",           lua.create_function(self::get_path)?)?;
    data.set("get_date",           lua.create_function(self::get_date)?)?;
    data.set("get_time",           lua.create_function(self::get_time)?)?;
    // TO-DO move into another module.
    data.set("dialog_message",     lua.create_function(self::dialog_message)?)?;

    global.set("data", data)?;

    Ok(())
}

//================================================================

#[function(
    from = "data",
    info = "Get a full list of every file in a given directory.",
    parameter(name = "path", info = "Path to directory.", kind = "string"),
    parameter(name = "recurse", info = "Recurse directory search.", kind = "boolean"),
    result(
        name = "file_list",
        info = "Table array of every file in given directory.",
        kind = "table"
    )
)]
fn get_list(lua: &mlua::Lua, (path, recurse): (String, bool)) -> mlua::Result<Vec<String>> {
    safe_file_get(lua, &path)?;

    let mut list = Vec::new();
    get_list_aux(&mut list, path, recurse)?;

    Ok(list)
}

fn get_list_aux(list: &mut Vec<String>, path: String, recurse: bool) -> anyhow::Result<()> {
    let file_path = std::fs::read_dir(path)?;

    for file in file_path {
        let file = file?;
        let path = file.path().display().to_string();

        list.push(path.clone());

        if recurse && file.file_type()?.is_dir() {
            get_list_aux(list, path, recurse)?;
        }
    }

    Ok(())
}

#[function(
    from = "data",
    info = "Get the data of a file.",
    parameter(name = "path", info = "Path to file.", kind = "string"),
    parameter(
        name = "binary",
        info = "Interpret the file data as UTF-8 string data, or as a MessagePack file.",
        kind = "boolean"
    ),
    result(name = "data", info = "File data.", kind(user_data(name = "any")))
)]
fn get_file(lua: &mlua::Lua, (path, binary): (String, bool)) -> mlua::Result<mlua::Value> {
    safe_file_get(lua, &path)?;

    if binary {
        value_from_pack(lua, &std::fs::read(path)?)
    } else {
        Ok(lua.to_value(&std::fs::read_to_string(path)?)?)
    }
}

#[function(
    from = "data",
    info = "Set the data of a file.",
    parameter(name = "path", info = "Path to file.", kind = "string"),
    parameter(
        name = "data",
        info = "Data to write to file.",
        kind(user_data(name = "any"))
    ),
    parameter(
        name = "binary",
        info = "Interpret the file data as UTF-8 string data, or as a MessagePack file.",
        kind = "boolean"
    )
)]
fn set_file(
    lua: &mlua::Lua,
    (path, data, binary): (String, mlua::Value, bool),
) -> mlua::Result<()> {
    safe_file_set(lua, &path)?;

    if binary {
        Ok(std::fs::write(path, value_into_pack(lua, data)?)?)
    } else {
        Ok(std::fs::write(path, data.to_string()?)?)
    }
}

#[function(
    from = "data",
    info = "Check the kind of a path.",
    parameter(name = "path", info = "Path.", kind = "string"),
    result(
        name = "kind",
        info = "Path kind.",
        kind(user_data(name = "PathKind")),
        optional = true
    )
)]
fn get_kind(_: &mlua::Lua, path: String) -> mlua::Result<Option<usize>> {
    let path = std::path::Path::new(&path);

    if path.exists() {
        if path.is_file() {
            return Ok(Some(0));
        } else if path.is_dir() {
            return Ok(Some(1));
        } else if path.is_symlink() {
            return Ok(Some(2));
        }
    }

    Ok(None)
}

#[function(
    from = "data",
    info = "Serialize a Lua value as string.",
    parameter(
        name = "data",
        info = "Lua value to serialize as string.",
        kind(user_data(name = "any"))
    ),
    parameter(name = "pretty", info = "Pretty serialization.", kind = "boolean"),
    result(name = "data", info = "Value as string.", kind = "string")
)]
fn into_string(_: &mlua::Lua, (data, pretty): (mlua::Value, bool)) -> mlua::Result<String> {
    let string = if pretty {
        serde_json::to_string_pretty(&data)
    } else {
        serde_json::to_string(&data)
    };

    match string {
        Ok(value) => Ok(value),
        Err(error) => Err(mlua::Error::external(error.to_string())),
    }
}

#[function(
    from = "data",
    info = "Deserialize a string as a Lua value.",
    parameter(
        name = "data",
        info = "String to deserialize as value.",
        kind = "string"
    ),
    result(
        name = "data",
        info = "String as value.",
        kind(user_data(name = "any"))
    )
)]
fn from_string(lua: &mlua::Lua, data: String) -> mlua::Result<mlua::Value> {
    match serde_json::from_str::<Value>(&data) {
        Ok(value) => lua.to_value(&value),
        Err(error) => Err(mlua::Error::external(error.to_string())),
    }
}

#[function(
    from = "data",
    info = "Get the current OS kind.",
    result(
        name = "system",
        info = "System kind.",
        kind(user_data(name = "SystemKind"))
    )
)]
#[rustfmt::skip]
fn get_system(_: &mlua::Lua, _: ()) -> mlua::Result<usize> {
    match std::env::consts::OS {
        "linux"   => Ok(0),
        "windows" => Ok(1),
        "mac"     => Ok(2),
        "android" => Ok(3),
        "ios"     => Ok(4),
        _         => Ok(5),
    }
}

#[function(
    from = "data",
    info = "Get the command line argument list.",
    result(
        name = "list",
        info = "Command line argument list.",
        kind(user_data(name = "string[]"))
    )
)]
#[rustfmt::skip]
fn get_argument_list(_: &mlua::Lua, _: ()) -> mlua::Result<Vec<String>> {
    Ok(std::env::args().map(|x| x.to_string()).collect())
}

#[function(
    from = "data",
    info = "Get the current path to the main folder.",
    result(name = "path", info = "Path to the main folder.", kind = "string")
)]
fn get_path(lua: &mlua::Lua, _: ()) -> mlua::Result<String> {
    let data = ScriptData::get(lua);

    Ok(data.path.clone())
}

#[function(
    from = "data",
    info = "Get the current date.",
    result(name = "day", info = "Day.", kind = "number"),
    result(name = "month", info = "Month.", kind = "number"),
    result(name = "year", info = "Year.", kind = "number")
)]
fn get_date(_: &mlua::Lua, _: ()) -> mlua::Result<(u32, u32, i32)> {
    let time = Local::now();

    Ok((time.day(), time.month(), time.year()))
}

#[function(
    from = "data",
    info = "Get the current time.",
    result(name = "hour", info = "Hour.", kind = "number"),
    result(name = "minute", info = "Minute.", kind = "number"),
    result(name = "second", info = "Second.", kind = "number")
)]
fn get_time(_: &mlua::Lua, _: ()) -> mlua::Result<(u32, u32, u32)> {
    let time = Local::now();

    Ok((time.hour(), time.minute(), time.second()))
}

#[function(
    from = "data",
    info = "Show a message dialog.",
    parameter(
        name = "kind",
        info = "Message kind.",
        kind(user_data(name = "MessageKind"))
    ),
    parameter(name = "name", info = "Message window name.", kind = "string"),
    parameter(name = "text", info = "Message window text.", kind = "string"),
    result(
        name = "button",
        info = "Text of the button that was hit.",
        kind = "string"
    )
)]
fn dialog_message(
    _: &mlua::Lua,
    (kind, name, text): (usize, String, String),
) -> mlua::Result<bool> {
    let kind = match kind {
        0 => rfd::MessageLevel::Info,
        1 => rfd::MessageLevel::Warning,
        _ => rfd::MessageLevel::Error,
    };

    let result = rfd::MessageDialog::new()
        .set_level(kind)
        .set_title(name)
        .set_description(text)
        .set_buttons(rfd::MessageButtons::YesNo)
        .show();

    match result {
        rfd::MessageDialogResult::Yes => Ok(true),
        _ => Ok(false),
    }
}

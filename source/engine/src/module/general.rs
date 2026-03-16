use crate::ScriptData;
use std::fmt::Display;

//================================================================

use lz4_flex::{compress_prepend_size, decompress_size_prepended};
use mlua::prelude::*;
use raylib::prelude::ffi;
use serde::{Deserialize, Serialize};
use std::ffi::CString;

//================================================================

#[repr(C)]
#[derive(Debug, Copy, Clone)]
enum ValueKind {
    Vector2 = 0,
    Vector3 = 1,
    Box2 = 2,
    Box3 = 3,
    Camera2D = 4,
    Camera3D = 5,
    Color = 6,
    Ray = 7,
    Unknown = 8,
}

impl ValueKind {
    fn from_u8(number: u8) -> ValueKind {
        match number {
            0 => Self::Vector2,
            1 => Self::Vector3,
            2 => Self::Box2,
            3 => Self::Box3,
            4 => Self::Camera2D,
            5 => Self::Camera3D,
            6 => Self::Color,
            7 => Self::Ray,
            _ => Self::Unknown,
        }
    }

    fn try_from<T: Copy + Clone + for<'a> Deserialize<'a>>(
        self,
        lua: &mlua::Lua,
        value: mlua::Value,
    ) -> mlua::Result<T> {
        unsafe {
            if value.type_name() == "other" {
                let value = value.to_pointer();
                let class = *(value as *const u8);

                if class == self as u8 {
                    Ok(*(value as *const T))
                } else {
                    Err(mlua::Error::runtime(format!(
                        "Incorrect FFI data type (was expecting {:?}, got {:?}).",
                        self,
                        Self::from_u8(class)
                    )))
                }
            } else {
                lua.from_value(value)
            }
        }
    }
}

//================================================================

#[repr(C)]
#[derive(Serialize, Deserialize, Copy, Clone)]
pub struct Vector2 {
    #[serde(skip)]
    pub kind: u8,
    pub x: f32,
    pub y: f32,
}

impl Default for Vector2 {
    fn default() -> Self {
        Self {
            kind: ValueKind::Vector2 as u8,
            x: 0.0,
            y: 0.0,
        }
    }
}

impl Vector2 {
    pub fn new(x: f32, y: f32) -> Self {
        Self {
            kind: ValueKind::Vector2 as u8,
            x,
            y,
        }
    }

    pub fn try_from(lua: &mlua::Lua, value: mlua::Value) -> mlua::Result<Self> {
        ValueKind::Vector2.try_from(lua, value)
    }
}

impl From<ffi::Vector2> for Vector2 {
    fn from(value: ffi::Vector2) -> Self {
        Self::new(value.x, value.y)
    }
}

impl From<Vector2> for ffi::Vector2 {
    fn from(value: Vector2) -> Self {
        Self {
            x: value.x,
            y: value.y,
        }
    }
}

//================================================================

#[repr(C)]
#[derive(Serialize, Deserialize, Copy, Clone)]
pub struct Vector3 {
    #[serde(skip)]
    pub kind: u8,
    pub x: f32,
    pub y: f32,
    pub z: f32,
}

impl Default for Vector3 {
    fn default() -> Self {
        Self {
            kind: ValueKind::Vector3 as u8,
            x: 0.0,
            y: 0.0,
            z: 0.0,
        }
    }
}

impl Vector3 {
    pub fn new(x: f32, y: f32, z: f32) -> Self {
        Self {
            kind: ValueKind::Vector3 as u8,
            x,
            y,
            z,
        }
    }

    pub fn try_from(lua: &mlua::Lua, value: mlua::Value) -> mlua::Result<Self> {
        ValueKind::Vector3.try_from(lua, value)
    }
}

impl From<ffi::Vector3> for Vector3 {
    fn from(value: ffi::Vector3) -> Self {
        Self::new(value.x, value.y, value.z)
    }
}

impl From<Vector3> for ffi::Vector3 {
    fn from(value: Vector3) -> Self {
        Self {
            x: value.x,
            y: value.y,
            z: value.z,
        }
    }
}

//================================================================

#[repr(C)]
#[derive(Serialize, Deserialize, Copy, Clone)]
pub struct Box2 {
    #[serde(skip)]
    pub kind: u8,
    pub p_x: f32,
    pub p_y: f32,
    pub s_x: f32,
    pub s_y: f32,
}

impl Box2 {
    pub fn try_from(lua: &mlua::Lua, value: mlua::Value) -> mlua::Result<Self> {
        ValueKind::Box2.try_from(lua, value)
    }
}

impl From<Box2> for ffi::Rectangle {
    fn from(value: Box2) -> Self {
        Self {
            x: value.p_x,
            y: value.p_y,
            width: value.s_x,
            height: value.s_y,
        }
    }
}

//================================================================

#[repr(C)]
#[derive(Serialize, Deserialize, Copy, Clone)]
pub struct Box3 {
    pub min: Vector3,
    pub max: Vector3,
}

impl Box3 {
    pub fn try_from(lua: &mlua::Lua, value: mlua::Value) -> mlua::Result<Self> {
        ValueKind::Box3.try_from(lua, value)
    }
}

impl From<Box3> for ffi::BoundingBox {
    fn from(value: Box3) -> Self {
        Self {
            min: ffi::Vector3 {
                x: value.min.x,
                y: value.min.y,
                z: value.min.z,
            },
            max: ffi::Vector3 {
                x: value.max.x,
                y: value.max.y,
                z: value.max.z,
            },
        }
    }
}

//================================================================

#[repr(C)]
#[derive(Serialize, Deserialize, Copy, Clone)]
pub struct Camera2D {
    #[serde(skip)]
    pub kind: u8,
    pub point: Vector2,
    pub shift: Vector2,
    pub angle: f32,
    pub zoom: f32,
}

impl Camera2D {
    pub fn try_from(lua: &mlua::Lua, value: mlua::Value) -> mlua::Result<Self> {
        ValueKind::Camera2D.try_from(lua, value)
    }
}

impl From<Camera2D> for ffi::Camera2D {
    fn from(value: Camera2D) -> Self {
        Self {
            offset: ffi::Vector2 {
                x: value.point.x,
                y: value.point.y,
            },
            target: ffi::Vector2 {
                x: value.shift.x,
                y: value.shift.y,
            },
            rotation: value.angle,
            zoom: value.zoom,
        }
    }
}

//================================================================

#[repr(C)]
#[derive(Serialize, Deserialize, Copy, Clone)]
pub struct Camera3D {
    #[serde(skip)]
    pub kind: u8,
    pub point: Vector3,
    pub focus: Vector3,
    pub angle: Vector3,
    pub zoom: f32,
    pub mode: i32,
}

impl Camera3D {
    pub fn try_from(lua: &mlua::Lua, value: mlua::Value) -> mlua::Result<Self> {
        ValueKind::Camera3D.try_from(lua, value)
    }
}

impl From<Camera3D> for ffi::Camera3D {
    fn from(value: Camera3D) -> Self {
        Self {
            position: value.point.into(),
            target: value.focus.into(),
            up: value.angle.into(),
            fovy: value.zoom,
            projection: value.mode,
        }
    }
}

//================================================================

#[repr(C)]
#[derive(Serialize, Deserialize, Copy, Clone)]
pub struct Color {
    #[serde(skip)]
    pub kind: u8,
    pub r: u8,
    pub g: u8,
    pub b: u8,
    pub a: u8,
}

impl Color {
    pub const WHITE: Color = Color {
        kind: 0,
        r: 255,
        g: 255,
        b: 255,
        a: 255,
    };
    pub const RED: Color = Color {
        kind: 0,
        r: 255,
        g: 0,
        b: 0,
        a: 255,
    };

    pub fn try_from(lua: &mlua::Lua, value: mlua::Value) -> mlua::Result<Self> {
        ValueKind::Color.try_from(lua, value)
    }
}

impl From<Color> for ffi::Color {
    fn from(value: Color) -> Self {
        Self {
            r: value.r,
            g: value.g,
            b: value.b,
            a: value.a,
        }
    }
}

//================================================================

#[repr(C)]
#[derive(Serialize, Deserialize, Copy, Clone)]
pub struct Ray {
    #[serde(skip)]
    pub kind: u8,
    pub source: Vector3,
    pub target: Vector3,
}

impl Ray {
    pub fn try_from(lua: &mlua::Lua, value: mlua::Value) -> mlua::Result<Self> {
        ValueKind::Ray.try_from(lua, value)
    }
}

impl From<Ray> for ffi::Ray {
    fn from(value: Ray) -> Self {
        ffi::Ray {
            position: value.source.into(),
            direction: value.target.into(),
        }
    }
}

//================================================================

const COMPRESS_SIZE: usize = 128;

pub fn value_into_pack(lua: &mlua::Lua, data: mlua::Value) -> mlua::Result<Vec<u8>> {
    let value: serde_value::Value = lua.from_value(data)?;
    let value = map_error(rmp_serde::to_vec_named(&value))?;

    if value.len() >= self::COMPRESS_SIZE {
        let value = compress_prepend_size(&value);
        let mut result = vec![1];
        result.extend(value);
        Ok(result)
    } else {
        let mut result = vec![0];
        result.extend(value);
        Ok(result)
    }
}

pub fn value_from_pack(lua: &mlua::Lua, data: &[u8]) -> mlua::Result<mlua::Value> {
    if let Some(compress) = data.first() {
        let slice = &data[1..];

        if *compress == 1 {
            let slice = map_error(decompress_size_prepended(slice))?;
            let value: serde_value::Value = map_error(rmp_serde::from_slice(&slice))?;
            lua.to_value(&value)
        } else {
            let value: serde_value::Value = map_error(rmp_serde::from_slice(slice))?;
            lua.to_value(&value)
        }
    } else {
        let value: serde_value::Value = map_error(rmp_serde::from_slice(data))?;
        lua.to_value(&value)
    }
}

pub fn safe_file_get(lua: &mlua::Lua, path: &str) -> anyhow::Result<()> {
    let data = ScriptData::get(lua);

    if data.safe {
        let path = std::path::Path::new(path);
        let root = std::fs::canonicalize(".")?;

        if path.is_absolute() {
            return Err(mlua::Error::RuntimeError(format!(
                "safe_file_get(): Absolute path is forbidden {path:?}.",
            ))
            .into());
        }

        let candidate = std::fs::canonicalize(root.join(path))?;

        if !candidate.starts_with(&root) {
            return Err(mlua::Error::RuntimeError(format!(
                "safe_file_get(): Working directory escape is forbidden {path:?}.",
            ))
            .into());
        }

        Ok(())
    } else {
        Ok(())
    }
}

pub fn safe_file_set(lua: &mlua::Lua, path: &str) -> anyhow::Result<()> {
    let data = ScriptData::get(lua);

    if data.safe {
        let path = std::path::Path::new(path);
        let root = std::fs::canonicalize(".")?;

        if path.is_absolute() {
            return Err(mlua::Error::RuntimeError(format!(
                "safe_file_set(): Absolute path is forbidden {path:?}.",
            ))
            .into());
        }

        let parent = path.parent().unwrap_or(std::path::Path::new("."));
        let parent = std::fs::canonicalize(root.join(parent))?;

        if !parent.starts_with(&root) {
            return Err(mlua::Error::RuntimeError(format!(
                "safe_file_set(): Working directory escape is forbidden {path:?}.",
            ))
            .into());
        }

        Ok(())
    } else {
        Ok(())
    }
}

pub fn c_string(text: &str) -> mlua::Result<CString> {
    let convert = CString::new(text);

    if let Ok(convert) = convert {
        Ok(convert)
    } else {
        Err(mlua::Error::external(format!(
            "Error converting Rust string to C string \"{text}\"."
        )))
    }
}

pub fn map_error<T, E>(result: std::result::Result<T, E>) -> mlua::Result<T>
where
    E: Into<Box<dyn std::error::Error + Send + Sync>>,
{
    match result {
        Ok(value) => Ok(value),
        Err(error) => Err(mlua::Error::ExternalError(error.into().into())),
    }
}

pub fn sub_string(
    _: &mlua::Lua,
    (value, index_a, index_b): (String, isize, Option<isize>),
) -> mlua::Result<String> {
    let character: Vec<char> = value.chars().collect();
    let length = character.len() as isize;

    if length == 0 {
        return Ok(String::new());
    }

    let index_b = index_b.unwrap_or(-1);

    let mut a = if index_a < 0 {
        length + index_a
    } else {
        index_a - 1
    };
    let mut b = if index_b < 0 {
        length + index_b
    } else {
        index_b - 1
    };

    a = a.max(0);
    b = b.min(length - 1);

    if a > b || a >= length {
        return Ok(String::new());
    }

    Ok(character[a as usize..=b as usize].iter().collect())
}

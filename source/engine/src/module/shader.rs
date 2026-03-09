use crate::module::general::*;
use engine_macro::*;

//================================================================

use mlua::prelude::*;
use raylib::prelude::*;
use std::ffi::c_void;

//================================================================

#[rustfmt::skip]
#[module(name = "shader", info = "Shader API.")]
pub fn set_global(lua: &mlua::Lua, global: &mlua::Table) -> anyhow::Result<()> {
    let shader = lua.create_table()?;

    shader.set("new", lua.create_function(self::Shader::new)?)?;

    global.set("shader", shader)?;

    Ok(())
}

//================================================================

#[class(info = "Shader class.")]
pub struct Shader {
    pub inner: ffi::Shader,
}

impl Shader {
    #[function(
        from = "shader",
        info = "Create a new Shader resource.",
        parameter(name = "data_vs", info = "Shader data (.vs file).", kind = "string"),
        parameter(name = "data_fs", info = "Shader data (.fs file).", kind = "string"),
        result(
            name = "shader",
            info = "Shader resource.",
            kind(user_data(name = "Shader"))
        )
    )]
    fn new(
        _: &mlua::Lua,
        (data_vs, data_fs): (Option<String>, Option<String>),
    ) -> mlua::Result<Self> {
        let mut data_vs_ptr: *const i8 = std::ptr::null();
        let mut data_fs_ptr: *const i8 = std::ptr::null();

        // TO-DO test if we can actually drop this variable?
        let _data_vs = if let Some(data_vs) = data_vs {
            let string = c_string(&data_vs)?;
            data_vs_ptr = string.as_ptr();
            Some(string)
        } else {
            None
        };

        let _data_fs = if let Some(data_fs) = data_fs {
            let string = c_string(&data_fs)?;
            data_fs_ptr = string.as_ptr();
            Some(string)
        } else {
            None
        };

        unsafe {
            let inner = ffi::LoadShaderFromMemory(data_vs_ptr, data_fs_ptr);

            if ffi::IsShaderValid(inner) {
                Ok(Self { inner })
            } else {
                Err(mlua::Error::external(
                    "shader.new_memory(): Error loading shader.",
                ))
            }
        }
    }

    #[method(
        from = "Shader",
        info = "Initialize a shader draw session.",
        parameter(name = "call", info = "Draw function.", kind = "function")
    )]
    fn draw(_: &mlua::Lua, this: &Self, call: mlua::Function) -> mlua::Result<()> {
        unsafe {
            ffi::BeginShaderMode(this.inner);
            let call = call.call::<()>(());
            ffi::EndShaderMode();

            call
        }
    }

    #[method(
        from = "Shader",
        info = "Get uniform variable index.",
        parameter(name = "name", info = "Uniform name.", kind = "string"),
        result(name = "index", info = "Uniform variable index.", kind = "number")
    )]
    fn get_index_constant(_: &mlua::Lua, this: &Self, name: String) -> mlua::Result<i32> {
        unsafe {
            Ok(ffi::GetShaderLocation(
                this.inner,
                c_string(&name)?.as_ptr(),
            ))
        }
    }

    #[method(
        from = "Shader",
        info = "Get attribute variable index.",
        parameter(name = "name", info = "Attribute name.", kind = "string"),
        result(name = "index", info = "Attribute variable index.", kind = "number")
    )]
    fn get_index_property(_: &mlua::Lua, this: &Self, name: String) -> mlua::Result<i32> {
        unsafe {
            Ok(ffi::GetShaderLocationAttrib(
                this.inner,
                c_string(&name)?.as_ptr(),
            ))
        }
    }

    #[method(
        from = "Shader",
        info = "Set a shader variable value (decimal).",
        parameter(name = "index", info = "Variable index.", kind = "string"),
        parameter(name = "value", info = "Variable value.", kind = "number")
    )]
    fn set_value_decimal(
        _: &mlua::Lua,
        this: &Self,
        (index, value): (i32, f32),
    ) -> mlua::Result<()> {
        unsafe {
            let value: *const f32 = &value;
            let value: *const c_void = value as *const c_void;

            ffi::SetShaderValue(
                this.inner,
                index,
                value,
                ffi::ShaderUniformDataType::SHADER_UNIFORM_FLOAT as i32,
            );

            Ok(())
        }
    }

    #[method(
        from = "Shader",
        info = "Set a shader variable value (integer).",
        parameter(name = "index", info = "Variable index.", kind = "string"),
        parameter(name = "value", info = "Variable value.", kind = "number")
    )]
    fn set_value_integer(
        _: &mlua::Lua,
        this: &Self,
        (index, value): (i32, i32),
    ) -> mlua::Result<()> {
        unsafe {
            let value: *const i32 = &value;
            let value: *const c_void = value as *const c_void;

            ffi::SetShaderValue(
                this.inner,
                index,
                value,
                ffi::ShaderUniformDataType::SHADER_UNIFORM_INT as i32,
            );

            Ok(())
        }
    }

    #[method(
        from = "Shader",
        info = "Set a shader variable value (Vector2).",
        parameter(name = "index", info = "Variable index.", kind = "string"),
        parameter(name = "value", info = "Variable value.", kind = "Vector2")
    )]
    fn set_value_vector_2(
        lua: &mlua::Lua,
        this: &Self,
        (index, value): (i32, mlua::Value),
    ) -> mlua::Result<()> {
        unsafe {
            let value: Vector2 = lua.from_value(value)?;
            let value: ffi::Vector2 = value.into();
            let value: *const ffi::Vector2 = &value;
            let value: *const c_void = value as *const c_void;

            ffi::SetShaderValue(
                this.inner,
                index,
                value,
                ffi::ShaderUniformDataType::SHADER_UNIFORM_VEC2 as i32,
            );

            Ok(())
        }
    }

    #[method(
        from = "Shader",
        info = "Set a shader variable value (Vector2).",
        parameter(name = "index", info = "Variable index.", kind = "string"),
        parameter(name = "value", info = "Variable value.", kind = "Vector3")
    )]
    fn set_value_vector_3(
        lua: &mlua::Lua,
        this: &Self,
        (index, value): (i32, mlua::Value),
    ) -> mlua::Result<()> {
        unsafe {
            let value: Vector3 = lua.from_value(value)?;
            let value: ffi::Vector3 = value.into();
            let value: *const ffi::Vector3 = &value;
            let value: *const c_void = value as *const c_void;

            ffi::SetShaderValue(
                this.inner,
                index,
                value,
                ffi::ShaderUniformDataType::SHADER_UNIFORM_VEC3 as i32,
            );

            Ok(())
        }
    }
}

impl Drop for Shader {
    fn drop(&mut self) {
        unsafe {
            ffi::UnloadShader(self.inner);
        }
    }
}

impl mlua::UserData for Shader {
    #[rustfmt::skip]
    fn add_methods<M: mlua::UserDataMethods<Self>>(method: &mut M) {
        method.add_method("draw",               Self::draw);
        method.add_method("get_index_constant", Self::get_index_constant);
        method.add_method("get_index_property", Self::get_index_property);
        method.add_method("set_value_decimal",  Self::set_value_decimal);
        method.add_method("set_value_integer",  Self::set_value_integer);
        method.add_method("set_value_vector_2", Self::set_value_vector_2);
        method.add_method("set_value_vector_3", Self::set_value_vector_3);
    }
}

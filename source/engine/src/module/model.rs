use super::general::*;
use engine_macro::*;

//================================================================

use raylib::prelude::ffi;

//================================================================

#[rustfmt::skip]
#[module(name = "model", info = "Model API.")]
pub fn set_global(lua: &mlua::Lua, global: &mlua::Table) -> anyhow::Result<()> {
    let model = lua.create_table()?;

    model.set("new", lua.create_function(self::Model::new)?)?;

    global.set("model", model)?;

    Ok(())
}

//================================================================

#[class(info = "Model class.")]
pub struct Model {
    pub inner: ffi::Model,
    pub animation: Vec<ffi::ModelAnimation>,
}

impl Model {
    #[function(
        from = "model",
        info = "Create a new Model resource.",
        parameter(name = "path", info = "Path to model.", kind = "string"),
        result(
            name = "model",
            info = "Model resource.",
            kind(user_data(name = "Model"))
        )
    )]
    fn new(_: &mlua::Lua, path: String) -> mlua::Result<Self> {
        unsafe {
            let inner = ffi::LoadModel(c_string(&path)?.as_ptr());

            if ffi::IsModelValid(inner) {
                let mut count = 0;
                let animation = {
                    let pointer = ffi::LoadModelAnimations(c_string(&path)?.as_ptr(), &mut count);

                    if pointer.is_null() {
                        Vec::default()
                    } else {
                        Vec::from_raw_parts(pointer, count as usize, count as usize)
                    }
                };

                Ok(Self { inner, animation })
            } else {
                Err(mlua::Error::external(format!(
                    "model.new(): Error loading model \"{path}\"."
                )))
            }
        }
    }

    #[method(
        from = "Model",
        info = "Draw model.",
        parameter(name = "point", info = "Model point.", kind = "Vector3"),
        parameter(name = "angle_axis", info = "Model angle axis.", kind = "Vector3"),
        parameter(name = "angle", info = "Model angle.", kind = "number"),
        parameter(name = "scale", info = "Model scale.", kind = "Vector3"),
        parameter(name = "color", info = "Model color.", kind = "Color")
    )]
    fn draw(
        lua: &mlua::Lua,
        this: &Self,
        (point, angle_axis, angle, scale, color): (
            mlua::Value,
            mlua::Value,
            f32,
            mlua::Value,
            mlua::Value,
        ),
    ) -> mlua::Result<()> {
        unsafe {
            let point = Vector3::try_from(lua, point)?;
            let angle_axis = Vector3::try_from(lua, angle_axis)?;
            let scale = Vector3::try_from(lua, scale)?;
            let color = Color::try_from(lua, color)?;

            ffi::DrawModelEx(
                this.inner,
                point.into(),
                angle_axis.into(),
                angle,
                scale.into(),
                color.into(),
            );

            Ok(())
        }
    }

    #[method(
        from = "Model",
        info = "Get the animation index frame count.",
        parameter(name = "index", info = "Model animation index.", kind = "number"),
        result(name = "count", info = "Model animation frame count.", kind = "number")
    )]
    fn get_animation_frame_count(_: &mlua::Lua, this: &Self, index: usize) -> mlua::Result<i32> {
        if let Some(index) = this.animation.get(index) {
            Ok(index.frameCount)
        } else {
            Err(mlua::Error::runtime(format!(
                "Model::get_animation_frame_count: Invalid animation index {index}."
            )))
        }
    }

    #[method(
        from = "Model",
        info = "Set the animation index and frame.",
        parameter(name = "index", info = "Model animation index.", kind = "number"),
        parameter(name = "frame", info = "Model animation frame.", kind = "number")
    )]
    fn set_animation_frame_index(
        _: &mlua::Lua,
        this: &Self,
        (index, frame): (usize, i32),
    ) -> mlua::Result<()> {
        unsafe {
            if let Some(index) = this.animation.get(index) {
                ffi::UpdateModelAnimation(this.inner, *index, frame);
            }

            Ok(())
        }
    }

    #[method(
        from = "Model",
        info = "",
        parameter(name = "shader", info = "", kind(user_data(name = "Shader")))
    )]
    fn set_light_map_shader(
        _: &mlua::Lua,
        this: &Self,
        shader: mlua::AnyUserData,
    ) -> mlua::Result<()> {
        unsafe {
            if let Ok(shader) = shader.borrow::<crate::module::shader::Shader>() {
                let light = this
                    .inner
                    .materials
                    .wrapping_add((this.inner.materialCount - 1) as usize);
                let mut light_map = (*(*light).maps.wrapping_add(0)).texture;

                ffi::GenTextureMipmaps(&mut light_map);
                ffi::SetTextureFilter(
                    light_map,
                    ffi::TextureFilter::TEXTURE_FILTER_TRILINEAR as i32,
                );

                for index in 1..this.inner.materialCount - 1 {
                    let material = this.inner.materials.wrapping_add(index as usize);
                    (*material).shader = shader.inner;
                    (*(*material).maps.wrapping_add(1)).texture = light_map;
                }
            }

            Ok(())
        }
    }
}

impl Drop for Model {
    fn drop(&mut self) {
        unsafe {
            ffi::UnloadModel(self.inner);

            for animation in &self.animation {
                ffi::UnloadModelAnimation(*animation);
            }
        }
    }
}

impl mlua::UserData for Model {
    #[rustfmt::skip]
    fn add_methods<M: mlua::UserDataMethods<Self>>(method: &mut M) {
        method.add_method("draw",                      Self::draw);
        method.add_method("get_animation_frame_count", Self::get_animation_frame_count);
        method.add_method("set_animation_frame_index", Self::set_animation_frame_index);
        method.add_method("set_light_map_shader",      Self::set_light_map_shader);
    }
}

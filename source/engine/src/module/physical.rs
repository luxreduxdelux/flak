use engine_macro::*;

//================================================================

use mlua::prelude::*;
use rapier3d::{control::KinematicCharacterController, prelude::*};
use raylib::prelude::*;

//================================================================

#[rustfmt::skip]
#[module(name = "physical", info = "Physical API.")]
pub fn set_global(lua: &mlua::Lua, global: &mlua::Table) -> anyhow::Result<()> {
    let physical = lua.create_table()?;

    physical.set("new", lua.create_function(self::Physical::new)?)?;

    global.set("physical", physical)?;

    Ok(())
}

#[class(info = "Physical class.")]
struct Physical {
    integration_parameters: IntegrationParameters,
    physics_pipeline: PhysicsPipeline,
    island_manager: IslandManager,
    broad_phase: DefaultBroadPhase,
    narrow_phase: NarrowPhase,
    rigid_body_set: RigidBodySet,
    collider_set: ColliderSet,
    impulse_joint_set: ImpulseJointSet,
    multibody_joint_set: MultibodyJointSet,
    ccd_solver: CCDSolver,
    debug_render_pipeline: DebugRenderPipeline,
}

impl Physical {
    #[function(
        from = "physical",
        info = "Create a new Physical instance.",
        result(
            name = "physical",
            info = "Physical instance.",
            kind(user_data(name = "Physical"))
        )
    )]
    fn new(_: &mlua::Lua, _: ()) -> mlua::Result<Self> {
        let physical = Self {
            integration_parameters: IntegrationParameters::default(),
            physics_pipeline: PhysicsPipeline::new(),
            island_manager: IslandManager::new(),
            broad_phase: DefaultBroadPhase::new(),
            narrow_phase: NarrowPhase::new(),
            rigid_body_set: RigidBodySet::new(),
            collider_set: ColliderSet::new(),
            impulse_joint_set: ImpulseJointSet::new(),
            multibody_joint_set: MultibodyJointSet::new(),
            ccd_solver: CCDSolver::new(),
            debug_render_pipeline: DebugRenderPipeline::default(),
        };

        Ok(physical)
    }

    #[method(
        from = "Physical",
        info = "Update the simulation.",
        parameter(name = "delta", info = "Time delta.", kind = "number")
    )]
    fn update(_: &mlua::Lua, this: &mut Self, _: ()) -> mlua::Result<()> {
        this.physics_pipeline.step(
            &vector![0.0, -9.81, 0.0],
            &this.integration_parameters,
            &mut this.island_manager,
            &mut this.broad_phase,
            &mut this.narrow_phase,
            &mut this.rigid_body_set,
            &mut this.collider_set,
            &mut this.impulse_joint_set,
            &mut this.multibody_joint_set,
            &mut this.ccd_solver,
            &(),
            &(),
        );

        Ok(())
    }

    #[method(from = "Physical", info = "Render the simulation.")]
    fn render(_: &mlua::Lua, this: &mut Self, _: ()) -> mlua::Result<()> {
        this.debug_render_pipeline.render(
            &mut PhysicalRender {},
            &this.rigid_body_set,
            &this.collider_set,
            &this.impulse_joint_set,
            &this.multibody_joint_set,
            &this.narrow_phase,
        );

        Ok(())
    }

    #[method(
        from = "Physical",
        info = "Create an interaction group.",
        parameter(name = "source", info = "Source mask.", kind = "number"),
        parameter(name = "target", info = "Target mask.", kind = "number"),
        result(
            name = "group",
            info = "Interaction group.",
            kind(user_data(name = "Group"))
        )
    )]
    fn create_group(
        lua: &mlua::Lua,
        _: &mut Self,
        (source, target): (u32, u32),
    ) -> mlua::Result<mlua::Value> {
        lua.to_value(&InteractionGroups::new(source.into(), target.into()))
    }

    #[method(
        from = "Physical",
        info = "Create a rigid body.",
        parameter(
            name = "dynamic",
            info = "Create a dynamic rigid body if true, static otherwise.",
            kind = "boolean"
        ),
        result(
            name = "rigid",
            info = "Rigid body handle.",
            kind(user_data(name = "Rigid"))
        )
    )]
    fn create_rigid(lua: &mlua::Lua, this: &mut Self, dynamic: bool) -> mlua::Result<mlua::Value> {
        let rigid = if dynamic {
            RigidBodyBuilder::dynamic()
        } else {
            RigidBodyBuilder::fixed()
        };

        lua.to_value(&this.rigid_body_set.insert(rigid))
    }

    #[method(
        from = "Physical",
        info = "Create a solid body (mesh).",
        parameter(
            name = "rigid",
            info = "Rigid body handle.",
            kind(user_data(name = "Rigid"))
        ),
        parameter(name = "model", info = "Model.", kind(user_data(name = "Model")))
    )]
    fn create_solid_mesh(
        lua: &mlua::Lua,
        this: &mut Self,
        (rigid, model): (mlua::Value, mlua::AnyUserData),
    ) -> mlua::Result<()> {
        let rigid: RigidBodyHandle = lua.from_value(rigid)?;

        if let Ok(model) = model.borrow::<crate::module::model::Model>() {
            unsafe {
                for i in 0..model.inner.meshCount {
                    let mesh = *model.inner.meshes.wrapping_add(i as usize);

                    let mut vertex = Vec::with_capacity((mesh.vertexCount) as usize);

                    for x in 0..mesh.vertexCount {
                        let x = (x * 3) as usize;

                        vertex.push(point![
                            *mesh.vertices.wrapping_add(x),
                            *mesh.vertices.wrapping_add(x + 1),
                            *mesh.vertices.wrapping_add(x + 2),
                        ])
                    }

                    let mut index = Vec::new();

                    for x in 0..mesh.triangleCount {
                        let x = (x * 3) as usize;

                        index.push([
                            *mesh.indices.wrapping_add(x) as u32,
                            *mesh.indices.wrapping_add(x + 1) as u32,
                            *mesh.indices.wrapping_add(x + 2) as u32,
                        ])
                    }

                    if let Ok(solid) = ColliderBuilder::trimesh(vertex, index) {
                        this.collider_set.insert_with_parent(
                            solid,
                            rigid,
                            &mut this.rigid_body_set,
                        );
                    }
                }
            }
        }

        Ok(())
    }

    #[method(
        from = "Physical",
        info = "Create a solid body (cube).",
        parameter(
            name = "rigid",
            info = "Rigid body handle.",
            kind(user_data(name = "Rigid"))
        ),
        parameter(name = "scale", info = "Solid body scale.", kind = "Vector3"),
        result(
            name = "solid",
            info = "Solid body handle.",
            kind(user_data(name = "Solid"))
        )
    )]
    fn create_solid_cube(
        lua: &mlua::Lua,
        this: &mut Self,
        (rigid, scale): (mlua::Value, mlua::Value),
    ) -> mlua::Result<mlua::Value> {
        let rigid: RigidBodyHandle = lua.from_value(rigid)?;
        let scale: Vector3 = lua.from_value(scale)?;
        let solid = ColliderBuilder::cuboid(scale.x, scale.y, scale.z);

        lua.to_value(
            &this
                .collider_set
                .insert_with_parent(solid, rigid, &mut this.rigid_body_set),
        )
    }

    #[method(
        from = "Physical",
        info = "Set the point of the rigid body.",
        parameter(
            name = "rigid",
            info = "Rigid body handle.",
            kind(user_data(name = "Rigid"))
        ),
        parameter(name = "point", info = "Body point.", kind = "Vector3")
    )]
    fn set_rigid_point(
        lua: &mlua::Lua,
        this: &mut Self,
        (rigid, point): (mlua::Value, mlua::Value),
    ) -> mlua::Result<()> {
        let rigid: RigidBodyHandle = lua.from_value(rigid)?;
        let rigid = this.rigid_body_set.get_mut(rigid).unwrap();
        let point: Vector3 = lua.from_value(point)?;

        rigid.set_translation(vector![point.x, point.y, point.z], true);

        Ok(())
    }

    #[method(
        from = "Physical",
        info = "Get the user-data of the rigid body.",
        parameter(
            name = "rigid",
            info = "Rigid body handle.",
            kind(user_data(name = "Rigid"))
        ),
        result(name = "a", info = "0:31 bit data.", kind = "number"),
        result(name = "b", info = "31:63 bit data.", kind = "number"),
        result(name = "c", info = "63:95 bit data.", kind = "number"),
        result(name = "d", info = "95:127 bit data.", kind = "number")
    )]
    fn get_rigid_data(
        lua: &mlua::Lua,
        this: &mut Self,
        rigid: mlua::Value,
    ) -> mlua::Result<(u32, u32, u32, u32)> {
        let rigid: RigidBodyHandle = lua.from_value(rigid)?;
        let rigid = this.rigid_body_set.get_mut(rigid).unwrap();
        let a = (rigid.user_data >> 96) as u32;
        let b = (rigid.user_data >> 64) as u32;
        let c = (rigid.user_data >> 32) as u32;
        let d = rigid.user_data as u32;

        Ok((a, b, c, d))
    }

    #[method(
        from = "Physical",
        info = "Set the user-data of the rigid body.",
        parameter(
            name = "rigid",
            info = "Rigid body handle.",
            kind(user_data(name = "Rigid"))
        ),
        parameter(name = "a", info = "0:31 bit data.", kind = "number"),
        parameter(name = "b", info = "31:63 bit data.", kind = "number"),
        parameter(name = "c", info = "63:95 bit data.", kind = "number"),
        parameter(name = "d", info = "95:127 bit data.", kind = "number")
    )]
    fn set_rigid_data(
        lua: &mlua::Lua,
        this: &mut Self,
        (rigid, a, b, c, d): (mlua::Value, u32, u32, u32, u32),
    ) -> mlua::Result<()> {
        let rigid: RigidBodyHandle = lua.from_value(rigid)?;
        let rigid = this.rigid_body_set.get_mut(rigid).unwrap();

        rigid.user_data =
            ((a as u128) << 96) | ((b as u128) << 64) | ((c as u128) << 32) | (d as u128);

        Ok(())
    }

    #[method(
        from = "Physical",
        info = "Move a character controller.",
        parameter(
            name = "rigid",
            info = "Rigid body handle.",
            kind(user_data(name = "Rigid"))
        ),
        parameter(
            name = "solid",
            info = "Solid body handle.",
            kind(user_data(name = "Solid"))
        ),
        parameter(name = "delta", info = "Time delta.", kind = "number"),
        parameter(name = "speed", info = "Speed vector.", kind = "Vector3"),
        result(name = "point", info = "Effective character point.", kind = "Vector3"),
        result(
            name = "floor",
            info = "True if character is on floor, false otherwise.",
            kind = "boolean"
        )
    )]
    fn move_controller(
        lua: &mlua::Lua,
        this: &mut Self,
        (rigid, solid, delta, speed): (mlua::Value, mlua::Value, f32, mlua::Value),
    ) -> mlua::Result<(mlua::Value, bool, bool)> {
        let rigid: RigidBodyHandle = lua.from_value(rigid)?;
        let solid: ColliderHandle = lua.from_value(solid)?;
        let speed: Vector3 = lua.from_value(speed)?;

        let speed = vector![speed.x * delta, speed.y * delta, speed.z * delta];
        let character_controller = KinematicCharacterController::default();
        let filter = QueryFilter::default().exclude_rigid_body(rigid);
        let query_pipeline = this.broad_phase.as_query_pipeline(
            this.narrow_phase.query_dispatcher(),
            &this.rigid_body_set,
            &this.collider_set,
            filter,
        );

        let solid = this.collider_set.get(solid).unwrap();

        let movement = character_controller.move_shape(
            delta,
            &query_pipeline,
            solid.shape(),
            solid.position(),
            speed,
            |_| {
                //println!("{collision:?}");
            },
        );

        let rigid = this.rigid_body_set.get_mut(rigid).unwrap();
        let rigid_point = rigid.position();
        let point = Vector3::new(
            rigid_point.translation.x + movement.translation.x,
            rigid_point.translation.y + movement.translation.y,
            rigid_point.translation.z + movement.translation.z,
        );

        Ok((
            lua.to_value(&point)?,
            movement.grounded,
            movement.is_sliding_down_slope,
        ))
    }

    #[method(
        from = "Physical",
        info = "Query the simulation with a ray.",
        parameter(name = "ray", info = "Ray to cast.", kind = "Ray"),
        parameter(name = "time", info = "Maximum time of impact.", kind = "number"),
        parameter(
            name = "rigid",
            info = "Rigid body handle to ignore.",
            kind(user_data(name = "Rigid")),
            optional = true
        ),
        parameter(
            name = "group",
            info = "Interaction group.",
            kind(user_data(name = "Group")),
            optional = true
        ),
        result(
            name = "rigid",
            info = "Impact rigid body.",
            kind(user_data(name = "Rigid"))
        ),
        result(name = "point", info = "Impact point.", kind = "Vector3"),
        result(name = "normal", info = "Impact normal.", kind = "Vector3")
    )]
    fn query_ray(
        lua: &mlua::Lua,
        this: &mut Self,
        (ray, time, rigid, group): (mlua::Value, f32, Option<mlua::Value>, Option<mlua::Value>),
    ) -> mlua::Result<(mlua::Value, mlua::Value, mlua::Value)> {
        let ray: crate::module::general::Ray = lua.from_value(ray)?;
        let ray = rapier3d::geometry::Ray::new(
            point![ray.source.x, ray.source.y, ray.source.z],
            vector![ray.target.x, ray.target.y, ray.target.z],
        );
        let mut filter = QueryFilter::default();

        if let Some(rigid) = rigid {
            let rigid: RigidBodyHandle = lua.from_value(rigid)?;
            filter = filter.exclude_rigid_body(rigid);
        }

        if let Some(group) = group {
            let group: InteractionGroups = lua.from_value(group)?;
            filter = filter.groups(group);
        }

        let query_pipeline = this.broad_phase.as_query_pipeline(
            this.narrow_phase.query_dispatcher(),
            &this.rigid_body_set,
            &this.collider_set,
            filter,
        );

        if let Some((handle, intersection)) =
            query_pipeline.cast_ray_and_get_normal(&ray, time, true)
        {
            let point = ray.point_at(intersection.time_of_impact);
            let point = Vector3::new(point.x, point.y, point.z);
            let normal = Vector3::new(
                intersection.normal.x,
                intersection.normal.y,
                intersection.normal.z,
            );
            let rigid = this.collider_set.get(handle).unwrap();
            let rigid = rigid.parent().unwrap();
            //println!("Rigid body {:?} hit at point {}", handle, point);

            Ok((
                lua.to_value(&rigid)?,
                lua.to_value(&point)?,
                lua.to_value(&normal)?,
            ))
        } else {
            Ok((mlua::Value::Nil, mlua::Value::Nil, mlua::Value::Nil))
        }
    }
}

impl mlua::UserData for Physical {
    #[rustfmt::skip]
    fn add_methods<M: mlua::UserDataMethods<Self>>(method: &mut M) {
        method.add_method_mut("update",            Self::update);
        method.add_method_mut("render",            Self::render);
        //method.add_method_mut("create_controller", Self::create_controller);
        method.add_method_mut("create_group",      Self::create_group);
        method.add_method_mut("create_rigid",      Self::create_rigid);
        method.add_method_mut("create_solid_mesh", Self::create_solid_mesh);
        method.add_method_mut("create_solid_cube", Self::create_solid_cube);
        method.add_method_mut("set_rigid_point",   Self::set_rigid_point);
        method.add_method_mut("get_rigid_data",    Self::get_rigid_data);
        method.add_method_mut("set_rigid_data",    Self::set_rigid_data);
        method.add_method_mut("move_controller",   Self::move_controller);
        method.add_method_mut("query_ray",         Self::query_ray);
        //method.add_method_mut("query_box",       Self::query_box);
    }
}

struct PhysicalRender {}

impl DebugRenderBackend for PhysicalRender {
    fn draw_line(&mut self, _: DebugRenderObject, a: Point<f32>, b: Point<f32>, _: DebugColor) {
        unsafe {
            ffi::DrawLine3D(
                Vector3::new(a.x, a.y, a.z).into(),
                Vector3::new(b.x, b.y, b.z).into(),
                Color::RED.into(),
            );
        }
    }
}

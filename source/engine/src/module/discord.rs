use std::{
    num::NonZero,
    time::{SystemTime, UNIX_EPOCH},
};

use crate::module::general::*;
use engine_macro::*;

//================================================================

use mlua::prelude::*;

//================================================================

#[rustfmt::skip]
#[module(name = "discord", info = "Discord API.")]
pub fn set_global(lua: &mlua::Lua, global: &mlua::Table) -> anyhow::Result<()> {
    let discord = lua.create_table()?;

    discord.set("new", lua.create_async_function(self::Discord::new)?)?;

    global.set("discord", discord)?;

    Ok(())
}

//================================================================

#[class(info = "Discord class.")]
struct Discord {
    handle: discord_sdk::Discord,
    user: discord_sdk::user::User,
    activity: discord_sdk::wheel::ActivitySpoke,
}

impl Discord {
    #[function(
        from = "discord",
        info = "Create a new Discord handle.",
        parameter(name = "identifier", info = "Discord application ID.", kind = "number"),
        result(
            name = "discord",
            info = "Discord handle.",
            kind(user_data(name = "Discord"))
        )
    )]
    async fn new(_: mlua::Lua, identifier: String) -> mlua::Result<Option<Self>> {
        let identifier = map_error(identifier.parse())?;
        let (wheel, handler) = discord_sdk::wheel::Wheel::new(Box::new(|err| {
            println!("Discord wheel error {err:?}");
        }));

        let mut user = wheel.user();

        let handle = map_error(discord_sdk::Discord::new(
            discord_sdk::DiscordApp::PlainId(identifier),
            discord_sdk::Subscriptions::ACTIVITY,
            Box::new(handler),
        ))?;

        map_error(user.0.changed().await)?;

        match &*user.0.borrow() {
            discord_sdk::wheel::UserState::Connected(user) => {
                let activity = wheel.activity();

                Ok(Some(Self {
                    handle,
                    user: user.clone(),
                    activity,
                }))
            }
            discord_sdk::wheel::UserState::Disconnected(_) => Ok(None),
        }
    }

    #[method(
        from = "Discord",
        info = "",
        parameter(name = "", info = "", kind = "number")
    )]
    async fn update(
        _: mlua::Lua,
        mut this: LuaUserDataRefMut<Self>,
        _: (),
    ) -> mlua::Result<Option<String>> {
        while let Ok(event) = this.activity.0.try_recv() {
            println!("Activity event: {event:?}");

            if let discord_sdk::activity::events::ActivityEvent::Join(secret_event) = event {
                return Ok(Some(secret_event.secret));
            }
        }

        Ok(None)
    }

    #[method(
        from = "Discord",
        info = "",
        parameter(name = "", info = "", kind = "number")
    )]
    async fn set_activity(
        _: mlua::Lua,
        this: LuaUserDataRef<Self>,
        (title, state, lobby_address, lobby_count, lobby_limit): (
            String,
            String,
            Option<String>,
            Option<u32>,
            Option<u32>,
        ),
    ) -> mlua::Result<()> {
        let mut activity = discord_sdk::activity::ActivityBuilder::default()
            .details(title)
            .state(state);

        if let Some(lobby_address) = lobby_address
            && let Some(lobby_count) = lobby_count
            && let Some(lobby_limit) = lobby_limit
        {
            let time = map_error(SystemTime::now().duration_since(UNIX_EPOCH))?.as_secs();

            activity = activity
                .secrets(discord_sdk::activity::Secrets {
                    r#match: None,
                    join: Some(lobby_address.clone()),
                    spectate: None,
                })
                .party(
                    format!("{}{}", time, this.user.id.0),
                    NonZero::new(lobby_count),
                    NonZero::new(lobby_limit),
                    discord_sdk::activity::PartyPrivacy::Public,
                )
                .instance(true);
        }

        println!(
            "Update activity: {:?}",
            this.handle.update_activity(activity).await
        );

        Ok(())
    }

    #[method(
        from = "Discord",
        info = "",
        parameter(name = "", info = "", kind = "number")
    )]
    fn get_name(_: &mlua::Lua, this: &Self, _: ()) -> mlua::Result<String> {
        Ok(this.user.username.clone())
    }
}

impl mlua::UserData for Discord {
    #[rustfmt::skip]
    fn add_methods<M: mlua::UserDataMethods<Self>>(method: &mut M) {
        method.add_async_method_mut("update",   Self::update);
        method.add_async_method("set_activity", Self::set_activity);
        method.add_method("get_name",           Self::get_name);
    }
}

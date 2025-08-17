use std::env;
use sha256::digest;
use teloxide::{prelude::*,
    types::{ChatKind, InlineKeyboardButton, InlineKeyboardMarkup, MessageKind},
    utils::command::BotCommands
};
use url::Url;

#[derive(BotCommands, Clone)]
#[command(rename_rule = "lowercase", description = "Bot commands:")]
enum Command {
    #[command(description = "Start the bot")]
    Start,
    #[command(description = "Show help")]
    Help,
}

#[tokio::main]
async fn main() {
    pretty_env_logger::init();
    log::info!("Starting delete join messages bot...");

    let bot = Bot::from_env();

    // if $DEVELOPER_CHAT_ID is provided a message is sent to the hoster of the bot
    if let Ok(developer_chat_id) = env::var("DEVELOPER_CHAT_ID") {
        bot.send_message(developer_chat_id, "Bot running".to_string()).await.expect("Bot couldn't send start message to developer chat");
    };

    let handler = Update::filter_message()
        .branch(
            dptree::entry()
                .filter_command::<Command>()
                .endpoint(handle_commands),
        )
        .branch(
            dptree::filter(|msg: Message| {
                // Check if message is a service message (user joined/left)
                matches!(
                    msg.kind,
                    MessageKind::NewChatMembers(_) |
                    MessageKind::LeftChatMember(_) |
                    MessageKind::GroupChatCreated(_) |
                    MessageKind::SupergroupChatCreated(_) |
                    MessageKind::ChannelChatCreated(_) |
                    MessageKind::Pinned(_)
                )
            })
            .endpoint(delete_service_message),
        );

    Dispatcher::builder(bot, handler)
        .dependencies(dptree::deps![])
        .default_handler(|_| Box::pin(async {}))
        .error_handler(LoggingErrorHandler::with_custom_text(
            "An error has occurred in the dispatcher",
        ))
        .enable_ctrlc_handler()
        .build()
        .dispatch()
        .await;
}

async fn handle_commands(bot: Bot, msg: Message, cmd: Command) -> ResponseResult<()> {

    let me = bot.get_me().await?;
    let bot_username = me.username();

    match cmd {
        Command::Start => {
            match msg.chat.kind {
                ChatKind::Private(_) => {
                    log::info!("Private chat");

                    let add_to_grp_str = format!("https://t.me/{}?startgroup=true", bot_username);
                    let add_to_grp_url = Url::parse(&add_to_grp_str).expect("Not a valid url, {e}");
                    let url_button = InlineKeyboardButton::url("Add me to your group.".to_string(), add_to_grp_url);
                    let keyboard = InlineKeyboardMarkup::default().append_row(vec![url_button]);

                    bot.send_message(msg.chat.id, get_start_texts_private())
                        .reply_markup(keyboard)
                        .await?;
                    }
                ChatKind::Public(_) => {
                    log::info!("Group chat");
                    bot.send_message(msg.chat.id, get_start_texts_group()).await?;
                }
            }
        } Command::Help => { bot.send_message(msg.chat.id, get_help_text())
            .await?; }
    }
    Ok(())
}

async fn delete_service_message(bot: Bot, msg: Message) -> ResponseResult<()> {
    let hashed_msg_id = digest(msg.chat.id.to_string());

    // Attempt to delete the service message
    match bot.delete_message(msg.chat.id, msg.id).await {
        Ok(_) => {
            log::info!("Successfully deleted service message in chat {}", hashed_msg_id);
        }
        Err(e) => {
            log::error!("Failed to delete message: {}", e);

            // Warn in group if deleting failed
            if let Some(_user) = msg.from {
                let error_msg =
                    "⚠️ Couldn't delete the service message. \n\
                    Could be missing admin privileges and/or permission to delete messages.";

                if let Err(send_err) = bot.send_message(msg.chat.id, error_msg).await {
                    log::error!("Failed to send error message to affected chat: {}", send_err);
                }
            }
        }
    }
    Ok(())
}

pub fn get_start_texts_private()-> &'static str {
    "👋 Hello! I'm a bot that automatically deletes system messages.\n\n\
    Add me to your group and promote me to admin and give me privileges to delete messages.\n\n\
    I will automatically remove:\n\
    • User joined messages\n\
    • User left messages\n\
    • Group creation messages\n\
    • Pinned messages warnings\n\n\
    Click the button bellow to start."
}

pub fn get_start_texts_group()-> &'static str {
    "👋 Hello! I'm a bot that automatically deletes system messages.\n\n\
    Give me admin permissions, and privileges to delete messages.\n\n\
    I will automatically remove:\n\
    • User joined messages\n\
    • User left messages\n\
    • Group creation messages\n\
    • Pinned messages warnings"
}

pub fn get_help_text()-> &'static  str {
    "🤖 What I do:\n\
    • Automatically delete join/leave notifications\n\
    • Keep your chat clean from service messages\n\
    • Work silently in the background\n\n\
    Setup:\n\
    1 - Add this bot to your group\n\
    2 - Make the bot an admin\n\
    3 - Give it permission to delete messages\n\n\
    Note: Admin privileges is necessary to delete messages!"
}

// Additional utility functions for more advanced features
#[allow(dead_code)]
async fn is_bot_admin(bot: &Bot, chat_id: ChatId) -> Result<bool, teloxide::RequestError> {
    let me = bot.get_me().await?;
    let admins = bot.get_chat_administrators(chat_id).await?;

    Ok(admins.iter().any(|admin| admin.user.id == me.id))
}

#[allow(dead_code)]
async fn get_bot_permissions(bot: &Bot, chat_id: ChatId) -> Result<Option<teloxide::types::ChatMemberKind>, teloxide::RequestError> {
    let me = bot.get_me().await?;
    let member = bot.get_chat_member(chat_id, me.id).await?;

    match member.kind {
        teloxide::types::ChatMemberKind::Owner(_owner) => Ok(None),
        teloxide::types::ChatMemberKind::Administrator(admin) => {
            // Check if bot has delete_messages permission
            if admin.can_delete_messages {
                Ok(None) // Bot has permission but we return None as it's not owner
            } else {
                Ok(None)
            }
        }
        _ => Ok(None),
    }
}

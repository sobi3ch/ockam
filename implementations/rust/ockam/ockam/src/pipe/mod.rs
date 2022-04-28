//! Ockam pipe module

mod behavior;
pub use behavior::{
    BehaviorHook, HandshakeInit, PipeBehavior, PipeModifier, ReceiverConfirm, ReceiverOrdering,
    SenderConfirm,
};

mod listener;
pub use listener::PipeListener;

mod receiver;
pub use receiver::PipeReceiver;

mod sender;
pub use sender::PipeSender;

#[cfg(test)]
mod tests;

use crate::{protocols::pipe::PipeMessage, Context};
use ockam_core::{Address, LocalMessage, Result, Route};

const CLUSTER_NAME: &str = "_internal.pipe";

/// Connect to the receiving end of a pipe
///
/// Returns the PipeSender's public address.
pub async fn connect_static<R: Into<Route>>(ctx: &mut Context, recv: R) -> Result<Address> {
    let addr = Address::random(0);
    PipeSender::create(
        ctx,
        recv.into(),
        addr.clone(),
        Address::random(0),
        PipeBehavior::empty(),
    )
    .await
    .map(|_| addr)
}

/// Connect to the receiving end of a pipe with custom behavior
///
/// Returns the PipeSender's public address.
pub async fn connect_static_with_behavior<R, P>(
    ctx: &mut Context,
    recv: R,
    hooks: P,
) -> Result<Address>
where
    R: Into<Route>,
    P: Into<PipeBehavior>,
{
    let addr = Address::random(0);
    PipeSender::create(
        ctx,
        recv.into(),
        addr.clone(),
        Address::random(0),
        hooks.into(),
    )
    .await
    .map(|_| addr)
}

/// Connect to the pipe receive listener and then to a pipe receiver
pub async fn connect_dynamic(ctx: &mut Context, listener: Route) -> Result<Address> {
    let addr = Address::random(0);
    let int_addr = Address::random(0);

    // Create an "uninitialised" PipeSender
    PipeSender::uninitialized(
        ctx,
        addr.clone(),
        int_addr.clone(),
        Some(listener),
        PipeBehavior::empty(),
    )
    .await?;

    // Then return public address
    Ok(addr)
}

/// Create a receiver with a static address
pub async fn receiver<I: Into<Address>>(ctx: &mut Context, addr: I) -> Result<()> {
    PipeReceiver::create(ctx, addr.into(), Address::random(0), PipeBehavior::empty()).await
}

/// Create a new receiver with an explicit behavior manager
pub async fn receiver_with_behavior<A, P>(ctx: &mut Context, addr: A, b: P) -> Result<()>
where
    A: Into<Address>,
    P: Into<PipeBehavior>,
{
    PipeReceiver::create(ctx, addr.into(), Address::random(0), b.into()).await
}

/// Create a pipe receive listener with custom behavior
///
/// This special worker will create pipe receivers for any incoming
/// connection.  The worker can simply be stopped via its address.
pub async fn listen_with_behavior<P: Into<PipeBehavior>>(
    ctx: &mut Context,
    hooks: P,
) -> Result<Address> {
    let addr = Address::random(0);
    PipeListener::create_with_behavior(ctx, addr.clone(), hooks.into())
        .await
        .map(|_| addr)
}

/// Create a pipe receive listener
///
/// This special worker will create pipe receivers for any incoming
/// connection.  The worker can simply be stopped via its address.
pub async fn listen(ctx: &mut Context) -> Result<Address> {
    let addr = Address::random(0);
    PipeListener::create(ctx, addr.clone()).await.map(|_| addr)
}

fn unpack_pipe_message(pipe_msg: &PipeMessage) -> Result<LocalMessage> {
    let nested = PipeMessage::to_transport(pipe_msg)?;
    Ok(LocalMessage::new(nested, vec![]))
}

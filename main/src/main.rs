use hyper::service::{make_service_fn, service_fn};
use hyper::Server;

use handler;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error + Send + Sync>> {

  let make_svc = make_service_fn(|_| async {
    Ok::<_, hyper::Error>(service_fn(handler::handle))
  });

  let addr = ([127, 0, 0, 1], 3000).into();
  let server = Server::bind(&addr).serve(make_svc);

  println!("Listening on http://{}", addr);

  server.await?;

  Ok(())
}

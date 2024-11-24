use clap::Parser;

#[derive(Parser, Debug)]
#[command(name = "ted")]
#[command(version = "0.1")]
#[command(about = "cool text editor", long_about = None)]
pub struct Cli {
    /// File name
    pub name: Option<String>,
}

pub enum Action {
    Quit,
    Save,

    MoveUp,
    MoveDown,
    MoveLeft,
    MoveRight,

    EnterMode(Mode),
}

#[derive(Debug)]
pub enum Mode {
    Normal,
    Insert,
}

impl Mode {
    pub fn to_string(&self) -> &str {
        match self {
            Self::Normal => "NORMAL",
            Self::Insert => "INSERT",
        }
    }
}

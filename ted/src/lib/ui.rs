pub struct Ui {
    pub x: u16,
    pub y: u16,
    pub x_offset: i16,
    pub y_offset: i16,
}

impl Ui {
    pub fn new() -> Self {
        Self {
            x: 1,
            y: 1,
            x_offset: 2,
            y_offset: 0,
        }
    }
}

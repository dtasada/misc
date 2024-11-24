use std::{
    fs::File,
    io::{BufRead, BufReader},
};

#[derive(Debug)]
pub struct Buffer {
    pub file: File,
    pub lines: Vec<Vec<char>>,
    pub x: u16,
    pub y: u16,
}

impl Buffer {
    pub fn new(file: File) -> Self {
        let reader = BufReader::new(&file);
        let rows: Vec<Vec<char>> = reader
            .lines()
            .map(|line| line.unwrap().chars().collect())
            .collect();

        Self {
            file,
            lines: rows,
            x: 1,
            y: 1,
        }
    }

    pub fn get_line(&self) -> &Vec<char> {
        &self.lines[(self.y - 1) as usize]
    }

    pub fn push_char(&mut self, ch: char) {
        self.lines[(self.y - 1) as usize].insert((self.x - 1) as usize, ch);
    }

    pub fn push_line(&mut self, line: Vec<char>) {
        self.lines.push(line)
    }

    pub fn push_empty_line(&mut self) {
        self.lines.insert((self.y - 1) as usize, vec![]);
    }
}

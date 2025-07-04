#[derive(Debug, PartialEq, Clone)]
struct V2 {
    x: i32,
    y: i32,
}

impl V2 {
    fn new(x: i32, y: i32) -> Self {
        V2 { x, y }
    }

    fn add(&self, other: &Self) -> Self {
        V2::new(self.x + other.x, self.y + other.y)
    }
}

pub fn part1() {
    let input = std::fs::read_to_string("resources/day6.txt").expect("File not found!");
    let lines: Vec<&str> = input.lines().collect();
    let grid_size = V2::new(lines.len() as i32, lines[0].chars().count() as i32);

    let mut guard_pos = V2::new(0, 0);
    let mut guard_dir = V2::new(0, -1);
    let mut map: Vec<Vec<char>> = vec![vec!['.'; grid_size.x as usize]; grid_size.y as usize];

    let mut places_been: Vec<V2> = Vec::new();

    lines.into_iter().enumerate().for_each(|(y, line)| {
        line.chars().into_iter().enumerate().for_each(|(x, char)| {
            if char == '^' {
                guard_pos = V2::new(x as i32, y as i32);
            } else {
                map[y][x] = char;
            }
        });
    });

    loop {
        guard_pos = guard_pos.add(&guard_dir);
        if !places_been.contains(&guard_pos) {
            places_been.push(guard_pos.clone());
        }

        let in_front = guard_pos.add(&guard_dir);
        if in_front.x < 0 || in_front.y < 0 || in_front.x > grid_size.x || in_front.y > grid_size.y
        {
            break;
        }
        println!("in_front: {:?}", in_front);
        if map[in_front.y as usize][in_front.x as usize] == '#' {
            guard_dir = V2::new(-guard_dir.y, guard_dir.x);
        }
    }

    println!("Guard: {:?}", guard_pos);
    println!("places_been.len() {:?}", places_been.len());
}

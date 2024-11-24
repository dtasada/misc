use std::{
    fmt::{self, Debug, Display, Formatter},
    fs::File,
    io::{self, BufRead},
};

#[derive(Debug, Clone)]
struct City {
    city: String,
    col: f32,
    rent: f32,
    col_plus_rent: f32,
    groceries: f32,
    restaurant_price: f32,
    purchasing_power: f32,
    total_score: f32,
}

impl Display for City {
    fn fmt(&self, f: &mut Formatter) -> fmt::Result {
        /* write!(
            f,
            "[city]\ncity = {}\ncol = {}\nrent = {}\ncol_plus_rent_index = {}\ngroceries = {}\nrestaurant_price = {}\npurchasing_power = {}\ntotal_index = {}\n",
            self.city,
            self.col,
            self.rent,
            self.col_plus_rent,
            self.groceries,
            self.restaurant_price,
            self.purchasing_power,
            self.total_score,
        ) */
        write!(
            f,
            "City(name='{}', col={}, rent={}, groceries={}, purchasing_power={}, total_score={})",
            self.city, self.col, self.rent, self.groceries, self.purchasing_power, self.total_score,
        )
    }
}

fn main() {
    let file = File::open("numbeo.txt").unwrap();
    let reader = io::BufReader::new(file);

    let mut cities = Vec::<City>::new();

    for line in reader.lines() {
        let line = line.unwrap();
        let fields = line.split("\t").collect::<Vec<&str>>();

        let city: String = fields[0].to_string();
        let cost_of_living_index: f32 = fields[1].parse().unwrap();
        let rent_index: f32 = fields[2].parse().unwrap();
        let cost_of_living_plus_rent_index: f32 = fields[3].parse().unwrap();
        let groceries_index: f32 = fields[4].parse().unwrap();
        let restaurant_price_index: f32 = fields[4].parse().unwrap();
        let local_purchasing_power_index: f32 = fields[4].parse().unwrap();

        let total_score = 1e4 * local_purchasing_power_index
            / (cost_of_living_index * rent_index * groceries_index);

        let city = City {
            city,
            col: cost_of_living_index,
            rent: rent_index,
            col_plus_rent: cost_of_living_plus_rent_index,
            groceries: groceries_index,
            restaurant_price: restaurant_price_index,
            purchasing_power: local_purchasing_power_index,
            total_score,
        };

        cities.push(city);
    }

    let mut cities_by_total = cities.to_vec();
    cities_by_total.sort_by(|a, b| a.total_score.partial_cmp(&b.total_score).unwrap());
    cities_by_total.reverse();

    for city in cities_by_total {
        println!("{}", city);
    }
}

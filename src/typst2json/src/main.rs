use std::env;

fn typst_to_json_safe(
    typst_file: String,
    font_path: String,
) -> String {
    let mut res = String::from("");
    res = res + &typst_file + &font_path;
    return res
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() != 3 {
        panic!("You must call with 2 args; called with {:?}", args);
    }
    let typst_file = args[1].clone();
    let font_path = args[2].clone();

    let out = typst_to_json_safe(typst_file, font_path);
    println!("{}", out);
}

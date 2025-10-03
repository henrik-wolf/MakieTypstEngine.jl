#[no_mangle]
pub extern "C" fn rust_add(a: i64, b: i64) -> i64 {
    return 2 * a + 3 * b;
}

#[no_mangle]
pub extern "C" fn typst_to_json(
    typst_file: Vec<u8>,
    font_path: Vec<u8>,
) -> Vec<u8> {
    let mut out = vec![0];
    out.extend(typst_file);
    out.extend(font_path);
    return out;
}


#[no_mangle]
pub extern "C" unsafe fn read_vec(
    ptr: *u8,
    length: u8,
    capacity: u8
) -> u8 {
    let vec = Vec::from_raw_parts(ptr, length.into(), capacity.into());
    dbg!(vec);
    return length
}


fn main() {
    dbg!(typst_to_json(vec![0, 1], vec![2, 3]));
}

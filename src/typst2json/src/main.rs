use typst2json::typst_to_json;
use std::ffi::CStr;

fn main() {
    let v1 = vec![72i8, 101i8, 108i8, 108i8, 111i8, 32i8];
    let v2 = vec![119i8, 111i8, 114i8, 108i8, 100i8, 0i8];
    let out = typst_to_json(v1.as_ptr(), v2.as_ptr());
    let str_out = unsafe {CStr::from_ptr(out)};
    dbg!(str_out.to_str().expect("Please tell me this works"));
}

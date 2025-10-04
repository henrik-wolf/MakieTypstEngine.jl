use std::ffi::{c_char, CStr, CString};

/* #[unsafe(no_mangle)]
pub extern "C" fn test_pass_string(s: *const c_char, len: i32) -> *mut c_char {
    let string: &str = std::slice::from_raw_parts(s, len as usize);
    let c_string = CString::new(string).unwrap();
    return c_string.into_raw();
} */

#[unsafe(no_mangle)]
pub extern "C" fn typst_to_json(
    typst_file: *const c_char,
    font_path: *const c_char,
) -> *const c_char {
    let cstr_file = unsafe { CStr::from_ptr(typst_file) };
    let cstr_fontpath = unsafe { CStr::from_ptr(font_path) };
    let mut final_string = String::new();
    final_string.extend(cstr_file.to_str());
    final_string.extend(cstr_fontpath.to_str());
    println!("{}", &final_string);
    let out = CString::new(final_string).unwrap();
    // let mut out = vec![0];
    // out.extend(typst_file);
    // out.extend(font_path);
    return out.as_ptr();
}

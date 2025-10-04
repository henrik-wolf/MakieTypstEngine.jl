use std::ffi::{c_char, CStr, CString};

#[unsafe(no_mangle)]
pub extern "C" fn test_pass_string(s: *const c_char) -> *const c_char {
    return s;
}



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

#[unsafe(no_mangle)]
pub unsafe extern "C" fn read_vec(ptr: *mut u8, length: u8, capacity: u8) -> u8 {
    let vec = unsafe { Vec::from_raw_parts(ptr, length.into(), capacity.into()) };
    dbg!(vec);
    return length;
}

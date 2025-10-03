use serde_json;
use std::fs;
use std::io::{self, Read, Write, stdout};
use typst::layout::PagedDocument;
use typst_as_lib::TypstEngine;
use typst_pdf;

mod serialise;
use crate::serialise::SerializableFrame;

// Set font path
// TODO: set this from the julia side, maybe as args?
static FONT: &[u8] = include_bytes!("../fonts/FiraMath-Regular.otf");
static _OUTPUT: &str = "output.pdf";

fn main() {
    // Read typst file from stdin to String
    let mut buffer = String::new();
    io::stdin()
        .read_to_string(&mut buffer)
        .expect("Failed to read stdin");

    // compile the document
    let virtual_path = "/main.typ";
    let sources = [(virtual_path, buffer.as_str())];
    let engine = TypstEngine::builder()
        .with_static_source_file_resolver(sources)
        .fonts([FONT])
        .build();
    let doc: PagedDocument = engine.compile(virtual_path).output.expect("errrrrror!");

    // get first (and hopefully only...) frame of the result
    let ser_frame = SerializableFrame(doc.pages.first().unwrap().frame.clone());
    let frame_string = serde_json::to_string(&ser_frame).unwrap();
    dbg!(&frame_string);
    stdout().write_all(frame_string.as_bytes()).unwrap();

    let options = Default::default();
    let pdf = typst_pdf::pdf(&doc, &options).expect("Could not generate pdf.");
    fs::write(_OUTPUT, pdf).expect("Could not write pdf.");
}

// fn full_compile(file_string: Vec<u8>, font_string: Vec<u8>) -> Vec<u8> {}

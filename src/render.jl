function typstelems_and_glyph_collection(
    input_text::TypstString,
    fontsize,
    font,
    align,
    rotation,
    justification,
    lineheight,
    word_wrap_width,
    color,
    strokecolor,
    strokewidth,
)

    input_text = L"\frac{\int_3^{200} x^2 dx}{z^6}"
    args = (fontsize, align, rotation, color, strokecolor, strokewidth, word_wrap_width)
    return Makie.texelems_and_glyph_collection(input_text, args...)
end

function append_typst_linesegment_data!(
    outputs,
    tex_offsets,
    tex_elements,
    fontsize,
    rotation,
    color,
    offset,
)
    Makie.append_tex_linesegment_data!(
        outputs,
        tex_offsets,
        tex_elements,
        fontsize,
        rotation,
        color,
        offset,
    )
end
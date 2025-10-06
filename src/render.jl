"""
Construct the preamble for the typst document from the Makie Theme
"""
function to_preamble(
    fontsize,
    font,
    align,
    rotation,
    justification,
    word_wrap_width,
    color,
    strokecolor,
    strokewidth,
)
    base_preamble = Typstry.preamble(context)
    makie_preamble = "#set text($(fontsize)pt)"
    base_preamble * makie_preamble
end

function to_fontpath(font)
    return joinpath(dirname(@__DIR__), "layout-cli", "fonts", "FiraMath-Regular.otf")
end

function generate_typst_elements(input_text, preamble, fontpath) end

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

    halign, valign = align
    preamble = to_preamble(
        fontsize,
        font,
        align,
        rotation,
        justification,
        word_wrap_width,
        color,
        strokecolor,
        strokewidth,
    )

    # get all elements (TODO)
    all_els = generate_typst_elements(input_text, preamble, to_fontpath(font))

    input_text = L"\frac{\int_3^{200} x^2 dx}{z^6}"
    args = (fontsize, align, rotation, color, strokecolor, strokewidth, word_wrap_width)
    return Makie.texelems_and_glyph_collection(input_text, args...)
end


# adds the lines to the output. Not sure if we really need this...
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
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
    makie_preamble = """
    #set text($(fontsize)pt)
    #set text(font: "Fira Math", 11pt)
    #show math.equation: set text(font: "Fira Math")
    """
    base_preamble * makie_preamble
end


"""
Figure out the path to the fontfile represented by the FTFont object on `font`.
This is necessary, as the rust cli needs a path to the font, as well as its name.
"""
function to_fontpath(font)
    return joinpath(dirname(@__DIR__), "layout-cli", "fonts", "FiraMath-Regular.otf")
end

function parse_location(location)
    x = parse(Float64, location["x"][1:end-2])
    y = parse(Float64, location["y"][1:end-2])
    return Point{2,Float64}(x, y)
end

"""
This is where the magic happens.
"""
function generate_typst_elements(input_text, preamble, fontpath)
    full_document = """
    $preamble

    // user code
    $input_text
    """
    all_els = compile_string(full_document)

    elements = map(all_els) do el
        if el["item"]["type"] == "text"
            (parse_location(el["location"]), 1.0)
        else
        end
    end

    # filter(isnothing, elements)
end

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

    fontpath = to_fontpath(font)

    # get all elements
    all_els = generate_typst_elements(input_text, preamble, fontpath)
    @debug all_els

    input_text = L"\frac{\int_3^{200} x^2 dx}{z^6}"
    input_text = L"x^2"
    args = (fontsize, align, rotation, color, strokecolor, strokewidth, word_wrap_width)
    els = MathTeXEngine.generate_tex_elements(input_text)
    @debug els
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
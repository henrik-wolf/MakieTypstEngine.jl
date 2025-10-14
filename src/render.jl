# MARK: prepare render

"""
Construct the preamble for the typst document from the Makie Theme
"""
function to_preamble(font, fontsize, justification)
    base_preamble = Typstry.preamble(context)
    makie_preamble = """
    #set text(font: "$(FreeTypeAbstraction.family_name(font))", $(fontsize)pt)
    #set align($(justification))

    #show math.equation: eq => {
        set text(font: "$(to_mathfont(font))")
        set align($(justification))
        eq
    }
    """
    base_preamble * makie_preamble
end


@kwdef struct TypstGlyph
    font::Dict{String,Any}
    size::Float64
    location::Point{2,Float64}
    text::String
    glyph::Dict{String,Any}
end

@kwdef struct TypstLine
    from::Point{2,Float64}
    to::Point{2,Float64}
    thickness::Float64
end


# MARK: post render cleanup
parse_pt(str) = parse(Float64, str[1:end-2])

function parse_location(location)
    x = parse_pt(location["x"])
    y = -parse_pt(location["y"])
    return Point{2,Float64}(x, y)
end

function append_text!(target, text, location = Point2f(0, 0))
    text["location"] = location
    text["content"]["size"] = parse_pt(text["content"]["size"])

    cumulated_advance = 0.0
    for glyph in text["content"]["glyphs"]
        c = text["content"]
        tg = TypstGlyph(
            font = c["font"],
            size = c["size"],
            # TODO: there seems to be some spacing issues with just this approach.
            # maybe it is not kerning aware?
            location = text["location"] + Point2f(cumulated_advance, 0.0),
            text = c["text"],
            glyph = glyph,
        )
        cumulated_advance += tg.size * parse_pt(tg.glyph["x_advance"])

        push!(target, tg)
    end
end

function append_line!(target, line, location = Point2f(0, 0))
    line["location"] = location
    delta = parse_location(line["content"]["to"])
    line["content"]["to"] = location + delta
    line["content"]["thickness"] = parse_pt(line["content"]["thickness"])
    tl = TypstLine(
        from = line["location"],
        to = line["content"]["to"],
        thickness = line["content"]["thickness"],
    )
    push!(target, tl)
end

function append_group!(target, group_els, offset = Point2f(0, 0))
    for el in group_els
        location = parse_location(el["location"]) + offset
        if el["type"] == "text"
            append_text!(target, el, location)
        elseif el["type"] == "line"
            append_line!(target, el, location)
        elseif el["type"] == "group"
            append_group!(target, el["content"], location)
        else
            throw(ArgumentError("encountered unknown type when processing results: $(el["type"])"))
        end
    end
end

function unroll_groups_and_locations(elements)
    unrolled_elements = []
    append_group!(unrolled_elements, elements, Point2f(0, 0))
    return unrolled_elements
end

"""
create a document from input text and preamble, render it and return tuple of
text and line elements.
"""
function generate_typst_elements(input_text, preamble)
    full_document = """
    $preamble

    // user code
    $input_text
    """

    additional_font_paths = [assetpath(), MathTeXEngine.FONTS]


    all_els = unroll_groups_and_locations(compile_string(full_document, additional_font_paths))
    return (
        filter(i -> (i isa TypstGlyph), all_els),
        filter(i -> (i isa TypstLine), all_els),
    )
end

"""
Convert a flat list of layouted glyphs from typst to something that makie understands.
"""
function to_glyphcollection(text_els, align, rotation, color, strokecolor, strokewidth)
    halign, valign = align

    cached_fonts = Dict{String,FTFont}()

    text_info = map(text_els) do el
        font = maybe_to_FTFont(from_typst_font(el.font))

        # TODO: doing caching in this way does not seem more efficient?
        # font_repr = repr(el.font)

        # if !haskey(cached_fonts, font_repr)
        #     cached_fonts[font_repr] = maybe_to_FTFont(from_typst_font(el.font))
        # end

        # font = cached_fonts[font_repr]

        glyphindex = el.glyph["id"]

        extent = Makie.GlyphExtent(font, glyphindex)
        scale = Vec2f(el.size)
        bbox = Makie.height_insensitive_boundingbox_with_advance(extent)
        baseposition = to_ndim(Vec3f, el.location, 0)
        (font, glyphindex, extent, bbox * scale[1], baseposition, scale)
    end

    fonts = getindex.(text_info, 1)
    glyphindices = getindex.(text_info, 2)
    extents = getindex.(text_info, 3)
    bboxes = getindex.(text_info, 4)
    basepositions = getindex.(text_info, 5)
    scales_2d = getindex.(text_info, 6)


    bb = isempty(bboxes) ? BBox(0, 0, 0, 0) : begin
        mapreduce(union, zip(bboxes, basepositions)) do (b, pos)
            Rect2f(Rect3f(b) + pos)
        end
    end
    xshift = Makie.get_xshift(minimum(bb)[1], maximum(bb)[1], halign)
    yshift = Makie.get_yshift(minimum(bb)[2], maximum(bb)[2], valign, default = 0.0f0)
    shift = Vec3f(xshift, yshift, 0)
    positions = basepositions .- Ref(shift)
    positions .= Ref(rotation) .* positions

    pre_align_gl = Makie.GlyphCollection(
        glyphindices,
        fonts,
        Point3f.(positions),
        extents,
        scales_2d,
        rotation,
        color,
        strokecolor,
        strokewidth,
    )
    return pre_align_gl, Point2f(xshift, yshift)
end


# MARK: Makie source inspired functions
"""
takes the input string, and runs the rendering pipeline on it. Returns
the `TypstLines`, a `GlyphCollection` and an offset vector by which the glyphs
have been shifted.
"""
function typstelems_and_glyph_collection(
    # inputs to typst
    input_text::TypstString, font, fontsize, justification,
    # set by makie after render
    align, rotation, color, strokecolor, strokewidth,
    # currently unused
    lineheight, word_wrap_width,
)
    # TODO: this feels hacky...
    resolved_justification = if justification isa Makie.Automatic
        align[1]
    else
        justification
    end

    preamble = to_preamble(font, fontsize, resolved_justification)

    # compile to flat lists of glyphs and lines
    text_els, line_els = generate_typst_elements(input_text, preamble)

    gc, offset = to_glyphcollection(text_els, align, rotation, color, strokecolor, strokewidth)
    return line_els, gc, offset
end


"""
Adds all the Lines that are returned by the typst layouter to the plot.
"""
function append_typst_linesegment_data!(outputs, align_offset, line_elements,
    rotation, color, offset,
)

    block_idx = length(outputs.text_blocks)
    pos_idx = first(last(outputs.text_blocks))

    for el in line_elements
        p0 = rotation * to_ndim(Point3f, el.from .- align_offset, 0) .+ offset
        p1 = rotation * to_ndim(Point3f, el.to .- align_offset, 0) .+ offset
        push!(outputs.linesegments, p0, p1)
        thickness = el.thickness
        push!(outputs.linewidths, thickness, thickness)
        push!(outputs.linecolors, color, color)
        push!(outputs.lineindices, block_idx => pos_idx, block_idx => pos_idx)
    end
    return nothing
end
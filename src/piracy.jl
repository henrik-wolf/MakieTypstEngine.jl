# TODO: we should figure out how we want this to be loaded, as it is definitely piracy
# Since our hacky typst layout CLI (currently in debug mode) is about 100mb in size,
# I am not sure if we want this package to be loaded with either typstry, makie or a
# combination of the two...
# We could potentially put this code in a package extension for Makie that explicity
# depends on this MakieTypstEngine and Typstry. Then a user would have to explicity load both
# packages (alongside Makie) to get what is here promised.

# this is the main entry point
function Makie.convert_text_string!(outputs::NamedTuple, input_text::TypstString,
    i, N, fontsize, font, align, rotation, justification, lineheight,
    word_wrap_width, offset, fonts, color, strokecolor, strokewidth,
)
    args =
        Makie.sv_getindex.((fontsize, font, align, rotation, justification,
                lineheight, word_wrap_width, color, strokecolor, strokewidth),
            i,
        )

    # this is where the real work happens. Takes the Typst String and text format args
    # returns MathTexEngine elements in tex_elements, a GlyphCollection gc and some offset as Point2f
    tex_elements, gc, tex_offsets = typstelems_and_glyph_collection(input_text, args...)
    curr = length(outputs.glyphindices)
    n = length(gc.glyphs)

    # adds all the glyphs returned from the compiliation step to the outputs
    push!(outputs.glyphcollections, gc)
    push!(outputs.text_blocks, (curr+1):(curr+n))
    append!(outputs.glyphindices, gc.glyphs)
    append!(outputs.glyph_origins, gc.origins)
    append!(outputs.glyph_extents, gc.extents)
    append!(outputs.font_per_char, Makie.collect_vector(gc.fonts, n))
    append!(outputs.text_color, Makie.collect_vector(gc.colors, n))
    append!(outputs.text_strokecolor, Makie.collect_vector(gc.strokecolors, n))
    append!(outputs.text_strokewidth, Makie.collect_vector(gc.strokewidths, n))
    append!(outputs.text_rotation, Makie.collect_vector(gc.rotations, n))
    append!(outputs.text_scales, Makie.collect_vector(gc.scales, n))

    # adds all lines from fractions and such to the outputs
    append_typst_linesegment_data!(outputs, tex_offsets, tex_elements,
        # fontsize
        args[1],
        # rotation
        args[4],
        # color
        args[8], Makie.sv_getindex(offset, i),
    )

    return
end

Makie.iswhitespace(l::TypstString) = Makie.iswhitespace(replace(l.text, '$' => ""))

@testitem "iswhitespace" begin
    using Typstry
    using Makie
    @test Makie.iswhitespace(typst"")
    @test Makie.iswhitespace(typst"$$")
    @test !Makie.iswhitespace(typst"$a+3/x$")
end
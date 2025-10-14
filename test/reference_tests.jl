test_strings = [
    (typst"$ 1/(1 + e^(-beta x)) $", L"\frac{1}{1 + e^{-\beta x}}"),
    (typst"$ integral_a^b sin(x^2) dif x $", L"\int_a^b \sin(x^2) \mathrm{d} x"),
    (typst"$ sin(x) = sum_(n=1)^infinity ((-1)^(n-1) x^(2n-1))/((2n-1)!) $", L"\sin x = \sum_{n = 1}^\infty {\frac{{\left( { - 1} \right)^{n - 1} x^{2n - 1} }}{{\left( {2n - 1} \right)!}}} "),
]
let
    MathTeXEngine.set_texfont_family!(FontFamily("TeXGyrePagella"))
    font = MakieTypstEngine.MTEFont("TeXGyrePagella")
    f = Figure(size = (500, 800))
    Label(f[0, 1], "MakieTypstEngine")
    Label(f[0, 2], "MathTeXEngine")
    Label(f[0, 3], "MakieTeX")
    for (i, (t, l)) in enumerate(test_strings)
        Label(f[i, 1], t, font = font)
        Label(f[i, 2], l)
        Label(f[i, 3], "tbd.")
    end
    f
end
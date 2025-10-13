test_strings = [
    (typst"$1/(1 + e^(-beta x))$", L"\frac{1}{1 + e^{-\beta x}}"),
    (typst"$ integral_a^b sin(x^2) dif x $", L"\int_a^b sin(x^2) \mathrm{d} x"),
]

let
    f = Figure(size = (400, 800))
    Label(f[0, 1], "MakieTypstEngine")
    Label(f[0, 2], "MathTeXEngine")
    Label(f[0, 3], "MakieTeX")
    for (i, (t, l)) in enumerate(test_strings)
        Label(f[i, 1], t)
        Label(f[i, 2], l)
        Label(f[i, 3], "tbd.")
    end
    f
end
#' SnazzieR Color Palette
#'
#' A collection of named hex colors grouped by hue and tone.
#' Each color is available as an exported object (e.g., \code{Red}, \code{Dark.Red}).
#'
#' @details
#' \if{html}{
#' <table style='width:100%; font-family: monospace; border-collapse: collapse;'>
#' <tr><th align='left'>Name</th><th align='left'>Hex</th><th align='left'>Swatch</th></tr>
#' <tr><td>Dark.Red</td><td>#9F193D</td><td><img src='figures/Dark.Red.png' style='width:1em; height:1em; border:1px solid #000;'></td></tr>
#' <tr><td>Red</td><td>#C31E4A</td><td><img src='figures/Red.png' style='width:1em; height:1em; border:1px solid #000;'></td></tr>
#' <tr><td>Light.Red</td><td>#E66084</td><td><img src='figures/Light.Red.png' style='width:1em; height:1em; border:1px solid #000;'></td></tr>
#' <tr><td>Pale.Red</td><td>#F1A7BB</td><td><img src='figures/Pale.Red.png' style='width:1em; height:1em; border:1px solid #000;'></td></tr>
#' <tr><td>Dark.Orange</td><td>#A77011</td><td><img src='figures/Dark.Orange.png' style='width:1em; height:1em; border:1px solid #000;'></td></tr>
#' <tr><td>Orange</td><td>#E99F1F</td><td><img src='figures/Orange.png' style='width:1em; height:1em; border:1px solid #000;'></td></tr>
#' <tr><td>Light.Orange</td><td>#F0BF6A</td><td><img src='figures/Light.Orange.png' style='width:1em; height:1em; border:1px solid #000;'></td></tr>
#' <tr><td>Pale.Orange</td><td>#F4CF90</td><td><img src='figures/Pale.Orange.png' style='width:1em; height:1em; border:1px solid #000;'></td></tr>
#' <tr><td>Yellow</td><td>#E8D206</td><td><img src='figures/Yellow.png' style='width:1em; height:1em; border:1px solid #000;'></td></tr>
#' <tr><td>Light.Yellow</td><td>#FFE373</td><td><img src='figures/Light.Yellow.png' style='width:1em; height:1em; border:1px solid #000;'></td></tr>
#' <tr><td>Pale.Yellow</td><td>#FFF8DC</td><td><img src='figures/Pale.Yellow.png' style='width:1em; height:1em; border:1px solid #000;'></td></tr>
#' <tr><td>Dark.Green</td><td>#54711E</td><td><img src='figures/Dark.Green.png' style='width:1em; height:1em; border:1px solid #000;'></td></tr>
#' <tr><td>Green</td><td>#83B02F</td><td><img src='figures/Green.png' style='width:1em; height:1em; border:1px solid #000;'></td></tr>
#' <tr><td>Light.Green</td><td>#ABD45E</td><td><img src='figures/Light.Green.png' style='width:1em; height:1em; border:1px solid #000;'></td></tr>
#' <tr><td>Pale.Green</td><td>#C4E18E</td><td><img src='figures/Pale.Green.png' style='width:1em; height:1em; border:1px solid #000;'></td></tr>
#' <tr><td>Dark.Blue</td><td>#004852</td><td><img src='figures/Dark.Blue.png' style='width:1em; height:1em; border:1px solid #000;'></td></tr>
#' <tr><td>Blue</td><td>#008C9E</td><td><img src='figures/Blue.png' style='width:1em; height:1em; border:1px solid #000;'></td></tr>
#' <tr><td>Light.Blue</td><td>#1FE5FF</td><td><img src='figures/Light.Blue.png' style='width:1em; height:1em; border:1px solid #000;'></td></tr>
#' <tr><td>Pale.Blue</td><td>#85F1FF</td><td><img src='figures/Pale.Blue.png' style='width:1em; height:1em; border:1px solid #000;'></td></tr>
#' <tr><td>Dark.Purple</td><td>#4E2183</td><td><img src='figures/Dark.Purple.png' style='width:1em; height:1em; border:1px solid #000;'></td></tr>
#' <tr><td>Purple</td><td>#743496</td><td><img src='figures/Purple.png' style='width:1em; height:1em; border:1px solid #000;'></td></tr>
#' <tr><td>Light.Purple</td><td>#A06CDA</td><td><img src='figures/Light.Purple.png' style='width:1em; height:1em; border:1px solid #000;'></td></tr>
#' <tr><td>Pale.Purple</td><td>#CAADEB</td><td><img src='figures/Pale.Purple.png' style='width:1em; height:1em; border:1px solid #000;'></td></tr>
#' <tr><td>Dark.Grey</td><td>#403A3F</td><td><img src='figures/Dark.Grey.png' style='width:1em; height:1em; border:1px solid #000;'></td></tr>
#' <tr><td>Grey</td><td>#6F646C</td><td><img src='figures/Grey.png' style='width:1em; height:1em; border:1px solid #000;'></td></tr>
#' <tr><td>Light.Grey</td><td>#9E949B</td><td><img src='figures/Light.Grey.png' style='width:1em; height:1em; border:1px solid #000;'></td></tr>
#' <tr><td>Pale.Grey</td><td>#CFC9CD</td><td><img src='figures/Pale.Grey.png' style='width:1em; height:1em; border:1px solid #000;'></td></tr>
#' </table>
#' }
#' \if{latex}{
#' This palette consists of named hex colors. Each color's name (e.g., \code{Dark.Red}) is available as an exported object.
#'
#' Swatch images are embedded below (not selectable):
#'
#' \out{
#' \\renewcommand{\\arraystretch}{1.4}
#' \\begin{tabular}{@{}l l c l l c l l@{}}
#' \\textbf{Color} & \\textbf{Swatch} & & \\textbf{Color} & \\textbf{Swatch} & & \\textbf{Color} & \\textbf{Swatch} \\\\
#' \\hline
#' & & & & & & & \\\\
#' \\raisebox{0.75em}{Deep.Red}     & \\includegraphics[width=2em]{Deep.Red.png}     && \\raisebox{0.75em}{Deep.Green}   & \\includegraphics[width=2em]{Deep.Green.png}     && \\raisebox{0.75em}{Deep.Grey}    & \\includegraphics[width=2em]{Deep.Grey.png} \\\\
#' \\raisebox{0.75em}{Dark.Red}     & \\includegraphics[width=2em]{Dark.Red.png}     && \\raisebox{0.75em}{Dark.Green}   & \\includegraphics[width=2em]{Dark.Green.png}     && \\raisebox{0.75em}{Dark.Grey}    & \\includegraphics[width=2em]{Dark.Grey.png} \\\\
#' \\raisebox{0.75em}{Red}          & \\includegraphics[width=2em]{Red.png}          && \\raisebox{0.75em}{Green}        & \\includegraphics[width=2em]{Green.png}          && \\raisebox{0.75em}{Grey}         & \\includegraphics[width=2em]{Grey.png} \\\\
#' \\raisebox{0.75em}{Light.Red}    & \\includegraphics[width=2em]{Light.Red.png}    && \\raisebox{0.75em}{Light.Green}  & \\includegraphics[width=2em]{Light.Green.png}    && \\raisebox{0.75em}{Light.Grey}   & \\includegraphics[width=2em]{Light.Grey.png} \\\\
#' \\raisebox{0.75em}{Pale.Red}     & \\includegraphics[width=2em]{Pale.Red.png}     && \\raisebox{0.75em}{Pale.Green}   & \\includegraphics[width=2em]{Pale.Green.png}     && \\raisebox{0.75em}{Pale.Grey}    & \\includegraphics[width=2em]{Pale.Grey.png} \\\\
#' \\raisebox{0.75em}{Deep.Orange}  & \\includegraphics[width=2em]{Deep.Orange.png}  && \\raisebox{0.75em}{Deep.Blue}    & \\includegraphics[width=2em]{Deep.Blue.png}      &&              &                                   \\\\
#' \\raisebox{0.75em}{Dark.Orange}  & \\includegraphics[width=2em]{Dark.Orange.png}  && \\raisebox{0.75em}{Dark.Blue}    & \\includegraphics[width=2em]{Dark.Blue.png}      &&              &                                   \\\\
#' \\raisebox{0.75em}{Orange}       & \\includegraphics[width=2em]{Orange.png}       && \\raisebox{0.75em}{Blue}         & \\includegraphics[width=2em]{Blue.png}           &&              &                                   \\\\
#' \\raisebox{0.75em}{Light.Orange} & \\includegraphics[width=2em]{Light.Orange.png} && \\raisebox{0.75em}{Light.Blue}   & \\includegraphics[width=2em]{Light.Blue.png}     &&              &                                   \\\\
#' \\raisebox{0.75em}{Pale.Orange}  & \\includegraphics[width=2em]{Pale.Orange.png}  && \\raisebox{0.75em}{Pale.Blue}    & \\includegraphics[width=2em]{Pale.Blue.png}      &&              &                                   \\\\
#' \\raisebox{0.75em}{Deep.Yellow}  & \\includegraphics[width=2em]{Deep.Yellow.png}  && \\raisebox{0.75em}{Deep.Purple}  & \\includegraphics[width=2em]{Deep.Purple.png}    &&              &                                   \\\\
#' \\raisebox{0.75em}{Dark.Yellow}  & \\includegraphics[width=2em]{Dark.Yellow.png}  && \\raisebox{0.75em}{Dark.Purple}  & \\includegraphics[width=2em]{Dark.Purple.png}    &&              &                                   \\\\
#' \\raisebox{0.75em}{Yellow}       & \\includegraphics[width=2em]{Yellow.png}       && \\raisebox{0.75em}{Purple}       & \\includegraphics[width=2em]{Purple.png}         &&              &                                   \\\\
#' \\raisebox{0.75em}{Light.Yellow} & \\includegraphics[width=2em]{Light.Yellow.png} && \\raisebox{0.75em}{Light.Purple} & \\includegraphics[width=2em]{Light.Purple.png}   &&              &                                   \\\\
#' \\raisebox{0.75em}{Pale.Yellow}  & \\includegraphics[width=2em]{Pale.Yellow.png}  && \\raisebox{0.75em}{Pale.Purple}  & \\includegraphics[width=2em]{Pale.Purple.png}    &&              &                                   \\\\
#' & & & & & & & \\\\
#' \\end{tabular}
#' }
#'
#' For the full list and hex codes, use \code{names(color.list)} or see \code{?color.list}.
#' }

#'
#' @format Each color is a character string representing a hex code.
#' @seealso \code{\link{color.list}}, \code{\link{color.ref}}
#' @name colors
#' @rdname colors
#' @keywords datasets
NULL



#' @rdname colors
#' @usage NULL
#' @format NULL
#' @export
Deep.Red <- "#590D21"

#' @rdname colors
#' @usage NULL
#' @format NULL
#' @export
Dark.Red <- "#9F193D"

#' @rdname colors
#' @usage NULL
#' @format NULL
#' @export
Red <- "#C31E4A"

#' @rdname colors
#' @usage NULL
#' @export
Light.Red <- "#E66084"

#' @rdname colors
#' @usage NULL
#' @format NULL
#' @export
Pale.Red <- "#F1A7BB"

#' @rdname colors
#' @usage NULL
#' @format NULL
#' @export
Deep.Orange <- "#6F4B0B"

#' @rdname colors
#' @usage NULL
#' @format NULL
#' @export
Dark.Orange <- "#A77011"

#' @rdname colors
#' @usage NULL
#' @format NULL
#' @export
Orange <- "#E99F1F"

#' @rdname colors
#' @usage NULL
#' @format NULL
#' @export
Light.Orange <- "#F0BF6A"

#' @rdname colors
#' @usage NULL
#' @format NULL
#' @export
Pale.Orange <- "#F4CF90"

#' @rdname colors
#' @usage NULL
#' @format NULL
#' @export
Deep.Yellow <- "#9D7F06"

#' @rdname colors
#' @usage NULL
#' @format NULL
#' @export
Dark.Yellow <- "#CEA708"

#' @rdname colors
#' @usage NULL
#' @format NULL
#' @export
Yellow <- "#E8D206"

#' @rdname colors
#' @usage NULL
#' @format NULL
#' @export
Light.Yellow <- "#FFE373"

#' @rdname colors
#' @usage NULL
#' @format NULL
#' @export
Pale.Yellow <- "#FFF8DC"

#' @rdname colors
#' @usage NULL
#' @format NULL
#' @export
Deep.Green <- "#304011"

#' @rdname colors
#' @usage NULL
#' @format NULL
#' @export
Dark.Green <- "#54711E"

#' @rdname colors
#' @usage NULL
#' @format NULL
#' @export
Green <- "#83B02F"

#' @rdname colors
#' @usage NULL
#' @format NULL
#' @export
Light.Green <- "#ABD45E"

#' @rdname colors
#' @usage NULL
#' @format NULL
#' @export
Pale.Green <- "#C4E18E"

#' @rdname colors
#' @usage NULL
#' @format NULL
#' @export
Deep.Blue <- "#002429"

#' @rdname colors
#' @usage NULL
#' @format NULL
#' @export
Dark.Blue <- "#004852"

#' @rdname colors
#' @usage NULL
#' @format NULL
#' @export
Blue <- "#008C9E"

#' @rdname colors
#' @usage NULL
#' @format NULL
#' @export
Light.Blue <- "#1FE5FF"

#' @rdname colors
#' @usage NULL
#' @format NULL
#' @export
Pale.Blue <- "#85F1FF"

#' @rdname colors
#' @usage NULL
#' @format NULL
#' @export
Deep.Purple <- "#271041"

#' @rdname colors
#' @usage NULL
#' @format NULL
#' @export
Dark.Purple <- "#4E2183"

#' @rdname colors
#' @usage NULL
#' @format NULL
#' @export
Purple <- "#743496"

#' @rdname colors
#' @usage NULL
#' @format NULL
#' @export
Light.Purple <- "#A06CDA"

#' @rdname colors
#' @usage NULL
#' @format NULL
#' @export
Pale.Purple <- "#CAADEB"

#' @rdname colors
#' @usage NULL
#' @format NULL
#' @export
Deep.Grey <- "#151315"

#' @rdname colors
#' @usage NULL
#' @format NULL
#' @export
Dark.Grey <- "#403A3F"

#' @rdname colors
#' @usage NULL
#' @format NULL
#' @export
Grey <- "#6F646C"

#' @rdname colors
#' @usage NULL
#' @format NULL
#' @export
Light.Grey <- "#9E949B"

#' @rdname colors
#' @usage NULL
#' @format NULL
#' @export
Pale.Grey <- "#CFC9CD"


#' List of all colors
#' @rdname colors
#' @export
color.list <- list(
  Deep.Red = Deep.Red,
  Dark.Red = Dark.Red,
  Red = Red,
  Light.Red = Light.Red,
  Pale.Red = Pale.Red,

  Deep.Orange = Deep.Orange,
  Dark.Orange = Dark.Orange,
  Orange = Orange,
  Light.Orange = Light.Orange,
  Pale.Orange = Pale.Orange,

  Deep.Yellow = Deep.Yellow,
  Dark.Yellow = Dark.Yellow,
  Yellow = Yellow,
  Light.Yellow = Light.Yellow,
  Pale.Yellow = Pale.Yellow,

  Deep.Green = Deep.Green,
  Dark.Green = Dark.Green,
  Green = Green,
  Light.Green = Light.Green,
  Pale.Green = Pale.Green,

  Deep.Blue = Deep.Blue,
  Dark.Blue = Dark.Blue,
  Blue = Blue,
  Light.Blue = Light.Blue,
  Pale.Blue = Pale.Blue,

  Deep.Purple = Deep.Purple,
  Dark.Purple = Dark.Purple,
  Purple = Purple,
  Light.Purple = Light.Purple,
  Pale.Purple = Pale.Purple,

  Deep.Grey = Deep.Grey,
  Dark.Grey = Dark.Grey,
  Grey = Grey,
  Light.Grey = Light.Grey,
  Pale.Grey = Pale.Grey
)

# common-macros.cwl - completion definitions for common-macros.sty
# common-macros.sty にコマンドを追加したらここも更新する

# Math operators
\argmax#m
\supp#m
\sign#m
\erfc#m
\sinc#m
\sgn#m
\geom{a}{b}{c}{z}#m

# Annotations
\mywarn{text}
\mycomm{text}
\myinfo{text}

# 検算未了マーク
\tbc{text}
\begin{tbcblock}
\end{tbcblock}
\tbctrue
\tbcfalse

# Math shortcuts
\ut#m
\myint#m
\myreal#m
\kg{left}{right}#m
\ddfi{p}#m
\ddf{p}#m
\nn#m
\lr{expr}#m
\lrm{expr}#m
\lrl{expr}#m

# Japanese in English documents
\jp{text}

# Color comments (共同執筆時の発言者色分け)
\NT{text}
\MD{text}
\PN{text}
\NTmod{text}
\md{text}

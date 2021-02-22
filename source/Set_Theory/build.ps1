$OutputName = "..\..\$($PSScriptRoot.Split("\") | Select-Object -Last 1).html"

pandoc --self-contained --template=..\PageTemplate.html5 (ls *.md).Name --ascii -o $OutputName --toc --number-sections
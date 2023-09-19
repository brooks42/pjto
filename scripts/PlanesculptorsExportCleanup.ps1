$withBreak = Get-Content pkto.txt, pjto.txt
$breakLine = $withBreak | Select-String -Pattern "1\.0" | Where {$_.lineNumber -ne 2}
$breakNumber = $breakLine.LineNumber

Get-Content pkto.txt, pjto.txt | Set-Content combined.txt
Get-Content combined.txt | where-object {($_.readcount -ne $breakNumber) -and ($_.readcount -ne ($breakNumber+1)) -and ($_.readcount -ne ($breakNumber-1))} | Set-Content nobreak.txt
$combined = Get-Content nobreak.txt
Remove-Item .\nobreak.txt
Remove-Item .\combined.txt

$basicsArray = "","(a)","(b)","(c)","(d)"
$plains = $island = $swamp = $mountain = $forest = 0
$linenumbers = $combined | Select-String -Pattern "Plains","Island","Swamp","Mountain","Forest"
ForEach ($line in $linenumbers)
{
    $delimiterLine = $line.LineNumber - 6
    $delimiter = $combined | Select-Object -Index $delimiterLine

    if ($delimiter -eq "===========")
    {
        if ($line.line -eq "Plains")
        {
            $combined[$line.LineNumber-1] = $line.line + $basicsArray[$plains]
            $plains++
        }
        elseif ($line.line -eq "Island")
        {
            $combined[$line.LineNumber-1] = $line.line + $basicsArray[$island]
            $island++
        }
        elseif ($line.line -eq "Swamp")
        {
            $combined[$line.LineNumber-1] = $line.line + $basicsArray[$swamp]
            $swamp++
        }
        elseif ($line.line -eq "Mountain")
        {
            $combined[$line.LineNumber-1] = $line.line + $basicsArray[$mountain]
            $mountain++
        }
        elseif ($line.line -eq "Forest")
        {
            $combined[$line.LineNumber-1] = $line.line + $basicsArray[$forest]
            $forest++
        }
    }
}

$linenumbers = $combined | select-string -Pattern "token"
$cloneArray = "","(a)","(b)"
$clone = 0
$treasureArray = "","(a)"
$treasure = 0
$foodArray = "","(a)"
$food = 0
ForEach ($line in $linenumbers)
{
    $delimiterLine = $line.LineNumber - 2
    $delimiter = $combined | Select-Object -Index $delimiterLine

    $nameLine = $line.LineNumber + 3
    $name = $combined | Select-Object -Index $nameLine

    if ($delimiter -eq "===========")
    {
        if ($name -eq "Clone")
        {
            $combined[$line.LineNumber+3] = $name + "Token" + $cloneArray[$clone]
            $clone++
        }
        elseif ($name -eq "Treasure")
        {
            $combined[$line.LineNumber+3] = $name + "Token" + $treasureArray[$treasure]
            $treasure++
        }
        elseif ($name -eq "Food")
        {
            $combined[$line.LineNumber+3] = $name + "Token" + $foodArray[$food]
            $food++
        }
        else
        {
            $combined[$line.LineNumber+3] = $name + "Token"
        }
    }
}

$linenumbers = $combined | select-string -Pattern "Chuck","Morty","Clair","Brock","Koga","Oak"
ForEach ($line in $linenumbers)
{
    $delimiterLine = $line.LineNumber - 9
    $delimiter = $combined | Select-Object -Index $delimiterLine

    $emblemLine = $line.LineNumber - 4
    $emblem = $combined | Select-Object -Index $emblemLine

    if ($delimiter -eq "===========" -and $emblem -eq "Emblem")
    {
        if ($line.line -like "*Brock*")
        {
            $combined[$line.LineNumber-4] = "BrockEmblem"
        }
        if ($line.line -like "*Koga*")
        {
            $combined[$line.LineNumber-4] = "KogaEmblem"
        }
        if ($line.line -like "*Oak*")
        {
            $combined[$line.LineNumber-4] = "OakEmblem"
        }
        if ($line.line -like "*Chuck*")
        {
            $combined[$line.LineNumber-4] = "ChuckEmblem"
        }
        if ($line.line -like "*Morty*")
        {
            $combined[$line.LineNumber-4] = "MortyEmblem"
        }
        if ($line.line -like "*Clair*")
        {
            $combined[$line.LineNumber-4] = "ClairEmblem"
        }
    }
}

$linenumbers = $combined | select-string -Pattern "Nidoran"
ForEach ($line in $linenumbers)
{
    $delimiterLine = $line.LineNumber - 6
    $delimiter = $combined | Select-Object -Index $delimiterLine

    $colorLine = $line.LineNumber
    $color = $combined | Select-Object -Index $colorLine
    
    if ($delimiter -eq "===========")
    {
        if ($color -eq "green")
        {
            $combined[$line.LineNumber-1] = "NidoranF"
        }
        else
        {
            $combined[$line.LineNumber-1] = "NidoranM"
        }
    }
}

$linenumbers = $combined | select-string -Pattern "PokÃ©mon â€"
ForEach ($line in $linenumbers)
{
    $typeLine = $line.LineNumber - 1
    $type = $combined | Select-Object -Index $typeLine

    if ($line.Line -like "Token Legendary*")
    {
        $types = $type.Substring(24)
        $combined[$line.LineNumber-1] = "Token Legendary Creature" + $types
    }
    elseif ($line.Line -like "Token*")
    {
        $types = $type.Substring(14)
        $combined[$line.LineNumber-1] = "Token Creature" + $types
    }
    elseif ($line.Line -like "Legendary*")
    {
        $types = $type.Substring(18)
        $combined[$line.LineNumber-1] = "Legendary Creature" + $types
    }
    elseif ($line.Line -like "Land*")
    {
        $types = $type.Substring(13)
        $combined[$line.LineNumber-1] = "Land Creature" + $types
    }
    elseif ($line.Line -like "Artifact*")
    {
        $types = $type.Substring(17)
        $combined[$line.LineNumber-1] = "Artifact Creature" + $types
    }
    else
    {
        $types = $type.Substring(8)
        $combined[$line.LineNumber-1] = "Creature" + $types
    }
}

$linenumbers = $combined | select-string -Pattern "Trainer â€"
ForEach ($line in $linenumbers)
{
    $typeLine = $line.LineNumber - 1
    $type = $combined | Select-Object -Index $typeLine

    if ($line.Line -like "Token*")
    {
        $types = $type.Substring(13)
        $combined[$line.LineNumber-1] = "Token Planeswalker" + $types
    }
    else
    {
        $types = $type.Substring(17)
        $combined[$line.LineNumber-1] = "Legendary Planeswalker" + $types
    }
}

$linenumbers = $combined | select-string -Pattern "Guard Spec","Silph Co"
ForEach ($line in $linenumbers)
{
    $delimiterLine = $line.LineNumber - 6
    $delimiter = $combined | Select-Object -Index $delimiterLine

    $nameLine = $line.LineNumber - 1
    $name = $combined | Select-Object -Index $nameLine
    
    if ($delimiter -eq "===========")
    {
        $combined[$line.LineNumber-1] = $name.Substring(0,$name.Length-1)
    }
}

$linenumbers = $combined | select-string -Pattern "/17","/6"
ForEach ($line in $linenumbers)
{
    $delimiterLine = $line.LineNumber - 3
    $delimiter = $combined | Select-Object -Index $delimiterLine

    $nameLine = $line.LineNumber + 2
    $name = $combined | Select-Object -Index $nameLine
    
    if ($delimiter -eq "===========")
    {
        $combined[$line.LineNumber+2] = $name + "Helper"
    }
}

$combined | Set-Content ".\final.txt"
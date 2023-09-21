#Converts pjto_cockatrice.xml to JSON compatible with draftmancer.com, and appends a cube list for use with the same site.

$xml = [xml](Get-Content -Raw .\pjto_cockatrice.xml)

$cardNodes = $xml.SelectNodes("//card")
$setNodes = $xml.SelectNodes("//set")
$setsNodes = $xml.SelectNodes("//sets")
$colorNodes = $xml.SelectNodes("//color")
$ptNodes = $xml.SelectNodes("//pt")
$tablerowNodes = $xml.SelectNodes("//tablerow")
$sideNodes = $xml.SelectNodes("//side")
$relatedNodes = $xml.SelectNodes("//related")
$textNodes = $xml.SelectNodes("//text")

$dfcArray = @()
foreach($node in $cardNodes)
{
    if ($node.prop.type -like "Basic*" -or $node.Name -like "*Token*" -or $node.Name -like "*Emblem" -or $node.Name -eq "Red Gyarados" -or $node.Name -eq "Red's Pikachu")
    {
        $node.ParentNode.RemoveChild($node) | Out-Null
    }
    
    if ($node.name -like "*(DFC)" -or $node.Name -eq "Mewtwo, Redeemed")
    {
        $dfcArray += $node
        $node.ParentNode.RemoveChild($node) | Out-Null
    }
}

$cardNodes = $xml.SelectNodes("//card")
$cubeList = @()
foreach($node in $cardNodes)
{
    if ($node.name -like "Nidoran*" -and $node.prop.colors -eq "G")
    {
        $node.name = $node.name.Replace("♀", "F")
    }
    if ($node.name -like "Nidoran*" -and $node.prop.colors -eq "B")
    {
        $node.name = $node.name.Replace("♂", "M")
    }
    if ($node.name -like "*(PKTO)" -or $node.name -like "*(PJTO)")
    {
        $node.name = $node.name.Replace("(", "")
        $node.name = $node.name.Replace(")", "")
    }

    if ($node.prop.manacost -eq "{R/G/W}")
    {
        $node.prop.manacost = "RGW"
    }

    $rarity = $node | Select @{n='rarity'; e={$_.set.rarity}}
    $picUrl = $node | Select @{n='picUrl'; e={$_.set.picUrl}}

    if ($node.prop.type -like "Legendary Pok*")
    {
        $initialType = $node.prop.type
        $typeWords = $initialType.Split(" ")
        $node.prop.type = "Legendary Creature"
        
        $count = 0
        $subtypes = @()
        foreach ($word in $typewords)
        {
            if ($count -gt 2)
            {
                $subtypes += $word
            }
            $count++
        }
    }
    elseif ($node.prop.type -like "Pok*")
    {
        $initialType = $node.prop.type
        $typeWords = $initialType.Split(" ")
        $node.prop.type = "Creature"

        $count = 0
        $subtypes = @()
        foreach ($word in $typewords)
        {
            if ($count -gt 1)
            {
                $subtypes += $word
            }
            $count++
        }
    }
    elseif ($node.prop.type -like "Artifact Pok*")
    {
        $initialType = $node.prop.type
        $typeWords = $initialType.Split(" ")
        $node.prop.type = "Artifact Creature"

        $count = 0
        $subtypes = @()
        foreach ($word in $typewords)
        {
            if ($count -gt 2)
            {
                $subtypes += $word
            }
            $count++
        }
    }
    elseif ($node.prop.type -like "Land Pok*")
    {
        $initialType = $node.prop.type
        $typeWords = $initialType.Split(" ")
        $node.prop.type = "Land Creature"

        $count = 0
        $subtypes = @()
        foreach ($word in $typewords)
        {
            if ($count -gt 2)
            {
                $subtypes += $word
            }
            $count++
        }
    }
    elseif ($node.prop.type -like "Legendary Trainer*")
    {
        $initialType = $node.prop.type
        $typeWords = $initialType.Split(" ")
        $node.prop.type = "Legendary Planeswalker"

        $count = 0
        $subtypes = @()
        foreach ($word in $typewords)
        {
            if ($count -gt 2)
            {
                $subtypes += $word
            }
            $count++
        }
    }
    else
    {
        $initialType = $node.prop.type
        $typeWords = $initialType.Split(" ")
        $node.prop.type = $typeWords[0]
        
        $count = 0
        $subtypes = @()
        foreach ($word in $typewords)
        {
            if ($count -gt 1)
            {
                $subtypes += $word
            }
            $count++
        }
    }
        
    $rarityElement = $node.AppendChild($xml.CreateElement("rarity"))
    $rarityText = $xml.CreateTextNode($rarity.rarity)
    [void]$rarityElement.AppendChild($rarityText);

    $picUrlElement = $node.AppendChild($xml.CreateElement("picUrl"))
    $enElement = $picUrlElement.AppendChild($xml.CreateElement("en"))
    $enText = $xml.CreateTextNode($picUrl.picUrl)
    [void]$enElement.AppendChild($enText);

    if ($subtypes.Count -eq 1)
    {
        $subtypes += ""
    }
    if ($subtypes.Count -gt 0)
    {
        foreach ($subtypeItem in $subtypes)
        {
            $subtypesElement = $node.AppendChild($xml.CreateElement("subtypes"))
            $subtypesText = $xml.CreateTextNode($subtypeItem)
            [void]$subtypesElement.AppendChild($subtypesText);
        }
    }

    if ($node.prop.type -like "PokÃ©mon*" -and $rarity.rarity -eq "common")
    {
        $cubeList += "2 " + $node.name
    }
    else
    {
        $cubeList += "1 " + $node.name
    }

    if ($node.related.innertext -like "*(DFC)*" -or $node.name -eq "Mewtwo")
    {
        foreach ($dfc in $dfcArray)
        {
            if ($node.related.innertext -eq $dfc.name)
            {
                $picUrl = $dfc | Select @{n='picUrl'; e={$_.set.picUrl}}
                $backElement = $node.AppendChild($xml.CreateElement("back"))

                $nameElement = $backElement.AppendChild($xml.CreateElement("name"))
                $nameText = $xml.CreateTextNode($dfc.Name)
                [void]$nameElement.AppendChild($nameText);

                $backPicUrlElement = $backElement.AppendChild($xml.CreateElement("backPicUrl"))
                $backEnElement = $backPicUrlElement.AppendChild($xml.CreateElement("backEn"))
                $backEnText = $xml.CreateTextNode($picUrl.picUrl)
                [void]$backEnElement.AppendChild($backEnText);

                if ($dfc.prop.type -like "Legendary*")
                {
                    $initialType = $dfc.prop.type
                    $typeWords = $initialType.Split(" ")
                    $dfc.prop.type = "Legendary Creature"

                    $count = 0
                    $subtypes = @()
                    foreach ($word in $typewords)
                    {
                        if ($count -gt 2)
                        {
                            $subtypes += $word
                        }
                        $count++
                    }

                }
                elseif ($dfc.prop.type -like "Artifact Pok*")
                {
                    $initialType = $dfc.prop.type
                    $typeWords = $initialType.Split(" ")
                    $dfc.prop.type = "Artifact Creature"

                    $count = 0
                    $subtypes = @()
                    foreach ($word in $typewords)
                    {
                        if ($count -gt 2)
                        {
                            $subtypes += $word
                        }
                        $count++
                    }
                }
                else
                {
                    $initialType = $dfc.prop.type
                    $typeWords = $initialType.Split(" ")
                    $dfc.prop.type = "Creature"

                    $count = 0
                    $subtypes = @()
                    foreach ($word in $typewords)
                    {
                        if ($count -gt 1)
                        {
                            $subtypes += $word
                        }
                        $count++
                    }
                }


                $typeElement = $backElement.AppendChild($xml.CreateElement("type"))
                $typeText = $xml.CreateTextNode($dfc.prop.type)
                [void]$typeElement.AppendChild($typeText);


                if ($subtypes.Count -eq 1)
                {
                    $subtypes += ""
                }
                if ($subtypes.Count -gt 0)
                {
                    foreach ($subtypeItem in $subtypes)
                    {

                        $subtypesElement = $backElement.AppendChild($xml.CreateElement("subtypes"))
                        $subtypesText = $xml.CreateTextNode($subtypeItem)
                        [void]$subtypesElement.AppendChild($subtypesText);
                    }
                }
            }
        }   
    }
}

#$xml.Save(".\test.xml")

$array = foreach ($card in $xml.cockatrice_carddatabase.cards.card)
{
    if ($card.back)
        {   
        $prop = [ordered]@{
            'name' = $card.name
            'mana_cost' = $card.prop.manacost
            'type' = $card.prop.type
            'subtypes' = $card.subtypes
            'rarity' = $card.rarity
            'image_uris' = @{
                'en' = $card.picUrl.en
            }
            'back' = @{ 
                'name' = $card.back.name
                'type' = $card.back.type
                'subtypes' = $card.back.subtypes
                'image_uris' = @{
                    'en' = $card.back.backPicUrl.BackEn
                }
            }
        }
    }
    elseif ($card.subtypes -and $card.prop.manacost)
    {
        $prop = [ordered]@{
            'name' = $card.name
            'mana_cost' = $card.prop.manacost
            'type' = $card.prop.type
            'subtypes' = $card.subtypes
            'rarity' = $card.rarity
            'image_uris' = @{
                'en' = $card.picUrl.en
            }
        }
    }
    elseif ($card.subtypes)
    {
            $prop = [ordered]@{
            'name' = $card.name
            'mana_cost' = ""
            'type' = $card.prop.type
            'subtypes' = $card.subtypes
            'rarity' = $card.rarity
            'image_uris' = @{
                'en' = $card.picUrl.en
            }
        }
    }
    elseif ($card.prop.manacost)
    {
        $prop = [ordered]@{
            'name' = $card.name
            'mana_cost' = $card.prop.manacost
            'type' = $card.prop.type
            'rarity' = $card.rarity
            'image_uris' = @{
                'en' = $card.picUrl.en
            }
        }
    }
    else
    {
        $prop = [ordered]@{
            'name' = $card.name
            'mana_cost' = ""
            'type' = $card.prop.type
            'rarity' = $card.rarity
            'image_uris' = @{
                'en' = $card.picUrl.en
            }
        }
    }
    New-Object -Type PSCustomObject -Property $prop
}

$array | ConvertTo-Json -Depth 3 | % { [System.Text.RegularExpressions.Regex]::Unescape($_) } | Set-Content -Path ".\Draftmancer.json"
Add-Content .\Draftmancer.json "[MainSlot(15)]"
Add-Content .\Draftmancer.json $cubeList
@("[CustomCards]") + (Get-Content .\Draftmancer.json) | Set-Content .\Draftmancer.json
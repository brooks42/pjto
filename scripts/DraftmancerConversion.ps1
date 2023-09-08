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
$cardNodes = $xml.SelectNodes("//card")

$dfcArray = @()
foreach($node in $cardNodes)
{
    if ($node.type -like "Basic*" -or $node.Name -like "*Token*" -or $node.Name -like "*Emblem" -or $node.Name -eq "Red Gyarados" -or $node.Name -eq "Red's Pikachu")
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
    if ($node.name -like "*(PKTO)" -or $node.name -like "*(PJTO)")
    {
        $node.name = $node.name.Replace("(", "")
        $node.name = $node.name.Replace(")", "")
    }

    if ($node.manacost -eq "{R/G/W}")
    {
        $node.manacost = "RGW"
    }

    $rarity = $node | Select @{n='rarity'; e={$_.set.rarity}}
    $picUrl = $node | Select @{n='picUrl'; e={$_.set.picUrl}}
        
    $rarityElement = $node.AppendChild($xml.CreateElement("rarity"))
    $rarityText = $xml.CreateTextNode($rarity.rarity)
    [void]$rarityElement.AppendChild($rarityText);

    $picUrlElement = $node.AppendChild($xml.CreateElement("picUrl"))
    $enElement = $picUrlElement.AppendChild($xml.CreateElement("en"))
    $enText = $xml.CreateTextNode($picUrl.picUrl)
    [void]$enElement.AppendChild($enText);

    if ($node.type -like "PokÃ©mon*" -and $rarity.rarity -eq "common")
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

                $typeElement = $backElement.AppendChild($xml.CreateElement("type"))
                $typeText = $xml.CreateTextNode($dfc.type)
                [void]$typeElement.AppendChild($typeText);
            }
        }   
    }
}

foreach($node in $setNodes){$node.ParentNode.RemoveChild($node) | Out-Null}
foreach($node in $setsNodes){$node.ParentNode.RemoveChild($node) | Out-Null}
foreach($node in $colorNodes){$node.ParentNode.RemoveChild($node) | Out-Null}
foreach($node in $ptNodes){$node.ParentNode.RemoveChild($node) | Out-Null}
foreach($node in $tablerowNodes){$node.ParentNode.RemoveChild($node) | Out-Null}
foreach($node in $sideNodes){$node.ParentNode.RemoveChild($node) | Out-Null}
foreach($node in $relatedNodes){$node.ParentNode.RemoveChild($node) | Out-Null}
foreach($node in $textNodes){$node.ParentNode.RemoveChild($node) | Out-Null}

$array = foreach ($card in $xml.cockatrice_carddatabase.cards.card)
{
    if ($card.back)
        {   
        $prop = [ordered]@{
            'name' = $card.name
            'mana_cost' = $card.manacost
            'type' = $card.type
            'rarity' = $card.rarity
            'image_uris' = @{
                'en' = $card.picUrl.en
            }
            'back' = @{ 
                'name' = $card.back.name
                'type' = $card.back.type
                'image_uris' = @{
                    'en' = $card.back.backPicUrl.BackEn
                }
            }
        }
    }
    else
    {
        $prop = [ordered]@{
            'name' = $card.name
            'mana_cost' = $card.manacost
            'type' = $card.type
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
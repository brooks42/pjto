#Converts pjto_cockatrice.xml using v3 Cockatrice database to v4

($xml = [xml]::new()).Load(".\pjto_cockatrice.xml")

$xml.cockatrice_carddatabase.version = "4"

$cardNodes = $xml.SelectNodes("//card")
$deleteNodes = $xml.SelectNodes("//side") + $xml.SelectNodes("//color") + $xml.SelectNodes("//pt") + $xml.SelectNodes("//type") + $xml.SelectNodes("//manacost")

foreach($node in $cardNodes)
{
    $propElement = $node.AppendChild($xml.CreateElement("prop"))

    $typeElement = $propElement.AppendChild($xml.CreateElement("type"))
    $typeText = $xml.CreateTextNode($node.type)
    [void]$typeElement.AppendChild($typeText);

    if ($node.type -like "*Pok*") {$maintype = "Pokémon"}
    elseif ($node.type -like "*Trainer*") {$maintype = "Trainer"}
    elseif ($node.type -like "*Land*") {$maintype = "Land"}
    elseif ($node.type -like "*Artifact*") {$maintype = "Artifact"}
    elseif ($node.type -like "*Enchantment*") {$maintype = "Enchantment"}
    elseif ($node.type -like "*Instant*") {$maintype = "Instant"}
    elseif ($node.type -like "*Sorcery*") {$maintype = "Sorcery"}

    $maintypeElement = $propElement.AppendChild($xml.CreateElement("maintype"))
    $maintypeText = $xml.CreateTextNode($maintype)
    [void]$maintypeElement.AppendChild($maintypeText);

    if ($node.side -ne "back")
    {
        $cmc = 0
        if ($node.manacost -like "*{*")
        {
            $chars = $node.manacost.ToCharArray()
            ForEach ($char in $chars)
            {
                if ($char -match "^\d+$")
                {
                    $cmc = $char.ToString()/1
                }
                elseif ($char -eq "{")
                {
                    $cmc = $cmc - 3
                }
                else
                {
                    $cmc++
                }
            }
        }
        elseif ($node.manacost)
        {
            $chars = $node.manacost.ToCharArray()
            ForEach ($char in $chars)
            {
                if ($char -match "^\d+$")
                {
                    $cmc = $char.ToString()/1
                }
                else
                {
                    $cmc++
                }
            }
        }
        $cmcElement = $propElement.AppendChild($xml.CreateElement("cmc"))
        $cmcText = $xml.CreateTextNode($cmc)
        [void]$cmcElement.AppendChild($cmcText);
    }

    if ($node.side)
    {
        $sideElement = $propElement.AppendChild($xml.CreateElement("side"))
        $sideText = $xml.CreateTextNode($node.side)
        [void]$sideElement.AppendChild($sideText);
    }

    if ($node.color)
    {
        $colorElement = $propElement.AppendChild($xml.CreateElement("colors"))
        $colorText = $xml.CreateTextNode($node.color)
        [void]$colorElement.AppendChild($colorText);
    }
    
    if ($node.manacost)
    {
        $manacostElement = $propElement.AppendChild($xml.CreateElement("manacost"))
        $manacostText = $xml.CreateTextNode($node.manacost)
        [void]$manacostElement.AppendChild($manacostText);
    }

    if ($node.pt)
    {
        $ptElement = $propElement.AppendChild($xml.CreateElement("pt"))
        $ptText = $xml.CreateTextNode($node.pt)
        [void]$ptElement.AppendChild($ptText);
    }

    if ($node.related -is [Object[]] -and $node.related.attach)
    {
        $count = 0
        ForEach ($related in $node.related)
        {
            if ($related.attach)
            {
                $node.related[$count].attach = "transform"    
            }
            $count++
        }
    }
    elseif ($node.related.attach)
    {
        $node.related.attach = "transform"
    }

}

ForEach ($node in $deleteNodes)
{
    if ($node.ParentNode.Name -ne "prop")
    {
        $node.ParentNode.RemoveChild($node) | Out-Null
    }
}

$xml.Save(".\test.xml")
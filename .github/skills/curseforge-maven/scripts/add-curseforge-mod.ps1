[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ModUrl,

    [string]$PomPath = "pom.xml",

    [string]$RepositoryUrl = "https://www.curseforge.com/api/maven/",

    [string]$ReleaseType = "release",

    [string]$FileName
)

function Get-CurseForgeSlug {
    param([string]$Url)

    try {
        $uri = [System.Uri]$Url
        $path = $uri.AbsolutePath.TrimEnd('/')
        $segments = $path.Split('/') | Where-Object { $_ -ne "" }
        if (-not $segments -or $segments.Count -lt 1) {
            throw "URL path not recognized."
        }
        return $segments[-1]
    } catch {
        throw "Invalid URL: $Url"
    }
}

function Parse-FileName {
    param(
        [string]$Name,
        [string]$ReleaseType
    )

    $clean = $Name.Trim()
    if ($clean.EndsWith(".jar")) {
        $clean = $clean.Substring(0, $clean.Length - 4)
    }

    $marker = "-$ReleaseType-"
    if ($clean -like "*$marker*") {
        $parts = $clean -split [regex]::Escape($marker), 2
        return [pscustomobject]@{
            Artifact = $parts[0]
            Tag = $parts[1]
        }
    }

    $suffix = "-$ReleaseType"
    if ($clean.EndsWith($suffix)) {
        $artifact = $clean.Substring(0, $clean.Length - $suffix.Length)
        return [pscustomobject]@{
            Artifact = $artifact
            Tag = ""
        }
    }

    return $null
}

function New-Element {
    param(
        [xml]$Document,
        [string]$Name,
        [string]$NamespaceUri,
        [string]$Value
    )

    $element = $Document.CreateElement($Name, $NamespaceUri)
    if ($null -ne $Value) {
        $element.InnerText = $Value
    }
    return $element
}

if (-not (Test-Path $PomPath)) {
    throw "pom.xml not found at path: $PomPath"
}

$slug = Get-CurseForgeSlug -Url $ModUrl

if (-not $FileName) {
    $FileName = Read-Host "Enter latest release file name (e.g., MyMod-1.2.3-release-universal.jar)"
}

$parsed = Parse-FileName -Name $FileName -ReleaseType $ReleaseType
if (-not $parsed) {
    Write-Warning "Could not parse the file name."
    $artifact = Read-Host "Enter mavenArtifact (file name without -$ReleaseType-<tag>)"
    $tag = Read-Host "Enter file tag/classifier (e.g., universal) or leave blank"
} else {
    $artifact = $parsed.Artifact
    $tag = $parsed.Tag
}

[xml]$pom = Get-Content $PomPath
$nsUri = $pom.Project.NamespaceURI
$ns = New-Object System.Xml.XmlNamespaceManager($pom.NameTable)
$ns.AddNamespace("m", $nsUri)

$projectNode = $pom.SelectSingleNode("/m:project", $ns)
if (-not $projectNode) {
    throw "Invalid pom.xml: missing <project> root."
}

$repositoriesNode = $pom.SelectSingleNode("/m:project/m:repositories", $ns)
if (-not $repositoriesNode) {
    $repositoriesNode = New-Element -Document $pom -Name "repositories" -NamespaceUri $nsUri
    [void]$projectNode.AppendChild($repositoriesNode)
}

$repoNode = $pom.SelectSingleNode("/m:project/m:repositories/m:repository[m:id='curseforge']", $ns)
if (-not $repoNode) {
    $repoNode = New-Element -Document $pom -Name "repository" -NamespaceUri $nsUri
    [void]$repositoriesNode.AppendChild($repoNode)
    [void]$repoNode.AppendChild((New-Element -Document $pom -Name "id" -NamespaceUri $nsUri -Value "curseforge"))
    [void]$repoNode.AppendChild((New-Element -Document $pom -Name "name" -NamespaceUri $nsUri -Value "CurseForge Maven"))
    [void]$repoNode.AppendChild((New-Element -Document $pom -Name "url" -NamespaceUri $nsUri -Value $RepositoryUrl))
} else {
    $urlNode = $repoNode.SelectSingleNode("m:url", $ns)
    if ($urlNode) {
        $urlNode.InnerText = $RepositoryUrl
    } else {
        [void]$repoNode.AppendChild((New-Element -Document $pom -Name "url" -NamespaceUri $nsUri -Value $RepositoryUrl))
    }
}

$dependenciesNode = $pom.SelectSingleNode("/m:project/m:dependencies", $ns)
if (-not $dependenciesNode) {
    $dependenciesNode = New-Element -Document $pom -Name "dependencies" -NamespaceUri $nsUri
    [void]$projectNode.AppendChild($dependenciesNode)
}

$dependencyQuery = "/m:project/m:dependencies/m:dependency[m:groupId='$slug' and m:artifactId='$artifact' and m:version='$ReleaseType']"
if ($tag -and $tag.Trim() -ne "") {
    $dependencyQuery += " and m:classifier='$tag'"
}

$dependencyNode = $pom.SelectSingleNode($dependencyQuery, $ns)
if ($dependencyNode) {
    Write-Host "Dependency already exists: $slug:$artifact:$ReleaseType" -ForegroundColor Yellow
} else {
    $dependencyNode = New-Element -Document $pom -Name "dependency" -NamespaceUri $nsUri
    [void]$dependencyNode.AppendChild((New-Element -Document $pom -Name "groupId" -NamespaceUri $nsUri -Value $slug))
    [void]$dependencyNode.AppendChild((New-Element -Document $pom -Name "artifactId" -NamespaceUri $nsUri -Value $artifact))
    [void]$dependencyNode.AppendChild((New-Element -Document $pom -Name "version" -NamespaceUri $nsUri -Value $ReleaseType))
    if ($tag -and $tag.Trim() -ne "") {
        [void]$dependencyNode.AppendChild((New-Element -Document $pom -Name "classifier" -NamespaceUri $nsUri -Value $tag))
    }
    [void]$dependenciesNode.AppendChild($dependencyNode)
    Write-Host "Added dependency: $slug:$artifact:$ReleaseType" -ForegroundColor Green
}

$pom.Save($PomPath)
Write-Host "Updated pom.xml at $PomPath" -ForegroundColor Green
Write-Host "Ensure CURSE_USER and CURSE_TOKEN are set in your environment." -ForegroundColor Cyan

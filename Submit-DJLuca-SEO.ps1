# DJ LUCA - PowerShell SEO Auto-Population Script
# Site: https://lucasound22.github.io/DJLUCA/
# Owner: Luca Marino - lucamarino78@gmail.com
# Usage: Right-click -> Run with PowerShell, or: .\Submit-DJLuca-SEO.ps1

param(
    [string]$SiteUrl = "https://lucasound22.github.io/DJLUCA/",
    [string]$RepoPath = ".\DJLUCA"
)

Write-Host "=== DJ LUCA SEO Auto-Aggregation ===" -ForegroundColor Cyan
Write-Host "Site: $SiteUrl" -ForegroundColor White

$today = Get-Date -Format "yyyy-MM-dd"

# 1. Create sitemap.xml + robots.txt with today's date
$sitemapContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url><loc>$SiteUrl</loc><lastmod>$today</lastmod><priority>1.0</priority><changefreq>weekly</changefreq></url>
</urlset>
"@

$robotsContent = @"
User-agent: *
Allow: /

Sitemap: ${SiteUrl}sitemap.xml
"@

if (!(Test-Path $RepoPath)) { New-Item -ItemType Directory -Path $RepoPath | Out-Null }
Set-Content -Path (Join-Path $RepoPath "sitemap.xml") -Value $sitemapContent -Encoding UTF8
Set-Content -Path (Join-Path $RepoPath "robots.txt") -Value $robotsContent -Encoding UTF8
Write-Host "✓ Created sitemap.xml and robots.txt in $RepoPath" -ForegroundColor Green

# 2. Ping Google & Bing (free, no API key)
Write-Host "`nPinging search engines..." -ForegroundColor Yellow
$pingUrls = @(
    "https://www.google.com/ping?sitemap=$([uri]::EscapeDataString("${SiteUrl}sitemap.xml"))",
    "https://www.bing.com/ping?sitemap=$([uri]::EscapeDataString("${SiteUrl}sitemap.xml"))"
)
foreach ($ping in $pingUrls) {
    try {
        $r = Invoke-WebRequest -Uri $ping -UseBasicParsing -TimeoutSec 10
        Write-Host "  ✓ Pinged: $ping -> $($r.StatusCode)" -ForegroundColor Green
    } catch {
        Write-Host "  ! Ping blocked (just open Search Console manually): $ping" -ForegroundColor DarkYellow
    }
}

# 3. Open free aggregation submission pages
Write-Host "`nOpening free DJ aggregation pages..." -ForegroundColor Yellow
$urls = @(
    "https://search.google.com/search-console/welcome",
    "https://www.bing.com/webmasters/",
    "https://business.google.com/create",
    "https://www.crowdpleaser.com.au/list-your-act",
    "https://www.entertainmentnow.com.au/",
    "https://www.gumtree.com.au/",
    "https://search.google.com/test/rich-results?url=$([uri]::EscapeDataString($SiteUrl))"
)
foreach ($u in $urls) { try { Start-Process $u } catch { Write-Host "Open manually: $u" }; Start-Sleep -Milliseconds 700 }

Write-Host @"

=== MANUAL 30-SEC STEPS (Do these once) ===

1. GOOGLE SEARCH CONSOLE:
   - Add property: $SiteUrl
   - Upload verification file to repo root (googleXXXX.html)
   - Sitemaps -> Submit: ${SiteUrl}sitemap.xml
   - URL Inspection -> Request Indexing

2. GOOGLE BUSINESS PROFILE (Ranks for 'DJ near me' / club bookings):
   - https://business.google.com/create
   - Name: DJ Luca / Lucasound
   - Category: DJ, DJ Service, Wedding DJ
   - Location: Melbourne VIC 3073, Service areas: Melbourne, Byron Bay, Gold Coast
   - Website: $SiteUrl
   - Photos: pic_1.jpg + pic_3.jpg
   - Services: Club DJ, Wedding DJ, Vinyl DJ, Corporate DJ, Festival DJ
   - Get 3 reviews

3. BING WEBMASTER (auto-feeds Yahoo + DuckDuckGo):
   - Add site, submit same sitemap.xml

4. FREE DJ DIRECTORIES - Copy/paste this bio:

DJ Luca Marino - Melbourne vinyl purist since 2002. Purveyor of deep, infectious dance grooves. Residencies Lounge, Laundry, CMoog Byron Bay, Platinum Gold Coast. Supported Aphrodite, Nick Warren, Coldcuts/DJ Food/Ninja Tunes QLD. 3 records never leave box: Cameo Word Up, Jetsto Funk Say It Again, Vernon Burch Getup & Dance. Loyal following Swinging Safari Gold Coast & French Connection Melbourne - Parliament & Prince as well as Deep Dish & Bob Sinclar. Vinyl only. Book: lucamarino78@gmail.com | $SiteUrl | Mixcloud: House_Keeping

Submit to:
- crowdpleaser.com.au
- entertainmentnow.com.au
- bark.com.au (DJ Hire Melbourne)
- oneflare.com.au
- gumtree.com.au (Entertainment > DJs)

5. SOCIAL BACKLINKS (boosts aggregation):
   - Mixcloud House_Keeping bio -> add $SiteUrl
   - Facebook HouseKeepingDJLuca -> Website = $SiteUrl
   - Instagram @lucamarino22 -> Link in bio = $SiteUrl
   - Instinct Music page already links, keep it

"@

Write-Host "`n✓ Done! Now: cd $RepoPath; git add .; git commit -m 'SEO aggregation'; git push" -ForegroundColor Green

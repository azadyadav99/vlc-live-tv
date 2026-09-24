# Generate ChannelMenu.html from livetv.m3u8 (channel numbers + stars)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$m3uPath = Join-Path $root 'playlist\livetv.m3u8'
$outPath = Join-Path $root 'menu\ChannelMenu.html'
$livePath = Join-Path $env:APPDATA 'vlc\ChannelMenu.html'

$lines = [System.IO.File]::ReadAllLines($m3uPath)
$chans = New-Object 'System.Collections.Generic.List[object]'
$ext = $null; $name = $null; $grp = $null; $declared = ''
$chno = 0
foreach ($l in $lines) {
  if ($l -like '#EXTINF*') {
    $ext = $l
    $name = if ($l -match ',([^,]+)$') { $Matches[1] } else { '' }
    $grp = if ($l -match 'group-title="([^"]*)"') { $Matches[1] } else { 'Featured' }
    $cMatch = [regex]::Match($l, 'tvg-chno="([^"]+)"')
    $declared = if ($cMatch.Success) { $cMatch.Groups[1].Value } else { '' }
  } elseif ($ext -and $l -match '^(https?|rtmp|rtsp|udp)://') {
    $chno++
    $display = if ($declared) { $declared } else { [string]$chno }
    $chans.Add([pscustomobject]@{ N = $name; G = $grp; U = $l; C = $chno; D = $display })
    $ext = $null
  }
}
Write-Output "parsed $($chans.Count)"

function Esc([string]$s) {
  if ($null -eq $s) { return '' }
  $s = $s -replace '&', '&amp;'
  $s = $s -replace '<', '&lt;'
  $s = $s -replace '>', '&gt;'
  $s = $s -replace '"', '&quot;'
  return $s
}

# --- language detection ---
$GroupLang = @{
  'Italy'='Italian'; 'VOD Italy'='Italian'; 'San Marino'='Italian'
  'Greece'='Greek'; 'Cyprus'='Greek'
  'Hungary'='Hungarian'
  'Ukraine'='Ukrainian'
  'UK'='English'; 'USA'='English'; 'Australia'='English'; 'Ireland'='English'
  'Canada'='English'; 'News'='English'; 'Business'='English'
  'Hollywood'='English'; 'Weather'='English'
  'Music (EN)'='English'; 'Documentaries (EN)'='English'; 'VOD Movies (EN)'='English'
  'Nigeria'='English'
  'Spain'='Spanish'; 'Chile'='Spanish'; 'Mexico'='Spanish'; 'Argentina'='Spanish'
  'Peru'='Spanish'; 'Costa Rica'='Spanish'; 'Venezuela'='Spanish'
  'News (ES)'='Spanish'
  'Russia'='Russian'
  'China'='Chinese'
  '?? / Japan'='Japanese'
  'Czech Republic'='Czech'
  'Germany'='German'; 'Austria'='German'; 'Switzerland'='German'
  'North Macedonia'='Macedonian'
  'Finland'='Finnish'
  'United Arab Emirates'='Arabic'; 'Lebanon'='Arabic'; 'Saudi Arabia'='Arabic'
  'Egypt'='Arabic'; 'Iraq'='Arabic'; 'Qatar'='Arabic'
  'News (AR)'='Arabic'
  'Slovakia'='Slovak'
  'Netherlands'='Dutch'
  'Belarus'='Belarusian'
  'Romania'='Romanian'; 'Moldova'='Romanian'
  'Korea'='Korean'; 'North Korea'='Korean'
  'Turkey'='Turkish'
  'France'='French'; 'Monaco'='French'; 'Belgium'='French'
  'Lithuania'='Lithuanian'
  'Albania'='Albanian'; 'Kosovo'='Albanian'
  'Denmark'='Danish'
  'Poland'='Polish'
  'Turkmenistan'='Turkmen'
  'Estonia'='Estonian'
  'Croatia'='Croatian'
  'Brazil'='Portuguese'; 'Portugal'='Portuguese'
  'Georgia'='Georgian'
  'Azerbaijan'='Azerbaijani'
  'Israel'='Hebrew'
  'Bosnia and Herzegovina'='Bosnian'
  'Iran'='Persian'
  'Sweden'='Swedish'
  'Somalia'='Somali'
  'Armenia'='Armenian'
  'Kazakhstan'='Kazakh'
  'Latvia'='Latvian'
  'Luxembourg'='Luxembourgish'
  'Malta'='Maltese'
  'Mongolia'='Mongolian'
  'Montenegro'='Montenegrin'
  'Serbia'='Serbian'
  'Slovenia'='Slovenian'
  'Andorra'='Catalan'
  'Faroe Islands'='Faroese'
  'Iceland'='Icelandic'
}
$IndiaKw = @(
  @('\bKannada\b','Kannada'), @('\bTelugu\b','Telugu'), @('\bTamil\b','Tamil'),
  @('\bMalayalam\b','Malayalam'), @('\bMarathi\b','Marathi'),
  @('\bBengali\b','Bengali'), @('\bBangla\b','Bengali'),
  @('\bPunjabi\b','Punjabi'), @('\bGujarati\b','Gujarati'),
  @('\bOdia\b','Odia'), @('\bOriya\b','Odia'),
  @('\bBhojpuri\b','Bhojpuri'), @('\bUrdu\b','Urdu'), @('\bHindi\b','Hindi')
)
$IndiaBrand = @(
  # English services
  @('(?i)CVR English','English'), @('(?i)Angel TV','English'),
  @('(?i)NDTV 24x7','English'), @('(?i)\bWION\b','English'),
  @('(?i)Republic TV','English'), @('(?i)Times Now(?! Navbharat)','English'),
  @('(?i)Mirror Now','English'), @('(?i)NewsX','English'),
  @('(?i)CNBC TV18(?! Awaaz)','English'), @('(?i)\bET Now\b','English'),
  @('(?i)History TV18','English'), @('(?i)Travelxp','English'),
  # Malayalam
  @('(?i)Kairali','Malayalam'), @('(?i)Asianet','Malayalam'),
  @('(?i)Manorama','Malayalam'), @('(?i)Mazhavil','Malayalam'),
  @('(?i)Kerala|Keralam|Palakkad','Malayalam'),
  @('(?i)Reporter TV','Malayalam'), @('(?i)Media One','Malayalam'),
  @('(?i)Mathrubhumi','Malayalam'), @('(?i)Kaumudy','Malayalam'),
  @('(?i)Amrita TV','Malayalam'), @('(?i)Jaihind TV','Malayalam'),
  @('(?i)Kappa TV','Malayalam'), @('(?i)Janam TV','Malayalam'),
  @('(?i)Joy TV','Malayalam'), @('(?i)Hebron TV','Malayalam'),
  @('(?i)Hosanna','Malayalam'), @('(?i)Sankara TV','Malayalam'),
  @('(?i)Safari TV','Malayalam'), @('(?i)Kite Victers','Malayalam'),
  @('(?i)Vaanavil','Malayalam'), @('(?i)Vanitha TV','Malayalam'),
  # Tamil
  @('(?i)Polimer','Tamil'), @('(?i)Thanthi','Tamil'), @('(?i)Makkal','Tamil'),
  @('(?i)Peppers TV','Tamil'), @('(?i)Vendhar','Tamil'), @('(?i)Vasanth TV','Tamil'),
  @('(?i)News J','Tamil'), @('(?i)Tamilan','Tamil'), @('(?i)TamilVision','Tamil'),
  @('(?i)Thendral','Tamil'), @('(?i)Kalaignar','Tamil'), @('(?i)Malai Murasu','Tamil'),
  @('(?i)Isai Aruvi','Tamil'), @('(?i)Sirippoli','Tamil'), @('(?i)Sathiyam','Tamil'),
  @('(?i)Sooriyan','Tamil'), @('(?i)Moon TV','Tamil'), @('(?i)Puthiya Thalaimurai','Tamil'),
  @('(?i)Puthuyugam','Tamil'), @('(?i)Star Vijay','Tamil'), @('(?i)Vijay Takkar','Tamil'),
  @('(?i)Marutam','Tamil'), @('(?i)Nambikkai','Tamil'), @('(?i)Chithiram','Tamil'),
  @('(?i)Suriya TV','Tamil'), @('(?i)Dhool TV','Tamil'), @('(?i)Sun Gemini','Telugu'),
  # Telugu
  @('(?i)Star Maa','Telugu'), @('(?i)\bCVR\b(?! English)','Telugu'),
  @('(?i)\bSVBC\b','Telugu'), @('(?i)\bHMTV\b','Telugu'),
  @('(?i)\bABN\b','Telugu'), @('(?i)Sakshi','Telugu'),
  @('(?i)V6 News','Telugu'), @('(?i)\bT News\b','Telugu'),
  @('(?i)Mahaa','Telugu'), @('(?i)\bGemini\b','Telugu'),
  @('(?i)ETV (Beats|Comedy|Josh|Cinema|Plus|News)','Telugu'),
  @('(?i)DD Yadagiri','Telugu'), @('(?i)DD Saptagiri','Telugu'),
  # Bengali
  @('(?i)ABP Ananda','Bengali'), @('(?i)Sony Aath','Bengali'),
  @('(?i)Star Jalsha','Bengali'), @('(?i)Zee 24 Ghanta','Bengali'),
  @('(?i)Kolkata|Calcutta|Akhon','Bengali'), @('(?i)Samay Kolkata','Bengali'),
  @('(?i)Rongeen','Bengali'), @('(?i)Ananda Barta','Bengali'),
  # Marathi
  @('(?i)ABP Majha','Marathi'), @('(?i)Star Pravah','Marathi'),
  @('(?i)Jai Maharashtra','Marathi'), @('(?i)Pudhari','Marathi'),
  @('(?i)Sahyadri','Marathi'), @('(?i)Zee 24 Taas','Marathi'),
  @('(?i)9X Jhakaas','Marathi'),
  # Gujarati
  @('(?i)ABP Asmita','Gujarati'), @('(?i)Sandesh News','Gujarati'),
  @('(?i)Gujarat','Gujarati'), @('(?i)DD Girnar','Gujarati'),
  # Punjabi
  @('(?i)\bPTC\b','Punjabi'), @('(?i)9X Tashan','Punjabi'),
  @('(?i)Balle Balle','Punjabi'), @('(?i)Punjab','Punjabi'),
  @('(?i)Chardikla','Punjabi'), @('(?i)Gaunda Punjab','Punjabi'),
  # Odia
  @('(?i)Odisha|Odisha TV','Odia'), @('(?i)Kalinga TV','Odia'),
  @('(?i)Argus News','Odia'), @('(?i)Prameya','Odia'),
  @('(?i)Nandighosha','Odia'), @('(?i)Rengoni','Odia'),
  # Assamese
  @('(?i)Prag News','Assamese'), @('(?i)\bAsom\b','Assamese'),
  @('(?i)Assam Talks','Assamese'), @('(?i)\bDY 365\b','Assamese'),
  @('(?i)Pratidin Time','Assamese'), @('(?i)Jonack','Assamese'),
  # Kannada
  @('(?i)Public TV','Kannada'), @('(?i)Power TV','Kannada'),
  @('(?i)DD Chandana','Kannada'),
  # other
  @('(?i)DD Kashir','Kashmiri'), @('(?i)\bNepal\b','Nepali')
)
$KidsEn = @('Nicktoons','Disney Channel','Disney XD','Nick Jr. (Pluto)','Nickelodeon (Pluto)','Pluto TV Retro Toons','ToonGoggles','MeTV Toons')
$MoviesLang = @{ 'Sony Pix'='English'; 'Sony Pix HD'='English'; 'Asianet Movies'='Malayalam' }
$FeaturedLang = @{ 'Colors Kannada'='Kannada'; 'Colors Tamil'='Tamil'; 'Colors Marathi'='Marathi' }

function Get-Lang([string]$n, [string]$g) {
  if ($g -eq 'Kids & Cartoons') {
    if ($KidsEn -contains $n) { return 'English' }
    return 'Hindi'
  }
  if ($g -eq 'Movies (IN)') {
    if ($MoviesLang.ContainsKey($n)) { return $MoviesLang[$n] }
    return 'Hindi'
  }
  if ($g -eq 'Featured') {
    if ($FeaturedLang.ContainsKey($n)) { return $FeaturedLang[$n] }
    return 'Hindi'
  }
  if ($g -eq 'India') {
    foreach ($r in $IndiaKw) { if ($n -match $r[0]) { return $r[1] } }
    foreach ($r in $IndiaBrand) { if ($n -match $r[0]) { return $r[1] } }
    return 'Hindi'
  }
  if ($g -eq 'Canada' -and $n -match '(?i)\bICI\b|\bT.l.') { return 'French' }
  if ($g -match '(?i)Japan') { return 'Japanese' }
  if ($GroupLang.ContainsKey($g)) { return $GroupLang[$g] }
  return 'English'
}

foreach ($c in $chans) {
  $c | Add-Member -NotePropertyName L -NotePropertyValue (Get-Lang $c.N $c.G)
}
Write-Output ("languages assigned; sample: {0}" -f (($chans | Select-Object -First 5 | ForEach-Object { "$($_.N) ($($_.L))" }) -join ' | '))

$order = New-Object 'System.Collections.Generic.List[string]'
$byG = @{}
foreach ($c in $chans) {
  if (-not $byG.ContainsKey($c.G)) {
    $byG[$c.G] = New-Object 'System.Collections.Generic.List[object]'
    [void]$order.Add($c.G)
  }
  $byG[$c.G].Add($c)
}

$css = @'
:root {
  color-scheme: dark;
  --bg: #0b0d12; --panel: #12151c; --card: #171b24; --card-h: #1e2433;
  --line: #262c3a; --text: #e8eaed; --dim: #8b93a7; --accent: #6ea8fe;
  --accent-2: #8ab4f8; --ok: #3ddc84; --star: #f5c542; --star-dim: #3a3420;
  --num: #5f6b85;
}
* { box-sizing: border-box; }
body { margin:0; font:14px/1.45 "Segoe UI",system-ui,sans-serif; background:var(--bg); color:var(--text); }
header {
  position:sticky; top:0; z-index:20;
  background:linear-gradient(180deg,#12151c 0%,rgba(18,21,28,.96) 100%);
  border-bottom:1px solid var(--line); padding:14px 18px 12px;
  backdrop-filter: blur(8px);
}
.brand { display:flex; align-items:baseline; gap:10px; flex-wrap:wrap; margin-bottom:8px; }
h1 { margin:0; font-size:18px; font-weight:650; letter-spacing:.02em; }
h1 .dot { color:var(--ok); font-size:11px; vertical-align:middle; margin-left:6px; }
.sub { color:var(--dim); font-size:12px; }
.tools { display:flex; gap:10px; align-items:center; flex-wrap:wrap; }
#q {
  flex:1; min-width:200px; max-width:520px; padding:10px 12px;
  border-radius:10px; border:1px solid var(--line); background:var(--bg);
  color:var(--text); font-size:14px; outline:none;
}
#q:focus { border-color:var(--accent); box-shadow:0 0 0 3px rgba(110,168,254,.15); }
.chip {
  border:1px solid var(--line); background:var(--card); color:var(--dim);
  border-radius:999px; padding:7px 12px; font-size:12px; cursor:pointer;
  user-select:none; white-space:nowrap;
}
.chip:hover { border-color:var(--accent); color:var(--text); }
.chip.on { background:#1a2740; border-color:var(--accent); color:var(--accent-2); }
.meta { margin-top:8px; color:var(--dim); font-size:12px; min-height:1.2em; }
.wrap { padding:14px 18px 48px; max-width:1000px; }
.group {
  margin:22px 0 8px; font-size:11px; letter-spacing:.08em; text-transform:uppercase;
  color:var(--accent-2); font-weight:700; display:flex; align-items:center; gap:8px;
}
.group::after { content:""; flex:1; height:1px; background:linear-gradient(90deg,var(--line),transparent); }
.group span { color:var(--num); font-weight:500; letter-spacing:0; text-transform:none; font-size:12px; }
a.ch {
  display:grid; grid-template-columns: 56px 1fr auto auto; gap:10px; align-items:center;
  padding:9px 12px; margin:4px 0; border-radius:10px; background:var(--card);
  color:var(--text); text-decoration:none; border:1px solid transparent;
  transition: background .12s, border-color .12s, transform .08s;
}
a.ch:hover { background:var(--card-h); border-color:var(--line); }
a.ch:active { transform: translateY(1px); }
a.ch .n {
  font-variant-numeric: tabular-nums; font-size:12px; color:var(--num);
  background:#0e1118; border:1px solid var(--line); border-radius:6px;
  text-align:center; padding:3px 0; letter-spacing:.03em;
}
a.ch .name { font-weight:550; min-width:0; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
a.ch .name .lang { color:var(--dim); font-weight:400; font-size:12px; }
a.ch .grp { color:var(--dim); font-size:12px; white-space:nowrap; }
.star {
  width:32px; height:32px; border-radius:8px; border:1px solid transparent;
  background:transparent; color:var(--num); font-size:16px; line-height:1;
  cursor:pointer; display:grid; place-items:center;
}
.star:hover { background:#2a2410; color:var(--star); border-color:#5a4a20; }
.star.on { color:var(--star); background:var(--star-dim); border-color:#6a5a30; }
a.ch.fav { background:#1a1f16; border-color:#2e3a24; }
a.ch.fav .name { color:#c8e6a0; }
.hidden { display:none !important; }
.empty { padding:28px; color:var(--dim); text-align:center; }
footer { color:var(--num); font-size:11px; text-align:center; padding:8px 16px 24px; }
@media (max-width:640px) {
  a.ch { grid-template-columns: 48px 1fr auto auto; gap:8px; }
  a.ch .grp { display:none; }
}
'@

$js = @'
(function () {
  var KEY = "livetv.favs.v1";
  var q = document.getElementById("q");
  var meta = document.getElementById("meta");
  var empty = document.getElementById("empty");
  var favBtn = document.getElementById("favOnly");
  var clearBtn = document.getElementById("clearFav");
  var foot = document.getElementById("foot");
  var favOnly = false;

  function loadFavs() {
    try { return new Set(JSON.parse(localStorage.getItem(KEY) || "[]")); }
    catch (e) { return new Set(); }
  }
  function saveFavs(s) {
    try { localStorage.setItem(KEY, JSON.stringify(Array.from(s))); } catch (e) {}
  }
  var favs = loadFavs();

  function keyOf(a) { return a.dataset.url || a.getAttribute("href") || a.dataset.name || ""; }
  function paintStar(a) {
    var btn = a.querySelector(".star");
    var on = favs.has(keyOf(a));
    if (btn) btn.classList.toggle("on", on);
    a.classList.toggle("fav", on);
  }
  function paintAll() {
    document.querySelectorAll("a.ch").forEach(paintStar);
    var n = favs.size;
    favBtn.textContent = n ? "★ Favorites (" + n + ")" : "★ Favorites";
    favBtn.classList.toggle("on", favOnly);
  }

  function filter() {
    var t = (q.value || "").trim().toLowerCase();
    var shown = 0;
    document.querySelectorAll("a.ch").forEach(function (a) {
      var hit = !t
        || (a.dataset.name || "").toLowerCase().indexOf(t) >= 0
        || (a.dataset.group || "").toLowerCase().indexOf(t) >= 0
        || (a.dataset.lang || "").toLowerCase().indexOf(t) >= 0
        || (a.dataset.chno || "").indexOf(t) >= 0
        || (a.dataset.dchno || "").indexOf(t) >= 0;
      if (hit && favOnly) hit = favs.has(keyOf(a));
      a.classList.toggle("hidden", !hit);
      if (hit) shown++;
    });
    document.querySelectorAll(".group").forEach(function (g) {
      if (!t && !favOnly) { g.classList.remove("hidden"); return; }
      var gname = (g.dataset.group || "").toLowerCase();
      var any = false;
      var sel = 'a.ch[data-group="' + (g.dataset.group || "").replace(/"/g, '\\"') + '"]';
      var nodes = document.querySelectorAll(sel);
      for (var i = 0; i < nodes.length; i++) {
        if (!nodes[i].classList.contains("hidden")) { any = true; break; }
      }
      if (!any && gname.indexOf(t) >= 0 && !favOnly) any = true;
      g.classList.toggle("hidden", !any);
    });
    var total = document.querySelectorAll("a.ch").length;
    meta.textContent = (t || favOnly) ? (shown + " match(es)") : (total + " channels");
    empty.classList.toggle("hidden", shown > 0);
  }

  document.getElementById("list").addEventListener("click", function (e) {
    var btn = e.target.closest ? e.target.closest("button.star") : null;
    if (!btn) return;
    e.preventDefault();
    e.stopPropagation();
    var a = btn.closest("a.ch");
    if (!a) return;
    var k = keyOf(a);
    if (favs.has(k)) favs.delete(k); else favs.add(k);
    saveFavs(favs);
    paintStar(a);
    paintAll();
    if (favOnly) filter();
  });

  q.addEventListener("input", filter);
  favBtn.addEventListener("click", function () {
    favOnly = !favOnly;
    paintAll();
    filter();
  });
  clearBtn.addEventListener("click", function () {
    if (!favs.size) return;
    if (!confirm("Clear all favorites?")) return;
    favs = new Set();
    saveFavs(favs);
    paintAll();
    filter();
  });
  document.querySelectorAll("a.ch").forEach(function (a) {
    a.addEventListener("click", function () {
      a.style.opacity = "0.55";
      setTimeout(function () { a.style.opacity = ""; }, 350);
    });
  });

  paintAll();
  filter();
  foot.textContent = "livetv.m3u8 · " + totalChannels + " channels · stars saved in this browser";
})();
'@

$sb = New-Object System.Text.StringBuilder
[void]$sb.Append("<!DOCTYPE html>`n<html lang=""en""><head><meta charset=""utf-8"">`n")
[void]$sb.Append("<meta name=""viewport"" content=""width=device-width,initial-scale=1"">`n")
[void]$sb.Append("<title>Live TV — All Channels</title>`n<style>`n")
[void]$sb.Append($css)
[void]$sb.Append("`n</style></head><body>`n")
[void]$sb.Append("<header>`n")
[void]$sb.Append("  <div class=""brand"">`n")
[void]$sb.Append("    <h1>Live TV <span class=""dot"">●</span></h1>`n")
[void]$sb.Append("    <div class=""sub"">Click a channel to open in VLC · ★ to favorite · (language) shown after each name</div>`n")
[void]$sb.Append("  </div>`n")
[void]$sb.Append("  <div class=""tools"">`n")
[void]$sb.Append("    <input id=""q"" type=""search"" placeholder=""Search name, language, group, number (Sony, Hindi, Kids, 42)"" autofocus>`n")
[void]$sb.Append("    <button type=""button"" class=""chip"" id=""favOnly"" title=""Show only starred channels"">★ Favorites</button>`n")
[void]$sb.Append("    <button type=""button"" class=""chip"" id=""clearFav"" title=""Clear all favorites"">Clear stars</button>`n")
[void]$sb.Append("  </div>`n")
[void]$sb.Append("  <div class=""meta"" id=""meta""></div>`n")
[void]$sb.Append("</header>`n<div class=""wrap"" id=""list"">`n")

foreach ($g in $order) {
  $list = $byG[$g]
  $count = $list.Count
  if ($g -eq 'Featured') {
    [void]$sb.Append('<div class="group" data-group="FEATURED">FEATURED</div>' + "`n")
  } else {
    $eg = Esc $g
    [void]$sb.Append('<div class="group" data-group="' + $eg + '">' + $eg + ' <span>(' + $count + ')</span></div>' + "`n")
  }
  foreach ($c in $list) {
    $eh = Esc ('livetv://' + [uri]::EscapeDataString($c.U))
    $full = $c.N + ' (' + $c.L + ')'
    $en = Esc $full
    $el = Esc $c.L
    $eg2 = Esc $c.G
    $eu = Esc $c.U
    $star = [string][char]0x2605
    [void]$sb.Append('<a class="ch" href="' + $eh + '" data-name="' + $en + '" data-group="' + $eg2 + '" data-chno="' + $c.C + '" data-dchno="' + (Esc $c.D) + '" data-lang="' + $el + '" data-url="' + $eu + '"><span class="n">' + (Esc $c.D) + '</span><span class="name">' + (Esc $c.N) + ' <span class="lang">(' + $el + ')</span></span><span class="grp">' + $eg2 + '</span><button type="button" class="star" title="Favorite" aria-label="Favorite">' + $star + '</button></a>' + "`n")
  }
}

[void]$sb.Append("</div>`n")
[void]$sb.Append('<div class="empty hidden" id="empty">No channels match.</div>' + "`n")
[void]$sb.Append('<footer id="foot"></footer>' + "`n")
[void]$sb.Append("<script>`nvar totalChannels = $($chans.Count);`n")
[void]$sb.Append($js)
[void]$sb.Append("`n</script>`n</body></html>`n")

$dir = Split-Path -Parent $outPath
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
$utf8 = New-Object System.Text.UTF8Encoding($false)
$text = $sb.ToString()
[System.IO.File]::WriteAllText($outPath, $text, $utf8)
[System.IO.File]::WriteAllText($livePath, $text, $utf8)

$h = [System.IO.File]::ReadAllText($outPath)
Write-Output ("wrote bytes={0} anchors={1} chno={2} groups={3}" -f `
  (Get-Item $outPath).Length,
  ([regex]::Matches($h, '<a class="ch')).Count,
  ([regex]::Matches($h, 'data-chno=')).Count,
  ([regex]::Matches($h, '<div class="group"')).Count)

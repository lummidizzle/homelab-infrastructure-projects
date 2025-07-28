# upgrade-readme.ps1

$readmePath = "README.md"

# 1. Load existing README and remove non-ASCII (corrupted) characters
$content = Get-Content $readmePath -Raw
$cleaned = $content -replace '[^\x00-\x7F]', ''

# 2. Inject badges and updated header (if not already there)
$badges = @"
![Profile views](https://komarev.com/ghpvc/?username=lummidizzle&label=Profile%20views&color=0e75b6&style=flat)
[![LinkedIn](https://img.shields.io/badge/-LinkedIn-0077B5?logo=linkedin&logoColor=white)](https://www.linkedin.com/in/olu-familusi)
[![GitHub Followers](https://img.shields.io/github/followers/lummidizzle?style=social)](https://github.com/lummidizzle)

"@

# Add header and badges if not already present
if ($cleaned -notmatch 'komarev\.com') {
    $cleaned = $cleaned -replace '(?ms)^#*\s*Olumide Familusi.*?\n+', "# Olumide Familusi`n`n" + $badges
}

# 3. Add Table of Contents if not already there
$toc = @"
## 📚 Table of Contents
- [About Me](#about-me)
- [Current Projects](#current-projects)
- [What You'll Find in My Repos](#what-youll-find-in-my-repos)
- [Certifications](#certifications)

"@

if ($cleaned -notmatch '## 📚 Table of Contents') {
    $cleaned = $cleaned -replace '(?ms)(About Me)', "$toc`$1"
}

# 4. Save updated README
$cleaned | Set-Content $readmePath -Encoding UTF8

Write-Host "✅ README.md has been cleaned, updated, and upgraded." -ForegroundColor Green

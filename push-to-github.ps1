Param(
    [string]$RemoteUrl
)

function Abort($msg){ Write-Host $msg -ForegroundColor Red; exit 1 }

if (-not (Get-Command git -ErrorAction SilentlyContinue)) { Abort "Git не найден в PATH. Установите Git и повторите." }

$root = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
Set-Location $root

Write-Host "Рабочая директория:`"$(Get-Location)`""

if (-not (Test-Path .git)) {
    Write-Host "Инициализирую git..."
    git init
}

$name = git config user.name
if (-not $name) {
    $name = Read-Host "Введите git user.name (например: Your Name)"
    if ($name) { git config user.name "$name" }
}

$email = git config user.email
if (-not $email) {
    $email = Read-Host "Введите git user.email (например: you@example.com)"
    if ($email) { git config user.email "$email" }
}

Write-Host "Добавляю файлы и делаю коммит (если есть изменения)..."
git add .
try { git commit -m "Initial commit" } catch { Write-Host "Нет новых изменений для коммита." }

git branch -M main 2>$null

if (-not $RemoteUrl) {
    $RemoteUrl = Read-Host "Введите URL удалённого репозитория (например https://github.com/user/repo.git)"
}

if (-not $RemoteUrl) { Abort "Remote URL не указан. Операция прервана." }

# remove existing origin to avoid duplicate
git remote remove origin 2>$null
git remote add origin $RemoteUrl

Write-Host "Попытка подтянуть (rebase) ветку main с удалённого репозитория (если он не пустой)..."
git pull --rebase origin main 2>$null

Write-Host "Пушу на origin/main..."
git push -u origin main

if ($LASTEXITCODE -eq 0) { Write-Host "Успешно: проект отправлен в $RemoteUrl" -ForegroundColor Green } else { Write-Host "Ошибка при push. Проверьте вывод выше." -ForegroundColor Red }

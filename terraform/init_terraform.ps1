
# Buscar subcarpetas que contengan archivos .tf, ignorando la carpeta oculta .terraform
$dirs = Get-ChildItem -Recurse -Filter "*.tf" | 
        Where-Object { $_.FullName -notmatch '\\\.terraform\\' } | 
        Select-Object -ExpandProperty DirectoryName -Unique

# Ejecutar terraform init en cada ruta encontrada
foreach ($dir in $dirs) {
    Write-Host "`n===> Inicializando en: $dir" -ForegroundColor Cyan
    Push-Location $dir
    terraform init && terraform fmt -check
    Pop-Location
}

# Script para configurar Git e criar repositório para o Sistema GED
Write-Host "Configurando Git para o Sistema GED Prodesp..." -ForegroundColor Green

# Verificar se o Git está instalado
try {
    $gitVersion = git --version
    Write-Host "Git encontrado: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "Git nao encontrado. Instalando..." -ForegroundColor Red
    winget install --id Git.Git -e --source winget
    Write-Host "Git instalado. Reinicie o terminal e execute este script novamente." -ForegroundColor Green
    exit
}

# Configurar Git (substitua pelos seus dados)
Write-Host "Configurando Git..." -ForegroundColor Yellow
git config --global user.name "Seu Nome"
git config --global user.email "seu.email@prodesp.sp.gov.br"

# Inicializar repositório
Write-Host "Inicializando repositorio Git..." -ForegroundColor Yellow
git init

# Adicionar arquivos
Write-Host "Adicionando arquivos ao repositorio..." -ForegroundColor Yellow
git add .

# Fazer primeiro commit
Write-Host "Fazendo primeiro commit..." -ForegroundColor Yellow
git commit -m "Versao inicial do Sistema GED Prodesp

- Sistema completo de gestao de documentos
- Autenticacao e controle de acesso
- Integracao com Supabase
- Recuperacao de senha
- Primeiro acesso obrigatorio
- Interface responsiva"

Write-Host "Repositorio Git configurado com sucesso!" -ForegroundColor Green
Write-Host ""
Write-Host "Proximos passos:" -ForegroundColor Cyan
Write-Host "1. Crie uma conta no GitHub: https://github.com" -ForegroundColor White
Write-Host "2. Crie um novo repositorio no GitHub" -ForegroundColor White
Write-Host "3. Execute os comandos que aparecerao no GitHub:" -ForegroundColor White
Write-Host "   git remote add origin https://github.com/SEU_USUARIO/ged-prodesp.git" -ForegroundColor White
Write-Host "   git branch -M main" -ForegroundColor White
Write-Host "   git push -u origin main" -ForegroundColor White
Write-Host ""
Write-Host "Depois disso, voce podera compartilhar o link do repositorio com outros usuarios!" -ForegroundColor Green

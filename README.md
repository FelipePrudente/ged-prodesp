# 🗂️ Sistema GED - Gestão Eletrônica de Documentos Prodesp

Sistema completo de gestão de documentos desenvolvido para a Prodesp, com autenticação, controle de acesso por perfis e armazenamento em nuvem.

## 🚀 Funcionalidades

- **Autenticação Segura**: Login com e-mail e senha
- **Controle de Acesso**: Múltiplos perfis (Admin, Usuário, Visualizador)
- **Gestão de Usuários**: Cadastro, edição e controle de perfis
- **Gestão de Documentos**: Upload, busca e organização
- **Recuperação de Senha**: Sistema de recuperação via administradores
- **Primeiro Acesso**: Troca obrigatória de senha para novos usuários
- **Armazenamento em Nuvem**: Integração com Supabase Storage

## 📋 Pré-requisitos

- Navegador web moderno (Chrome, Firefox, Safari, Edge)
- Conexão com internet
- Conta de usuário criada por um administrador

## 🛠️ Instalação e Configuração

### Para Desenvolvedores

1. **Clone o repositório:**
   ```bash
   git clone [URL_DO_REPOSITORIO]
   cd ged
   ```

2. **Configure o Supabase:**
   - Crie uma conta em [supabase.com](https://supabase.com)
   - Crie um novo projeto
   - Execute os scripts SQL fornecidos na pasta `database/`
   - Configure as políticas de segurança

3. **Configure as credenciais:**
   - Edite o arquivo `supabaseClient.js`
   - Substitua `YOUR_SUPABASE_URL` e `YOUR_SUPABASE_ANON_KEY` pelas suas credenciais

4. **Execute localmente:**
   - Abra o arquivo `index.html` em um servidor web local
   - Ou use um servidor simples: `python -m http.server 8000`

### Para Usuários Finais

1. **Acesse o sistema:**
   - Abra o navegador
   - Acesse a URL fornecida pelo administrador

2. **Primeiro acesso:**
   - Use as credenciais fornecidas pelo administrador
   - O sistema irá solicitar a troca da senha

## 🔐 Configuração do Supabase

### 1. Criar Projeto
- Acesse [supabase.com](https://supabase.com)
- Crie um novo projeto
- Anote a URL e a chave anônima

### 2. Executar Scripts SQL
Execute os seguintes scripts no SQL Editor do Supabase:

```sql
-- Extensões necessárias
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Tipo para roles
CREATE TYPE user_role AS ENUM ('admin', 'user', 'viewer');

-- Tabelas principais
CREATE TABLE IF NOT EXISTS public.areas (
    id BIGSERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.assuntos (
    id BIGSERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    area_id BIGINT REFERENCES public.areas(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.tipos_documento (
    id BIGSERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    extensoes VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.profiles (
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    nome VARCHAR(255),
    area_id BIGINT REFERENCES public.areas(id),
    primeiro_acesso BOOLEAN DEFAULT true,
    senha_provisoria BOOLEAN DEFAULT false,
    solicitou_recuperacao BOOLEAN DEFAULT false,
    data_solicitacao TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.user_roles (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    role user_role NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, role)
);

CREATE TABLE IF NOT EXISTS public.documentos (
    id BIGSERIAL PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    descricao TEXT,
    arquivo_path TEXT NOT NULL,
    arquivo_nome VARCHAR(255) NOT NULL,
    arquivo_tamanho BIGINT,
    area_id BIGINT REFERENCES public.areas(id),
    assunto_id BIGINT REFERENCES public.assuntos(id),
    tipo_id BIGINT REFERENCES public.tipos_documento(id),
    user_id UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.solicitacoes_recuperacao (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL,
    nome VARCHAR(255),
    data_solicitacao TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    status VARCHAR(50) DEFAULT 'pendente',
    observacoes TEXT,
    admin_responsavel UUID REFERENCES auth.users(id),
    data_resolucao TIMESTAMPTZ
);

-- Habilitar RLS
ALTER TABLE public.areas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assuntos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tipos_documento ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.documentos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.solicitacoes_recuperacao ENABLE ROW LEVEL SECURITY;

-- Políticas RLS (execute as políticas conforme necessário)
```

### 3. Configurar Storage
- Crie um bucket chamado `documentos`
- Configure as políticas de acesso

## 👥 Perfis de Usuário

### Administrador
- Cadastro e gestão de usuários
- Gestão de áreas, assuntos e tipos de documento
- Aprovação de solicitações de recuperação de senha
- Acesso completo ao sistema

### Usuário
- Upload e gestão de documentos
- Busca e visualização de documentos
- Solicitação de recuperação de senha

### Visualizador
- Apenas visualização de documentos
- Busca de documentos

## 🔧 Configuração de Credenciais

Edite o arquivo `supabaseClient.js`:

```javascript
const supabaseUrl = 'SUA_URL_DO_SUPABASE';
const supabaseAnonKey = 'SUA_CHAVE_ANONIMA_DO_SUPABASE';
```

## 📁 Estrutura do Projeto

```
ged/
├── index.html              # Página de login
├── admin.html              # Painel administrativo
├── dashboard.html          # Dashboard de usuário
├── primeiro-acesso.html    # Troca de senha
├── supabaseClient.js       # Configuração do Supabase
├── logo-prodesp.svg        # Logo da empresa
├── .gitignore             # Arquivos ignorados pelo Git
└── README.md              # Este arquivo
```

## 🚨 Segurança

- Todas as senhas são criptografadas
- Controle de acesso baseado em perfis
- Políticas RLS no Supabase
- Validação de entrada de dados
- Sanitização de nomes de arquivo

## 🐛 Solução de Problemas

### Erro de Login
- Verifique se as credenciais estão corretas
- Certifique-se de que o usuário foi criado por um administrador

### Erro de Upload
- Verifique se o arquivo não excede o limite de tamanho
- Certifique-se de que o tipo de arquivo é permitido

### Erro de Conexão
- Verifique a conexão com a internet
- Confirme se as credenciais do Supabase estão corretas

## 📞 Suporte

Para suporte técnico, entre em contato com a equipe de TI da Prodesp.

## 📄 Licença

Este projeto é de uso interno da Prodesp.

---

**Desenvolvido para Prodesp - Companhia de Processamento de Dados do Estado de São Paulo**

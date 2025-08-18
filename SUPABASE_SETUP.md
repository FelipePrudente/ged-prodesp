# 🔧 Configuração do Supabase para o Sistema GED

## 📋 Pré-requisitos

1. Conta no Supabase (gratuita): [supabase.com](https://supabase.com)
2. Acesso ao painel administrativo do Supabase

## 🚀 Passo a Passo

### 1. Criar Projeto no Supabase

1. Acesse [supabase.com](https://supabase.com)
2. Faça login ou crie uma conta
3. Clique em "New Project"
4. Preencha:
   - **Name**: `ged-prodesp` (ou nome de sua preferência)
   - **Database Password**: Crie uma senha forte
   - **Region**: Escolha a região mais próxima (ex: São Paulo)
5. Clique em "Create new project"
6. Aguarde a criação (pode levar alguns minutos)

### 2. Obter Credenciais

1. No painel do projeto, vá para **Settings** → **API**
2. Anote:
   - **Project URL**: `https://xxxxxxxxxxxxx.supabase.co`
   - **anon public**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

### 3. Executar Script SQL

1. No painel do Supabase, vá para **SQL Editor**
2. Clique em "New query"
3. Copie e cole todo o conteúdo do arquivo `schema.sql`
4. Clique em "Run" para executar

### 4. Configurar Storage

1. Vá para **Storage** no menu lateral
2. Clique em "Create a new bucket"
3. Configure:
   - **Name**: `documentos`
   - **Public bucket**: Desmarcado (privado)
4. Clique em "Create bucket"

### 5. Configurar Políticas de Storage

1. No bucket `documentos`, vá para **Policies**
2. Clique em "New Policy"
3. Configure as seguintes políticas:

#### Política para Upload (INSERT)
```sql
-- Nome: "Usuários podem fazer upload de seus próprios arquivos"
-- Target roles: authenticated
-- Using expression:
auth.uid()::text = (storage.foldername(name))[1]
```

#### Política para Download (SELECT)
```sql
-- Nome: "Usuários podem baixar arquivos"
-- Target roles: authenticated
-- Using expression:
true
```

#### Política para Delete
```sql
-- Nome: "Usuários podem deletar seus próprios arquivos"
-- Target roles: authenticated
-- Using expression:
auth.uid()::text = (storage.foldername(name))[1]
```

### 6. Configurar Autenticação

1. Vá para **Authentication** → **Settings**
2. Configure:
   - **Site URL**: URL onde o sistema será hospedado
   - **Redirect URLs**: Adicione URLs de redirecionamento após login

### 7. Criar Usuário Administrador

1. Vá para **Authentication** → **Users**
2. Clique em "Add user"
3. Preencha:
   - **Email**: `admin@prodesp.sp.gov.br`
   - **Password**: Crie uma senha forte
4. Clique em "Create user"

### 8. Configurar Perfil do Admin

Execute este SQL no SQL Editor:

```sql
-- Inserir perfil do administrador
INSERT INTO public.profiles (user_id, email, nome, primeiro_acesso, senha_provisoria)
SELECT 
    id,
    'admin@prodesp.sp.gov.br',
    'Administrador Prodesp',
    false,
    false
FROM auth.users 
WHERE email = 'admin@prodesp.sp.gov.br';

-- Inserir role de administrador
INSERT INTO public.user_roles (user_id, role)
SELECT 
    id,
    'admin'::user_role
FROM auth.users 
WHERE email = 'admin@prodesp.sp.gov.br';
```

### 9. Atualizar Arquivo de Configuração

1. Edite o arquivo `supabaseClient.js`
2. Substitua as credenciais:

```javascript
const supabaseUrl = 'https://SEU_PROJECT_ID.supabase.co';
const supabaseAnonKey = 'SUA_CHAVE_ANONIMA';
```

## 🔍 Verificação

### Testar Configuração

1. Abra o arquivo `index.html` em um servidor web
2. Tente fazer login com o usuário admin
3. Verifique se consegue acessar o painel administrativo
4. Teste o upload de um documento

### Verificar Tabelas

Execute no SQL Editor:

```sql
-- Verificar se as tabelas foram criadas
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Verificar políticas RLS
SELECT schemaname, tablename, policyname 
FROM pg_policies 
WHERE schemaname = 'public' 
ORDER BY tablename, policyname;
```

## 🚨 Problemas Comuns

### Erro de Conexão
- Verifique se as credenciais estão corretas
- Confirme se o projeto está ativo

### Erro de RLS
- Verifique se as políticas foram criadas corretamente
- Execute `NOTIFY pgrst, 'reload schema';`

### Erro de Storage
- Verifique se o bucket `documentos` foi criado
- Confirme se as políticas de storage estão configuradas

### Erro de Autenticação
- Verifique se o usuário foi criado corretamente
- Confirme se o perfil e roles foram inseridos

## 📞 Suporte

Se encontrar problemas:
1. Verifique os logs no painel do Supabase
2. Consulte a documentação oficial: [supabase.com/docs](https://supabase.com/docs)
3. Entre em contato com a equipe de TI

---

**Configuração concluída! O sistema GED está pronto para uso.**

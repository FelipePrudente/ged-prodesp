# 🚀 Guia Rápido para Homologação - Sistema GED

## ✅ **Arquivo ZIP Criado: `ged-prodesp.zip`**

O arquivo está pronto para ser compartilhado com os usuários de teste.

## 📦 **Opções de Compartilhamento**

### **Opção 1: Google Drive (Recomendado)**

1. **Acesse**: https://drive.google.com
2. **Faça login** com sua conta Google
3. **Clique em "Novo"** → "Upload de arquivo"
4. **Selecione** o arquivo `ged-prodesp.zip`
5. **Após upload**, clique com botão direito no arquivo
6. **Selecione "Compartilhar"**
7. **Configure como**: "Qualquer pessoa com o link pode visualizar"
8. **Copie o link** e compartilhe com os usuários

### **Opção 2: OneDrive**

1. **Acesse**: https://onedrive.live.com
2. **Faça login** com sua conta Microsoft
3. **Clique em "Carregar"** → "Arquivos"
4. **Selecione** o arquivo `ged-prodesp.zip`
5. **Após upload**, clique com botão direito no arquivo
6. **Selecione "Compartilhar"**
7. **Configure como**: "Qualquer pessoa pode visualizar"
8. **Copie o link** e compartilhe com os usuários

### **Opção 3: Email**

1. **Abra seu email** (Outlook, Gmail, etc.)
2. **Crie novo email**
3. **Anexe** o arquivo `ged-prodesp.zip`
4. **Envie** para os usuários de teste

## 📋 **Instruções para os Usuários de Teste**

### **1. Baixar e Extrair**
- Baixem o arquivo `ged-prodesp.zip`
- Extraiam em uma pasta (ex: `C:\ged-prodesp`)

### **2. Configurar Supabase**
1. **Criar conta**: https://supabase.com
2. **Criar projeto**:
   - Nome: `ged-prodesp-[SEU_NOME]`
   - Região: São Paulo
   - Senha: crie uma senha forte
3. **Executar script SQL**:
   - Vá em "SQL Editor"
   - Abra o arquivo `database/schema.sql`
   - Copie todo o conteúdo e execute
4. **Configurar Storage**:
   - Vá em "Storage"
   - Crie bucket chamado `documentos`
   - Configure políticas conforme `database/SUPABASE_SETUP.md`

### **3. Configurar Credenciais**
1. **Editar** o arquivo `supabaseClient.js`
2. **Substituir** as credenciais:
   ```javascript
   const supabaseUrl = 'https://SEU_PROJECT_ID.supabase.co';
   const supabaseAnonKey = 'SUA_CHAVE_ANONIMA';
   ```

### **4. Criar Usuário Admin**
1. **Vá em "Authentication"** → "Users"
2. **Clique "Add user"**
3. **Preencha**:
   - Email: `admin@prodesp.sp.gov.br`
   - Password: crie uma senha forte
4. **Execute SQL** para configurar perfil:
   ```sql
   INSERT INTO public.profiles (user_id, email, nome, primeiro_acesso, senha_provisoria)
   SELECT id, 'admin@prodesp.sp.gov.br', 'Administrador Prodesp', false, false
   FROM auth.users WHERE email = 'admin@prodesp.sp.gov.br';
   
   INSERT INTO public.user_roles (user_id, role)
   SELECT id, 'admin'::user_role
   FROM auth.users WHERE email = 'admin@prodesp.sp.gov.br';
   ```

### **5. Executar Sistema**
1. **Instale Python** (se não tiver): https://python.org
2. **Abra PowerShell** na pasta do projeto
3. **Execute**:
   ```powershell
   python -m http.server 8000
   ```
4. **Acesse**: http://localhost:8000
5. **Faça login** com o usuário admin

## 🧪 **Testes a Realizar**

### **Funcionalidades Básicas**
- [ ] Login/logout
- [ ] Cadastro de usuários
- [ ] Cadastro de áreas
- [ ] Cadastro de assuntos
- [ ] Cadastro de tipos de documento

### **Funcionalidades de Documentos**
- [ ] Upload de documentos
- [ ] Busca de documentos
- [ ] Download de documentos
- [ ] Exclusão de documentos

### **Funcionalidades de Segurança**
- [ ] Recuperação de senha
- [ ] Primeiro acesso obrigatório
- [ ] Troca de senha provisória
- [ ] Controle de perfis

### **Funcionalidades Administrativas**
- [ ] Aprovação de recuperação de senha
- [ ] Gestão de usuários
- [ ] Alternância de perfis

## 📞 **Suporte**

### **Documentação Disponível**
- `README.md` - Documentação completa
- `database/SUPABASE_SETUP.md` - Configuração Supabase
- `database/schema.sql` - Script do banco de dados

### **Problemas Comuns**
1. **Erro de CORS**: Use servidor web (não abra HTML diretamente)
2. **Erro de RLS**: Execute o script SQL completo
3. **Erro de Storage**: Configure as políticas do bucket
4. **Erro de Login**: Verifique se o usuário foi criado corretamente

## 📊 **Coleta de Feedback**

### **Formulário de Teste**
Crie um formulário simples para os usuários reportarem:

1. **Funcionalidades testadas**
2. **Problemas encontrados**
3. **Sugestões de melhoria**
4. **Avaliação geral** (1-5)

### **Reunião de Feedback**
- Agende uma reunião após os testes
- Discuta os problemas encontrados
- Priorize as correções necessárias

## 🎯 **Próximos Passos**

1. **Compartilhe o arquivo ZIP** com os usuários
2. **Acompanhe os testes** e colete feedback
3. **Corrija problemas** identificados
4. **Prepare para produção** após homologação

---

**✅ Sistema GED pronto para homologação!**

**📁 Arquivo**: `ged-prodesp.zip` (37KB)
**📋 Usuários**: Siga as instruções acima
**📞 Suporte**: Use a documentação fornecida

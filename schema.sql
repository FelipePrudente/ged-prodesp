-- =====================================================
-- SCHEMA COMPLETO DO SISTEMA GED - PRODESP
-- =====================================================

-- Extensões necessárias
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Tipo para roles de usuário
CREATE TYPE user_role AS ENUM ('admin', 'user', 'viewer');

-- =====================================================
-- TABELAS PRINCIPAIS
-- =====================================================

-- Tabela de áreas
CREATE TABLE IF NOT EXISTS public.areas (
    id BIGSERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de assuntos (relacionados às áreas)
CREATE TABLE IF NOT EXISTS public.assuntos (
    id BIGSERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    area_id BIGINT REFERENCES public.areas(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de tipos de documento
CREATE TABLE IF NOT EXISTS public.tipos_documento (
    id BIGSERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    extensoes VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabela de perfis de usuário (estende auth.users)
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

-- Tabela de roles de usuário (múltiplos perfis por usuário)
CREATE TABLE IF NOT EXISTS public.user_roles (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    role user_role NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, role)
);

-- Tabela de documentos
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

-- Tabela de solicitações de recuperação de senha
CREATE TABLE IF NOT EXISTS public.solicitacoes_recuperacao (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL,
    nome VARCHAR(255),
    data_solicitacao TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    status VARCHAR(50) DEFAULT 'pendente', -- pendente, aprovada, rejeitada
    observacoes TEXT,
    admin_responsavel UUID REFERENCES auth.users(id),
    data_resolucao TIMESTAMPTZ
);

-- =====================================================
-- HABILITAR ROW LEVEL SECURITY (RLS)
-- =====================================================

ALTER TABLE public.areas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assuntos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tipos_documento ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.documentos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.solicitacoes_recuperacao ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- POLÍTICAS RLS
-- =====================================================

-- Políticas para áreas
CREATE POLICY "areas_select_all" ON public.areas 
FOR SELECT USING (true);

CREATE POLICY "areas_insert_admin" ON public.areas 
FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = auth.uid() AND role = 'admin')
);

CREATE POLICY "areas_update_admin" ON public.areas 
FOR UPDATE USING (
    EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = auth.uid() AND role = 'admin')
);

CREATE POLICY "areas_delete_admin" ON public.areas 
FOR DELETE USING (
    EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = auth.uid() AND role = 'admin')
);

-- Políticas para assuntos
CREATE POLICY "assuntos_select_all" ON public.assuntos 
FOR SELECT USING (true);

CREATE POLICY "assuntos_insert_admin" ON public.assuntos 
FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = auth.uid() AND role = 'admin')
);

CREATE POLICY "assuntos_update_admin" ON public.assuntos 
FOR UPDATE USING (
    EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = auth.uid() AND role = 'admin')
);

CREATE POLICY "assuntos_delete_admin" ON public.assuntos 
FOR DELETE USING (
    EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = auth.uid() AND role = 'admin')
);

-- Políticas para tipos de documento
CREATE POLICY "tipos_select_all" ON public.tipos_documento 
FOR SELECT USING (true);

CREATE POLICY "tipos_insert_admin" ON public.tipos_documento 
FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = auth.uid() AND role = 'admin')
);

CREATE POLICY "tipos_update_admin" ON public.tipos_documento 
FOR UPDATE USING (
    EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = auth.uid() AND role = 'admin')
);

CREATE POLICY "tipos_delete_admin" ON public.tipos_documento 
FOR DELETE USING (
    EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = auth.uid() AND role = 'admin')
);

-- Políticas para profiles
CREATE POLICY "profiles_select_all" ON public.profiles 
FOR SELECT USING (true);

CREATE POLICY "profiles_insert_self" ON public.profiles 
FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "profiles_update_self" ON public.profiles 
FOR UPDATE USING (auth.uid() = user_id);

-- Políticas para user_roles
CREATE POLICY "user_roles_select_all" ON public.user_roles 
FOR SELECT USING (true);

CREATE POLICY "user_roles_insert_self" ON public.user_roles 
FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "user_roles_update_self" ON public.user_roles 
FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "user_roles_delete_self" ON public.user_roles 
FOR DELETE USING (auth.uid() = user_id);

-- Políticas para documentos
CREATE POLICY "documentos_select_all" ON public.documentos 
FOR SELECT USING (true);

CREATE POLICY "documentos_insert_self" ON public.documentos 
FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "documentos_update_owner" ON public.documentos 
FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "documentos_delete_owner" ON public.documentos 
FOR DELETE USING (auth.uid() = user_id);

-- Políticas para solicitações de recuperação
CREATE POLICY "solicitacoes_select_all" ON public.solicitacoes_recuperacao 
FOR SELECT USING (true);

CREATE POLICY "solicitacoes_insert_anon_if_email_exists" ON public.solicitacoes_recuperacao
FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM auth.users WHERE email = solicitacoes_recuperacao.email)
);

CREATE POLICY "solicitacoes_update_admin" ON public.solicitacoes_recuperacao 
FOR UPDATE USING (
    EXISTS (SELECT 1 FROM public.user_roles WHERE user_id = auth.uid() AND role = 'admin')
);

-- =====================================================
-- FUNÇÕES RPC
-- =====================================================

-- Função para admin alterar senha de usuário
CREATE OR REPLACE FUNCTION alterar_senha_usuario_admin(
    p_user_id UUID,
    p_nova_senha TEXT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Verificar se o usuário atual é admin
    IF NOT EXISTS (
        SELECT 1 FROM public.user_roles 
        WHERE user_id = auth.uid() AND role = 'admin'
    ) THEN
        RETURN FALSE;
    END IF;
    
    -- Atualizar senha criptografada na tabela auth.users
    UPDATE auth.users 
    SET encrypted_password = crypt(p_nova_senha, gen_salt('bf'))
    WHERE id = p_user_id;
    
    -- Marcar como senha provisória no profile
    UPDATE public.profiles 
    SET senha_provisoria = true,
        solicitou_recuperacao = false
    WHERE user_id = p_user_id;
    
    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END;
$$;

-- =====================================================
-- DADOS INICIAIS (OPCIONAL)
-- =====================================================

-- Inserir área padrão
INSERT INTO public.areas (nome, descricao) 
VALUES ('Tecnologia da Informação', 'Departamento de TI da Prodesp')
ON CONFLICT DO NOTHING;

-- Inserir tipo de documento padrão
INSERT INTO public.tipos_documento (nome, descricao, extensoes) 
VALUES ('Documento Oficial', 'Documentos oficiais da empresa', '.pdf, .doc, .docx')
ON CONFLICT DO NOTHING;

-- =====================================================
-- ÍNDICES PARA PERFORMANCE
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);
CREATE INDEX IF NOT EXISTS idx_user_roles_user_id ON public.user_roles(user_id);
CREATE INDEX IF NOT EXISTS idx_documentos_user_id ON public.documentos(user_id);
CREATE INDEX IF NOT EXISTS idx_documentos_area_id ON public.documentos(area_id);
CREATE INDEX IF NOT EXISTS idx_documentos_assunto_id ON public.documentos(assunto_id);
CREATE INDEX IF NOT EXISTS idx_solicitacoes_user_id ON public.solicitacoes_recuperacao(user_id);
CREATE INDEX IF NOT EXISTS idx_solicitacoes_status ON public.solicitacoes_recuperacao(status);

-- =====================================================
-- RECARREGAR SCHEMA
-- =====================================================

NOTIFY pgrst, 'reload schema';

-- =====================================================
-- SCHEMA COMPLETO DO SISTEMA GED - PRODESP
-- Execute este script no SQL Editor do Supabase (novo projeto)
-- =====================================================

-- Extensões necessárias
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Tipo para roles de usuário
DO $$ BEGIN
    CREATE TYPE user_role AS ENUM ('admin', 'user', 'viewer');
EXCEPTION
    WHEN duplicate_object THEN NULL;
END $$;

-- =====================================================
-- TABELAS PRINCIPAIS
-- =====================================================

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

-- Colunas alinhadas com o frontend (file_path, owner)
CREATE TABLE IF NOT EXISTS public.documentos (
    id BIGSERIAL PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    descricao TEXT,
    file_path TEXT NOT NULL,
    owner UUID REFERENCES auth.users(id),
    area_id BIGINT REFERENCES public.areas(id),
    assunto_id BIGINT REFERENCES public.assuntos(id),
    tipo_id BIGINT REFERENCES public.tipos_documento(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

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
-- FUNÇÃO AUXILIAR: verificar se usuário é admin
-- =====================================================

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.user_roles
        WHERE user_id = auth.uid() AND role = 'admin'
    );
$$;

-- =====================================================
-- POLÍTICAS RLS
-- =====================================================

-- Áreas
CREATE POLICY "areas_select_all" ON public.areas
FOR SELECT USING (true);

CREATE POLICY "areas_insert_admin" ON public.areas
FOR INSERT WITH CHECK (public.is_admin());

CREATE POLICY "areas_update_admin" ON public.areas
FOR UPDATE USING (public.is_admin());

CREATE POLICY "areas_delete_admin" ON public.areas
FOR DELETE USING (public.is_admin());

-- Assuntos
CREATE POLICY "assuntos_select_all" ON public.assuntos
FOR SELECT USING (true);

CREATE POLICY "assuntos_insert_admin" ON public.assuntos
FOR INSERT WITH CHECK (public.is_admin());

CREATE POLICY "assuntos_update_admin" ON public.assuntos
FOR UPDATE USING (public.is_admin());

CREATE POLICY "assuntos_delete_admin" ON public.assuntos
FOR DELETE USING (public.is_admin());

-- Tipos de documento
CREATE POLICY "tipos_select_all" ON public.tipos_documento
FOR SELECT USING (true);

CREATE POLICY "tipos_insert_admin" ON public.tipos_documento
FOR INSERT WITH CHECK (public.is_admin());

CREATE POLICY "tipos_update_admin" ON public.tipos_documento
FOR UPDATE USING (public.is_admin());

CREATE POLICY "tipos_delete_admin" ON public.tipos_documento
FOR DELETE USING (public.is_admin());

-- Profiles
CREATE POLICY "profiles_select_all" ON public.profiles
FOR SELECT USING (true);

CREATE POLICY "profiles_insert_self_or_admin" ON public.profiles
FOR INSERT WITH CHECK (auth.uid() = user_id OR public.is_admin());

CREATE POLICY "profiles_update_self_or_admin" ON public.profiles
FOR UPDATE USING (auth.uid() = user_id OR public.is_admin());

-- User roles
CREATE POLICY "user_roles_select_all" ON public.user_roles
FOR SELECT USING (true);

CREATE POLICY "user_roles_insert_self_or_admin" ON public.user_roles
FOR INSERT WITH CHECK (auth.uid() = user_id OR public.is_admin());

CREATE POLICY "user_roles_update_self_or_admin" ON public.user_roles
FOR UPDATE USING (auth.uid() = user_id OR public.is_admin());

CREATE POLICY "user_roles_delete_self_or_admin" ON public.user_roles
FOR DELETE USING (auth.uid() = user_id OR public.is_admin());

-- Documentos
CREATE POLICY "documentos_select_all" ON public.documentos
FOR SELECT USING (true);

CREATE POLICY "documentos_insert_owner" ON public.documentos
FOR INSERT WITH CHECK (auth.uid() = owner);

CREATE POLICY "documentos_update_owner" ON public.documentos
FOR UPDATE USING (auth.uid() = owner OR public.is_admin());

CREATE POLICY "documentos_delete_owner" ON public.documentos
FOR DELETE USING (auth.uid() = owner OR public.is_admin());

-- Solicitações de recuperação
CREATE POLICY "solicitacoes_select_all" ON public.solicitacoes_recuperacao
FOR SELECT USING (true);

CREATE POLICY "solicitacoes_insert_anon_if_email_exists" ON public.solicitacoes_recuperacao
FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM auth.users WHERE email = solicitacoes_recuperacao.email)
);

CREATE POLICY "solicitacoes_update_admin" ON public.solicitacoes_recuperacao
FOR UPDATE USING (public.is_admin());

-- =====================================================
-- FUNÇÕES RPC
-- =====================================================

-- Criar solicitação de recuperação de senha
CREATE OR REPLACE FUNCTION public.criar_solicitacao_recuperacao(
    p_user_id UUID,
    p_email TEXT,
    p_nome TEXT
)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_id BIGINT;
BEGIN
    INSERT INTO public.solicitacoes_recuperacao (user_id, email, nome, status)
    VALUES (p_user_id, p_email, p_nome, 'pendente')
    RETURNING id INTO v_id;

    UPDATE public.profiles
    SET solicitou_recuperacao = true,
        data_solicitacao = NOW()
    WHERE user_id = p_user_id;

    RETURN v_id;
END;
$$;

-- Admin alterar senha de usuário
CREATE OR REPLACE FUNCTION public.alterar_senha_usuario_admin(
    p_user_id UUID,
    p_nova_senha TEXT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    IF NOT public.is_admin() THEN
        RETURN FALSE;
    END IF;

    UPDATE auth.users
    SET encrypted_password = crypt(p_nova_senha, gen_salt('bf')),
        updated_at = NOW()
    WHERE id = p_user_id;

    UPDATE public.profiles
    SET senha_provisoria = true,
        solicitou_recuperacao = false,
        primeiro_acesso = true
    WHERE user_id = p_user_id;

    RETURN TRUE;
EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END;
$$;

GRANT EXECUTE ON FUNCTION public.criar_solicitacao_recuperacao(UUID, TEXT, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.alterar_senha_usuario_admin(UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated;

-- =====================================================
-- STORAGE: bucket + políticas
-- =====================================================

INSERT INTO storage.buckets (id, name, public)
VALUES ('documentos', 'documentos', false)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "storage_documentos_select"
ON storage.objects FOR SELECT TO authenticated
USING (bucket_id = 'documentos');

CREATE POLICY "storage_documentos_insert"
ON storage.objects FOR INSERT TO authenticated
WITH CHECK (
    bucket_id = 'documentos'
    AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "storage_documentos_update"
ON storage.objects FOR UPDATE TO authenticated
USING (
    bucket_id = 'documentos'
    AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "storage_documentos_delete"
ON storage.objects FOR DELETE TO authenticated
USING (
    bucket_id = 'documentos'
    AND auth.uid()::text = (storage.foldername(name))[1]
);

-- =====================================================
-- DADOS INICIAIS
-- =====================================================

INSERT INTO public.areas (nome, descricao)
SELECT 'Tecnologia da Informação', 'Departamento de TI da Prodesp'
WHERE NOT EXISTS (
    SELECT 1 FROM public.areas WHERE nome = 'Tecnologia da Informação'
);

INSERT INTO public.tipos_documento (nome, descricao, extensoes)
SELECT 'Documento Oficial', 'Documentos oficiais da empresa', '.pdf, .doc, .docx'
WHERE NOT EXISTS (
    SELECT 1 FROM public.tipos_documento WHERE nome = 'Documento Oficial'
);

-- =====================================================
-- ÍNDICES
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);
CREATE INDEX IF NOT EXISTS idx_user_roles_user_id ON public.user_roles(user_id);
CREATE INDEX IF NOT EXISTS idx_documentos_owner ON public.documentos(owner);
CREATE INDEX IF NOT EXISTS idx_documentos_area_id ON public.documentos(area_id);
CREATE INDEX IF NOT EXISTS idx_documentos_assunto_id ON public.documentos(assunto_id);
CREATE INDEX IF NOT EXISTS idx_solicitacoes_user_id ON public.solicitacoes_recuperacao(user_id);
CREATE INDEX IF NOT EXISTS idx_solicitacoes_status ON public.solicitacoes_recuperacao(status);

NOTIFY pgrst, 'reload schema';

-- =====================================================
-- PROMOVER USUÁRIO(S) A ADMINISTRADOR
-- Execute no SQL Editor do Supabase
-- =====================================================

-- 1) Veja quais usuários existem no Auth
SELECT id, email, created_at
FROM auth.users
ORDER BY created_at;

-- 2) Garante profile + role admin para TODOS os usuários já criados
--    (útil no início do projeto / homologação)
INSERT INTO public.profiles (user_id, email, nome, primeiro_acesso, senha_provisoria)
SELECT
    u.id,
    u.email,
    COALESCE(u.raw_user_meta_data->>'nome', split_part(u.email, '@', 1)),
    false,
    false
FROM auth.users u
ON CONFLICT (user_id) DO UPDATE
SET
    primeiro_acesso = false,
    senha_provisoria = false;

INSERT INTO public.user_roles (user_id, role)
SELECT u.id, 'admin'::user_role
FROM auth.users u
ON CONFLICT (user_id, role) DO NOTHING;

INSERT INTO public.user_roles (user_id, role)
SELECT u.id, 'user'::user_role
FROM auth.users u
ON CONFLICT (user_id, role) DO NOTHING;

-- 3) Conferência: deve aparecer role = admin
SELECT p.email, p.nome, ur.role
FROM public.profiles p
JOIN public.user_roles ur ON ur.user_id = p.user_id
ORDER BY p.email, ur.role;

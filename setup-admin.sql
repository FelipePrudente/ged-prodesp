-- =====================================================
-- CONFIGURAR USUÁRIO ADMINISTRADOR
-- Execute DEPOIS de criar o usuário em Authentication → Users
-- Substitua o e-mail se usar outro
-- =====================================================

INSERT INTO public.profiles (user_id, email, nome, primeiro_acesso, senha_provisoria)
SELECT
    id,
    email,
    'Administrador Prodesp',
    false,
    false
FROM auth.users
WHERE email = 'admin@prodesp.sp.gov.br'
ON CONFLICT (user_id) DO UPDATE
SET
    nome = EXCLUDED.nome,
    primeiro_acesso = false,
    senha_provisoria = false;

INSERT INTO public.user_roles (user_id, role)
SELECT
    id,
    'admin'::user_role
FROM auth.users
WHERE email = 'admin@prodesp.sp.gov.br'
ON CONFLICT (user_id, role) DO NOTHING;

-- Vincular admin à área padrão (opcional)
UPDATE public.profiles p
SET area_id = a.id
FROM public.areas a
WHERE p.email = 'admin@prodesp.sp.gov.br'
  AND a.nome = 'Tecnologia da Informação';

-- =====================================================
-- MIGRAÇÃO: múltiplos anexos por documento
-- Execute no SQL Editor do projeto Supabase existente
-- =====================================================

-- 1) Tabela de anexos
CREATE TABLE IF NOT EXISTS public.documento_arquivos (
    id BIGSERIAL PRIMARY KEY,
    documento_id BIGINT NOT NULL REFERENCES public.documentos(id) ON DELETE CASCADE,
    file_path TEXT NOT NULL,
    nome_arquivo VARCHAR(255) NOT NULL,
    tamanho BIGINT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2) Migrar anexos existentes a partir de documentos.file_path
INSERT INTO public.documento_arquivos (documento_id, file_path, nome_arquivo, tamanho)
SELECT
    d.id,
    d.file_path,
    COALESCE(NULLIF(split_part(d.file_path, '/', 2), ''), d.file_path),
    NULL
FROM public.documentos d
WHERE d.file_path IS NOT NULL
  AND NOT EXISTS (
      SELECT 1
      FROM public.documento_arquivos da
      WHERE da.documento_id = d.id
        AND da.file_path = d.file_path
  );

-- 3) file_path legado passa a ser opcional
ALTER TABLE public.documentos
    ALTER COLUMN file_path DROP NOT NULL;

-- 4) RLS
ALTER TABLE public.documento_arquivos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "documento_arquivos_select_all" ON public.documento_arquivos;
DROP POLICY IF EXISTS "documento_arquivos_insert_owner" ON public.documento_arquivos;
DROP POLICY IF EXISTS "documento_arquivos_update_owner" ON public.documento_arquivos;
DROP POLICY IF EXISTS "documento_arquivos_delete_owner" ON public.documento_arquivos;

CREATE POLICY "documento_arquivos_select_all" ON public.documento_arquivos
FOR SELECT USING (true);

CREATE POLICY "documento_arquivos_insert_owner" ON public.documento_arquivos
FOR INSERT WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.documentos d
        WHERE d.id = documento_id
          AND (d.owner = auth.uid() OR public.is_admin())
    )
);

CREATE POLICY "documento_arquivos_update_owner" ON public.documento_arquivos
FOR UPDATE USING (
    EXISTS (
        SELECT 1 FROM public.documentos d
        WHERE d.id = documento_id
          AND (d.owner = auth.uid() OR public.is_admin())
    )
);

CREATE POLICY "documento_arquivos_delete_owner" ON public.documento_arquivos
FOR DELETE USING (
    EXISTS (
        SELECT 1 FROM public.documentos d
        WHERE d.id = documento_id
          AND (d.owner = auth.uid() OR public.is_admin())
    )
);

CREATE INDEX IF NOT EXISTS idx_documento_arquivos_documento_id
    ON public.documento_arquivos(documento_id);

NOTIFY pgrst, 'reload schema';

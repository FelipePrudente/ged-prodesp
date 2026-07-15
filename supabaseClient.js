(function(){
    const SUPABASE_URL = 'https://tikmezjelvxxndcpveze.supabase.co';
    const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRpa21lemplbHZ4eG5kY3B2ZXplIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQxMTgxOTksImV4cCI6MjA5OTY5NDE5OX0.85_lEEATmRT0M7YAr5ODT-wY1TiU_Fhxs2306YJjaFQ';

    if (!window.supabase || !window.supabase.createClient) {
        console.error('Supabase SDK não carregado. Verifique a tag de script do CDN.');
        return;
    }

    const client = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
    window.supabaseClient = client;
})();

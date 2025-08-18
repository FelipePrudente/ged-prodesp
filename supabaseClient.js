(function(){
    const SUPABASE_URL = 'https://aafurobhajrlksycamyx.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFhZnVyb2JoYWpybGtzeWNhbXl4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU1Mzc2MjAsImV4cCI6MjA3MTExMzYyMH0.mwozYXVpaZx7vhQGN8OeUuoYmZEqm73_CahF6JdRxT8';

    if (!window.supabase || !window.supabase.createClient) {
        console.error('Supabase SDK não carregado. Verifique a tag de script do CDN.');
        return;
    }

    const client = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
    window.supabaseClient = client;
})();

(() => {
    if (window.tennisbotInitialized) return;
    window.tennisbotInitialized = true;

    const form = document.getElementById('chatbot-form');
    const input = document.getElementById('chatbot-input-text');
    const messages = document.getElementById('chatbot-messages-body');
    if (!form || !input || !messages) return;

    const addMessage = (text, own = false, link = null, linkText = 'Más información aquí') => {
        const bubble = document.createElement('div');
        bubble.className = `msg-bubble ${own ? 'msg-own' : 'msg-other'}`;
        bubble.textContent = text;
        if (link) {
            const anchor = document.createElement('a');
            anchor.href = link;
            anchor.textContent = linkText;
            anchor.className = 'chatbot-more-link';
            anchor.target = '_self';
            bubble.appendChild(document.createElement('br'));
            bubble.appendChild(anchor);
        }
        messages.appendChild(bubble);
        messages.scrollTop = messages.scrollHeight;
    };

    document.querySelectorAll('[data-chatbot-prompt]').forEach((button) => {
        button.addEventListener('click', () => {
            input.value = button.dataset.chatbotPrompt;
            form.requestSubmit();
        });
    });

    form.addEventListener('submit', async (event) => {
        event.preventDefault();
        const text = input.value.trim();
        if (!text) return;
        addMessage(text, true);
        input.value = '';
        try {
            const response = await fetch('/api/chatbot', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ mensaje: text, pagina: document.body.className }) });
            const data = await response.json().catch(() => ({}));
            addMessage(data.respuesta || 'No pude procesar la pregunta. Prueba con reservas, jugadores o productos.', false, data.enlace, data.enlace_texto);
        } catch (error) {
            addMessage('No pude conectar con el asistente. Revisa tu conexión e inténtalo de nuevo.');
        }
    });
})();

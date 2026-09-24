(() => {
    if (window.tennisselWidgetsInitialized) return;
    window.tennisselWidgetsInitialized = true;

    const root = document.getElementById('tennissel-widgets');
    if (!root) return;

    const currentUserId = Number(root.dataset.userId);
    const currentRole = root.dataset.role;
    const panels = ['chatbot-window', 'widget-window', 'widget-teacher-window', 'chat-universal-box'];
    let activeChatUser = null;

    const showPanel = (id) => {
        panels.forEach((panelId) => {
            const panel = document.getElementById(panelId);
            if (panel) panel.classList.toggle('widget-hidden', panelId !== id);
        });
    };

    const escapeHtml = (value) => String(value ?? '').replace(/[&<>"']/g, (character) => ({
        '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;'
    }[character]));

    const requestJson = async (url, options = {}) => {
        const response = await fetch(url, { headers: { 'Content-Type': 'application/json' }, ...options });
        const data = await response.json().catch(() => ({}));
        if (!response.ok) throw new Error(data.error || 'No se pudo completar la solicitud.');
        return data;
    };

    const renderPeople = (items, type) => {
        const container = document.getElementById(type === 'radar' ? 'radar-list' : 'teacher-list');
        if (!container) return;
        if (!items.length) {
            container.innerHTML = '<p class="widget-empty">No hay perfiles disponibles todavía.</p>';
            return;
        }
        container.innerHTML = items.map((person) => {
            const distance = person.distancia_km !== undefined && person.distancia_km < 9999 ? `<small>${escapeHtml(person.distancia_km)} km</small>` : '';
            const state = person.estado_chat === 'aceptado' ? 'Abrir chat' : person.estado_chat === 'enviado' ? 'Solicitud enviada' : person.estado_chat === 'recibido' ? 'Aceptar solicitud' : 'Contactar';
            const disabled = person.estado_chat === 'enviado' ? ' disabled' : '';
            return `<article class="widget-person-card" data-profile-id="${person.id}">
                <div class="widget-person-summary"><img class="widget-avatar" src="${person.foto ? `/static/uploads/perfiles/${encodeURIComponent(person.foto)}` : '/static/IMG/logo.png'}" alt="Foto de ${escapeHtml(person.nombre)}"><div><strong>${escapeHtml(person.nombre)}</strong><span>${escapeHtml(person.nivel || 'Nivel no indicado')} ${distance}</span></div></div>
                <button class="widget-action" data-person-id="${person.id}" data-person-name="${escapeHtml(person.nombre)}" data-contact-state="${person.estado_chat}"${disabled}>${state}</button>
            </article>`;
        }).join('');
        container.querySelectorAll('[data-person-id]').forEach((button) => {
            button.addEventListener('click', (event) => { event.stopPropagation(); contactPerson(button); });
        });
        container.querySelectorAll('[data-profile-id]').forEach((card) => {
            card.addEventListener('click', () => showProfile(card.dataset.profileId));
        });
    };

    const loadPeople = async (type) => {
        const container = document.getElementById(type === 'radar' ? 'radar-list' : 'teacher-list');
        if (!container) return;
        try {
            const people = await requestJson(type === 'radar' ? '/api/radar' : (currentRole === 'profesor' ? '/api/contactos' : '/api/profesores'));
            renderPeople(people, type);
        } catch (error) {
            container.innerHTML = `<p class="widget-error">${escapeHtml(error.message)}</p>`;
        }
    };

    const contactPerson = async (button) => {
        const personId = Number(button.dataset.personId);
        const state = button.dataset.contactState;
        if (state === 'aceptado') {
            openChat(personId, button.dataset.personName);
            return;
        }
        try {
            if (state === 'recibido') {
                const cards = await requestJson('/api/contactos');
                const contact = cards.find((item) => Number(item.id) === personId);
                if (contact) await requestJson('/api/responder_solicitud', { method: 'POST', body: JSON.stringify({ contacto_id: contact.contacto_id, estado: 'aceptada' }) });
                openChat(personId, button.dataset.personName);
                return;
            }
            await requestJson('/api/solicitar_chat', {
                method: 'POST', body: JSON.stringify({ receptor_id: personId })
            });
            button.textContent = 'Solicitud enviada';
            button.disabled = true;
            button.dataset.contactState = 'enviado';
        } catch (error) {
            button.textContent = error.message;
        }
    };

    const renderMessages = (messages) => {
        const container = document.getElementById('chat-messages-body');
        if (!container) return;
        container.innerHTML = messages.length ? messages.map((message) => {
            const own = Number(message.emisor_id) === currentUserId;
            if (message.tipo === 'propuesta') {
                let proposal = {};
                try { proposal = JSON.parse(message.datos_extra || '{}'); } catch (error) { proposal = {}; }
                const actions = !own && message.estado_propuesta === 'pendiente' ? `<div class="proposal-actions"><button data-proposal-action="aceptada" data-message-id="${message.id}">Aceptar y reservar</button><button data-proposal-action="rechazada" data-message-id="${message.id}">Rechazar</button></div>` : `<small>${escapeHtml(message.estado_propuesta || 'pendiente')}</small>`;
                return `<div class="msg-bubble ${own ? 'msg-own' : 'msg-other'}"><strong>Propuesta de clase</strong><br>${escapeHtml(message.texto)}<br><small>${escapeHtml(proposal.fecha_reserva || '')} ${escapeHtml(proposal.hora_reserva || '')}</small>${actions}</div>`;
            }
            const reportButton = !own ? `<button class="message-report" data-message-id="${message.id}" type="button">Denunciar</button>` : '';
            return `<div class="msg-bubble ${own ? 'msg-own' : 'msg-other'}">${escapeHtml(message.texto)}${reportButton}</div>`;
        }).join('') : '<p class="widget-empty">Todavia no hay mensajes.</p>';
        container.scrollTop = container.scrollHeight;
        container.querySelectorAll('[data-proposal-action]').forEach((button) => {
            button.addEventListener('click', async () => {
                try {
                    await requestJson('/api/responder_propuesta', { method: 'POST', body: JSON.stringify({ mensaje_id: button.dataset.messageId, accion: button.dataset.proposalAction }) });
                    loadMessages();
                } catch (error) { button.textContent = error.message; }
            });
        });
        container.querySelectorAll('.message-report').forEach((button) => {
            button.addEventListener('click', async () => {
                const reason = window.prompt('Motivo de la denuncia:', 'Lenguaje ofensivo o conducta inapropiada.');
                if (!reason) return;
                const result = await requestJson('/api/denunciar_mensaje', { method: 'POST', body: JSON.stringify({ mensaje_id: button.dataset.messageId, motivo: reason }) });
                if (result.status === 'success') { button.textContent = 'Denunciado'; button.disabled = true; }
            });
        });
    };

    const loadMessages = async () => {
        if (!activeChatUser) return;
        try {
            renderMessages(await requestJson(`/api/mensajes/${activeChatUser.id}`));
        } catch (error) {
            renderMessages([{ texto: error.message, emisor_id: 0 }]);
        }
    };

    const openChat = (id, name) => {
        activeChatUser = { id, name };
        document.getElementById('chat-target-name').textContent = name;
        document.getElementById('proposal-toggle').hidden = currentRole !== 'profesor';
        document.getElementById('proposal-form').hidden = true;
        showPanel('chat-universal-box');
        loadMessages();
    };

    const showProfile = async (id) => {
        try {
            const profile = await requestJson(`/api/perfiles/${id}`);
            const modal = document.createElement('div');
            modal.className = 'widget-profile-modal';
            modal.innerHTML = `<div class="widget-profile-card"><button class="btn-close-widget widget-profile-close" type="button">&times;</button><img class="widget-profile-photo" src="${profile.foto ? `/static/uploads/perfiles/${encodeURIComponent(profile.foto)}` : '/static/IMG/logo.png'}" alt="Foto de perfil"><h3>${escapeHtml(profile.nombre)}</h3><p>${escapeHtml(profile.barrio || 'Barrio no indicado')}</p><p>${escapeHtml(profile.nivel || 'Nivel no indicado')} · ${escapeHtml(profile.mano || 'Mano no indicada')} · ${escapeHtml(profile.reves || 'Revés no indicado')}</p></div>`;
            document.body.appendChild(modal);
            modal.addEventListener('click', (event) => { if (event.target === modal || event.target.closest('.widget-profile-close')) modal.remove(); });
        } catch (error) { window.alert(error.message); }
    };

    document.getElementById('chatbot-launcher')?.addEventListener('click', () => showPanel('chatbot-window'));
    document.getElementById('widget-launcher')?.addEventListener('click', () => { showPanel('widget-window'); loadPeople('radar'); });
    document.getElementById('widget-teacher-launcher')?.addEventListener('click', () => { showPanel('widget-teacher-window'); loadPeople('teachers'); });
    document.getElementById('widget-dock-toggle')?.addEventListener('click', (event) => {
        const collapsed = root.classList.toggle('is-collapsed');
        event.currentTarget.setAttribute('aria-expanded', String(!collapsed));
        event.currentTarget.setAttribute('aria-label', collapsed ? 'Mostrar accesos flotantes' : 'Ocultar accesos flotantes');
        event.currentTarget.innerHTML = `<i class="fa-solid fa-chevron-${collapsed ? 'up' : 'down'}"></i>`;
    });
    root.querySelectorAll('[data-close-widget]').forEach((button) => button.addEventListener('click', () => showPanel(null)));
    document.getElementById('chat-back-button')?.addEventListener('click', () => showPanel('widget-window'));

    document.getElementById('chat-form')?.addEventListener('submit', async (event) => {
        event.preventDefault();
        const input = document.getElementById('chat-input-text');
        const text = input.value.trim();
        if (!text || !activeChatUser) return;
        try {
            await requestJson('/api/enviar_mensaje', { method: 'POST', body: JSON.stringify({ receptor_id: activeChatUser.id, texto: text }) });
            input.value = '';
            loadMessages();
        } catch (error) {
            input.setCustomValidity(error.message);
            input.reportValidity();
        }
    });

    document.getElementById('proposal-toggle')?.addEventListener('click', async () => {
        const form = document.getElementById('proposal-form');
        form.hidden = !form.hidden;
        if (!form.hidden && document.getElementById('proposal-location').options.length <= 1) {
            const locations = await requestJson('/api/locaciones/canchas');
            document.getElementById('proposal-location').innerHTML = '<option value="">Cancha</option>' + locations.map((location) => `<option value="${location.id}">${escapeHtml(location.nombre)}</option>`).join('');
        }
    });

    document.getElementById('proposal-form')?.addEventListener('submit', async (event) => {
        event.preventDefault();
        if (!activeChatUser) return;
        const location = document.getElementById('proposal-location');
        const date = document.getElementById('proposal-date').value;
        const time = document.getElementById('proposal-time').value;
        const duration = document.getElementById('proposal-duration').value;
        try {
            await requestJson('/api/enviar_mensaje', { method: 'POST', body: JSON.stringify({ receptor_id: activeChatUser.id, tipo: 'propuesta', texto: `Reserva propuesta en ${location.selectedOptions[0].text}`, datos_extra: { locacion_id: location.value, fecha_reserva: date, hora_reserva: time, duracion: duration } }) });
            event.target.reset();
            event.target.hidden = true;
            loadMessages();
        } catch (error) { window.alert(error.message); }
    });

    if (currentRole === 'profesor') document.getElementById('teacher-launcher-label').textContent = 'Mis chats';
})();

(() => {
    const peopleList = document.getElementById('matchmaking-people');
    const teacherList = document.getElementById('matchmaking-teachers');
    const messages = document.getElementById('matchmaking-messages');
    const input = document.getElementById('matchmaking-input');
    const title = document.getElementById('matchmaking-chat-title');
    const currentRole = document.body.dataset.role;
    let activeUser = null;

    const escapeHtml = (value) => String(value ?? '').replace(/[&<>"']/g, (character) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;' }[character]));
    const api = async (url, options) => { const response = await fetch(url, options); const data = await response.json().catch(() => ({})); if (!response.ok) throw new Error(data.error || `No se pudo completar la acción (${response.status}).`); return data; };
    const avatar = (person) => person.foto ? `/static/uploads/perfiles/${encodeURIComponent(person.foto)}` : '/static/IMG/logo.png';

    const renderPeople = (items, target) => {
        target.innerHTML = items.length ? items.map((person) => `<article class="match-person" data-person="${person.id}" data-name="${escapeHtml(person.nombre)}">
            <img src="${avatar(person)}" alt="Foto de ${escapeHtml(person.nombre)}"><div><strong>${escapeHtml(person.nombre)}</strong><span>${escapeHtml(person.barrio || 'Barrio no indicado')} · ${escapeHtml(person.nivel || 'Nivel no indicado')}</span><small>${escapeHtml(person.mano || 'Mano no indicada')} · ${escapeHtml(person.reves || 'Revés no indicado')}</small></div><button type="button" data-action="${person.estado_chat}" data-contact="${person.contacto_id || ''}">${person.estado_chat === 'aceptado' ? 'Chat' : person.estado_chat === 'recibido' ? 'Aceptar' : person.estado_chat === 'enviado' ? 'Enviada' : 'Contactar'}</button></article>`).join('') : '<p class="match-empty">No hay personas disponibles.</p>';
        target.querySelectorAll('.match-person').forEach((card) => {
            card.addEventListener('click', () => openProfile(card.dataset.person));
            card.querySelector('button').addEventListener('click', async (event) => { event.stopPropagation(); await handleContact(card); });
        });
    };

    const handleContact = async (card) => {
        const button = card.querySelector('button');
        const state = button.dataset.action;
        const id = Number(card.dataset.person);
        try {
            if (state === 'aceptado') return openChat(id, card.dataset.name);
            if (state === 'recibido') { await api('/api/responder_solicitud', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ contacto_id: button.dataset.contact, estado: 'aceptada' }) }); return openChat(id, card.dataset.name); }
            await api('/api/solicitar_chat', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ receptor_id: id }) });
            button.textContent = 'Enviada'; button.disabled = true;
        } catch (error) { button.textContent = error.message; }
    };

    const loadPeople = async () => {
        try {
            renderPeople(await api('/api/matchmaking/usuarios'), peopleList);
        } catch (error) {
            peopleList.innerHTML = `<p class="match-empty">${escapeHtml(error.message)}</p>`;
        }
        if (teacherList) {
            try {
                renderPeople(await api('/api/profesores'), teacherList);
            } catch (error) {
                teacherList.innerHTML = `<p class="match-empty">${escapeHtml(error.message)}</p>`;
            }
        }
    };
    const openChat = (id, name) => { activeUser = id; title.textContent = `Chat con ${name}`; messages.innerHTML = '<p class="match-empty">Cargando conversación...</p>'; loadMessages(); };
    const loadMessages = async () => {
        if (!activeUser) return;
        try {
            const data = await api(`/api/mensajes/${activeUser}`);
            messages.innerHTML = data.length ? data.map((message) => {
                const own = message.emisor_id === Number(document.body.dataset.userId);
                if (message.tipo === 'propuesta') {
                    let proposal = {};
                    try { proposal = JSON.parse(message.datos_extra || '{}'); } catch (error) { proposal = {}; }
                    const pending = !own && message.estado_propuesta === 'pendiente';
                    const actions = pending ? `<div class="proposal-actions"><button type="button" data-proposal-action="aceptada" data-message-id="${message.id}">Aceptar reserva</button><button type="button" data-proposal-action="rechazada" data-message-id="${message.id}">Rechazar</button></div>` : `<small>${escapeHtml(message.estado_propuesta || 'pendiente')}</small>`;
                    return `<div class="match-message ${own ? 'mine' : 'theirs'}"><strong>Propuesta de reserva</strong><br>${escapeHtml(message.texto)}<br><small>${escapeHtml(proposal.fecha_reserva || '')} · ${escapeHtml(proposal.hora_reserva || '')} · ${escapeHtml(proposal.duracion || '1')} hora(s)</small>${actions}</div>`;
                }
                return `<div class="match-message ${own ? 'mine' : 'theirs'}">${escapeHtml(message.texto)}</div>`;
            }).join('') : '<p class="match-empty">Todavía no hay mensajes.</p>';
            messages.querySelectorAll('[data-proposal-action]').forEach((button) => button.addEventListener('click', async () => {
                button.disabled = true;
                try { await api('/api/responder_propuesta', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ mensaje_id: button.dataset.messageId, accion: button.dataset.proposalAction }) }); loadMessages(); }
                catch (error) { button.disabled = false; button.textContent = error.message; }
            }));
            messages.scrollTop = messages.scrollHeight;
        } catch (error) { messages.innerHTML = `<p class="match-empty">${escapeHtml(error.message)}</p>`; }
    };
    const closeProfile = () => { document.getElementById('matchmaking-profile-modal').hidden = true; };
    const openProfile = async (id) => { try { const profile = await api(`/api/perfiles/${id}`); document.getElementById('matchmaking-profile').innerHTML = `<button type="button" class="match-profile-close" data-close-profile aria-label="Cerrar perfil">&times;</button><img src="${avatar(profile)}" alt="Foto de perfil"><h3>${escapeHtml(profile.nombre)}</h3><p>${escapeHtml(profile.barrio || 'Barrio no indicado')}</p><p>${escapeHtml(profile.nivel || 'Nivel no indicado')} · ${escapeHtml(profile.mano || 'Mano no indicada')} · ${escapeHtml(profile.reves || 'Revés no indicado')}</p>`; document.getElementById('matchmaking-profile-modal').hidden = false; } catch (error) { window.alert(error.message); } };

    const sendMessage = async () => {
        const text = input.value.trim();
        if (!text || !activeUser) return;
        const sendButton = document.getElementById('matchmaking-send');
        sendButton.disabled = true;
        try {
            await api('/api/enviar_mensaje', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ receptor_id: activeUser, texto: text }) });
            input.value = '';
            loadMessages();
        } catch (error) {
            messages.insertAdjacentHTML('beforeend', `<p class="match-error">${escapeHtml(error.message)}</p>`);
        } finally {
            sendButton.disabled = false;
        }
    };
    document.getElementById('matchmaking-send')?.addEventListener('click', sendMessage);
    input?.addEventListener('keydown', (event) => { if (event.key === 'Enter') { event.preventDefault(); sendMessage(); } });
    const proposalToggle = document.getElementById('matchmaking-proposal-toggle');
    const proposalForm = document.getElementById('matchmaking-proposal-form');
    const proposalLocation = document.getElementById('matchmaking-proposal-location');
    const proposalDate = document.getElementById('matchmaking-proposal-date');
    const proposalTime = document.getElementById('matchmaking-proposal-time');
    const proposalDuration = document.getElementById('matchmaking-proposal-duration');
    const proposalSummary = document.getElementById('matchmaking-proposal-summary');
    const proposalLocationStatus = document.getElementById('matchmaking-proposal-location-status');
    if (proposalDate) proposalDate.min = new Date().toISOString().slice(0, 10);
    const updateProposalSummary = () => {
        if (!proposalSummary) return;
        const locationName = proposalLocation?.selectedOptions[0]?.text;
        const duration = proposalDuration?.value;
        proposalSummary.textContent = locationName && proposalDate?.value && proposalTime?.value
            ? `${locationName} · ${proposalDate.value} · ${proposalTime.value} · ${duration} hora${duration === '1' ? '' : 's'}`
            : 'Selecciona lugar, fecha y hora';
    };
    [proposalLocation, proposalDate, proposalTime, proposalDuration].forEach((field) => field?.addEventListener('input', updateProposalSummary));
    proposalLocation?.addEventListener('change', updateProposalSummary);
    const loadProposalLocations = async () => {
        if (!proposalLocation || proposalLocation.dataset.loaded === 'true') return;
        proposalLocation.disabled = true;
        if (proposalLocationStatus) proposalLocationStatus.textContent = 'Buscando canchas disponibles...';
        try {
            const locations = await api('/api/locaciones/canchas');
            proposalLocation.innerHTML = locations.length
                ? '<option value="">Selecciona una cancha</option>' + locations.map((location) => `<option value="${location.id}">${escapeHtml(location.nombre)}</option>`).join('')
                : '<option value="">No hay canchas registradas</option>';
            proposalLocation.dataset.loaded = 'true';
            if (proposalLocationStatus) proposalLocationStatus.textContent = locations.length ? `${locations.length} canchas disponibles` : 'Registra una cancha para continuar.';
        } catch (error) {
            proposalLocation.innerHTML = '<option value="">No se pudieron cargar</option>';
            if (proposalLocationStatus) proposalLocationStatus.textContent = error.message;
        } finally {
            proposalLocation.disabled = false;
        }
    };
    proposalToggle?.addEventListener('click', async () => {
        proposalForm.hidden = !proposalForm.hidden;
        if (!proposalForm.hidden) loadProposalLocations();
    });
    proposalForm?.addEventListener('submit', async (event) => {
        event.preventDefault();
        if (!activeUser) return;
        const date = document.getElementById('matchmaking-proposal-date').value;
        const time = document.getElementById('matchmaking-proposal-time').value;
        const duration = document.getElementById('matchmaking-proposal-duration').value;
        const locationName = proposalLocation.selectedOptions[0]?.text || 'Cancha';
        try {
            await api('/api/enviar_mensaje', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ receptor_id: activeUser, tipo: 'propuesta', texto: `Propuesta en ${locationName}`, datos_extra: { locacion_id: proposalLocation.value, fecha_reserva: date, hora_reserva: time, duracion: duration } }) });
            proposalForm.reset(); proposalForm.hidden = true; updateProposalSummary(); loadMessages();
        } catch (error) { messages.insertAdjacentHTML('beforeend', `<p class="match-error">${escapeHtml(error.message)}</p>`); }
    });
    document.getElementById('matchmaking-profile-modal')?.addEventListener('click', (event) => {
        if (event.target.id === 'matchmaking-profile-modal' || event.target.closest('[data-close-profile]')) closeProfile();
    });
    loadPeople();
})();

(() => {
    const dateInput = document.getElementById('reservas-date');
    const calendar = document.getElementById('reservas-calendar');
    const courts = document.getElementById('reservas-courts');
    const feedback = document.getElementById('reservas-feedback');
    const label = document.getElementById('reservas-selected-label');
    const loading = document.getElementById('reservas-loading');
    const courtFilter = document.getElementById('reservas-court-filter');
    const durationSelect = document.getElementById('reservas-duration');
    const myList = document.getElementById('reservas-my-list');
    const myToggle = document.getElementById('reservas-my-toggle');
    const confirmation = document.getElementById('reservas-confirmation');
    const confirmationText = document.getElementById('reservas-confirmation-text');
    const confirmButton = document.getElementById('reservas-confirm');
    const backButton = document.getElementById('reservas-back');
    let selectedReservation = null;
    if (!dateInput || !calendar || !courts) return;

    const today = new Date();
    const isoDate = (date) => {
        const offset = date.getTimezoneOffset();
        return new Date(date.getTime() - offset * 60000).toISOString().slice(0, 10);
    };
    const escapeHtml = (value) => String(value ?? '').replace(/[&<>"']/g, (character) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;' }[character]));
    dateInput.value = isoDate(today);

    const showFeedback = (message, error = false) => {
        feedback.hidden = false;
        feedback.className = `reservas-feedback ${error ? 'is-error' : 'is-success'}`;
        feedback.textContent = message;
        window.setTimeout(() => { feedback.hidden = true; }, 4500);
    };

    const formatTime = (value) => String(value || '').slice(0, 5);
    const renderMyReservations = (items) => {
        if (!myList) return;
        myList.innerHTML = items.length ? items.map((item) => `<article class="reserva-mine"><div><strong>${escapeHtml(item.nombre_cancha)}</strong><span>${escapeHtml(item.direccion || '')}</span></div><time>${escapeHtml(item.fecha_reserva)} · ${formatTime(item.hora_reserva)} - ${formatTime(item.hora_fin)}</time><button class="reserva-delete" type="button" data-reservation-id="${item.id}">Eliminar reserva</button></article>`).join('') : '<p class="reservas-empty">Todavía no tienes reservas próximas.</p>';
        myList.querySelectorAll('[data-reservation-id]').forEach((button) => button.addEventListener('click', () => deleteReservation(button.dataset.reservationId)));
    };

    const deleteReservation = async (reservationId) => {
        if (!window.confirm('¿Quieres eliminar esta reserva?')) return;
        try {
            const response = await fetch(`/api/reservas/${reservationId}`, { method: 'DELETE' });
            const data = await response.json().catch(() => ({}));
            if (!response.ok) throw new Error(data.error || 'No se pudo eliminar la reserva.');
            showFeedback('Reserva eliminada correctamente.');
            loadAvailability();
        } catch (error) {
            showFeedback(error.message, true);
        }
    };

    const loadAvailability = async () => {
        const date = dateInput.value;
        if (!date) return;
        loading.textContent = 'Cargando...';
        label.textContent = `Canchas para ${date}`;
        try {
            const response = await fetch(`/api/reservas/disponibilidad?fecha=${encodeURIComponent(date)}`);
            const data = await response.json().catch(() => ({}));
            if (!response.ok) throw new Error(data.error || 'No se pudo cargar la disponibilidad.');
            renderMyReservations(data.mis_reservas || []);
            const selectedCourt = courtFilter.value || 'todas';
            courtFilter.innerHTML = '<option value="todas">Todas las canchas</option>' + data.canchas.map((court) => `<option value="${court.id}">${escapeHtml(court.nombre)}</option>`).join('');
            courtFilter.value = data.canchas.some((court) => String(court.id) === selectedCourt) ? selectedCourt : 'todas';
            const filteredCourts = courtFilter.value === 'todas' ? data.canchas : data.canchas.filter((court) => String(court.id) === courtFilter.value);
            const duration = Number(durationSelect?.value || 1);
            courts.innerHTML = filteredCourts.map((court) => `<article class="reserva-court-card">
                <div class="reserva-court-title"><div><h3>${escapeHtml(court.nombre)}</h3><p>${escapeHtml(court.direccion || '')}</p></div><span>${court.reservas.length} reservadas</span></div>
                <div class="reserva-hours">${data.horarios.map((hour) => {
                        const start = Number(hour.slice(0, 2));
                        const end = start + duration;
                        const booking = court.reservas.find((item) => {
                            const bookingStart = Number(String(item.hora_reserva).slice(0, 2));
                            const bookingEnd = Number(String(item.hora_fin).slice(0, 2));
                            return bookingStart < end && bookingEnd > start;
                        });
                        const outsideHours = end > 22;
                        const endHour = String(Number(hour.slice(0, 2)) + 1).padStart(2, '0') + ':00';
                        const unavailable = booking || outsideHours;
                        return `<button class="reserva-hour ${unavailable ? 'is-booked' : ''}" type="button" data-location="${court.id}" data-hour="${hour}" ${unavailable ? 'disabled' : ''}><strong>${hour} - ${String(end).padStart(2, '0')}:00</strong><small>${booking ? 'No disponible' : outsideHours ? 'Fuera de horario' : 'Disponible'}</small></button>`;
                }).join('')}</div>
            </article>`).join('') || '<p class="reservas-empty">No hay canchas disponibles.</p>';
            courts.querySelectorAll('.reserva-hour:not(.is-booked)').forEach((button) => button.addEventListener('click', () => selectReservation(button.dataset.location, button.dataset.hour, button.closest('.reserva-court-card')?.querySelector('h3')?.textContent || 'Cancha')));
        } catch (error) {
            const message = escapeHtml(error.message);
            courts.innerHTML = `<p class="reservas-empty">${message}</p>`;
            if (myList) myList.innerHTML = `<p class="reservas-empty">No se pudieron cargar tus reservas: ${message}</p>`;
        }
        loading.textContent = '';
    };

    const selectReservation = (locationId, hour, courtName) => {
        const duration = Number(durationSelect?.value || 1);
        const endHour = `${String(Number(hour.slice(0, 2)) + duration).padStart(2, '0')}:00`;
        selectedReservation = { locationId, hour, duration };
        confirmationText.textContent = `${courtName} · ${dateInput.value} · ${hour} - ${endHour}`;
        confirmation.hidden = false;
        confirmation.focus({ preventScroll: true });
    };

    const reserve = async (locationId, hour, button) => {
        const duration = Number(durationSelect?.value || 1);
        const endHour = `${String(Number(hour.slice(0, 2)) + duration).padStart(2, '0')}:00:00`;
        if (button) {
            button.disabled = true;
            button.classList.add('is-saving');
            const status = button.querySelector('small');
            if (status) status.textContent = 'Guardando...';
            if (button.id === 'reservas-confirm') button.textContent = 'Guardando...';
        }
        try {
            const response = await fetch('/api/reservas', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ locacion_id: locationId, fecha_reserva: dateInput.value, hora_reserva: hour, hora_fin: endHour }) });
            const data = await response.json().catch(() => ({}));
            if (!response.ok) { showFeedback(data.error || 'No se pudo reservar. Comprueba la conexión con la base de datos.', true); return; }
            showFeedback('Reserva confirmada. También puedes verla en Mapas.');
            selectedReservation = null;
            confirmation.hidden = true;
            loadAvailability();
        } catch (error) {
            showFeedback('No se pudo conectar con el servidor. Inténtalo de nuevo.', true);
        } finally {
            if (button && button.isConnected && !button.classList.contains('is-booked')) {
                button.disabled = false;
                button.classList.remove('is-saving');
                if (button.id === 'reservas-confirm') button.textContent = 'Enviar reserva';
            }
        }
    };

    const renderCalendar = () => {
        const selected = new Date(`${dateInput.value}T12:00:00`);
        const year = selected.getFullYear();
        const month = selected.getMonth();
        const first = new Date(year, month, 1);
        const days = new Date(year, month + 1, 0).getDate();
        const start = (first.getDay() + 6) % 7;
        calendar.innerHTML = `<div class="calendar-month"><button type="button" data-month="-1">&lsaquo;</button><strong>${selected.toLocaleDateString('es-CO', { month: 'long', year: 'numeric' })}</strong><button type="button" data-month="1">&rsaquo;</button></div><div class="calendar-weekdays">${['L', 'M', 'X', 'J', 'V', 'S', 'D'].map((day) => `<span>${day}</span>`).join('')}</div><div class="calendar-days">${Array.from({ length: start }, () => '<span></span>').join('')}${Array.from({ length: days }, (_, index) => { const day = index + 1; const value = isoDate(new Date(year, month, day)); return `<button type="button" class="${value === dateInput.value ? 'is-selected' : ''}" data-date="${value}">${day}</button>`; }).join('')}</div>`;
        calendar.querySelectorAll('[data-date]').forEach((button) => button.addEventListener('click', () => { dateInput.value = button.dataset.date; renderCalendar(); loadAvailability(); }));
        calendar.querySelectorAll('[data-month]').forEach((button) => button.addEventListener('click', () => { const next = new Date(year, month + Number(button.dataset.month), 1); dateInput.value = isoDate(next); renderCalendar(); loadAvailability(); }));
    };

    dateInput.addEventListener('change', () => { renderCalendar(); loadAvailability(); });
    courtFilter?.addEventListener('change', loadAvailability);
    durationSelect?.addEventListener('change', loadAvailability);
    confirmButton?.addEventListener('click', () => {
        if (!selectedReservation) return;
        confirmButton.disabled = true;
        reserve(selectedReservation.locationId, selectedReservation.hour, confirmButton).finally(() => { confirmButton.disabled = false; });
    });
    backButton?.addEventListener('click', () => {
        selectedReservation = null;
        confirmation.hidden = true;
        const availableButton = courts.querySelector('.reserva-hour:not(.is-booked)');
        availableButton?.focus({ preventScroll: true });
    });
    myToggle?.addEventListener('click', () => {
        const collapsed = myList.classList.toggle('is-collapsed');
        myToggle.setAttribute('aria-expanded', String(!collapsed));
        myToggle.innerHTML = `<i class="fa-solid fa-chevron-${collapsed ? 'down' : 'up'}"></i>`;
    });
    document.getElementById('reservas-today')?.addEventListener('click', () => { dateInput.value = isoDate(today); renderCalendar(); loadAvailability(); });
    renderCalendar();
    loadAvailability();
})();

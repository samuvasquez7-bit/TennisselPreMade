/**
 * TENNISSEL 2.0 - Sistema Interactivo de Catálogo, Carrito y Filtros
 * Ubicación: static/js/carrito.js
 */

if (typeof window.carritoInitialized === 'undefined') {
    window.carritoInitialized = true;

    document.addEventListener('DOMContentLoaded', () => {
        
        // ==========================================================================
        // 1. CONTROL DE APERTURA DE MENÚS (Navbar & Perfil)
        // ==========================================================================
        const menuToggle = document.getElementById("menuToggle");
        const navbarMenu = document.getElementById("navbarMenu");
        const perfilBtn = document.getElementById("perfilBtn");
        const menuPerfil = document.getElementById("menuPerfil");
        const perfilContainer = document.getElementById("perfilContainer");

        if (menuToggle && navbarMenu && !menuToggle.dataset.menuBound) {
            menuToggle.dataset.menuBound = "true";
            menuToggle.addEventListener("click", () => {
                navbarMenu.classList.toggle("active");
                menuToggle.classList.toggle("open");
            });
        }

        if (perfilBtn && menuPerfil && !perfilBtn.dataset.perfilBound) {
            perfilBtn.dataset.perfilBound = "true";
            perfilBtn.addEventListener("click", (e) => {
                e.stopPropagation();
                menuPerfil.classList.toggle("show");
                if (perfilContainer) perfilContainer.classList.toggle("active");
            });
        }

        document.addEventListener("click", () => {
            if (menuPerfil) menuPerfil.classList.remove("show");
            if (perfilContainer) perfilContainer.classList.remove("active");
            if (navbarMenu) navbarMenu.classList.remove("active");
        });

        // ==========================================================================
        // 2. INICIALIZACIÓN Y CONFIGURACIÓN DEL CONTADOR DEL CARRITO
        // ==========================================================================
        actualizarContador();

        // Capturamos los botones de agregar al carrito con protección de duplicados
        const botonesComprar = document.querySelectorAll('.btn-agregar');
        
        botonesComprar.forEach(boton => {
            if (!boton.dataset.carritoBound) {
                boton.dataset.carritoBound = "true";
                boton.addEventListener('click', () => {
                    const id = boton.getAttribute('data-id');
                    const nombre = boton.getAttribute('data-nombre');
                    const precio = parseInt(boton.getAttribute('data-precio'));

                    const productoSeleccionado = {
                        id: id,
                        nombre: nombre,
                        precio: precio,
                        cantidad: 1
                    };

                    añadirAlLocalStorage(productoSeleccionado);
                });
            }
        });

        // ==========================================================================
        // 3. LÓGICA DE FILTRADO DINÁMICO DE PRODUCTOS
        // ==========================================================================
        const botonesFiltro = document.querySelectorAll('.filtro-btn');
        const tarjetasProductos = document.querySelectorAll('.producto-card');

        botonesFiltro.forEach(botonFiltro => {
            if (!botonFiltro.dataset.filtroBound) {
                botonFiltro.dataset.filtroBound = "true";
                botonFiltro.addEventListener('click', () => {
                    botonesFiltro.forEach(btn => btn.classList.remove('active'));
                    botonFiltro.classList.add('active');

                    const categoriaSeleccionada = botonFiltro.getAttribute('data-categoria');

                    tarjetasProductos.forEach(tarjeta => {
                        const categoriaTarjeta = tarjeta.getAttribute('data-categoria');

                        if (categoriaSeleccionada === 'Todos' || categoriaSeleccionada === categoriaTarjeta) {
                            tarjeta.style.display = 'block';
                        } else {
                            tarjeta.style.display = 'none';
                        }
                    });
                });
            }
        });

        // ==========================================================================
        // 4. RENDERIZADO DE LA TABLA DEL CARRITO
        // ==========================================================================
        if (document.getElementById('contenedor-tabla-carrito')) {
            renderizarPaginaCarrito();
        }

        // ==========================================================================
        // 5. LÓGICA DE BÚSQUEDA EN EL NAVBAR
        // ==========================================================================
        const searchInput = document.getElementById('searchInput');
        const searchBtn = document.getElementById('searchBtn');

        if (searchInput && searchBtn && !searchBtn.dataset.searchBound) {
            searchBtn.dataset.searchBound = "true";
            searchBtn.addEventListener('click', () => {
                const query = searchInput.value.trim();
                if (query) {
                    console.log('Buscando:', query);
                }
            });

            searchInput.addEventListener('keypress', (e) => {
                if (e.key === 'Enter') {
                    searchBtn.click();
                }
            });
        }
    });
}

// ==========================================================================
// FUNCIONES GLOBALES DEL CARRITO (Se mantienen igual)
// ==========================================================================

function añadirAlLocalStorage(producto) {
    let listaCarrito = JSON.parse(localStorage.getItem('carrito')) || [];
    const productoExistente = listaCarrito.find(item => item.id === producto.id);

    if (productoExistente) {
        productoExistente.cantidad += 1;
    } else {
        listaCarrito.push(producto);
    }

    localStorage.setItem('carrito', JSON.stringify(listaCarrito));
    actualizarContador();
    alert(`¡Se ha añadido "${producto.nombre}" con éxito al carrito! 🛒`);
}

function actualizarContador() {
    const contenedorContador = document.getElementById('contador-carrito');
    
    if (contenedorContador) {
        let listaCarrito = JSON.parse(localStorage.getItem('carrito')) || [];
        const totalProductos = listaCarrito.reduce((acumulado, item) => acumulado + item.cantidad, 0);
        contenedorContador.textContent = totalProductos;
    }
}

function renderizarPaginaCarrito() {
    const tabla = document.getElementById('contenedor-tabla-carrito');
    const totalContenedor = document.getElementById('gran-total-carrito');
    
    let carrito = JSON.parse(localStorage.getItem('carrito')) || [];

    if (carrito.length === 0) {
        tabla.innerHTML = `
            <div class="text-center py-5">
                <p class="text-muted fs-5">No tienes productos seleccionados todavía.</p>
                <a href="/productos" class="btn-productos-volver">Ver Catálogo de Productos</a>
            </div>
        `;
        if (totalContenedor) totalContenedor.innerText = "$0";
        return;
    }

    let htmlGenerado = '';
    let sumaGranTotal = 0;

    carrito.forEach(item => {
        let subtotal = item.precio * item.cantidad;
        sumaGranTotal += subtotal;

        htmlGenerado += `
            <div class="carrito-item">
                <div class="carrito-info">
                    <h5>${item.nombre}</h5>
                    <small>Precio unitario: $${item.precio.toLocaleString('es-CO')}</small>
                </div>
                
                <div class="carrito-cantidad">
                    <button class="btn-cantidad" onclick="cambiarCantidad('${item.id}', -1)">-</button>
                    <span class="cantidad-numero">${item.cantidad}</span>
                    <button class="btn-cantidad" onclick="cambiarCantidad('${item.id}', 1)">+</button>
                </div>

                <div class="carrito-acciones">
                    <span class="subtotal-precio">$${subtotal.toLocaleString('es-CO')}</span>
                    <button class="btn-eliminar" onclick="eliminarDelCarrito('${item.id}')">🗑️</button>
                </div>
            </div>
        `;
    });

    tabla.innerHTML = htmlGenerado;
    if (totalContenedor) {
        totalContenedor.innerText = '$' + sumaGranTotal.toLocaleString('es-CO');
    }
}

function cambiarCantidad(id, cambio) {
    let carrito = JSON.parse(localStorage.getItem('carrito')) || [];
    const producto = carrito.find(item => item.id === id);

    if (producto) {
        producto.cantidad += cambio;
        if (producto.cantidad <= 0) {
            carrito = carrito.filter(item => item.id !== id);
        }
    }

    localStorage.setItem('carrito', JSON.stringify(carrito));
    actualizarContador();
    renderizarPaginaCarrito();
}

function eliminarDelCarrito(id) {
    let carrito = JSON.parse(localStorage.getItem('carrito')) || [];
    carrito = carrito.filter(item => item.id !== id);
    
    localStorage.setItem('carrito', JSON.stringify(carrito));
    actualizarContador();
    renderizarPaginaCarrito();
}

function vaciarCarritoCompleto() {
    if (confirm('¿Seguro que deseas remover todos los productos del carrito?')) {
        localStorage.removeItem('carrito');
        actualizarContador();
        renderizarPaginaCarrito();
    }
}

function procesarPagoFinal() {
    alert('Redireccionando a la pasarela de pago seguro de TENNISSEL... ¡Gracias por tu compra!');
    localStorage.removeItem('carrito');
    window.location.href = '/';
}

// Control robusto del menú hamburguesa
const menuToggle = document.getElementById('menuToggle');
const navbarMenu = document.getElementById('navbarMenu');

if (menuToggle && navbarMenu) {
    menuToggle.addEventListener('click', function(e) {
        e.stopPropagation();
        navbarMenu.classList.toggle('active');
        menuToggle.classList.toggle('active');
    });

    // Cerrar al hacer clic fuera
    document.addEventListener('click', function(e) {
        if (!navbarMenu.contains(e.target) && !menuToggle.contains(e.target)) {
            navbarMenu.classList.remove('active');
            menuToggle.classList.remove('active');
        }
    });
}
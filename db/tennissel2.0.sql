-- ===== tennissel2.0.sql =====
CREATE DATABASE IF NOT EXISTS `tennissel20` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE `tennissel20`;

-- ============================================================
-- 1. TABLA DE USUARIOS
-- ============================================================
CREATE TABLE IF NOT EXISTS `usuarios` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `username` VARCHAR(50) NOT NULL UNIQUE,
  `nombre_completo` VARCHAR(255) DEFAULT NULL,
  `email` VARCHAR(100) NOT NULL UNIQUE,
  `telefono` VARCHAR(20) DEFAULT NULL,
  `ciudad` VARCHAR(100) DEFAULT NULL,
  `password` VARCHAR(255) NOT NULL,
    `rol` ENUM('admin', 'cliente', 'visita', 'premium', 'jugador', 'profesor', 'tienda') DEFAULT 'cliente',
    `baneado` BOOLEAN NOT NULL DEFAULT FALSE,
    `motivo_baneo` VARCHAR(255) DEFAULT NULL,
    `evidencia_baneo` TEXT DEFAULT NULL,
    `locacion_baneo` INT DEFAULT NULL,
    `fecha_baneo` DATETIME DEFAULT NULL,
  `fecha_creacion` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 2. TABLA DE PERFILES DE JUGADOR
-- ============================================================
CREATE TABLE IF NOT EXISTS `perfil_usuario` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `usuario_id` INT NOT NULL UNIQUE,
    `apellido` VARCHAR(50) DEFAULT NULL,
    `foto` VARCHAR(255) DEFAULT 'default.png',
    `fecha_nacimiento` DATE DEFAULT NULL,
    `nivel` ENUM('principiante', 'intermedio', 'avanzado', 'profesional') DEFAULT 'principiante',
    `mano` ENUM('diestro', 'zurdo', 'ambidiestro') DEFAULT 'diestro',
    `reves` ENUM('una_mano', 'dos_manos') DEFAULT 'dos_manos',
    `club` VARCHAR(100) DEFAULT NULL,
    `biografia` TEXT,
    `ubicacion_texto` VARCHAR(255) DEFAULT NULL,
    `lat` DECIMAL(10,7) DEFAULT NULL,
    `lng` DECIMAL(10,7) DEFAULT NULL,
    `compartir` BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (`usuario_id`) REFERENCES `usuarios`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 3. TABLA PREMIUM (faltante)
-- ============================================================
CREATE TABLE IF NOT EXISTS `premium` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `plan` VARCHAR(50) NOT NULL,
    `fecha_inicio` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `usuarios`(`id`) ON DELETE CASCADE,
    UNIQUE KEY `unique_user_premium` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- 4. TABLAS DE SOLICITUDES Y SOPORTE TÉCNICO
-- ============================================================
CREATE TABLE IF NOT EXISTS `solicitudes_contacto` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `usuario_id` INT NULL,
    `nombre` VARCHAR(100) NOT NULL,
    `correo` VARCHAR(100) NOT NULL,
    `motivo` VARCHAR(50) NOT NULL, 
    `mensaje` TEXT NOT NULL,
    `fecha_envio` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `respuesta` TEXT DEFAULT NULL,
    `fecha_respuesta` TIMESTAMP NULL DEFAULT NULL,
    `admin_id` INT DEFAULT NULL,
    `leido_por_usuario` BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (`usuario_id`) REFERENCES `usuarios`(`id`) ON DELETE SET NULL,
    FOREIGN KEY (`admin_id`) REFERENCES `usuarios`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `soporte_tecnico` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `usuario_id` INT NOT NULL,
    `motivo` VARCHAR(100) NOT NULL,
    `mensaje` TEXT NOT NULL,
    `fecha_envio` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `respuesta` TEXT DEFAULT NULL,
    `fecha_respuesta` TIMESTAMP NULL DEFAULT NULL,
    `admin_id` INT DEFAULT NULL,
    FOREIGN KEY (`usuario_id`) REFERENCES `usuarios`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`admin_id`) REFERENCES `usuarios`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================
-- RESETEO Y RECREACIÓN DE TABLAS DE ENTRENAMIENTO
-- ============================================================
DROP TABLE IF EXISTS rutinas_entrenamiento;
DROP TABLE IF EXISTS ejercicios;

CREATE TABLE ejercicios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    categoria VARCHAR(50),
    dificultad VARCHAR(20) DEFAULT 'Intermedio'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE rutinas_entrenamiento (
    id INT AUTO_INCREMENT PRIMARY KEY,
    dia_semana VARCHAR(20) NOT NULL,       
    tipo_usuario VARCHAR(20) NOT NULL,    
    titulo_rutina VARCHAR(150) NOT NULL,
    objetivo TEXT NOT NULL,               
    consejo_entrenador TEXT,              
    ejercicio_id INT,
    series_repeticiones VARCHAR(50),
    duracion_minutos INT,
    calorias_estimadas INT,               
    imagen_url VARCHAR(255) DEFAULT NULL,
    FOREIGN KEY (ejercicio_id) REFERENCES ejercicios(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO ejercicios (id, nombre, descripcion, categoria, dificultad) VALUES 
(1, 'Sombra Mecánica de Golpes', 'Repetición técnica de derecha y revés cruzado analizando plano de impacto.', 'Técnica', 'Principiante'),
(2, 'Footwork en Escalera y Conos', 'Coordinación de apoyos cortos en Split-Step y cambio de dirección explosivo.', 'Físico', 'Intermedio'),
(3, 'Servicio Angular a Puntos Ciegos', 'Colocación táctica de saques planos y cortados buscando vértices.', 'Técnica Avanzada', 'Avanzado'),
(4, 'Recuperación Activa Miofascial', 'Descompresión articular y estiramientos guiados con bandas y rodillo.', 'Recuperación', 'Principiante'),
(5, 'Simulación Táctica Tie-Break', 'Puntos simulados con penalización de tiempo y presión por errores.', 'Competencia', 'Élite'),
(6, 'Ataque de Bola Corta y Volea', 'Transición rápida de línea de fondo a la red tras golpe de aproximación.', 'Táctica', 'Intermedio'),
(7, 'Fuerza Explosiva e Isometría', 'Rutina de tren inferior con saltos pliométricos y sentadillas búlgaras.', 'Físico', 'Avanzado'),
(8, 'Defensa Profunda y Globos Tácticos', 'Devolución de bolas pesadas en zona defensiva con bolas altas.', 'Táctica', 'Intermedio'),
(9, 'Cadena Biomecánica de Saque', 'Optimización del impulso piernas-cadera-hombro para aumentar velocidad.', 'Técnica Avanzada', 'Élite'),
(10, 'Aceleración Lateral y Side-Steps', 'Desplazamiento horizontal continuo en línea de fondo.', 'Físico', 'Intermedio'),
(11, 'Voleas Reactivas en Corta Distancia', 'Pared de voleas a alta velocidad trabajando tiempo de reacción.', 'Técnica', 'Avanzado'),
(12, 'Control de Resto sobre Primer Saque', 'Bloqueo de restes agresivos acortando la preparación de raqueta.', 'Táctica', 'Élite'),
(13, 'Movilidad Articular de Hombros y Caderas', 'Liberación de cápsula articular con flexibilidad dinámica.', 'Recuperación', 'Principiante'),
(14, 'Combinaciones Combinadas de Drive', 'Patrón de 3 golpes: Drive profundo, revés paralelo y remate.', 'Táctica Avanzada', 'Élite');

INSERT INTO rutinas_entrenamiento (dia_semana, tipo_usuario, titulo_rutina, objetivo, consejo_entrenador, ejercicio_id, series_repeticiones, duracion_minutos, calorias_estimadas, imagen_url) VALUES 
-- LUNES
('Lunes', 'free', 'Acondicionamiento y Base Técnica', 'Establecer la memoria muscular de la raqueta y activación aeróbica inicial.', 'Mantén el codo alineado y relajado en el acompañamiento.', 1, '3 series de 15 reps', 35, 280, 'IMG/entreno_1.jpeg'),
('Lunes', 'premium', 'Aceleración Positiva y Transición a la Red', 'Desarrollar la agresividad atacando bolas cortas con volea decisiva.', 'Transfiere el peso del cuerpo hacia adelante antes del impacto.', 6, '5 series de 10 reps', 50, 480, 'IMG/entrenop_1.jpeg'),

-- MARTES
('Martes', 'free', 'Agilidad y Velocidad en Línea de Fondo', 'Mejorar el tiempo de llegada a bolas abiertas y el freno en Split-Step.', 'No cruces los pies al desplazarte de lado.', 2, '4 series de 1 min', 30, 320, 'IMG/entreno_2.jpeg'),
('Martes', 'premium', 'Servicio Mecánico y Potencia Angular', 'Incrementar porcentaje de primeros saques por encima del 65% con peso.', 'Visualiza la trayectoria de la bola antes de la elevación.', 9, '5 series de 20 saques', 55, 510, 'IMG/entrenop_2.jpeg'),

-- MIÉRCOLES
('Miércoles', 'free', 'Construcción de Punto y Control Lateral', 'Desarrollar consistencia en peloteos largos de más de 10 golpes.', 'Busca 1 metro por encima de la red para ganar profundidad.', 10, '4 series de 12 reps', 35, 300, 'IMG/entreno_3.jpeg'),
('Miércoles', 'premium', 'Dominio de Red y Voleas Reactivas', 'Reforzar la capacidad de reacción en intercambios rápidos en la red.', 'Corta el swing tras el impacto, no hagas armado largo.', 11, '6 series de 30 seg', 45, 430, 'IMG/entrenop_3.jpeg'),

-- JUEVES
('Jueves', 'free', 'Resistencia Físico-Táctica Defensiva', 'Sostener la defensa contra jugadores agresivos desde el fondo.', 'Usa empuñadura neutra cuando estés fuera de posición.', 8, '4 series de 10 reps', 40, 360, 'IMG/entreno_4.jpeg'),
('Jueves', 'premium', 'Potenciación Pliométrica e Impacto', 'Generar torque máximo con la cadera en golpes en carrera.', 'Exhala con fuerza en el punto exacto de contacto.', 7, '5 series de 8 reps', 50, 520, 'IMG/entrenop_4.jpeg'),

-- VIERNES
('Viernes', 'free', 'Consolidación de Patrones de Golpeo', 'Repaso técnico sin exigencia cardiovascular excesiva.', 'Analiza tus ángulos de salida de raqueta frente al espejo.', 1, '3 series de 15 reps', 30, 250, 'IMG/entreno_5.jpeg'),
('Viernes', 'premium', 'Devolución de Saque y Ataque al Resto', 'Neutralizar servicios potentes neutralizando el segundo saque rival.', 'Adelanta el Split-Step 1 metro dentro de la línea.', 12, '5 series de 12 restos', 45, 460, 'IMG/entrenop_5.jpeg'),

-- SÁBADO
('Sábado', 'free', 'Sombra Táctica y Flexibilidad en Pista', 'Mantener movilidad muscular y ritmo sin impacto destructivo.', 'No fuerces articulaciones frías en la mañana.', 4, '3 series de 10 reps', 25, 190, 'IMG/entreno_6.jpeg'),
('Sábado', 'premium', 'Simulación de Situaciones Críticas de Partido', 'Manejo de la presión mental en Tie-Breaks y Break-Points.', 'Controla tu frecuencia cardíaca entre punto y punto.', 5, '4 sets de 12 min', 65, 680, 'IMG/entrenop_6.jpeg'),

-- DOMINGO
('Domingo', 'free', 'Descanso Activo y Flexibilidad General', 'Remover el ácido láctico acumulado durante la semana.', 'Mantén una hidratación constante durante el día.', 13, '1 sesión general', 20, 140, 'IMG/entreno_7.jpeg'),
('Domingo', 'premium', 'Liberación Miofascial y Carga Metabólica', 'Regeneración tisular con rodillo de espuma y estiramiento asistido.', 'Aplica respiración diafragmática para bajar el cortisol.', 4, '1 sesión guiada', 40, 230, 'IMG/entrenop_7.png');
-- ============================================================
-- 6. TABLA: CATEGORÍAS DE TIENDA
-- ============================================================
CREATE TABLE IF NOT EXISTS categorias (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    icono VARCHAR(50) DEFAULT 'fa-tag',
    orden INT DEFAULT 0,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO categorias (nombre, slug, descripcion, orden) VALUES
('Raquetas', 'raquetas', 'Raquetas profesionales de alto rendimiento', 1),
('Pelotas y Grip', 'pelotas-grip', 'Pelotas, overgrips y accesorios de agarre', 2),
('Maletines y Ropa', 'maletines-ropa', 'Equipamiento deportivo y vestimenta', 3),
('Tecnología', 'tecnologia', 'Gadgets inteligentes para tenis', 4)
ON DUPLICATE KEY UPDATE nombre=nombre;

-- ============================================================
-- 7. TABLA: PRODUCTOS 
-- ============================================================
CREATE TABLE IF NOT EXISTS productos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    owner_user_id INT NULL,
    nombre VARCHAR(150) NOT NULL,
    slug VARCHAR(150) NOT NULL UNIQUE,
    descripcion_corta VARCHAR(255),
    descripcion_larga TEXT,
    categoria_id INT NOT NULL,
    subcategoria VARCHAR(100) DEFAULT NULL,
    marca VARCHAR(50),
    color VARCHAR(50) DEFAULT NULL,
    talla VARCHAR(50) DEFAULT NULL,
    precio DECIMAL(12, 2) NOT NULL,
    precio_anterior DECIMAL(12, 2),
    stock INT NOT NULL DEFAULT 0,
    sku VARCHAR(50) UNIQUE,
    imagen_principal VARCHAR(255) DEFAULT 'default-product.jpg',
    imagenes JSON,
    video_url VARCHAR(255),
    especificaciones JSON,
    peso DECIMAL(6,2),
    destacado BOOLEAN DEFAULT FALSE,
    badge VARCHAR(50),
    activo BOOLEAN DEFAULT TRUE,
    visitas INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO productos (nombre, slug, descripcion_corta, descripcion_larga, categoria_id, subcategoria, marca, color, talla, precio, precio_anterior, stock, sku, imagen_principal, badge, destacado, especificaciones) VALUES
('Wilson Pro Classic', 'wilson-pro-classic', 'Diseño tradicional de precisión con marco de carbono.', 'Diseño tradicional de precisión con marco de carbono de alto módulo y un balance ideal para golpes controlados. Perfecta para jugadores intermedios y avanzados.', 1, 'Raquetas', 'Wilson', 'Negro', 'L3', 620000, 750000, 15, 'WIL-PRO-001', 'produ1.jfif', 'Clásica', FALSE, '{"peso": "300g", "cabeza": "100 in²"}'),
('Head Extreme Neon', 'head-extreme-neon', 'Marco aerodinámico optimizado para spin explosivo.', 'Marco aerodinámico optimizado para generar un spin explosivo y una velocidad de swing inigualable. Color neón exclusivo.', 1, 'Raquetas', 'Head', 'Verde Neón', 'L2', 695000, NULL, 8, 'HEAD-EXT-002', 'produ2.jfif', 'Élite', TRUE, '{"peso": "285g", "cabeza": "100 in²"}'),
('Overgrip Artengo Tacky', 'overgrip-artengo-tacky', 'Absorción máxima de sudor y textura microperforada.', 'Absorción máxima de sudor y textura microperforada para evitar cualquier deslizamiento durante el juego.', 2, 'Accesorios', 'Artengo', 'Negro', 'Única', 15000, NULL, 200, 'ART-OVG-003', 'produ3.jfif', NULL, FALSE, '{"material": "Poliuretano"}'),
('Pelotas Champ Tour (x3)', 'pelotas-champ-tour-x3', 'Fieltro de alta visibilidad y núcleo reforzado.', 'Fieltro de alta visibilidad y núcleo de presión reforzado para un rebote consistente en canchas duras.', 2, 'Pelotas', 'Champ', 'Amarillo', 'Única', 24000, 28000, 150, 'CHAMP-3PK-004', 'produ4.jfif', NULL, FALSE, '{"cantidad": "3 unidades"}'),
('Wilson Team Edition (x4)', 'wilson-team-edition-x4', 'Pelotas aprobadas por la ITF. Máxima durabilidad.', 'Pelotas aprobadas por la ITF. Máxima durabilidad en todo tipo de superficies de juego. Pack de 4 unidades.', 2, 'Pelotas', 'Wilson', 'Amarillo', 'Única', 32000, 38000, 80, 'WIL-TEAM-005', 'produ5.jfif', 'Top Ventas', TRUE, '{"cantidad": "4 unidades"}'),
('Shorts Pro Dry-Fit', 'shorts-pro-dryfit', 'Tela ultraligera con bolsillos para pelotas.', 'Tela ultraligera con bolsillos profundos diseñados específicamente para guardar pelotas con comodidad. Tecnología Dry-Fit.', 3, 'Ropa', 'TENNISSEL', 'Negro/Azul', 'M', 85000, NULL, 45, 'TNS-SRT-006', 'produ6.jfif', NULL, FALSE, '{"material": "Poliéster Dry-Fit"}'),
('Morral Tour Pack 2.0', 'morral-tour-pack-2', 'Compartimento aislado para zapatillas y espacio para raquetas.', 'Incluye compartimento aislado para zapatillas, espacio trasero para raquetas y bolsillos térmicos laterales.', 3, 'Accesorios', 'TENNISSEL', 'Negro', 'Única', 175000, 210000, 20, 'TNS-MOR-007', 'produ7.jfif', 'Completo', FALSE, '{"capacidad": "2 raquetas"}'),
('Wilson Super Tour 9R', 'wilson-super-tour-9r', 'Raquetero premium con revestimiento Thermoguard.', 'Raquetero premium con revestimiento Thermoguard para proteger hasta 9 raquetas de temperaturas extremas.', 3, 'Accesorios', 'Wilson', 'Rojo', 'Única', 420000, 490000, 12, 'WIL-9R-008', 'produ8.jfif', 'Exclusivo', TRUE, '{"capacidad": "9 raquetas"}'),
('Tennibot Partner Smart', 'tennibot-partner-smart', 'Lanzapelotas robotizado con control por app.', 'Lanzapelotas robotizado con control de velocidad, efectos de top-spin y oscilación programable por app.', 4, 'Tecnología', 'Tennibot', 'Blanco', 'Única', 2450000, 2800000, 3, 'TNB-SMART-009', 'produ9.jfif', 'Tecnología', TRUE, '{"velocidad": "10-120 km/h"}'),
('Babolat Pure Aero 2024', 'babolat-pure-aero-2024', 'La raqueta insignia para jugadores de spin.', 'La raqueta insignia para jugadores de spin. Marco aerodinámico con tecnología FSI Spin para un control superior.', 1, 'Raquetas', 'Babolat', 'Amarillo/Negro', 'L3', 720000, 850000, 10, 'BAB-AERO-010', 'produ10.jfif', 'Nueva', TRUE, '{"peso": "300g"}'),
('Yonex EZONE 98', 'yonex-ezone-98', 'Tecnología Isométrica que amplía el punto dulce.', 'Tecnología Isométrica que amplía el punto dulce. Potencia y precisión en cada golpe con absorción de vibraciones.', 1, 'Raquetas', 'Yonex', 'Azul', 'L2', 780000, 920000, 7, 'YNX-EZONE-011', 'produ11.jfif', 'Premium', TRUE, '{"peso": "305g"}'),
('Pelotas Head ATP Tour (x6)', 'pelotas-head-atp-tour-x6', 'Pelotas oficiales del circuito ATP. Pack de 6.', 'Pelotas oficiales del circuito ATP. Fieltro premium con rebote uniforme, ideales para competición de alto nivel.', 2, 'Pelotas', 'Head', 'Amarillo', 'Única', 48000, 55000, 60, 'HEAD-ATP-012', 'produ12.jfif', NULL, FALSE, '{"cantidad": "6 unidades"}'),
('Overgrip Wilson Pro Feel (x3)', 'overgrip-wilson-pro-feel-x3', 'Pack de 3 overgrips con tacto seco y duradero.', 'Pack de 3 overgrips con tacto seco y duradero. Máximo control incluso en partidos largos bajo altas temperaturas.', 2, 'Accesorios', 'Wilson', 'Blanco', 'Única', 28000, 35000, 120, 'WIL-OVG-013', 'produ13.jfif', 'Top Ventas', FALSE, '{"cantidad": "3 unidades"}'),
('Kit Antivibradores Pro (x5)', 'kit-antivibradores-pro-x5', 'Set de 5 antivibradores de silicona premium.', 'Set de 5 antivibradores de silicona premium. Reducen la vibración del encordado y mejoran la sensación de golpeo.', 2, 'Accesorios', 'TENNISSEL', 'Surtidos', 'Única', 18000, NULL, 250, 'TNS-ANT-014', 'produ14.jfif', NULL, FALSE, '{"cantidad": "5 unidades"}'),
('Camiseta Performance Dry-Fit', 'camiseta-performance-dryfit', 'Tejido transpirable con protección UV 50+.', 'Tejido transpirable de secado rápido con protección UV 50+. Diseño ergonómico para libertad total de movimiento.', 3, 'Ropa', 'TENNISSEL', 'Blanco/Negro', 'L', 95000, 120000, 35, 'TNS-CAM-015', 'produ15.jfif', 'Nuevo', FALSE, '{"material": "Poliéster Dry-Fit"}'),
('Gorra Tennissel Classic', 'gorra-tennissel-classic', 'Gorra ligera con banda interior absorbente.', 'Gorra ligera con banda interior absorbente y ajuste regulable. Protege del sol sin añadir peso durante el juego.', 3, 'Ropa', 'TENNISSEL', 'Negro', 'Única', 45000, 60000, 50, 'TNS-GOR-016', 'produ16.jfif', NULL, FALSE, '{"material": "Algodón"}'),
('Zapatillas Court Pro Clay', 'zapatillas-court-pro-clay', 'Suela espiga especializada para tierra batida.', 'Suela espiga especializada para tierra batida. Amortiguación de gel en talón y refuerzo lateral para cambios bruscos.', 3, 'Zapatillas', 'TENNISSEL', 'Blanco/Verde', '42 EUR', 320000, 380000, 18, 'TNS-ZAP-017', 'produ17.jfif', 'Élite', TRUE, '{"suela": "Espiga"}'),
('Sensor Babolat Pop', 'sensor-babolat-pop', 'Sensor que se acopla al puño de la raqueta.', 'Sensor que se acopla al puño de la raqueta. Mide potencia, efectos, tipos de golpe y porcentaje de dulce zona vía app.', 4, 'Tecnología', 'Babolat', 'Negro', 'Única', 380000, 450000, 25, 'BAB-POP-018', 'produ18.jfif', 'Smart', FALSE, '{"conectividad": "Bluetooth"}'),
('Cámara SwingVision AI', 'camara-swingvision-ai', 'Cámara con IA para análisis de partidos.', 'Cámara con IA que graba tus partidos, analiza la técnica y realiza líneas de llamada automáticas en tiempo real.', 4, 'Tecnología', 'SwingVision', 'Negro', 'Única', 1250000, 1500000, 5, 'SWV-AI-019', 'produ19.jfif', 'Pro', TRUE, '{"resolucion": "4K"}'),
('Muñequera Smart Track Pro', 'munequera-smart-track-pro', 'Wearable deportivo para monitorización en pista.', 'Wearable deportivo que monitoriza ritmo cardíaco, calorías, distancia recorrida y calidad del movimiento en pista.', 4, 'Tecnología', 'TENNISSEL', 'Negro', 'Única', 290000, 350000, 30, 'TNS-MUN-020', 'produ20.jfif', 'Wearable', FALSE, '{"sensores": "Cardíaco"}'),
('Nike Court Air Zoom Vapor Pro 2', 'nike-court-zoom-vapor-pro-2', 'Zapatillas de alto rendimiento con amortiguación Zoom Air.', 'Zapatillas ligeras y con gran capacidad de respuesta, diseñadas para deslizamientos rápidos en pista dura.', 1, 'Zapatillas', 'Nike', 'Blanco/Azul', '42 EUR', 480000, 560000, 22, 'NIK-VPR-021', 'produ21.jfif', 'Nuevo', TRUE, '{"suela": "Cancha dura"}'),
('Adidas Barricade 2024', 'adidas-barricade-2024', 'Máxima estabilidad y durabilidad para tenistas exigentes.', 'Modelo clásico renovado con sistema Geofit y suela Adiwear para resistir los partidos más intensos.', 1, 'Zapatillas', 'Adidas', 'Negro/Rojo', '43 EUR', 520000, 610000, 14, 'ADI-BAR-022', 'produ22.jfif', 'Élite', TRUE, '{"sistema": "Geofit"}'),
('Raqueta Wilson Blade 98 V8', 'wilson-blade-98-v8', 'Control supremo con tecnología FortyFeel.', 'Raqueta preferida por los profesionales que buscan flexibilidad extrema y sensación de conexión.', 1, 'Raquetas', 'Wilson', 'Verde', 'L3', 790000, 920000, 10, 'WIL-BLD-023', 'produ23.jfif', 'Top Ventas', TRUE, '{"peso": "305g"}'),
('Raqueta Head Speed MP 2024', 'head-speed-mp-2024', 'Velocidad y control manejable para jugadores versátiles.', 'Incorpora tecnología Auxetic 2.0 para una respuesta excepcional en cada impacto.', 1, 'Raquetas', 'Head', 'Blanco/Negro', 'L2', 750000, 880000, 12, 'HEA-SPD-024', 'produ24.jfif', 'Nueva', TRUE, '{"peso": "300g"}'),
('Raqueta Babolat Pure Drive', 'babolat-pure-drive', 'Potencia explosiva en cada golpe.', 'La raqueta icónica de potencia accesible y gran versatilidad para dominar desde el fondo de pista.', 1, 'Raquetas', 'Babolat', 'Azul', 'L3', 730000, 840000, 16, 'BAB-DRV-025', 'produ25.jfif', 'Clásica', TRUE, '{"peso": "300g"}'),
('Raqueta Yonex VCORE 100', 'yonex-vcore-100', 'Diseñada para efectos altos y trayectorias pronunciadas.', 'Tecnología Aero Trench que reduces la resistencia al aire.', 1, 'Raquetas', 'Yonex', 'Rojo', 'L2', 760000, 890000, 9, 'YNX-VCR-026', 'produ26.jfif', 'Premium', TRUE, '{"peso": "300g"}'),
('Raqueta Prince Textreme Tour 100', 'prince-textreme-tour-100', 'Control y estabilidad superior en carbono.', 'Estructura Textreme para minimizar la torsión y maximizar la precisión.', 1, 'Raquetas', 'Prince', 'Negro/Verde', 'L3', 640000, 720000, 8, 'PRN-TUR-027', 'produ27.jfif', NULL, FALSE, '{"peso": "310g"}'),
('Tubos Pelotas Babolat Team (x3)', 'pelotas-babolat-team-x3', 'Durabilidad y tacto excelente para entrenamiento.', 'Bote presurizado con excelente retención de presión.', 2, 'Pelotas', 'Babolat', 'Amarillo', 'Única', 26000, 30000, 100, 'BAB-PLT-028', 'produ28.jfif', NULL, FALSE, '{"cantidad": "3"}'),
('Caja Pelotas Wilson Championship', 'caja-pelotas-wilson-championship', 'Caja institucional para clubes y entrenadores.', 'Pack mayorista de 24 tubos de 3 pelotas cada uno.', 2, 'Pelotas', 'Wilson', 'Amarillo', 'Única', 580000, 680000, 5, 'WIL-CAJ-029', 'produ29.jfif', 'Oferta', TRUE, '{"cantidad": "72"}'),
('Overgrip Tourna Grip XL (x3)', 'overgrip-tourna-grip-xl', 'El overgrip legendario de alta fricción.', 'Utilizado por profesionales en el circuito mundial.', 2, 'Accesorios', 'Tourna', 'Azul', 'XL', 32000, 38000, 150, 'TRN-OVG-030', 'produ30.jfif', 'Top Ventas', FALSE, '{"cantidad": "3"}'),
('Overgrip Babolat VS Original (x3)', 'overgrip-babolat-vs-original', 'Tacto ultrafino para máxima sensibilidad.', 'Overgrip extremadamente delgado.', 2, 'Accesorios', 'Babolat', 'Blanco', 'Standard', 35000, 42000, 110, 'BAB-OVG-031', 'produ31.jfif', NULL, FALSE, '{"grosor": "0.43mm"}'),
('Antivibradores Wilson Smiley (x2)', 'antivibradores-wilson-smiley', 'Divertidos antivibradores de diseño clásico.', 'Reducen eficazmente las frecuencias.', 2, 'Accesorios', 'Wilson', 'Amarillo', 'Única', 15000, NULL, 80, 'WIL-ANT-032', 'produ32.jfif', NULL, FALSE, '{"cantidad": "2"}'),
('Funda Individual Acolchada', 'funda-individual-acolchada', 'Protección básica y transporte fácil para raqueta.', 'Funda con cremallera y correa.', 2, 'Accesorios', 'TENNISSEL', 'Negro', 'Única', 45000, 55000, 40, 'TNS-FND-033', 'produ33.jfif', NULL, FALSE, '{"material": "Nylon"}'),
('Bolsa Sport Head Core', 'bolsa-sport-head-core', 'Morral deportivo práctico para accesorios y ropa.', 'Compartimento principal amplio.', 2, 'Accesorios', 'Head', 'Rojo/Negro', 'Única', 120000, 145000, 25, 'HEA-BLS-034', 'produ34.jfif', NULL, FALSE, '{"capacidad": "25L"}'),
('Polo Nike Court Dri-FIT', 'polo-nike-court-dri-fit', 'Elegancia clásica con cuello y tecnología antitranspirante.', 'Polo transpirable.', 3, 'Ropa', 'Nike', 'Blanco', 'L', 160000, 190000, 30, 'NIK-POL-035', 'produ35.jfif', 'Nuevo', FALSE, '{"material": "Poliéster"}'),
('Falda Nike Court Victory', 'falda-nike-court-victory', 'Falda con shorts internos integrados de gran comodidad.', 'Diseño plisado ligero.', 3, 'Ropa', 'Nike', 'Negro', 'M', 150000, 180000, 20, 'NIK-FLD-036', 'produ36.jfif', 'Nuevo', FALSE, '{"shorts": "Sí"}'),
('Short Adidas Club 3-Stripes', 'short-adidas-club-3-stripes', 'Short clásico de entrenamiento con bolsillos hondos.', 'Cintura elástica.', 3, 'Ropa', 'Adidas', 'Azul marino', 'L', 110000, 135000, 35, 'ADI-SRT-037', 'produ37.jfif', NULL, FALSE, '{"material": "AEROREADY"}'),
('Camiseta Adidas Freelift', 'camiseta-adidas-freelift', 'Diseño especial que evita que la prenda se suba al sacar.', 'Patrón ergonómico.', 3, 'Ropa', 'Adidas', 'Gris', 'L', 130000, 155000, 28, 'ADI-CAM-038', 'produ38.jfif', NULL, FALSE, '{"corte": "Atlético"}'),
('Medias de Compresión Pro (Pack x3)', 'medias-comppresion-pro-x3', 'Soporte muscular y prevención de fatiga en pantorrillas.', 'Tejido graduado.', 3, 'Ropa', 'TENNISSEL', 'Blanco', 'M', 55000, 70000, 60, 'TNS-MED-039', 'produ39.jfif', NULL, FALSE, '{"cantidad": "3 pares"}'),
('Visera Deportiva Wilson', 'visera-deportiva-wilson', 'Visera ultraligera con banda de rizo antitranspirante.', 'Protección solar.', 3, 'Ropa', 'Wilson', 'Rojo', 'Única', 42000, 50000, 45, 'WIL-VSR-040', 'produ40.jfif', NULL, FALSE, '{"material": "Poliéster"}'),
('Chaqueta Térmica de Warm-up', 'chaqueta-termica-warm-up', 'Chaqueta ligera de calentamiento con cremallera completa.', 'Ideal para mantener temperatura.', 3, 'Ropa', 'TENNISSEL', 'Negro', 'L', 220000, 260000, 15, 'TNS-CHQ-041', 'produ41.jfif', 'Élite', FALSE, '{"material": "Softshell"}'),
('Pantaloneta Térmica de Compresión', 'pantaloneta-termica-compresion', 'Short interior de compresión para usar bajo la falda o short.', 'Soporte muscular.', 3, 'Ropa', 'TENNISSEL', 'Negro', 'M', 75000, 90000, 25, 'TNS-PTC-042', 'produ42.jfif', NULL, FALSE, '{"material": "Elastano"}'),
('Cuerda Wilson NXT Power 16', 'cuerda-wilson-nxt-power-16', 'Multi-filamento de altísima comodidad y potencia.', 'Tripa sintética.', 2, 'Accesorios', 'Wilson', 'Natural', 'Única', 65000, 78000, 40, 'WIL-CRD-043', 'produ43.jfif', 'Premium', FALSE, '{"calibre": "1.30mm"}'),
('Cuerda Babolat RPM Blast 16', 'cuerda-babolat-rpm-blast-16', 'Monofilamento octogonal para efectos máximos.', 'Efectos letales.', 2, 'Accesorios', 'Babolat', 'Negro', 'Única', 70000, 85000, 50, 'BAB-CRD-044', 'produ44.jfif', 'Top Ventas', FALSE, '{"calibre": "1.30mm"}'),
('Antivibrador de Gusano Long Vibra', 'antivibrador-gusano-long-vibra', 'Antivibrador alargado que cubre más cuerdas principales.', 'Máxima reducción.', 2, 'Accesorios', 'TENNISSEL', 'Azul', 'Única', 12000, NULL, 90, 'TNS-ANT-045', 'produ45.jfif', NULL, FALSE, '{"material": "Silicona"}'),
('Toalla de Microfibra Deportiva', 'toalla-microfibra-deportiva', 'Toalla de secado rápido con gancho de transporte.', 'Secado rápido.', 3, 'Accesorios', 'TENNISSEL', 'Azul', 'Única', 38000, 48000, 55, 'TNS-TOA-046', 'produ46.jfif', NULL, FALSE, '{"dimensiones": "80x40"}'),
('Gafas de Sol Deportivas Polarizadas', 'gafas-sol-deportivas-polarizadas', 'Gafas con protección UV400 y lentes anti-reflejo.', 'Protección UV400.', 3, 'Accesorios', 'TENNISSEL', 'Negro/Verde', 'Única', 180000, 220000, 18, 'TNS-GFS-047', 'produ47.jfif', 'Nuevo', FALSE, '{"lentes": "Polarizados"}'),
('Muñequera Elastizada Tennissel (Par)', 'munequera-elastizada-tennissel-par', 'Par de muñequeras de alta absorción de rizo de algodón.', 'Absorción alta.', 3, 'Ropa', 'TENNISSEL', 'Blanco', 'Única', 22000, 28000, 120, 'TNS-MNQ-048', 'produ48.jfif', NULL, FALSE, '{"material": "Algodón"}'),
('Cinta Antideslizante para Mango (Rollos x10)', 'cinta-antideslizante-mango-x10', 'Pack de 10 rollos de reemplazo base para empuñaduras.', 'Renueva el mango.', 2, 'Accesorios', 'TENNISSEL', 'Negro', 'Standard', 95000, 115000, 22, 'TNS-GRP-049', 'produ49.jfif', NULL, FALSE, '{"cantidad": "10"}'),
('Botella Térmica Acero Inoxidable 1L', 'botella-termica-acero-inoxidable-1l', 'Mantiene tus bebidas frías hasta por 24 horas en pista.', 'Frío 24 horas.', 3, 'Accesorios', 'TENNISSEL', 'Verde', '1 Litro', 85000, 105000, 40, 'TNS-BOT-050', 'produ50.jfif', 'Top Ventas', FALSE, '{"material": "Acero"}');

-- ============================================================
-- 8. TABLA PREGUNTAS FRECUENTES (faltante)
-- ============================================================
CREATE TABLE IF NOT EXISTS preguntas_frecuentes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    producto_id INT NOT NULL,
    usuario_id INT DEFAULT NULL,
    pregunta TEXT NOT NULL,
    respuesta TEXT,
    aprobada BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS preguntas_frecuentes_valoraciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pregunta_id INT NOT NULL,
    usuario_id INT NOT NULL,
    calificacion TINYINT NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY valoracion_unica (pregunta_id, usuario_id),
    FOREIGN KEY (pregunta_id) REFERENCES preguntas_frecuentes(id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS producto_valoraciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    producto_id INT NOT NULL,
    usuario_id INT NOT NULL,
    calificacion TINYINT NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY valoracion_producto_usuario (producto_id, usuario_id),
    FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Preguntas iniciales administradas para productos que todavía no tienen FAQ.
INSERT INTO preguntas_frecuentes (producto_id, pregunta, respuesta, aprobada)
SELECT p.id, '¿Este producto tiene garantía?', 'Sí, aplica la garantía indicada por el fabricante.', 1
FROM productos p
WHERE NOT EXISTS (
    SELECT 1 FROM preguntas_frecuentes pf
    WHERE pf.producto_id = p.id AND pf.pregunta = '¿Este producto tiene garantía?'
);

INSERT INTO preguntas_frecuentes (producto_id, pregunta, respuesta, aprobada)
SELECT p.id, '¿Cómo puedo saber si hay stock?', 'La disponibilidad se actualiza en la ficha del producto.', 1
FROM productos p
WHERE NOT EXISTS (
    SELECT 1 FROM preguntas_frecuentes pf
    WHERE pf.producto_id = p.id AND pf.pregunta = '¿Cómo puedo saber si hay stock?'
);

-- ============================================================
-- 9. TABLA: CARRITO DE COMPRAS
-- ============================================================
CREATE TABLE IF NOT EXISTS carrito (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE CASCADE,
    UNIQUE KEY unique_carrito_item (usuario_id, producto_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ordenes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    numero_orden VARCHAR(20) NOT NULL UNIQUE,

    estado ENUM(
        'pendiente',
        'pagado',
        'en_proceso',
        'enviado',
        'entregado',
        'cancelado'
    ) DEFAULT 'pendiente',

    subtotal DECIMAL(12, 2) NOT NULL,
    envio DECIMAL(12, 2) DEFAULT 0,
    descuento DECIMAL(12, 2) DEFAULT 0,
    total DECIMAL(12, 2) NOT NULL,

    direccion_envio TEXT,
    ciudad_envio VARCHAR(50),
    telefono_envio VARCHAR(20),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id)
        ON DELETE RESTRICT
) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS orden_items (
    id INT AUTO_INCREMENT PRIMARY KEY,

    orden_id INT NOT NULL,
    producto_id INT NOT NULL,

    nombre_producto VARCHAR(150) NOT NULL,
    cantidad INT NOT NULL,

    precio_unitario DECIMAL(12, 2) NOT NULL,
    subtotal DECIMAL(12, 2) NOT NULL,

    FOREIGN KEY (orden_id)
        REFERENCES ordenes(id)
        ON DELETE CASCADE,

    FOREIGN KEY (producto_id)
        REFERENCES productos(id)
        ON DELETE RESTRICT
) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;


CREATE TABLE IF NOT EXISTS pagos (
    id INT AUTO_INCREMENT PRIMARY KEY,

    orden_id INT,
    usuario_id INT NOT NULL,

    monto DECIMAL(12, 2) NOT NULL,

    metodo ENUM(
        'tarjeta',
        'transferencia',
        'efecty',
        'nequi',
        'daviplata',
        'paypal'
    ) NOT NULL,

    estado ENUM(
        'pendiente',
        'completado',
        'fallido',
        'reembolsado'
    ) DEFAULT 'pendiente',

    referencia_pago VARCHAR(100),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (orden_id)
        REFERENCES ordenes(id)
        ON DELETE SET NULL,

    FOREIGN KEY (usuario_id)
        REFERENCES usuarios(id)
        ON DELETE RESTRICT
) ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 11. RESEÑAS Y FAVORITOS
-- ============================================================
CREATE TABLE IF NOT EXISTS resenas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    producto_id INT NOT NULL,
    usuario_id INT NOT NULL,
    calificacion INT NOT NULL,
    comentario TEXT,
    aprobada BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS favoritos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    producto_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE CASCADE,
    UNIQUE KEY unique_favorito (usuario_id, producto_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 12. FACTURAS
-- ============================================================
CREATE TABLE IF NOT EXISTS facturas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(12,2) NOT NULL DEFAULT 0,
    estado VARCHAR(20) DEFAULT 'pagado',
    metodo_pago VARCHAR(50) DEFAULT 'tarjeta',
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS detalle_factura (
    id INT AUTO_INCREMENT PRIMARY KEY,
    factura_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL DEFAULT 1,
    precio_unitario DECIMAL(12,2) NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (factura_id) REFERENCES facturas(id) ON DELETE CASCADE,
    FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 1. Permitir que la contraseña sea opcional (NULL)
ALTER TABLE usuarios MODIFY `password` VARCHAR(255) NULL;

-- 2. Permitir que el username sea opcional (NULL)
ALTER TABLE usuarios MODIFY `username` VARCHAR(50) NULL;

-- 3. Agregar columnas para identificar al proveedor y su ID único
ALTER TABLE usuarios 
ADD COLUMN `oauth_provider` VARCHAR(50) DEFAULT NULL,
ADD COLUMN `oauth_id` VARCHAR(255) DEFAULT NULL;

DROP TABLE IF EXISTS comentarios;
DROP TABLE IF EXISTS reservas;
DROP TABLE IF EXISTS locaciones;

-- 1. Tabla de locaciones
CREATE TABLE locaciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    lat DECIMAL(10, 6) NOT NULL,
    lng DECIMAL(10, 6) NOT NULL,
    estrellas VARCHAR(15) DEFAULT '⭐⭐⭐⭐⭐',
    direccion VARCHAR(150) NOT NULL,
    horario VARCHAR(100) NOT NULL,
    telefono VARCHAR(50) NOT NULL,
    precio_aprox VARCHAR(100) NOT NULL,
    info_adicional TEXT NOT NULL,
    imagen_url VARCHAR(255) DEFAULT 'https://images.unsplash.com/photo-1595435934249-5df7ed86e1c0?auto=format&fit=crop&w=500&q=60'
);

-- 2. Tabla de comentarios
CREATE TABLE comentarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    locacion_id INT,
    usuario_id INT NULL,
    nombre_usuario VARCHAR(50) NOT NULL,
    comentario TEXT NOT NULL,
    estrellas INT NOT NULL,
    FOREIGN KEY (locacion_id) REFERENCES locaciones(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS comentarios_valoraciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    comentario_id INT NOT NULL,
    usuario_id INT NOT NULL,
    calificacion TINYINT NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY valoracion_comentario_usuario (comentario_id, usuario_id),
    FOREIGN KEY (comentario_id) REFERENCES comentarios(id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS apelaciones_baneo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    correo VARCHAR(100) NOT NULL,
    motivo TEXT NOT NULL,
    evidencia_comentario TEXT DEFAULT NULL,
    locacion_id INT DEFAULT NULL,
    estado ENUM('pendiente', 'aprobada', 'rechazada') NOT NULL DEFAULT 'pendiente',
    fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    revisado_por INT DEFAULT NULL,
    fecha_revision DATETIME DEFAULT NULL,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (revisado_por) REFERENCES usuarios(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS notificaciones_moderacion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    apelacion_id INT DEFAULT NULL,
    titulo VARCHAR(150) NOT NULL,
    apelacion TEXT NOT NULL,
    respuesta TEXT NOT NULL,
    evidencia TEXT DEFAULT NULL,
    fecha_respuesta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (apelacion_id) REFERENCES apelaciones_baneo(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Tabla de Reservas con validación de duplicados
CREATE TABLE reservas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    locacion_id INT NOT NULL,
    user_id INT NULL,
    nombre_usuario VARCHAR(50) NOT NULL,
    fecha_reserva DATE NOT NULL,
    hora_reserva TIME NOT NULL,
    hora_fin TIME DEFAULT NULL,
    FOREIGN KEY (locacion_id) REFERENCES locaciones(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES usuarios(id) ON DELETE SET NULL,
    UNIQUE (locacion_id, fecha_reserva, hora_reserva)
);

-- 4. Inserciones de las Canchas
INSERT INTO locaciones (nombre, tipo, lat, lng, estrellas, direccion, horario, telefono, precio_aprox, info_adicional, imagen_url) VALUES
('Centro de Alto Rendimiento (CAR)', 'cancha', 4.658600, -74.086200, '⭐⭐⭐⭐⭐', 'Calle 63 # 59a-06', 'Lunes a Domingo: 6:00 AM - 10:00 PM', '601-4320290', '$45,000 - $60,000 / hora', 'El complejo de tenis público más grande del país. Múltiples canchas de polvo de ladrillo', 'https://lh3.googleusercontent.com/gps-cs-s/AHRPTWkc-aAn39cbiq2_1WEyTZALUoUBFuuxVmtbvoOGQWl4GFYzliEXYOFgRqRwXc-GcREIY_TEQeSlOR6ePuV9zm6G2_5Cx2Lh74CV-3zGLySAwwioIelAuXMTeovSWLFtkOCVYGC5=s680-w680-h510-rw'),
('Liga de Tenis de Bogotá (Sede Salitre)', 'cancha', 4.653400, -74.093300, '⭐⭐⭐⭐⭐', 'Av. 68 # 63, Unidad Deportiva El Salitre', 'Lunes a Domingo: 6:00 AM - 9:00 PM', '601-6302222', '$50,000 / hora', 'Sede oficial. Excelente para torneos amateurs y clases grupales.', 'https://lh3.googleusercontent.com/gps-cs-s/AHRPTWlLjppWb47bJOXc2PZbuZWDB53WhtE6_9_7m7L2ktj92NKtGv5iPYb8OER_LOWKWkkdM8iQJCrJk9AYPHO-tPWorYtmOiyWQcJRTYK7RzxcFHw4H6IXUMzcFNDqKL32npTAnFew=s680-w680-h510-rw'),
('América Tenis Club', 'cancha', 4.630500, -74.068200, '⭐⭐⭐⭐', 'Calle 51 # 4-06', 'Martes a Domingo: 6:00 AM - 8:00 PM', '601-3401122', 'Solo Socios', 'Club tradicional en el sector de Chapinero. Canchas en excelente estado y ambiente clásico.', 'https://lh3.googleusercontent.com/gps-cs-s/AHRPTWn1riCbUwMRCfd1UyQzLyadIslmno8YsTN9aDJGs8TOEzyq69cHblTcI8DrT-2GIJlr26ZhelEo9EWYMjCFZsopDHFZjuVx0xJf10aHPpGteKKmRFXtsav_L2hCFk_KnEzLjzQ0_w=s680-w680-h510-rw'),
('Compensar Avenida 68', 'cancha', 4.661600, -74.093600, '⭐⭐⭐⭐⭐', 'Av. 68 # 49A - 47', 'Lunes a Domingo: 6:00 AM - 9:00 PM', '601-3077001', '$25,000 (Afiliados)', 'Instalaciones impecables, reserva estricta por plataforma. Cuentan con muros de práctica.', 'https://lh3.googleusercontent.com/gps-cs-s/AHRPTWnKQ9RMUDJtROAFVyoh2_5hg0z7PV25Y6MoWoCq1bF7Tu6c2c1eXKYDyN4OOJjw3ZigQxTN6e3706RD5d6keYCOYvooEg2E5z2wH1Z7c-7c6ECT4otos_uoj-FC4q4DH3ec-kRqO_CVuvxH=s680-w680-h510-rw'),
('Club Los Lagartos', 'cancha', 4.706100, -74.079200, '⭐⭐⭐⭐⭐', 'Calle 116 # 72A-80', 'Martes a Domingo: 6:00 AM - 10:00 PM', '601-6430000', 'Solo Socios / Invitados', 'Uno de los clubes privados más prestigiosos. Excelente infraestructura y torneos internos.', 'https://i.ytimg.com/vi/xLKb7FZKJG0/sddefault.jpg'),
('Academia Forest Hills', 'cancha', 4.725500, -74.032100, '⭐⭐⭐⭐', 'Calle 134 # 7B-83', 'Lunes a Sábado: 7:00 AM - 8:00 PM', '310-5551234', '$65,000 / hora con profesor', 'Enfocado en la enseñanza y formación de niños y adultos desde nivel cero.', 'https://lh3.googleusercontent.com/gps-cs-s/AHRPTWnBX1oYFemLPmuonRSbQeSyvC6Q-pWydvAF5zf7XTEFDxrsn8HDeT2EDERXxgrf6xdL9_Iz67i7LhIiU558GQKV1P-gaBQ0Zb6SbinCYSsE_akSk0QScKZD90kt7dh9OhQ2zU2E4w=s680-w680-h510-rw'),
('Parque Nacional (Canchas Públicas)', 'cancha', 4.623500, -74.064200, '⭐⭐⭐', 'Carrera 7 con Calle 39', 'Lunes a Domingo: 6:00 AM - 5:00 PM', 'Sin teléfono', 'Entrada Libre / Público', 'Canchas duras. Se deben apartar por orden de llegada. Ambiente urbano e histórico.', 'https://lh3.googleusercontent.com/gps-cs-s/AHRPTWnoBmJyQXVGi5ZZ3hFHe20ttLeKdVBQWL40T7HLaWLSucs34TkE9UMULuj_0tI165bmI7E_lPt3sJ9TQ4T2F495Kgj87_tub5IOTIIqpK5u9_KPcXytVf8rFswmuzh4ul2SFqOGGA=s680-w680-h510-rw'),
('Parque San Andrés', 'cancha', 4.706500, -74.112000, '⭐⭐⭐⭐', 'Calle 82 # 100A', 'Lunes a Domingo: 6:00 AM - 6:00 PM', '601-4321111', 'Gratis (Reserva en el IDRD)', 'Canchas públicas al occidente, cerca al Portal 80. Suelen estar muy concurridas.', 'https://lh3.googleusercontent.com/gps-cs-s/AHRPTWmNLHeeAWX32m0udE4Jg8S6bB1loc9WmS6IC-OM-kfzla9_tgwU1fRylNtrWQc6RgbeVsxAzbyFqqmOBmB-wuENfapRMLAT055WsLReA1rLLD-DOamUPrLtY0MUVxWlTZuhEj9eaA=s680-w680-h510-rw'),
('Carmel Club Campestre', 'cancha', 4.740000, -74.050000, '⭐⭐⭐⭐⭐', 'Autopista Norte # 153-81', 'Martes a Domingo: 6:00 AM - 10:00 PM', '601-6670000', 'Solo Socios', 'Excelentes canchas de polvo de ladrillo, restaurantes y zonas húmedas.', 'https://lh3.googleusercontent.com/gps-cs-s/AHRPTWmfBYQ7asdL4NICQtR5JmTsAnkGcyYFiaeSF-RLxeOPSpPo4FgWPg-Mbi3TQPh6KNVKG10UHrSJDUaALoShm49SZGxAh6czEf-0c0Kh2Sq5a-4AQ1DF33x_uX54hs_8_yFPRZlgRA=s680-w680-h510-rw'),
('Club Guaymaral', 'cancha', 4.780000, -74.045000, '⭐⭐⭐⭐⭐', 'Autopista Norte Kilómetro 16', 'Martes a Domingo: 6:00 AM - 8:00 PM', '601-8050000', 'Solo Socios', 'Complejo masivo con decenas de canchas. Sede frecuente de torneos juveniles.', 'https://lh3.googleusercontent.com/gps-cs-s/AHRPTWkll0VmJlwDJzyxJ-tGpWoZoWcxqql1BnpF5ghdFw5EWONF_pkuVIKc8tphFiKVwMJb9AR_vz-vbT6FCcn114XS4mLouX9RuMqLiDHCNpU2RaH6m-x0uYeHgFaZws7WZy08qYFW=s680-w680-h510-rw'),
('El Rancho Club de Tenis', 'cancha', 4.755000, -74.030000, '⭐⭐⭐⭐', 'Calle 245 # 7-50', 'Lunes a Domingo: 6:00 AM - 6:00 PM', '320-1234567', '$40,000 / hora', 'Lugar tranquilo al norte, ideal para alquilar canchas sin membresía estricta.', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSt6lskF6r4D-Mi8_oq97d0b13d1vCJDnW-B7shTVybD6l_UWDZc84x5wg&s=10'),
('Canchas Suba Casa Blanca', 'cancha', 4.735000, -74.082000, '⭐⭐⭐⭐⭐', 'Calle 146B # 78-20', 'Lunes a Domingo: 7:00 AM - 9:00 PM', '310-1234567', '$30,000 / hora', 'Canchas bien ilumnidadas y excelente vista al mirador.', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRftdJ8DO2ljvF_hXgK0FK4MReQrveQttZWEVByuEGIuo0nTISLKVOZQV4&s=10'),
('Fontanar del Río', 'cancha', 4.754287788709206, -74.11236706329588, '⭐⭐⭐⭐⭐', 'Ac 145 # 141a-99', 'Lunes a Domingo: 6:00 AM - 6:00 PM', '300-6060823', 'Gratis', 'Buenas canchas de ladrillo y buen espacio familiar.', 'https://deportebogota.com/wp-content/uploads/2023/01/fontanar.jpg'),
('Canchas de tenis El Porvenir', 'cancha', 4.643712774363262, -74.19418157725725, '⭐⭐⭐', '16 Cl. 56f Sur', 'Lunes a Domingo: 7:00 AM - 5:00 PM', 'No cuenta con teléfono', '$Gratis', 'Canchas públicas de tenis, ideal para principiantes y familias.', 'https://lh3.googleusercontent.com/gps-cs-s/AHRPTWmdrjwmFQGu5SGOlX89Vm2eA5R8jjhlJ2dYud-FeubpplM_M9kfZz2K4RwhB0JeSHBdy_12CbnZ_xA7DqFiN5LDDstiMchzK3bC1Q4fgZRkGhcGUTqFyLp4kA27r6L9VSJi87Am=s680-w680-h510-rw'),
-- 5. TIENDAS
('Marin Tenis', 'tienda', 4.7251756165285705, -74.07164675767082, '⭐⭐⭐⭐⭐', 'Cra. 59d # 132-28', 'Lunes a Domingo: 6:00 AM - 6:00 PM', '321-9575144', 'Raquetas desde $250.000', 'Tienda especializada en tenis.', 'https://lh3.googleusercontent.com/gps-cs-s/AHRPTWnvHpsDlpNj8_QUBRYrfxvGpH4jm6I8ZOF_3Ot-LUm0ki_4CM1mWCdy2EZhTkxnYod3VAdWbFWUNl621JzURjXpMd7QcfnqP8Tq_OgOWUdEjXSrjasHE-PHcMNDCHEdDlV3u6SIP-Xgg89r=s680-w680-h510-rw'),
('Wilson Sporting Goods Bogotá', 'tienda', 4.700781883139602, -74.08115778667477, '⭐⭐⭐⭐⭐', 'Av. Boyacá # 99-82', 'Lunes a Domingo: 6:00 AM - 6:00 PM', '305-3550109', 'Raquetas desde $300.000', 'Los mejores precios.', 'https://lh3.googleusercontent.com/gps-cs-s/AHRPTWkPGriOa13k2oC0mkr5C_xnIfBm5xrolWwAJO662hxSvMhSrHtOd5XNdpl5OIuU57JnM2tXAWaONfhL-w9tYW04bvs9Dv4Vk38_yh5Be0kzPoq9XNf1UA5X0k2i2m0F052JljnNcgyDhdo=s680-w680-h510-rw'),
('Casa del Tenis', 'tienda', 4.687461870304872, -74.06486699815214, '⭐⭐⭐⭐', '17098 Cra. 68', 'Lunes a Domingo: 6:00 AM - 6:00 PM', '315-6787872', 'Pelotas desde $20.000', 'Pelotas de tenis y accesorios.', 'https://lh3.googleusercontent.com/gps-cs-s/AHRPTWmGdK0SPCUKKCKBC7lPNCAYgwArYSlT2pfdvF7YK6v9xbxtjnd5qO2o81-huzzlOL6OD1-Us7EaAh3HorGFLJ5tCdC9Pc-hplNAlyuTsgOakTQVSOJYKjGS6eCKoYP0s-k2-GrT=s680-w680-h510-rw'),
('Sport Pro / Sede Bosque Popular', 'tienda', 4.6707076650998465, -74.09673718650623, '⭐⭐⭐⭐', 'Cl. 63c # 69-44', 'Lunes a Sabado: 6:00 AM - 6:30 PM', '310-39833973', 'Suplementos desde $30.000', 'Suplementos deportivos.', 'https://lh3.googleusercontent.com/gps-cs-s/AHRPTWkA0-AIV74AtGHzF0XOHScr85JVu_efBrQ-xQWRQ4v2eC494oAztE1ZvDTeqh-d0kCogRFfa-vx6xucIKCSy2FJN7sGrSbDyt4UxvqznMrSVDNJPe-NypvCJ4CxZRMBr2h3qyYZjP0WVIfF=s680-w680-h510-rw'),
('El Tenista tienda Deportiva', 'tienda', 4.687221112648343, -74.06475597116459, '⭐⭐⭐⭐⭐', '59, Cra. 58 # 98A', 'Lunes a Sabado: 6:00 AM - 7:00 PM', '316-0109104', 'Raquetas desde $2.500.000', 'Raquetas de elite.', 'https://lh3.googleusercontent.com/gps-cs-s/AHRPTWntgF83Hji-Dyeq60Uv70rMoprNNEnaHUuXRy0AisfdOWPaz1CuK__3LW16smmGszFnlf-ByWk6G254uBU6MSw-kDv2dKvXjE6o_b79s0glpVX4_so45yONhEQ9hp4FaGFdnp4=s680-w680-h510-rw'),
('Tennis Store', 'tienda', 4.671552933724795, -74.097025, '⭐⭐⭐⭐⭐', 'Cra 69 # 63a-2', 'Lunes a Sabado: 6:00 AM - 7:00 PM', '310-2043412', 'Estuches desde $500.000', 'Variedad de raquetas, grips.', 'https://lh3.googleusercontent.com/gps-cs-s/AHRPTWmPVrPjdlxNwn5AT3YxLCay5srR0SaD_we2aLuouFzAiLfUor1YytyGVdTM7A1RDO84NfoRW46Fm7awjV_-rd2oTe1far1sy_9LEjV71f29a2Ionz0tzyD9jzXUFjnqSFUScYUf3u8bawRV=s680-w680-h510-rw'),
('Tenis Club Colombia', 'tienda', 4.7084605257848775, -74.07132883262824, '⭐⭐⭐⭐⭐', 'Avenida Suba # 124 - 20 Local 11 Bogotá, Bogotá, Cundinamarca', 'Lunes a Sabado: 6:00 AM - 8:00 PM', '3123640315', 'Raquetas desde $100,000', 'Tienda especializada.', 'https://lh3.googleusercontent.com/gps-cs-s/AHRPTWl-HuA8zOAOyH3GA8oQhi32JR2jU1K5C8Q173jM0hCcKngHSrUJjBrNha0wasqvSiS84dL3YUMJ0G8JTGL1Np-pWz4rjGtw6Okr6EwVaDWdPnmDWH1WObdCy4RQMhsKD2KRZcdt3NFSzFgz=s680-w680-h510-rw'),
('Break point', 'tienda', 4.756707857271586, -74.05309400567566, '⭐⭐⭐⭐', 'Cl. 174a # 54A 11,', 'Lunes a domingo: 6:00 AM - 5:30 PM', '3114485283', 'Pelotas desde $22,000', 'Pelotas de tenis.', 'https://lh3.googleusercontent.com/gps-cs-s/AHRPTWkjvIULXS4My3SjbJ4_-p5lG-tRPvMq172iNZCaCIfaQBfp9hJYJLJTwWym-4Ag9F95FhJus4T30Da2pdAdCIrQJ0ElL4CAKcGWbiAAevzQyKrh7KfbptHVNgCjKrM-oZhZNv4XoBzJ6ZoV=s680-w680-h510-rw'),
('Larry Tennis', 'tienda', 4.647121947389463, -74.07402681916994, '⭐⭐⭐⭐⭐', 'Dg. 61b #25-19, Teusaquillo', 'Lunes a domingo: 10:00 AM - 8:30 PM', '3144439827', 'Estuches y raquetas desde $500.000', 'Productos de tenis y accesorios.', 'https://lh3.googleusercontent.com/gps-cs-s/AHRPTWnVqwNuUp1fqeIaYiQjxXq1lo7B0lBsljdLvrKc_B8soksSh3QxlS0bjAF1sL_BrwoikEBrWQ7oDOrz9gKrbrP5mrV7TDBGbKQQ2tI6Z9Rc_-hHrul-Md8_zAjqZkzuR9edCr9GmYyEm0E=s680-w680-h510-rw'),
('Tennis Y Squash', 'tienda', 4.72202807551478, -74.05708423635758, '⭐⭐⭐⭐', 'Cra. 52a # 134 A 75', 'Lunes a domingo: 10:00 AM - 6:00 PM', '3104787859', 'Zapatos y raquetas desde $200.000', 'Zapatos y raquetas.', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRmHqjBiJtHEmhCtOf6ol4A6B1FT4f14KRLcRKqcq4nI_E67oA_KQZOKV4&s=10'),
-- 6. BARES
('Sports Bar El Saque', 'bar', 4.676500, -74.048200, '⭐⭐⭐⭐⭐', 'Parque 93, Cra 13 # 93-45', 'Lunes a Domingo: 12:00 PM - 2:00 AM', '322-5556677', 'Platos desde $40,000', 'Bar deportivo, 5 pantallas exclusivas.', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR0WN045DFx4VV-OuGLEZESPq9DdGrMqcI36Ny8UDHCzzBi42cZcVxXSrs&s=10'),
('The Pub (Zona T)', 'bar', 4.668500, -74.054500, '⭐⭐⭐⭐', 'Cra 12A # 83-48', 'Lunes a Sábado: 4:00 PM - 3:00 AM', '601-6101122', 'Cervezas desde $15,000', 'Pub inglés tradicional.', 'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/09/c6/d4/4c/the-pub.jpg?w=1100&h=1100&s=1'),
('Buffalo Wings (Salitre)', 'bar', 4.652000, -74.100000, '⭐⭐⭐⭐', 'C.C. Salitre Plaza', 'Lunes a Domingo: 12:00 PM - 11:00 PM', '601-7008000', 'Combos desde $35,000', 'Alitas y torneos ATP.', 'https://tofuu.getjusto.com/orioneat-local/resized2/rCqsvs52PYDQq3cZN-800-x.webp'),
('McCarthys Irish Pub', 'bar', 4.613000, -74.067000, '⭐⭐⭐⭐', 'La Macarena, Cra 4 # 26A-10', 'Martes a Domingo: 5:00 PM - 2:00 AM', '310-4445566', 'Hamburguesas desde $32,000', 'Rock y torneos internacionales.', 'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/2d/6b/a3/43/la-fiesta-fue-epica-en.jpg?w=500&h=-1&s=1'),
('Hooters Usaquén', 'bar', 4.695000, -74.030000, '⭐⭐⭐⭐', 'Calle 119 # 11-36', 'Lunes a Domingo: 12:00 PM - 12:00 AM', '601-2131234', 'Platos desde $45,000', 'Pantallas gigantes.', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQKx6Dso2lvDqQN2H-eO_ELQM6waSfINNpKez_D_v-OKORp1wLHSEwTXkU&s=10');

CREATE TABLE IF NOT EXISTS comentarios_valoraciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    comentario_id INT NOT NULL,
    usuario_id INT NOT NULL,
    calificacion TINYINT NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY valoracion_comentario_usuario (comentario_id, usuario_id),
    FOREIGN KEY (comentario_id) REFERENCES comentarios(id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
UPDATE preguntas_frecuentes SET aprobada = 1 WHERE respuesta IS NOT NULL AND respuesta <> '';
CREATE TABLE IF NOT EXISTS preguntas_frecuentes_valoraciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    pregunta_id INT NOT NULL,
    usuario_id INT NOT NULL,
    calificacion TINYINT NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY valoracion_unica (pregunta_id, usuario_id),
    FOREIGN KEY (pregunta_id) REFERENCES preguntas_frecuentes(id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
ALTER TABLE comentarios ADD CONSTRAINT fk_comentarios_usuario
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE SET NULL;
CREATE TABLE IF NOT EXISTS apelaciones_baneo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    correo VARCHAR(100) NOT NULL,
    motivo TEXT NOT NULL,
    estado ENUM('pendiente', 'aprobada', 'rechazada') NOT NULL DEFAULT 'pendiente',
    fecha_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    revisado_por INT DEFAULT NULL,
    fecha_revision DATETIME DEFAULT NULL,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (revisado_por) REFERENCES usuarios(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- chatbot y chat usuarios/profesores

CREATE TABLE IF NOT EXISTS contacts (
    id INT NOT NULL AUTO_INCREMENT,
    emisor_id INT NOT NULL,
    receptor_id INT NOT NULL,
    estado ENUM('pendiente', 'aceptada', 'rechazada') NOT NULL DEFAULT 'pendiente',
    creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_contacto (emisor_id, receptor_id),
    CONSTRAINT fk_contacts_emisor FOREIGN KEY (emisor_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    CONSTRAINT fk_contacts_receptor FOREIGN KEY (receptor_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS messages (
    id BIGINT NOT NULL AUTO_INCREMENT,
    emisor_id INT NOT NULL,
    receptor_id INT NOT NULL,
    texto TEXT NOT NULL,
    tipo ENUM('texto', 'propuesta', 'sistema') NOT NULL DEFAULT 'texto',
    datos_extra TEXT NULL,
    estado_propuesta ENUM('pendiente', 'aceptada', 'rechazada') NULL,
    enviado DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_msg_emisor FOREIGN KEY (emisor_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    CONSTRAINT fk_msg_receptor FOREIGN KEY (receptor_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS denuncias_mensajes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    mensaje_id BIGINT NOT NULL,
    denunciante_id INT NOT NULL,
    denunciado_id INT NOT NULL,
    motivo VARCHAR(255) NOT NULL,
    estado ENUM('pendiente', 'revisada', 'descartada') NOT NULL DEFAULT 'pendiente',
    fecha_denuncia TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (mensaje_id) REFERENCES messages(id) ON DELETE CASCADE,
    FOREIGN KEY (denunciante_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (denunciado_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Imágenes locales de las ubicaciones descargadas en static/IMG.
-- Se asignan en el mismo orden de las primeras 24 ubicaciones insertadas.
UPDATE locaciones
SET imagen_url = CASE id
    WHEN 1 THEN 'IMG/tenis_lugar1.jpeg'
    WHEN 2 THEN 'IMG/tenis_lugar2.jpg'
    WHEN 3 THEN 'IMG/tenis_lugar3.jpg'
    WHEN 4 THEN 'IMG/tenis_lugar4.jpg'
    WHEN 5 THEN 'IMG/tenis_lugar5.png'
    WHEN 6 THEN 'IMG/tenis_lugar6.jpg'
    WHEN 7 THEN 'IMG/tenis_lugar7.jpg'
    WHEN 8 THEN 'IMG/tenis_lugar8.jpg'
    WHEN 9 THEN 'IMG/tenis_lugar9.jpg'
    WHEN 10 THEN 'IMG/tenis_lugar10.jpg'
    WHEN 11 THEN 'IMG/tenis_lugar11.jpg'
    WHEN 12 THEN 'IMG/tenis_lugar12.jpg'
    WHEN 13 THEN 'IMG/tenis_lugar13.jpeg'
    WHEN 14 THEN 'IMG/tenis_lugar14.jpg'
    WHEN 15 THEN 'IMG/tenis_lugar15.png'
    WHEN 16 THEN 'IMG/tenis_lugar16.png'
    WHEN 17 THEN 'IMG/tenis_lugar17.jpg'
    WHEN 18 THEN 'IMG/tenis_lugar18.png'
    WHEN 19 THEN 'IMG/tenis_lugar19.jpg'
    WHEN 20 THEN 'IMG/tenis_lugar20.png'
    WHEN 21 THEN 'IMG/tenis_lugar21.png'
    WHEN 22 THEN 'IMG/tenis_lugar22.jpg'
    WHEN 23 THEN 'IMG/tenis_lugar23.png'
    WHEN 24 THEN 'IMG/tenis_lugar24.jpg'
    ELSE imagen_url
END
WHERE id BETWEEN 1 AND 24;

-- Tablas de contenido editable para las categorias informativas
CREATE TABLE IF NOT EXISTS contenido_jugadores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipo VARCHAR(80) NOT NULL UNIQUE,
    titulo VARCHAR(180) NOT NULL,
    texto TEXT NOT NULL,
    orden INT DEFAULT 0,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS contenido_partidos_recientes LIKE contenido_jugadores;
CREATE TABLE IF NOT EXISTS contenido_datos_y_tips LIKE contenido_jugadores;
CREATE TABLE IF NOT EXISTS contenido_noticias_semanales LIKE contenido_jugadores;
CREATE TABLE IF NOT EXISTS contenido_noticias_new LIKE contenido_jugadores;
CREATE TABLE IF NOT EXISTS contenido_marcas_y_utiles LIKE contenido_jugadores;
CREATE TABLE IF NOT EXISTS contenido_sitios_tennis LIKE contenido_jugadores;

INSERT INTO contenido_jugadores (tipo, titulo, texto, orden, activo) VALUES
('intro', 'Jugadores: talento, tecnica y legado', 'Descubre a los tenistas mas influyentes, sus estilos, sus grandes triunfos y lo que marco su carrera. Analiza como construyen un punto, gestionan la presion y convierten una buena actuacion en una temporada historica.', 1, TRUE),
('perfil', 'Escala de rendimiento', 'Cada jugador tiene un estilo unico: servicio, devolucion, reves, volea, desplazamiento y resistencia. Comparar estas areas ayuda a entender por que un tenista domina una superficie y mantiene su nivel durante partidos largos.', 2, TRUE),
('destacados', 'Referentes del circuito', 'Los mejores jugadores combinan talento, disciplina y capacidad para competir en las grandes citas. Sus carreras tambien muestran la importancia de la preparacion fisica, la recuperacion y la adaptacion constante.', 3, TRUE),
('legado', 'Como se construye una carrera', 'Un titulo es solo una parte de la historia: el ranking, la regularidad, las rivalidades, la influencia fuera de la pista y la capacidad de superar lesiones tambien forman el legado de un campeon.', 4, TRUE),
('estilo', 'Estilos que cambian un partido', 'Los jugadores agresivos buscan tomar la iniciativa temprano, mientras que los defensivos construyen el punto con paciencia y profundidad. Tambien existen perfiles completos que cambian de plan segun el rival y la superficie.', 5, TRUE)
ON DUPLICATE KEY UPDATE tipo = tipo;

INSERT INTO contenido_partidos_recientes (tipo, titulo, texto, orden, activo) VALUES
('intro', 'Partidos recientes', 'Consulta los encuentros mas destacados del circuito profesional con analisis de resultados, protagonistas, superficie, ritmo de juego y decisiones que cambiaron el marcador.', 1, TRUE),
('resumen', 'Momento clave de la temporada', 'Cada partido refleja cambios de ritmo, decisiones estrategicas y momentos decisivos. Observa quien gano los puntos importantes, como respondio al quiebre y que patron se repitio.', 2, TRUE),
('lectura', 'Que mirar en un partido', 'Mas alla del resultado, fijate en el porcentaje de primeros servicios, la calidad de la devolucion, los errores no forzados y la forma en que cada jugador protege su saque bajo presion.', 3, TRUE),
('tactica', 'La tactica detras del marcador', 'Un resultado puede esconder un partido muy igualado. Revisa los puntos de quiebre, la direccion del saque, la posicion en la devolucion y los cambios tacticos realizados despues de cada set.', 4, TRUE)
ON DUPLICATE KEY UPDATE tipo = tipo;

INSERT INTO contenido_datos_y_tips (tipo, titulo, texto, orden, activo) VALUES
('intro', 'Datos y tips', 'Aumenta tu conocimiento del juego con estadisticas, recomendaciones y claves para mejorar tu preparacion. Usa los datos como una guia para tomar mejores decisiones, no como sustituto de la observacion en pista.', 1, TRUE),
('patrones', 'Patrones de juego', 'Observa como cambia la dinamica segun la superficie, el rival y la presion. Identifica si conviene abrir la pista, atacar el reves, variar alturas o alargar el intercambio.', 2, TRUE),
('claves', 'Tips para entrenar', 'Mejora tu servicio, la capacidad de reaccion y la gestion emocional durante los puntos largos. Divide cada sesion en objetivos medibles y registra que funciono.', 3, TRUE),
('partido', 'Convierte la estadistica en accion', 'Un porcentaje bajo de primeros servicios puede convertirse en un objetivo tecnico; muchos errores en la red, en una sesion de aproximacion; y una mala respuesta al break point, en un ejercicio especifico.', 4, TRUE),
('recuperacion', 'Entrena y recupera mejor', 'Alterna sesiones intensas con movilidad, hidratacion y descanso. La recuperacion permite asimilar el trabajo, reduce el riesgo de sobrecarga y ayuda a llegar a la siguiente practica con objetivos claros.', 5, TRUE)
ON DUPLICATE KEY UPDATE tipo = tipo;

INSERT INTO contenido_noticias_semanales (tipo, titulo, texto, orden, activo) VALUES
('intro', 'Noticias semanales', 'Encuentra los temas mas relevantes de la semana: resultados, cambios de ranking, torneos proximos, lesiones y novedades que pueden transformar la temporada.', 1, TRUE),
('resumen', 'Lo mas destacado', 'La agenda semanal combina resultados, novedades del circuito y detalles que influyen en la temporada. Cada resumen aporta contexto para entender que ocurrio y por que fue importante.', 2, TRUE),
('agenda', 'La proxima semana', 'Revisa los partidos anunciados, las superficies, los cuadros y las historias que merecen seguimiento. Preparar la agenda permite disfrutar mas cada torneo.', 3, TRUE),
('ranking', 'Cambios que importan', 'Una buena semana puede acercar a un jugador a los puestos de privilegio, una lesion puede cambiar el cuadro y una victoria inesperada puede abrir una nueva historia. El ranking siempre necesita contexto.', 4, TRUE)
ON DUPLICATE KEY UPDATE tipo = tipo;

INSERT INTO contenido_noticias_new (tipo, titulo, texto, orden, activo) VALUES
('intro', 'Noticias de ultimo momento', 'Mantenete al dia con novedades recientes, resultados inmediatos y movimientos clave en el tenis. Consulta siempre la fecha y la fuente para distinguir una actualizacion confirmada de un rumor.', 1, TRUE),
('destacadas', 'Actualizacion instantanea', 'El contexto cambia en cada jornada. Un cambio de rival, una retirada o una pista afectada por el clima puede modificar por completo la lectura de un partido.', 2, TRUE),
('contexto', 'Informacion con contexto', 'Una noticia se entiende mejor cuando incluye el torneo, la ronda, la superficie, el historial entre jugadores y las consecuencias para el ranking o el calendario.', 3, TRUE),
('confirmacion', 'Antes de compartir', 'Comprueba si la informacion procede del torneo, del jugador, de una organizacion oficial o de una fuente periodistica fiable. Separar los hechos confirmados de las especulaciones mejora la conversacion deportiva.', 4, TRUE)
ON DUPLICATE KEY UPDATE tipo = tipo;

INSERT INTO contenido_marcas_y_utiles (tipo, titulo, texto, orden, activo) VALUES
('intro', 'Marcas y utiles', 'Explora marcas, accesorios y utiles que mejoran el rendimiento, la comodidad y la experiencia de juego. La mejor eleccion depende del nivel, la frecuencia, la superficie y las sensaciones de cada jugador.', 1, TRUE),
('equipamiento', 'Que suele utilizar un jugador', 'Raquetas, pelotas, grip, ropa y complementos marcan la diferencia. Revisa peso, balance, tamano de cabeza, durabilidad, ventilacion y mantenimiento antes de comprar.', 2, TRUE),
('cuidado', 'Cuida tu equipo', 'Cambiar el overgrip, revisar el encordado, secar las zapatillas y guardar las pelotas correctamente prolonga la vida util del material y conserva sensaciones constantes.', 3, TRUE),
('eleccion', 'Compra segun tu juego', 'No existe un producto perfecto para todos. Define primero tu nivel, presupuesto y objetivo; despues compara materiales, garantia, comodidad y disponibilidad de repuestos antes de decidir.', 4, TRUE)
ON DUPLICATE KEY UPDATE tipo = tipo;

INSERT INTO contenido_sitios_tennis (tipo, titulo, texto, orden, activo) VALUES
('intro', 'Sitios para ver tennis', 'Descubre plataformas y recursos para seguir partido a partido, estadisticas y analisis. Combina una fuente de resultados en directo con otra de analisis para obtener una vision completa.', 1, TRUE),
('recursos', 'Fuentes recomendadas', 'Los mejores recursos combinan resultados en directo, perfiles de jugadores y analisis de torneos. Busca calendarios claros, informacion sobre superficies, cuadros actualizados y estadisticas comparables.', 2, TRUE),
('seguimiento', 'Organiza tu seguimiento', 'Guarda tus torneos favoritos, revisa los horarios segun tu zona y consulta las condiciones de la pista. Asi podras seguir la temporada sin perder los partidos que te interesan.', 3, TRUE),
('estadisticas', 'Compara con criterio', 'Usa las estadisticas para responder preguntas concretas: quien gana mas puntos con el primer saque, quien salva mas break points o quien mejora en una superficie. Comparar una sola cifra puede llevar a conclusiones equivocadas.', 4, TRUE)
ON DUPLICATE KEY UPDATE tipo = tipo;

CREATE TABLE IF NOT EXISTS contenido_torneos LIKE contenido_jugadores;

CREATE TABLE IF NOT EXISTS torneos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(180) NOT NULL,
    categoria VARCHAR(100) NOT NULL,
    fecha VARCHAR(100) NOT NULL,
    lugar VARCHAR(180) NOT NULL,
    nivel VARCHAR(100) NOT NULL,
    descripcion TEXT NOT NULL,
    orden INT DEFAULT 0,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO contenido_torneos (tipo, titulo, texto, orden, activo) VALUES
('calendario', 'Como seguir el calendario', 'Consulta las fechas, la categoria y el lugar de cada evento. Confirma siempre los horarios y requisitos de inscripcion con la organizacion antes de participar.', 1, TRUE),
('preparacion', 'Preparate para competir', 'Planifica tus entrenamientos, descanso e hidratacion antes del torneo. Llegar con tiempo y conocer la superficie ayuda a rendir mejor desde el primer partido.', 2, TRUE)
ON DUPLICATE KEY UPDATE tipo = tipo;

INSERT INTO torneos (nombre, categoria, fecha, lugar, nivel, descripcion, orden, activo) VALUES
('Copa TENNISSEL', 'Amateur', 'Proximamente', 'Bogota, Colombia', 'Todos los niveles', 'Evento de referencia para la comunidad TENNISSEL. Consulta las novedades y la apertura de inscripciones en esta seccion.', 1, TRUE)
ON DUPLICATE KEY UPDATE nombre = nombre;

SHOW TABLES LIKE 'contenido_%';
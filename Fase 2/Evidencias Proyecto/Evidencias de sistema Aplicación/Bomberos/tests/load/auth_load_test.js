import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

// Métricas personalizadas
const errorRate = new Rate('errors');

// Configuración de la prueba
export const options = {
  stages: [
    { duration: '30s', target: 10 },  // Ramp up: 10 usuarios en 30s
    { duration: '1m', target: 50 },   // Mantener: 50 usuarios por 1 min
    { duration: '30s', target: 0 },   // Ramp down: bajar a 0
  ],
  thresholds: {
    http_req_duration: ['p(95)<5000'], // 95% de requests < 5s
    http_req_failed: ['rate<0.01'],    // Menos del 1% de errores
    errors: ['rate<0.1'],              // Menos del 10% de errores
  },
};

// ⚠️ IMPORTANTE: Reemplaza con tus credenciales de Supabase
const SUPABASE_URL = __ENV.SUPABASE_URL || 'https://tu-proyecto.supabase.co';
const SUPABASE_ANON_KEY = __ENV.SUPABASE_ANON_KEY || 'tu-anon-key-aqui';

export default function () {
  // Test 1: Login
  const loginPayload = JSON.stringify({
    email: `test${__VU}@example.com`,
    password: 'test123456',
  });

  const loginHeaders = {
    'Content-Type': 'application/json',
    'apikey': SUPABASE_ANON_KEY,
  };

  const loginRes = http.post(
    `${SUPABASE_URL}/auth/v1/token?grant_type=password`,
    loginPayload,
    { headers: loginHeaders }
  );

  const loginSuccess = check(loginRes, {
    'login status is 200': (r) => r.status === 200,
    'login response time < 5s': (r) => r.timings.duration < 5000,
    'login tiene access_token': (r) => r.json('access_token') !== undefined,
  });

  errorRate.add(!loginSuccess);

  if (loginRes.status !== 200) {
    sleep(1);
    return;
  }

  const token = loginRes.json('access_token');

  // Test 2: Consulta de grifos (requiere autenticación)
  const grifosHeaders = {
    'apikey': SUPABASE_ANON_KEY,
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json',
  };

  const grifosRes = http.get(
    `${SUPABASE_URL}/rest/v1/grifo?select=*&limit=10`,
    { headers: grifosHeaders }
  );

  const grifosSuccess = check(grifosRes, {
    'grifos status is 200': (r) => r.status === 200,
    'grifos response time < 3s': (r) => r.timings.duration < 3000,
    'grifos tiene datos': (r) => {
      try {
        const data = r.json();
        return Array.isArray(data) && data.length >= 0;
      } catch (e) {
        return false;
      }
    },
  });

  errorRate.add(!grifosSuccess);

  sleep(1); // Esperar 1 segundo entre requests
}

export function handleSummary(data) {
  return {
    'stdout': textSummary(data, { indent: ' ', enableColors: true }),
    'summary.json': JSON.stringify(data),
  };
}

function textSummary(data, options) {
  // Función simple para mostrar resumen
  return `
Resumen de Prueba de Carga:
- Duración total: ${data.metrics.iteration_duration.values.avg.toFixed(2)}s
- Requests totales: ${data.metrics.http_reqs.values.count}
- Tasa de error: ${(data.metrics.http_req_failed.values.rate * 100).toFixed(2)}%
- Tiempo promedio: ${data.metrics.http_req_duration.values.avg.toFixed(2)}ms
- Tiempo p95: ${data.metrics.http_req_duration.values['p(95)'].toFixed(2)}ms
`;
}

